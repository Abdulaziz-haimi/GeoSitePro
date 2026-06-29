using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI.WebControls;

public partial class SiteMapPage : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SiteMap.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjects();
            LoadSourceTypes();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadSelectedProject();
        }
    }

    private void ApplyPermissions()
    {
        bool edit = SecurityHelper.HasPermission("SiteMap.Edit");
        bool generate = SecurityHelper.HasPermission("SiteMap.Generate");
        pnlSettings.Enabled = edit;
        pnlAddPoint.Enabled = edit;
        btnGenerateActual.Visible = generate;
        btnGeneratePlan.Visible = generate;
        btnSaveSettings.Visible = edit;
        btnSavePoint.Visible = edit;
    }

    private long SelectedProjectId
    {
        get { long id; return long.TryParse(ddlProject.SelectedValue, out id) ? id : 0; }
    }

    private void LoadProjects()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlProject.DataSource = dt;
                ddlProject.DataTextField = "ProjectName";
                ddlProject.DataValueField = "ProjectId";
                ddlProject.DataBind();
                ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadSourceTypes()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LookupItems_GetByCategory", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CategoryCode", "MapPointSource");
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlPointSource.DataSource = dt;
                ddlPointSource.DataTextField = "NameAr";
                ddlPointSource.DataValueField = "LookupItemId";
                ddlPointSource.DataBind();
            }
        }
        catch
        {
            ddlPointSource.Items.Clear();
        }
        ddlPointSource.Items.Insert(0, new ListItem("-- المصدر --", ""));
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadSelectedProject(); }
    protected void btnLoad_Click(object sender, EventArgs e) { LoadSelectedProject(); }

    private void LoadSelectedProject()
    {
        HideMessage();
        pnlProject.Visible = pnlSettings.Visible = pnlMap.Visible = pnlAddPoint.Visible = pnlPoints.Visible = false;
        litMapSvg.Text = string.Empty;
        if (SelectedProjectId <= 0) return;
        LoadProjectMap();
        LoadPoints();
    }

    private void LoadProjectMap()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectMap_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }
                DataRow p = ds.Tables[0].Rows[0];
                litProjectTitle.Text = Server.HtmlEncode(Convert.ToString(p["ProjectCode"]) + " - " + Convert.ToString(p["ProjectName"]));
                litProjectMeta.Text = Server.HtmlEncode(Convert.ToString(p["ProjectTypeNameAr"]) + " | " + Convert.ToString(p["City"]) + " | " + Convert.ToString(p["LocationName"]));

                if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0) BindSettings(ds.Tables[1].Rows[0]); else ClearSettings();
                if (ds.Tables.Count > 4 && ds.Tables[4].Rows.Count > 0)
                {
                    DataRow c = ds.Tables[4].Rows[0];
                    litActualCount.Text = Convert.ToString(c["ActualBoreholeCount"]);
                    litLayoutCount.Text = Convert.ToString(c["LayoutPointCount"]);
                    litMissingCoordCount.Text = Convert.ToString(c["MissingCoordinateCount"]);
                }

                DataTable points = ds.Tables.Count > 3 ? ds.Tables[3] : new DataTable();
                litMapSvg.Text = BuildMapSvg(points);
                pnlProject.Visible = pnlSettings.Visible = pnlMap.Visible = pnlAddPoint.Visible = pnlPoints.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindSettings(DataRow r)
    {
        txtCoordinateSystem.Text = Convert.ToString(r["CoordinateSystem"]);
        txtEPSG.Text = Convert.ToString(r["EPSGCode"]);
        txtOriginEasting.Text = FormatDecimal(r["OriginEasting"]);
        txtOriginNorthing.Text = FormatDecimal(r["OriginNorthing"]);
        txtScaleDenominator.Text = FormatDecimal(r["ScaleDenominator"]);
        txtNorthAngle.Text = FormatDecimal(r["NorthAngleDeg"]);
        txtBoundaryText.Text = Convert.ToString(r["SiteBoundaryText"]);
        txtMapNotes.Text = Convert.ToString(r["Notes"]);
    }

    private void ClearSettings()
    {
        txtCoordinateSystem.Text = "UTM / Local Grid";
        txtEPSG.Text = string.Empty;
        txtOriginEasting.Text = string.Empty;
        txtOriginNorthing.Text = string.Empty;
        txtScaleDenominator.Text = "500";
        txtNorthAngle.Text = "0";
        txtBoundaryText.Text = string.Empty;
        txtMapNotes.Text = string.Empty;
    }

    private void LoadPoints()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectBoreholeLayoutPoints_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvPoints.DataSource = dt;
                gvPoints.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSaveSettings_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("SiteMap.Edit")) { ShowError("لا تملك صلاحية تعديل إعدادات الخريطة."); return; }
        if (SelectedProjectId <= 0) { ShowError("اختر المشروع أولًا."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectMapSettings_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                cmd.Parameters.AddWithValue("@CoordinateSystem", DataHelper.DbValue(txtCoordinateSystem.Text));
                cmd.Parameters.AddWithValue("@EPSGCode", DataHelper.DbValue(txtEPSG.Text));
                cmd.Parameters.AddWithValue("@OriginEasting", DataHelper.DbValue(ParseDecimal(txtOriginEasting.Text)));
                cmd.Parameters.AddWithValue("@OriginNorthing", DataHelper.DbValue(ParseDecimal(txtOriginNorthing.Text)));
                cmd.Parameters.AddWithValue("@ScaleDenominator", DataHelper.DbValue(ParseDecimal(txtScaleDenominator.Text)));
                cmd.Parameters.AddWithValue("@NorthAngleDeg", DataHelper.DbValue(ParseDecimal(txtNorthAngle.Text)));
                cmd.Parameters.AddWithValue("@SiteBoundaryText", DataHelper.DbValue(txtBoundaryText.Text));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtMapNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حفظ إعدادات الخريطة.");
            LoadProjectMap();
            LoadPoints();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnGenerateActual_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("SiteMap.Generate")) { ShowError("لا تملك صلاحية توليد نقاط الخريطة."); return; }
        ExecuteGenerate("sp_ProjectBoreholeLayout_GenerateFromActual", "تم توليد نقاط الخريطة من الجسات الفعلية.");
    }

    protected void btnGeneratePlan_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("SiteMap.Generate")) { ShowError("لا تملك صلاحية توليد نقاط الخريطة."); return; }
        ExecuteGenerate("sp_ProjectBoreholeLayout_GenerateFromApprovedPlan", "تم توليد نقاط مبدئية من خطة التحري المعتمدة/الأحدث.");
    }

    private void ExecuteGenerate(string sp, string message)
    {
        if (SelectedProjectId <= 0) { ShowError("اختر المشروع أولًا."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sp, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess(message);
            LoadProjectMap();
            LoadPoints();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSavePoint_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("SiteMap.Edit")) { ShowError("لا تملك صلاحية تعديل نقاط الخريطة."); return; }
        if (SelectedProjectId <= 0) { ShowError("اختر المشروع أولًا."); return; }
        try
        {
            long pointId; long.TryParse(hfPointId.Value, out pointId);
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectBoreholeLayoutPoint_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LayoutPointId", pointId > 0 ? (object)pointId : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                cmd.Parameters.AddWithValue("@SourceTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlPointSource)));
                cmd.Parameters.AddWithValue("@BoreholeCode", DataHelper.DbValue(txtPointCode.Text));
                cmd.Parameters.AddWithValue("@Easting", DataHelper.DbValue(ParseDecimal(txtPointEasting.Text)));
                cmd.Parameters.AddWithValue("@Northing", DataHelper.DbValue(ParseDecimal(txtPointNorthing.Text)));
                cmd.Parameters.AddWithValue("@ElevationM", DataHelper.DbValue(ParseDecimal(txtPointElevation.Text)));
                cmd.Parameters.AddWithValue("@PlannedDepthM", DataHelper.DbValue(ParseDecimal(txtPointDepth.Text)));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtPointNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ClearPointForm();
            ShowSuccess("تم حفظ نقطة الجسة.");
            LoadProjectMap();
            LoadPoints();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnClearPoint_Click(object sender, EventArgs e) { ClearPointForm(); }

    protected void gvPoints_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditPoint") LoadPointForEdit(id);
        if (e.CommandName == "DeletePoint") DeletePoint(id);
    }

    private void LoadPointForEdit(long id)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectBoreholeLayoutPoint_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LayoutPointId", id);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("النقطة غير موجودة."); return; }
                DataRow r = dt.Rows[0];
                hfPointId.Value = Convert.ToString(r["LayoutPointId"]);
                txtPointCode.Text = Convert.ToString(r["BoreholeCode"]);
                SetSelected(ddlPointSource, r["SourceTypeId"]);
                txtPointEasting.Text = FormatDecimal(r["Easting"]);
                txtPointNorthing.Text = FormatDecimal(r["Northing"]);
                txtPointElevation.Text = FormatDecimal(r["ElevationM"]);
                txtPointDepth.Text = FormatDecimal(r["PlannedDepthM"]);
                txtPointNotes.Text = Convert.ToString(r["Notes"]);
                ShowSuccess("تم تحميل النقطة للتعديل.");
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeletePoint(long id)
    {
        if (!SecurityHelper.HasPermission("SiteMap.Edit")) { ShowError("لا تملك صلاحية حذف نقاط الخريطة."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectBoreholeLayoutPoint_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LayoutPointId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف النقطة.");
            LoadProjectMap();
            LoadPoints();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private string BuildMapSvg(DataTable dt)
    {
        List<DataRow> rows = new List<DataRow>();
        decimal minE = 0, maxE = 0, minN = 0, maxN = 0;
        bool first = true;
        foreach (DataRow r in dt.Rows)
        {
            if (r["Easting"] == DBNull.Value || r["Northing"] == DBNull.Value) continue;
            decimal e = Convert.ToDecimal(r["Easting"]); decimal n = Convert.ToDecimal(r["Northing"]);
            if (first) { minE = maxE = e; minN = maxN = n; first = false; }
            else { if (e < minE) minE = e; if (e > maxE) maxE = e; if (n < minN) minN = n; if (n > maxN) maxN = n; }
            rows.Add(r);
        }
        if (rows.Count == 0)
            return "<div class='gsp-muted'>لا يمكن رسم الخريطة لأن نقاط الجسات لا تحتوي Easting/Northing. أدخل الإحداثيات أو اضغط توليد من الجسات الفعلية بعد إدخال إحداثياتها.</div>";

        decimal spanE = Math.Max(maxE - minE, 1);
        decimal spanN = Math.Max(maxN - minN, 1);
        decimal pad = 70;
        decimal width = 1000, height = 520;
        decimal plotW = width - 2 * pad, plotH = height - 2 * pad;
        decimal scale = Math.Min(plotW / spanE, plotH / spanN);

        StringBuilder sb = new StringBuilder();
        sb.Append("<svg class='gsp-svg-map' viewBox='0 0 1000 520' xmlns='http://www.w3.org/2000/svg'>");
        sb.Append("<defs><marker id='arrow' markerWidth='10' markerHeight='10' refX='5' refY='3' orient='auto' markerUnits='strokeWidth'><path d='M0,0 L0,6 L6,3 z' fill='#0f766e'/></marker></defs>");
        sb.Append("<rect x='0' y='0' width='1000' height='520' fill='#ffffff'/>");
        sb.Append("<rect x='55' y='45' width='890' height='405' fill='#f8fafc' stroke='#cbd5e1' stroke-width='1'/>");
        sb.Append("<line x1='90' y1='420' x2='160' y2='420' stroke='#0f766e' stroke-width='3' marker-end='url(#arrow)'/><text x='78' y='445' font-size='12' fill='#0f766e'>Easting</text>");
        sb.Append("<line x1='90' y1='420' x2='90' y2='350' stroke='#0f766e' stroke-width='3' marker-end='url(#arrow)'/><text x='40' y='352' font-size='12' fill='#0f766e'>North</text>");
        sb.Append("<text x='65' y='30' font-size='14' font-weight='800' fill='#0f172a'>Borehole Layout - Project Grid</text>");

        int i = 0;
        foreach (DataRow r in rows)
        {
            decimal e = Convert.ToDecimal(r["Easting"]); decimal n = Convert.ToDecimal(r["Northing"]);
            decimal x = pad + (e - minE) * scale;
            decimal y = height - pad - (n - minN) * scale;
            string code = Server.HtmlEncode(Convert.ToString(r["BoreholeCode"]));
            string source = Server.HtmlEncode(Convert.ToString(r["SourceTypeCode"]));
            string fill = source == "ACTUAL" ? "#0f766e" : source == "PLANNED" ? "#d97706" : "#2563eb";
            sb.AppendFormat(CultureInfo.InvariantCulture, "<circle cx='{0:0.##}' cy='{1:0.##}' r='9' fill='{2}' stroke='#111827' stroke-width='1'/>", x, y, fill);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='{0:0.##}' y='{1:0.##}' font-size='12' font-weight='800' fill='#111827'>{2}</text>", x + 12, y - 8, code);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='{0:0.##}' y='{1:0.##}' font-size='10' fill='#64748b'>E:{2:0.###} N:{3:0.###}</text>", x + 12, y + 8, e, n);
            i++;
        }
        sb.Append("<rect x='760' y='18' width='190' height='70' rx='10' fill='#ffffff' stroke='#e2e8f0'/>");
        sb.Append("<circle cx='782' cy='40' r='7' fill='#0f766e'/><text x='800' y='44' font-size='12'>Actual Borehole</text>");
        sb.Append("<circle cx='782' cy='62' r='7' fill='#d97706'/><text x='800' y='66' font-size='12'>Planned Point</text>");
        sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='65' y='490' font-size='11' fill='#64748b'>Extent: E {0:0.###} - {1:0.###} | N {2:0.###} - {3:0.###}</text>", minE, maxE, minN, maxN);
        sb.Append("</svg>");
        return sb.ToString();
    }

    private void ClearPointForm()
    {
        hfPointId.Value = string.Empty;
        txtPointCode.Text = string.Empty;
        if (ddlPointSource.Items.Count > 0) ddlPointSource.SelectedIndex = 0;
        txtPointEasting.Text = txtPointNorthing.Text = txtPointElevation.Text = txtPointDepth.Text = txtPointNotes.Text = string.Empty;
    }

    private decimal? ParseDecimal(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return null;
        decimal d;
        if (decimal.TryParse(text.Trim(), NumberStyles.Any, CultureInfo.CurrentCulture, out d)) return d;
        if (decimal.TryParse(text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out d)) return d;
        return null;
    }

    private string FormatDecimal(object value)
    {
        if (value == null || value == DBNull.Value) return string.Empty;
        decimal d; return decimal.TryParse(Convert.ToString(value), out d) ? d.ToString("0.###") : Convert.ToString(value);
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        if (value == null || value == DBNull.Value) return;
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
