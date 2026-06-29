using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI.WebControls;

public partial class CrossSections : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long CurrentSectionId
    {
        get { object v = ViewState["CurrentSectionId"]; long id; return v != null && long.TryParse(Convert.ToString(v), out id) ? id : 0; }
        set { ViewState["CurrentSectionId"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("CrossSections.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjects();
            LoadStatus();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadSelectedProject();
        }
    }

    private void ApplyPermissions()
    {
        bool edit = SecurityHelper.HasPermission("CrossSections.Edit");
        bool generate = SecurityHelper.HasPermission("CrossSections.Generate");
        pnlForm.Enabled = edit;
        btnSaveSection.Visible = edit;
        btnGenerateBoreholes.Visible = generate;
    }

    private long SelectedProjectId { get { long id; return long.TryParse(ddlProject.SelectedValue, out id) ? id : 0; } }

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

    private void LoadStatus()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LookupItems_GetByCategory", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CategoryCode", "CrossSectionStatus");
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlSectionStatus.DataSource = dt;
                ddlSectionStatus.DataTextField = "NameAr";
                ddlSectionStatus.DataValueField = "LookupItemId";
                ddlSectionStatus.DataBind();
            }
        }
        catch { ddlSectionStatus.Items.Clear(); }
        ddlSectionStatus.Items.Insert(0, new ListItem("-- الحالة --", ""));
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadSelectedProject(); }
    protected void btnLoad_Click(object sender, EventArgs e) { LoadSelectedProject(); }

    private void LoadSelectedProject()
    {
        HideMessage();
        CurrentSectionId = 0;
        pnlProject.Visible = pnlForm.Visible = pnlSections.Visible = pnlSectionView.Visible = false;
        if (SelectedProjectId <= 0) return;
        LoadProjectBrief();
        LoadSections();
    }

    private void LoadProjectBrief()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectDashboard_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }
                DataRow r = ds.Tables[0].Rows[0];
                litProjectTitle.Text = Server.HtmlEncode(Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["ProjectName"]));
                litProjectMeta.Text = Server.HtmlEncode(Convert.ToString(r["ProjectTypeNameAr"]) + " | " + Convert.ToString(r["City"]) + " | " + Convert.ToString(r["LocationName"]));
                pnlProject.Visible = true;
                pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadSections()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSections_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvSections.DataSource = dt;
                gvSections.DataBind();
                pnlSections.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSaveSection_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("CrossSections.Edit")) { ShowError("لا تملك صلاحية تعديل المقاطع."); return; }
        if (SelectedProjectId <= 0) { ShowError("اختر المشروع أولًا."); return; }
        try
        {
            long id; long.TryParse(hfSectionId.Value, out id);
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSection_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CrossSectionId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                cmd.Parameters.AddWithValue("@SectionCode", DataHelper.DbValue(txtSectionCode.Text));
                cmd.Parameters.AddWithValue("@SectionName", DataHelper.DbValue(txtSectionName.Text));
                cmd.Parameters.AddWithValue("@BaselineType", ddlBaselineType.SelectedValue);
                cmd.Parameters.AddWithValue("@SectionStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSectionStatus)));
                cmd.Parameters.AddWithValue("@HorizontalScale", DataHelper.DbValue(ParseDecimal(txtHorizontalScale.Text)));
                cmd.Parameters.AddWithValue("@VerticalScale", DataHelper.DbValue(ParseDecimal(txtVerticalScale.Text)));
                cmd.Parameters.AddWithValue("@StartEasting", DataHelper.DbValue(ParseDecimal(txtStartEasting.Text)));
                cmd.Parameters.AddWithValue("@StartNorthing", DataHelper.DbValue(ParseDecimal(txtStartNorthing.Text)));
                cmd.Parameters.AddWithValue("@EndEasting", DataHelper.DbValue(ParseDecimal(txtEndEasting.Text)));
                cmd.Parameters.AddWithValue("@EndNorthing", DataHelper.DbValue(ParseDecimal(txtEndNorthing.Text)));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                object result = cmd.ExecuteScalar();
                long newId; if (result != null && long.TryParse(Convert.ToString(result), out newId)) CurrentSectionId = newId;
            }
            if (CurrentSectionId <= 0)
            {
                long tempSectionId;
                if (long.TryParse(hfSectionId.Value, out tempSectionId)) CurrentSectionId = tempSectionId;
            }
            ShowSuccess("تم حفظ المقطع.");
            LoadSections();
            if (CurrentSectionId > 0) LoadSectionView(CurrentSectionId);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnGenerateBoreholes_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("CrossSections.Generate")) { ShowError("لا تملك صلاحية ربط الجسات بالمقطع."); return; }
        long id; long.TryParse(hfSectionId.Value, out id);
        if (id <= 0 && CurrentSectionId > 0) id = CurrentSectionId;
        if (id <= 0) { ShowError("احفظ المقطع أولًا ثم اربط الجسات."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSection_GenerateBoreholes", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CrossSectionId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم ربط الجسات بالمقطع حسب الإحداثيات.");
            LoadSections();
            LoadSectionView(id);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    protected void gvSections_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "ViewSection") LoadSectionView(id);
        if (e.CommandName == "EditSection") LoadSectionForEdit(id);
        if (e.CommandName == "DeleteSection") DeleteSection(id);
    }

    private void LoadSectionForEdit(long id)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSection_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CrossSectionId", id);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("المقطع غير موجود."); return; }
                DataRow r = dt.Rows[0];
                hfSectionId.Value = Convert.ToString(r["CrossSectionId"]);
                CurrentSectionId = id;
                txtSectionCode.Text = Convert.ToString(r["SectionCode"]);
                txtSectionName.Text = Convert.ToString(r["SectionName"]);
                SetSelected(ddlBaselineType, r["BaselineType"]);
                SetSelected(ddlSectionStatus, r["SectionStatusId"]);
                txtHorizontalScale.Text = FormatDecimal(r["HorizontalScale"]);
                txtVerticalScale.Text = FormatDecimal(r["VerticalScale"]);
                txtStartEasting.Text = FormatDecimal(r["StartEasting"]);
                txtStartNorthing.Text = FormatDecimal(r["StartNorthing"]);
                txtEndEasting.Text = FormatDecimal(r["EndEasting"]);
                txtEndNorthing.Text = FormatDecimal(r["EndNorthing"]);
                txtNotes.Text = Convert.ToString(r["Notes"]);
                ShowSuccess("تم تحميل المقطع للتعديل.");
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteSection(long id)
    {
        if (!SecurityHelper.HasPermission("CrossSections.Edit")) { ShowError("لا تملك صلاحية حذف المقاطع."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSection_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CrossSectionId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف المقطع.");
            ClearForm();
            pnlSectionView.Visible = false;
            LoadSections();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnRefreshSection_Click(object sender, EventArgs e)
    {
        if (CurrentSectionId > 0) LoadSectionView(CurrentSectionId);
    }

    private void LoadSectionView(long id)
    {
        try
        {
            CurrentSectionId = id;
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectCrossSectionData_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CrossSectionId", id);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المقطع غير موجود."); return; }
                DataRow s = ds.Tables[0].Rows[0];
                litSectionTitle.Text = Server.HtmlEncode(Convert.ToString(s["SectionCode"]) + " - " + Convert.ToString(s["SectionName"]));
                litSectionMeta.Text = Server.HtmlEncode("Baseline: " + Convert.ToString(s["BaselineType"]) + " | H:" + Convert.ToString(s["HorizontalScale"]) + " | V:" + Convert.ToString(s["VerticalScale"]));
                DataTable bhs = ds.Tables.Count > 1 ? ds.Tables[1] : new DataTable();
                DataTable layers = ds.Tables.Count > 2 ? ds.Tables[2] : new DataTable();
                gvSectionBoreholes.DataSource = bhs;
                gvSectionBoreholes.DataBind();
                litSectionSvg.Text = BuildSectionSvg(bhs, layers);
                pnlSectionView.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private string BuildSectionSvg(DataTable bhs, DataTable layers)
    {
        if (bhs.Rows.Count == 0) return "<div class='gsp-muted'>لا توجد جسات مرتبطة بالمقطع. اضغط ربط الجسات تلقائيًا بعد حفظ المقطع.</div>";
        decimal maxDepth = 1;
        foreach (DataRow r in bhs.Rows)
        {
            decimal d = GetDecimal(r, "ActualDepthM", GetDecimal(r, "PlannedDepthM", 0));
            if (d > maxDepth) maxDepth = d;
        }
        foreach (DataRow r in layers.Rows)
        {
            decimal d = GetDecimal(r, "DepthToM", 0);
            if (d > maxDepth) maxDepth = d;
        }

        decimal width = Math.Max(980, 160 + bhs.Rows.Count * 170);
        decimal height = 560;
        decimal top = 70, bottom = 70;
        decimal plotH = height - top - bottom;
        decimal depthScale = plotH / Math.Max(maxDepth, 1);
        decimal left = 90;
        decimal spacing = bhs.Rows.Count > 1 ? (width - 180) / (bhs.Rows.Count - 1) : 0;

        StringBuilder sb = new StringBuilder();
        sb.AppendFormat(CultureInfo.InvariantCulture, "<svg class='gsp-svg-section' viewBox='0 0 {0:0} 560' xmlns='http://www.w3.org/2000/svg'>", width);
        sb.Append("<rect x='0' y='0' width='100%' height='560' fill='#ffffff'/>");
        sb.Append("<text x='40' y='34' font-size='15' font-weight='800' fill='#0f172a'>Simplified Geotechnical Cross Section</text>");
        sb.AppendFormat(CultureInfo.InvariantCulture, "<line x1='70' y1='{0:0.##}' x2='{1:0.##}' y2='{0:0.##}' stroke='#111827' stroke-width='1.2'/>", top, width - 60);
        sb.AppendFormat(CultureInfo.InvariantCulture, "<line x1='70' y1='{0:0.##}' x2='70' y2='{1:0.##}' stroke='#334155' stroke-width='1'/>", top, height - bottom);
        for (int i = 0; i <= 5; i++)
        {
            decimal depth = maxDepth * i / 5m;
            decimal y = top + depth * depthScale;
            sb.AppendFormat(CultureInfo.InvariantCulture, "<line x1='70' y1='{0:0.##}' x2='{1:0.##}' y2='{0:0.##}' stroke='#e2e8f0' stroke-width='1'/>", y, width - 60);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='28' y='{0:0.##}' font-size='11' fill='#64748b'>{1:0.##} m</text>", y + 4, depth);
        }

        Dictionary<long, List<DataRow>> layerByBh = new Dictionary<long, List<DataRow>>();
        foreach (DataRow lr in layers.Rows)
        {
            long bhId = Convert.ToInt64(lr["BoreholeId"]);
            if (!layerByBh.ContainsKey(bhId)) layerByBh[bhId] = new List<DataRow>();
            layerByBh[bhId].Add(lr);
        }

        for (int i = 0; i < bhs.Rows.Count; i++)
        {
            DataRow bh = bhs.Rows[i];
            long bhId = Convert.ToInt64(bh["BoreholeId"]);
            decimal x = bhs.Rows.Count == 1 ? width / 2 : left + spacing * i;
            string code = Server.HtmlEncode(Convert.ToString(bh["BoreholeCode"]));
            decimal depth = GetDecimal(bh, "ActualDepthM", 0);
            decimal elev = GetDecimal(bh, "ElevationM", 0);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<line x1='{0:0.##}' y1='{1:0.##}' x2='{0:0.##}' y2='{2:0.##}' stroke='#0f172a' stroke-width='2'/>", x, top, top + depth * depthScale);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='{0:0.##}' y='55' font-size='13' text-anchor='middle' font-weight='800' fill='#0f766e'>{1}</text>", x, code);
            sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='{0:0.##}' y='{1:0.##}' font-size='10' text-anchor='middle' fill='#64748b'>Z {2:0.##} | D {3:0.##}m</text>", x, top + depth * depthScale + 16, elev, depth);
            if (layerByBh.ContainsKey(bhId))
            {
                int li = 0;
                foreach (DataRow l in layerByBh[bhId])
                {
                    decimal from = GetDecimal(l, "DepthFromM", 0);
                    decimal to = GetDecimal(l, "DepthToM", from);
                    if (to <= from) continue;
                    decimal y = top + from * depthScale;
                    decimal h = Math.Max((to - from) * depthScale, 5);
                    string css = "layer-fill-" + (li % 6).ToString();
                    string desc = Server.HtmlEncode(Convert.ToString(l["LayerDescription"]));
                    sb.AppendFormat(CultureInfo.InvariantCulture, "<rect x='{0:0.##}' y='{1:0.##}' width='80' height='{2:0.##}' class='{3}' stroke='#334155' stroke-width='.6' opacity='.88'/>", x - 40, y, h, css);
                    if (h > 18) sb.AppendFormat(CultureInfo.InvariantCulture, "<text x='{0:0.##}' y='{1:0.##}' font-size='9' text-anchor='middle' fill='#111827'>{2}</text>", x, y + 13, Trim(desc, 18));
                    li++;
                }
            }
        }
        sb.Append("<text x='40' y='540' font-size='11' fill='#64748b'>Note: This is a simplified schematic section generated from borehole log depths. It is not a CAD/GIS surveyed drawing.</text>");
        sb.Append("</svg>");
        return sb.ToString();
    }

    private string Trim(string text, int max)
    {
        if (string.IsNullOrEmpty(text) || text.Length <= max) return text;
        return text.Substring(0, max) + "...";
    }

    private decimal GetDecimal(DataRow r, string col, decimal fallback)
    {
        if (r.Table.Columns.Contains(col) && r[col] != DBNull.Value)
        {
            decimal d; if (decimal.TryParse(Convert.ToString(r[col]), out d)) return d;
        }
        return fallback;
    }

    private void ClearForm()
    {
        hfSectionId.Value = string.Empty; CurrentSectionId = 0;
        txtSectionCode.Text = txtSectionName.Text = txtStartEasting.Text = txtStartNorthing.Text = txtEndEasting.Text = txtEndNorthing.Text = txtNotes.Text = string.Empty;
        txtHorizontalScale.Text = "500"; txtVerticalScale.Text = "100";
        if (ddlBaselineType.Items.Count > 0) ddlBaselineType.SelectedIndex = 0;
        if (ddlSectionStatus.Items.Count > 0) ddlSectionStatus.SelectedIndex = 0;
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
