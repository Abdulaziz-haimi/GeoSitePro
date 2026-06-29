using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ProjectQualityCheck : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("QualityChecks.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjects();
            LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadQualityChecks();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("QualityChecks.Create"); }

    private void LoadProjects()
    {
        DataTable dt;
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
        }
        BindProject(ddlProject, dt, "-- اختر المشروع --");
        BindProject(ddlFilterProject, dt, "-- كل المشاريع --");
    }

    private void BindProject(DropDownList ddl, DataTable dt, string emptyText)
    {
        ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, ""));
    }

    private void LoadLookups()
    {
        BindLookup(ddlCheckArea, GetLookup("QualityCheckArea"), "-- اختر المنطقة --");
        BindLookup(ddlSeverity, GetLookup("QualitySeverity"), "-- اختر الخطورة --");
        DataTable status = GetLookup("QualityStatus");
        BindLookup(ddlStatus, status, "-- اختر الحالة --");
        BindLookup(ddlFilterStatus, status, "-- كل الحالات --");
    }

    private DataTable GetLookup(string category)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryCode", category);
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt;
        }
    }

    private void BindLookup(DropDownList ddl, DataTable dt, string emptyText)
    {
        ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, ""));
    }

    private void LoadQualityChecks()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_ProjectQualityChecks_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
            cmd.Parameters.AddWithValue("@StatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterStatus)));
            cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            gvQualityChecks.DataSource = dt; gvQualityChecks.DataBind();
        }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        ClearForm(); if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId); pnlForm.Visible = true; litFormTitle.Text = "إضافة بند فحص";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission(string.IsNullOrEmpty(hfQualityCheckId.Value) ? "QualityChecks.Create" : "QualityChecks.Edit")) { ShowError("لا تملك صلاحية الحفظ."); return; }
        if (DataHelper.SelectedLong(ddlProject) == null || string.IsNullOrWhiteSpace(txtChecklistItem.Text)) { ShowError("المشروع وبند الفحص مطلوبان."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectQualityCheck_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                long id; cmd.Parameters.AddWithValue("@QualityCheckId", long.TryParse(hfQualityCheckId.Value, out id) ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@CheckAreaId", DataHelper.DbValue(DataHelper.SelectedLong(ddlCheckArea)));
                cmd.Parameters.AddWithValue("@ChecklistItem", DataHelper.DbValue(txtChecklistItem.Text));
                cmd.Parameters.AddWithValue("@RequirementReference", DataHelper.DbValue(txtRequirementReference.Text));
                cmd.Parameters.AddWithValue("@SeverityId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSeverity)));
                cmd.Parameters.AddWithValue("@StatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlStatus)));
                cmd.Parameters.AddWithValue("@ResponsiblePerson", DataHelper.DbValue(txtResponsiblePerson.Text));
                cmd.Parameters.AddWithValue("@DueDate", DataHelper.DbValue(ParseDate(txtDueDate.Text)));
                cmd.Parameters.AddWithValue("@ClosedDate", DataHelper.DbValue(ParseDate(txtClosedDate.Text)));
                cmd.Parameters.AddWithValue("@EvidenceText", DataHelper.DbValue(txtEvidenceText.Text));
                cmd.Parameters.AddWithValue("@CorrectiveAction", DataHelper.DbValue(txtCorrectiveAction.Text));
                cmd.Parameters.AddWithValue("@Remarks", DataHelper.DbValue(txtRemarks.Text));
                cmd.Parameters.AddWithValue("@IsApproved", chkIsApproved.Checked);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            pnlForm.Visible = false; LoadQualityChecks(); ShowSuccess("تم حفظ بند الفحص.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadQualityChecks(); }
    protected void btnClear_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterProject.SelectedIndex = 0; ddlFilterStatus.SelectedIndex = 0; LoadQualityChecks(); }

    protected void gvQualityChecks_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadQualityCheck(id);
        if (e.CommandName == "ApproveItem") ApproveQualityCheck(id);
        if (e.CommandName == "DeleteItem") DeleteQualityCheck(id);
    }

    private void LoadQualityCheck(long id)
    {
        if (!SecurityHelper.HasPermission("QualityChecks.Edit")) { ShowError("لا تملك صلاحية التعديل."); return; }
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_ProjectQualityCheck_GetById", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@QualityCheckId", id);
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            if (dt.Rows.Count == 0) { ShowError("البند غير موجود."); return; }
            DataRow r = dt.Rows[0]; hfQualityCheckId.Value = Convert.ToString(r["QualityCheckId"]); SetSelected(ddlProject, r["ProjectId"]); SetSelected(ddlCheckArea, r["CheckAreaId"]); txtChecklistItem.Text = Convert.ToString(r["ChecklistItem"]); txtRequirementReference.Text = Convert.ToString(r["RequirementReference"]); SetSelected(ddlSeverity, r["SeverityId"]); SetSelected(ddlStatus, r["StatusId"]); txtResponsiblePerson.Text = Convert.ToString(r["ResponsiblePerson"]); txtDueDate.Text = FormatDate(r["DueDate"]); txtClosedDate.Text = FormatDate(r["ClosedDate"]); txtEvidenceText.Text = Convert.ToString(r["EvidenceText"]); txtCorrectiveAction.Text = Convert.ToString(r["CorrectiveAction"]); txtRemarks.Text = Convert.ToString(r["Remarks"]); chkIsApproved.Checked = r["IsApproved"] != DBNull.Value && Convert.ToBoolean(r["IsApproved"]); litFormTitle.Text = "تعديل بند فحص"; pnlForm.Visible = true;
        }
    }

    private void ApproveQualityCheck(long id)
    {
        if (!SecurityHelper.HasPermission("QualityChecks.Approve")) { ShowError("لا تملك صلاحية الاعتماد."); return; }
        ExecuteSimple("sp_ProjectQualityCheck_Approve", "@QualityCheckId", id); LoadQualityChecks(); ShowSuccess("تم اعتماد بند الفحص.");
    }

    private void DeleteQualityCheck(long id)
    {
        if (!SecurityHelper.HasPermission("QualityChecks.Delete")) { ShowError("لا تملك صلاحية الحذف."); return; }
        ExecuteSimple("sp_ProjectQualityCheck_Delete", "@QualityCheckId", id); LoadQualityChecks(); ShowSuccess("تم حذف بند الفحص.");
    }

    private void ExecuteSimple(string proc, string param, long id)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue(param, id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); }
    }

    private void ClearForm()
    {
        hfQualityCheckId.Value = ""; if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; if (ddlCheckArea.Items.Count > 0) ddlCheckArea.SelectedIndex = 0; if (ddlSeverity.Items.Count > 0) ddlSeverity.SelectedIndex = 0; if (ddlStatus.Items.Count > 0) ddlStatus.SelectedIndex = 0; txtChecklistItem.Text = ""; txtRequirementReference.Text = ""; txtResponsiblePerson.Text = ""; txtDueDate.Text = ""; txtClosedDate.Text = ""; txtEvidenceText.Text = ""; txtCorrectiveAction.Text = ""; txtRemarks.Text = ""; chkIsApproved.Checked = false;
    }

    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d.Date : null; }
    private string FormatDate(object value) { if (value == DBNull.Value || value == null) return ""; DateTime d; return DateTime.TryParse(Convert.ToString(value), out d) ? d.ToString("yyyy-MM-dd") : ""; }
    private void SetSelected(DropDownList ddl, object value) { ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; } }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
