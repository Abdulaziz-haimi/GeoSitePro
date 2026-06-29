using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ExportCenter : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("ExportCenter.View");
        if (!IsPostBack)
        {
            ApplyPermissions(); LoadProjects(); LoadLookups(); if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId); LoadExports();
        }
    }
    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("ExportCenter.Create"); }
    private void LoadProjects()
    {
        DataTable dt; using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); }
        BindProject(ddlProject, dt, "-- اختر المشروع --"); BindProject(ddlFilterProject, dt, "-- كل المشاريع --");
    }
    private void BindProject(DropDownList ddl, DataTable dt, string emptyText) { ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }
    private void LoadLookups() { BindLookup(ddlPackageType, GetLookup("ExportPackageType"), "-- اختر نوع الحزمة --"); }
    private DataTable GetLookup(string category) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", category); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; } }
    private void BindLookup(DropDownList ddl, DataTable dt, string emptyText) { ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }
    private void LoadExports()
    {
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ExportPackages_Get", con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject))); cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text)); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); gvExports.DataSource = dt; gvExports.DataBind(); }
    }
    protected void btnNew_Click(object sender, EventArgs e) { ClearForm(); if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId); pnlForm.Visible = true; }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadExports(); }
    protected void btnClear_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterProject.SelectedIndex = 0; LoadExports(); }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("ExportCenter.Create")) { ShowError("لا تملك صلاحية إنشاء حزم التصدير."); return; }
        if (DataHelper.SelectedLong(ddlProject) == null) { ShowError("اختر المشروع."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ExportPackage_Save", con))
            { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value); cmd.Parameters.AddWithValue("@PackageTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlPackageType))); cmd.Parameters.AddWithValue("@PackageTitle", DataHelper.DbValue(txtPackageTitle.Text)); cmd.Parameters.AddWithValue("@IncludeBoreholes", chkBoreholes.Checked); cmd.Parameters.AddWithValue("@IncludeSamples", chkSamples.Checked); cmd.Parameters.AddWithValue("@IncludeSPT", chkSPT.Checked); cmd.Parameters.AddWithValue("@IncludeGroundwater", chkGroundwater.Checked); cmd.Parameters.AddWithValue("@IncludeLabResults", chkLabResults.Checked); cmd.Parameters.AddWithValue("@IncludeReports", chkReports.Checked); cmd.Parameters.AddWithValue("@IncludeDocuments", chkDocuments.Checked); cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text)); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); }
            pnlForm.Visible = false; LoadExports(); ShowSuccess("تم إنشاء حزمة التصدير.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    protected void gvExports_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "MarkGenerated") { if (!SecurityHelper.HasPermission("ExportCenter.Generate")) { ShowError("لا تملك صلاحية التجهيز."); return; } ExecuteSimple("sp_ExportPackage_MarkGenerated", id); LoadExports(); ShowSuccess("تم تعليم الحزمة كجاهزة."); }
        if (e.CommandName == "DeleteItem") { if (!SecurityHelper.HasPermission("ExportCenter.Delete")) { ShowError("لا تملك صلاحية الحذف."); return; } ExecuteSimple("sp_ExportPackage_Delete", id); LoadExports(); ShowSuccess("تم حذف الحزمة."); }
    }
    private void ExecuteSimple(string proc, long id) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ExportPackageId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } }
    private void ClearForm() { if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; if (ddlPackageType.Items.Count > 0) ddlPackageType.SelectedIndex = 0; txtPackageTitle.Text = txtNotes.Text = ""; chkBoreholes.Checked = chkSamples.Checked = chkSPT.Checked = chkGroundwater.Checked = chkLabResults.Checked = chkReports.Checked = chkDocuments.Checked = true; }
    private void SetSelected(DropDownList ddl, object value) { ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; } }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
