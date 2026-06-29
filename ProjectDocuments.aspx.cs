using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

public partial class ProjectDocuments : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private const int MaxBytes = 25 * 1024 * 1024;

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("ProjectDocuments.View");
        if (!IsPostBack)
        {
            ApplyPermissions(); LoadProjects(); LoadLookups(); if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId); LoadDocuments();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("ProjectDocuments.Create"); }

    private void LoadProjects()
    {
        DataTable dt;
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); }
        BindProject(ddlProject, dt, "-- اختر المشروع --"); BindProject(ddlFilterProject, dt, "-- كل المشاريع --");
    }
    private void BindProject(DropDownList ddl, DataTable dt, string emptyText) { ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }

    private void LoadLookups()
    {
        DataTable dt = GetLookup("DocumentType"); BindLookup(ddlDocumentType, dt, "-- اختر نوع الملف --"); BindLookup(ddlFilterDocumentType, dt, "-- كل الأنواع --");
    }
    private DataTable GetLookup(string category)
    { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", category); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; } }
    private void BindLookup(DropDownList ddl, DataTable dt, string emptyText) { ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }

    private void LoadDocuments()
    {
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProjectDocuments_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject))); cmd.Parameters.AddWithValue("@DocumentTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterDocumentType))); cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); gvDocuments.DataSource = dt; gvDocuments.DataBind();
        }
    }

    protected void btnNew_Click(object sender, EventArgs e) { ClearForm(); if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId); pnlForm.Visible = true; }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadDocuments(); }
    protected void btnClear_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterProject.SelectedIndex = 0; ddlFilterDocumentType.SelectedIndex = 0; LoadDocuments(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("ProjectDocuments.Create")) { ShowError("لا تملك صلاحية إضافة المرفقات."); return; }
        if (DataHelper.SelectedLong(ddlProject) == null || string.IsNullOrWhiteSpace(txtDocumentTitle.Text)) { ShowError("المشروع وعنوان الملف مطلوبان."); return; }
        if (!fuDocument.HasFile) { ShowError("اختر ملفًا للرفع."); return; }
        if (fuDocument.PostedFile.ContentLength > MaxBytes) { ShowError("حجم الملف أكبر من 25MB."); return; }
        string ext = Path.GetExtension(fuDocument.FileName).ToLowerInvariant();
        if (",.pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.csv,.txt,".IndexOf("," + ext + ",", StringComparison.OrdinalIgnoreCase) < 0) { ShowError("امتداد الملف غير مسموح."); return; }
        try
        {
            string folder = Server.MapPath("~/App_Data/Uploads/ProjectDocuments"); if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
            string storedFileName = DateTime.Now.ToString("yyyyMMddHHmmssfff") + "_" + Guid.NewGuid().ToString("N") + ext;
            string fullPath = Path.Combine(folder, storedFileName); fuDocument.SaveAs(fullPath);
            using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProjectDocument_Save", con))
            {
                int versionNo; long relatedId;
                cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value); cmd.Parameters.AddWithValue("@DocumentTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlDocumentType))); cmd.Parameters.AddWithValue("@DocumentTitle", DataHelper.DbValue(txtDocumentTitle.Text)); cmd.Parameters.AddWithValue("@RelatedEntityName", DataHelper.DbValue(txtRelatedEntityName.Text)); cmd.Parameters.AddWithValue("@RelatedEntityId", long.TryParse(txtRelatedEntityId.Text, out relatedId) ? (object)relatedId : DBNull.Value); cmd.Parameters.AddWithValue("@OriginalFileName", Path.GetFileName(fuDocument.FileName)); cmd.Parameters.AddWithValue("@StoredFileName", storedFileName); cmd.Parameters.AddWithValue("@FileExtension", ext); cmd.Parameters.AddWithValue("@ContentType", fuDocument.PostedFile.ContentType); cmd.Parameters.AddWithValue("@FileSizeBytes", fuDocument.PostedFile.ContentLength); cmd.Parameters.AddWithValue("@StoragePath", "~/App_Data/Uploads/ProjectDocuments/" + storedFileName); cmd.Parameters.AddWithValue("@VersionNo", int.TryParse(txtVersionNo.Text, out versionNo) ? versionNo : 1); cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text)); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery();
            }
            pnlForm.Visible = false; LoadDocuments(); ShowSuccess("تم رفع المرفق وحفظ بياناته.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvDocuments_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "DownloadItem") DownloadDocument(id);
        if (e.CommandName == "ApproveItem") { if (!SecurityHelper.HasPermission("ProjectDocuments.Approve")) { ShowError("لا تملك صلاحية الاعتماد."); return; } ExecuteSimple("sp_ProjectDocument_Approve", id); LoadDocuments(); ShowSuccess("تم اعتماد المرفق."); }
        if (e.CommandName == "DeleteItem") { if (!SecurityHelper.HasPermission("ProjectDocuments.Delete")) { ShowError("لا تملك صلاحية الحذف."); return; } ExecuteSimple("sp_ProjectDocument_Delete", id); LoadDocuments(); ShowSuccess("تم حذف المرفق من السجل."); }
    }

    private void DownloadDocument(long id)
    {
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProjectDocument_GetById", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectDocumentId", id); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            if (dt.Rows.Count == 0) { ShowError("المرفق غير موجود."); return; }
            DataRow r = dt.Rows[0]; string virtualPath = Convert.ToString(r["StoragePath"]); string physicalPath = Server.MapPath(virtualPath);
            if (!File.Exists(physicalPath)) { ShowError("ملف المرفق غير موجود في مجلد التخزين."); return; }
            Response.Clear(); Response.ContentType = Convert.ToString(r["ContentType"]); Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Convert.ToString(r["OriginalFileName"]).Replace("\"", "") + "\""); Response.TransmitFile(physicalPath); Response.End();
        }
    }

    private void ExecuteSimple(string proc, long id) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectDocumentId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } }
    private void ClearForm() { if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; if (ddlDocumentType.Items.Count > 0) ddlDocumentType.SelectedIndex = 0; txtDocumentTitle.Text = txtRelatedEntityName.Text = txtRelatedEntityId.Text = txtNotes.Text = ""; txtVersionNo.Text = "1"; }
    private void SetSelected(DropDownList ddl, object value) { ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; } }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
