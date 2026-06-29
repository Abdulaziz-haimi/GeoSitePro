using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Reports : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Reports.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjectsDropDowns();
            LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadReports();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Reports.Create");
    }

    private void LoadProjectsDropDowns()
    {
        DataTable dt = GetProjects();
        BindProjectDropDown(ddlProject, dt, true);
        BindProjectDropDown(ddlFilterProject, dt, true);
    }

    private DataTable GetProjects()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private void BindProjectDropDown(DropDownList ddl, DataTable dt, bool addEmpty)
    {
        ddl.DataSource = dt;
        ddl.DataTextField = "ProjectName";
        ddl.DataValueField = "ProjectId";
        ddl.DataBind();
        if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadLookups()
    {
        BindLookup(ddlReportType, "ReportType", true);
        BindLookup(ddlReportStatus, "ReportStatus", true);
    }

    private void BindLookup(DropDownList ddl, string categoryCode, bool addEmpty)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryCode", categoryCode);
            cmd.Parameters.AddWithValue("@OnlyActive", true);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddl.DataSource = dt;
            ddl.DataTextField = "NameAr";
            ddl.DataValueField = "LookupItemId";
            ddl.DataBind();
            if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر --", ""));
        }
    }

    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadReports(); }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadReports(); }
    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        if (ddlFilterProject.Items.Count > 0) ddlFilterProject.SelectedIndex = 0;
        LoadReports();
    }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); HideMessage(); }

    private void LoadReports()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Reports_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvReports.DataSource = dt;
                gvReports.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("Reports.Create")) { ShowError("لا تملك صلاحية إضافة تقرير."); return; }
        ClearForm();
        if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value);
        else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
        txtIssueDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtRevisionNo.Text = "Rev.0";
        litFormTitle.Text = "إضافة تقرير فني";
        pnlForm.Visible = true;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long id; long.TryParse(hfReportId.Value, out id);
            bool isNew = id <= 0;
            if (isNew && !SecurityHelper.HasPermission("Reports.Create")) { ShowError("لا تملك صلاحية إضافة تقرير."); return; }
            if (!isNew && !SecurityHelper.HasPermission("Reports.Edit")) { ShowError("لا تملك صلاحية تعديل التقرير."); return; }

            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@ReportNo", DataHelper.DbValue(txtReportNo.Text));
                cmd.Parameters.AddWithValue("@ReportTitle", DataHelper.DbValue(txtReportTitle.Text));
                cmd.Parameters.AddWithValue("@ReportTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlReportType)));
                cmd.Parameters.AddWithValue("@ReportStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlReportStatus)));
                cmd.Parameters.AddWithValue("@IssueDate", DataHelper.DbValue(ParseDate(txtIssueDate.Text)));
                cmd.Parameters.AddWithValue("@RevisionNo", DataHelper.DbValue(txtRevisionNo.Text));
                cmd.Parameters.AddWithValue("@PreparedBy", DataHelper.DbValue(txtPreparedBy.Text));
                cmd.Parameters.AddWithValue("@ReviewedBy", DataHelper.DbValue(txtReviewedBy.Text));
                cmd.Parameters.AddWithValue("@ApprovedBy", DataHelper.DbValue(txtApprovedBy.Text));
                cmd.Parameters.AddWithValue("@ExecutiveSummary", DataHelper.DbValue(txtExecutiveSummary.Text));
                cmd.Parameters.AddWithValue("@Recommendations", DataHelper.DbValue(txtRecommendations.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                hfReportId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ التقرير بنجاح. يمكنك الآن تحرير الأقسام أو الطباعة.");
            pnlForm.Visible = false;
            SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value);
            LoadReports();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvReports_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadForEdit(id);
        else if (e.CommandName == "DeleteItem") DeleteReport(id);
        else if (e.CommandName == "ApproveItem") ApproveReport(id);
    }

    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("Reports.Edit")) { ShowError("لا تملك صلاحية تعديل التقرير."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", id);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("التقرير غير موجود."); return; }
                DataRow r = dt.Rows[0];
                hfReportId.Value = Convert.ToString(r["ReportId"]);
                SetSelected(ddlProject, r["ProjectId"]);
                SetSelected(ddlReportType, r["ReportTypeId"]);
                SetSelected(ddlReportStatus, r["ReportStatusId"]);
                txtReportNo.Text = Convert.ToString(r["ReportNo"]);
                txtReportTitle.Text = Convert.ToString(r["ReportTitle"]);
                txtIssueDate.Text = FormatDate(r["IssueDate"]);
                txtRevisionNo.Text = Convert.ToString(r["RevisionNo"]);
                txtPreparedBy.Text = Convert.ToString(r["PreparedBy"]);
                txtReviewedBy.Text = Convert.ToString(r["ReviewedBy"]);
                txtApprovedBy.Text = Convert.ToString(r["ApprovedBy"]);
                txtExecutiveSummary.Text = Convert.ToString(r["ExecutiveSummary"]);
                txtRecommendations.Text = Convert.ToString(r["Recommendations"]);
                litFormTitle.Text = "تعديل تقرير فني";
                pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteReport(long id)
    {
        if (!SecurityHelper.HasPermission("Reports.Delete")) { ShowError("لا تملك صلاحية حذف التقرير."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف التقرير منطقيًا."); LoadReports();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ApproveReport(long id)
    {
        if (!SecurityHelper.HasPermission("Reports.Approve")) { ShowError("لا تملك صلاحية اعتماد التقرير."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_Approve", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم اعتماد التقرير."); LoadReports();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; }
        if (string.IsNullOrWhiteSpace(txtReportTitle.Text)) { ShowError("عنوان التقرير مطلوب."); return false; }
        return true;
    }

    private void ClearForm()
    {
        hfReportId.Value = string.Empty;
        if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0;
        if (ddlReportType.Items.Count > 0) ddlReportType.SelectedIndex = 0;
        if (ddlReportStatus.Items.Count > 0) ddlReportStatus.SelectedIndex = 0;
        txtReportNo.Text = string.Empty; txtReportTitle.Text = string.Empty; txtIssueDate.Text = string.Empty; txtRevisionNo.Text = string.Empty;
        txtPreparedBy.Text = string.Empty; txtReviewedBy.Text = string.Empty; txtApprovedBy.Text = string.Empty;
        txtExecutiveSummary.Text = string.Empty; txtRecommendations.Text = string.Empty;
    }

    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
