using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class BoreholeLog : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long QueryBoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }
    private long SelectedBoreholeId { get { return DataHelper.SelectedLong(ddlBorehole).HasValue ? DataHelper.SelectedLong(ddlBorehole).Value : 0; } }
    private long SelectedProjectId { get { return DataHelper.SelectedLong(ddlProject).HasValue ? DataHelper.SelectedLong(ddlProject).Value : 0; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("BoreholeLog.View");
        if (!IsPostBack)
        {
            btnNewLayer.Visible = SecurityHelper.HasPermission("Boreholes.Edit");
            LoadProjects(); LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadBoreholes(); if (QueryBoreholeId > 0) SetSelected(ddlBorehole, QueryBoreholeId);
            LoadLog();
        }
    }

    private void LoadProjects()
    {
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddlProject.DataSource = dt; ddlProject.DataTextField = "ProjectName"; ddlProject.DataValueField = "ProjectId"; ddlProject.DataBind(); ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", "")); }
    }
    private void LoadLookups() { BindLookup(ddlSoilRockType, "SoilRockType", true); }
    private void BindLookup(DropDownList ddl, string categoryCode, bool addEmpty) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", categoryCode); cmd.Parameters.AddWithValue("@OnlyActive", true); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر --", "")); } }
    private void LoadBoreholes() { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Boreholes_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlProject))); cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddlBorehole.DataSource = dt; ddlBorehole.DataTextField = "BoreholeCode"; ddlBorehole.DataValueField = "BoreholeId"; ddlBorehole.DataBind(); ddlBorehole.Items.Insert(0, new ListItem("-- اختر الجسة --", "")); } }
    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadBoreholes(); pnlLayerForm.Visible = false; LoadLog(); }
    protected void ddlBorehole_SelectedIndexChanged(object sender, EventArgs e) { pnlLayerForm.Visible = false; LoadLog(); }

    private void LoadLog()
    {
        HideMessage();
        if (SelectedBoreholeId <= 0) { pnlHeader.Visible = false; BindEmpty(); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_BoreholeLog_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@BoreholeId", SelectedBoreholeId);
                DataSet ds = new DataSet(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("الجسة غير موجودة."); pnlHeader.Visible = false; BindEmpty(); return; }
                BindHeader(ds.Tables[0].Rows[0]);
                BindGrid(gvLayers, ds, 1); BindGrid(gvSamples, ds, 2); BindGrid(gvSPT, ds, 3); BindGrid(gvGroundwater, ds, 4);
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    private void BindHeader(DataRow r)
    {
        pnlHeader.Visible = true;
        litBoreholeCode.Text = Server.HtmlEncode(Convert.ToString(r["BoreholeCode"]));
        litProject.Text = Server.HtmlEncode(Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["ProjectName"]));
        litActualDepth.Text = Server.HtmlEncode(FormatDecimal(r["ActualDepthM"]) + " م");
        litDrillingMethod.Text = Server.HtmlEncode(Convert.ToString(r["DrillingMethodNameAr"]));
        litElevation.Text = Server.HtmlEncode(FormatDecimal(r["ElevationM"]));
        litGroundwater.Text = Server.HtmlEncode(FormatDecimal(r["GroundwaterDepthM"]));
        lnkBoreholeEdit.NavigateUrl = "~/Boreholes.aspx?ProjectId=" + Convert.ToString(r["ProjectId"]);
        lnkSamples.NavigateUrl = "~/Samples.aspx?ProjectId=" + Convert.ToString(r["ProjectId"]) + "&BoreholeId=" + Convert.ToString(r["BoreholeId"]);
        lnkSPT.NavigateUrl = "~/SPTTests.aspx?ProjectId=" + Convert.ToString(r["ProjectId"]) + "&BoreholeId=" + Convert.ToString(r["BoreholeId"]);
        lnkGroundwater.NavigateUrl = "~/Groundwater.aspx?ProjectId=" + Convert.ToString(r["ProjectId"]) + "&BoreholeId=" + Convert.ToString(r["BoreholeId"]);
    }
    private void BindGrid(GridView gv, DataSet ds, int index) { gv.DataSource = ds.Tables.Count > index ? ds.Tables[index] : new DataTable(); gv.DataBind(); }
    private void BindEmpty() { gvLayers.DataSource = new DataTable(); gvLayers.DataBind(); gvSamples.DataSource = new DataTable(); gvSamples.DataBind(); gvSPT.DataSource = new DataTable(); gvSPT.DataBind(); gvGroundwater.DataSource = new DataTable(); gvGroundwater.DataBind(); }

    protected void btnNewLayer_Click(object sender, EventArgs e)
    {
        if (SelectedBoreholeId <= 0) { ShowError("اختر الجسة أولًا قبل إضافة طبقة."); return; }
        if (!SecurityHelper.HasPermission("Boreholes.Edit")) { ShowError("لا تملك صلاحية تعديل سجل الجسة."); return; }
        ClearLayerForm(); litLayerFormTitle.Text = "إضافة طبقة"; pnlLayerForm.Visible = true;
    }
    protected void btnCancelLayer_Click(object sender, EventArgs e) { pnlLayerForm.Visible = false; ClearLayerForm(); HideMessage(); }
    protected void btnSaveLayer_Click(object sender, EventArgs e)
    {
        if (!ValidateLayer()) return;
        try
        {
            long layerId; long.TryParse(hfLayerId.Value, out layerId);
            using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_BoreholeLayer_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LayerId", layerId > 0 ? (object)layerId : DBNull.Value);
                cmd.Parameters.AddWithValue("@BoreholeId", SelectedBoreholeId);
                cmd.Parameters.AddWithValue("@FromDepthM", ParseDecimal(txtFromDepthM.Text).Value);
                cmd.Parameters.AddWithValue("@ToDepthM", ParseDecimal(txtToDepthM.Text).Value);
                cmd.Parameters.AddWithValue("@SoilRockTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSoilRockType)));
                cmd.Parameters.AddWithValue("@USCS", DataHelper.DbValue(txtUSCS.Text));
                cmd.Parameters.AddWithValue("@Description", DataHelper.DbValue(txtDescription.Text));
                cmd.Parameters.AddWithValue("@Color", DataHelper.DbValue(txtColor.Text));
                cmd.Parameters.AddWithValue("@ConsistencyDensity", DataHelper.DbValue(txtConsistencyDensity.Text));
                cmd.Parameters.AddWithValue("@MoistureCondition", DataHelper.DbValue(txtMoistureCondition.Text));
                cmd.Parameters.AddWithValue("@RecoveryPercent", DataHelper.DbValue(ParseDecimal(txtRecoveryPercent.Text)));
                cmd.Parameters.AddWithValue("@RQDPercent", DataHelper.DbValue(ParseDecimal(txtRQDPercent.Text)));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); hfLayerId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ طبقة الجسة بنجاح."); pnlLayerForm.Visible = false; LoadLog();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    protected void gvLayers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long layerId; if (!long.TryParse(Convert.ToString(e.CommandArgument), out layerId)) return;
        if (e.CommandName == "EditLayer") LoadLayerForEdit(layerId); else if (e.CommandName == "DeleteLayer") DeleteLayer(layerId);
    }
    private void LoadLayerForEdit(long layerId)
    {
        if (!SecurityHelper.HasPermission("Boreholes.Edit")) { ShowError("لا تملك صلاحية تعديل سجل الجسة."); return; }
        try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_BoreholeLayer_GetById", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@LayerId", layerId); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); if (dt.Rows.Count == 0) { ShowError("الطبقة غير موجودة."); return; } DataRow r = dt.Rows[0]; hfLayerId.Value = Convert.ToString(r["LayerId"]); txtFromDepthM.Text = FormatDecimal(r["FromDepthM"]); txtToDepthM.Text = FormatDecimal(r["ToDepthM"]); SetSelected(ddlSoilRockType, r["SoilRockTypeId"]); txtUSCS.Text = Convert.ToString(r["USCS"]); txtDescription.Text = Convert.ToString(r["Description"]); txtColor.Text = Convert.ToString(r["Color"]); txtConsistencyDensity.Text = Convert.ToString(r["ConsistencyDensity"]); txtMoistureCondition.Text = Convert.ToString(r["MoistureCondition"]); txtRecoveryPercent.Text = FormatDecimal(r["RecoveryPercent"]); txtRQDPercent.Text = FormatDecimal(r["RQDPercent"]); txtNotes.Text = Convert.ToString(r["Notes"]); litLayerFormTitle.Text = "تعديل طبقة"; pnlLayerForm.Visible = true; } }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    private void DeleteLayer(long layerId)
    {
        if (!SecurityHelper.HasPermission("Boreholes.Edit")) { ShowError("لا تملك صلاحية حذف طبقة من سجل الجسة."); return; }
        try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_BoreholeLayer_Delete", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@LayerId", layerId); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } ShowSuccess("تم حذف الطبقة منطقيًا."); LoadLog(); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    private bool ValidateLayer() { if (SelectedBoreholeId <= 0) { ShowError("اختر الجسة أولًا."); return false; } decimal? fromDepth = ParseDecimal(txtFromDepthM.Text); decimal? toDepth = ParseDecimal(txtToDepthM.Text); if (!fromDepth.HasValue || fromDepth.Value < 0) { ShowError("عمق البداية مطلوب ويجب أن يكون أكبر أو يساوي صفر."); return false; } if (!toDepth.HasValue || toDepth.Value <= fromDepth.Value) { ShowError("عمق النهاية يجب أن يكون أكبر من عمق البداية."); return false; } return true; }
    private void ClearLayerForm() { hfLayerId.Value = string.Empty; txtFromDepthM.Text = string.Empty; txtToDepthM.Text = string.Empty; if (ddlSoilRockType.Items.Count > 0) ddlSoilRockType.SelectedIndex = 0; txtUSCS.Text = string.Empty; txtDescription.Text = string.Empty; txtColor.Text = string.Empty; txtConsistencyDensity.Text = string.Empty; txtMoistureCondition.Text = string.Empty; txtRecoveryPercent.Text = string.Empty; txtRQDPercent.Text = string.Empty; txtNotes.Text = string.Empty; }
    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.##"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
