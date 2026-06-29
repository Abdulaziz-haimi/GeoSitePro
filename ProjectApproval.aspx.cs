using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

public partial class ProjectApproval : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Workflow.View");
        if (!IsPostBack)
        {
            LoadProjects();
            LoadWorkflowSteps();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadProject();
        }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadProject(); }
    protected void btnLoad_Click(object sender, EventArgs e) { LoadProject(); }

    private void LoadProjects()
    {
        DataTable dt = ExecuteTable("sp_Projects_Get", new SqlParameter("@SearchText", DBNull.Value));
        ddlProject.DataSource = dt;
        ddlProject.DataTextField = "ProjectName";
        ddlProject.DataValueField = "ProjectId";
        ddlProject.DataBind();
        ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadWorkflowSteps()
    {
        DataTable dt = ExecuteTable("sp_WorkflowSteps_Get", new SqlParameter("@EntityType", DBNull.Value));
        ddlWorkflowStep.DataSource = dt;
        ddlWorkflowStep.DataTextField = "StepDisplayName";
        ddlWorkflowStep.DataValueField = "WorkflowStepId";
        ddlWorkflowStep.DataBind();
        ddlWorkflowStep.Items.Insert(0, new ListItem("-- اختر مرحلة سير العمل --", ""));
    }

    private void LoadProject()
    {
        long? projectId = DataHelper.SelectedLong(ddlProject);
        pnlProject.Visible = projectId.HasValue;
        if (!projectId.HasValue) return;
        LoadSummary(projectId.Value);
        LoadRequests(projectId.Value);
    }

    private void LoadSummary(long projectId)
    {
        DataTable dt = ExecuteTable("sp_ApprovalDashboard_Get", new SqlParameter("@ProjectId", projectId));
        if (dt.Rows.Count == 0) { litSummary.Text = ""; return; }
        DataRow r = dt.Rows[0];
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='gsp-grid gsp-grid-4'>");
        AppendStat(sb, "Pending", r["PendingCount"]);
        AppendStat(sb, "Approved", r["ApprovedCount"]);
        AppendStat(sb, "Rejected", r["RejectedCount"]);
        AppendStat(sb, "Returned", r["ReturnedCount"]);
        sb.Append("</div><br/>");
        litSummary.Text = sb.ToString();
    }

    private void LoadRequests(long projectId)
    {
        gvRequests.DataSource = ExecuteTable("sp_ApprovalRequests_Get",
            new SqlParameter("@ProjectId", projectId),
            new SqlParameter("@Status", DBNull.Value),
            new SqlParameter("@SearchText", DBNull.Value),
            new SqlParameter("@AssignedToUserId", DBNull.Value));
        gvRequests.DataBind();
    }

    protected void btnCreateRequest_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Workflow.Create")) { ShowError("لا تملك صلاحية إنشاء طلب اعتماد."); return; }
        long? projectId = DataHelper.SelectedLong(ddlProject);
        long? stepId = DataHelper.SelectedLong(ddlWorkflowStep);
        if (!projectId.HasValue) { ShowError("اختر المشروع."); return; }
        if (!stepId.HasValue) { ShowError("اختر مرحلة سير العمل."); return; }
        if (string.IsNullOrWhiteSpace(txtRequestTitle.Text)) { ShowError("عنوان الطلب مطلوب."); return; }
        try
        {
            ExecuteScalar("sp_ApprovalRequest_Create",
                new SqlParameter("@ProjectId", projectId.Value),
                new SqlParameter("@EntityType", ddlEntityType.SelectedValue),
                new SqlParameter("@EntityId", DataHelper.DbValue(ParseLong(txtEntityId.Text))),
                new SqlParameter("@WorkflowStepId", stepId.Value),
                new SqlParameter("@RequestTitle", txtRequestTitle.Text.Trim()),
                new SqlParameter("@RequestDescription", DataHelper.DbValue(txtRequestDescription.Text)),
                new SqlParameter("@Priority", ddlPriority.SelectedValue),
                new SqlParameter("@AssignedToUserId", DBNull.Value),
                new SqlParameter("@AssignedToRoleId", DBNull.Value),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            txtEntityId.Text = txtRequestTitle.Text = txtRequestDescription.Text = string.Empty;
            ShowSuccess("تم إنشاء طلب الاعتماد بنجاح.");
            LoadProject();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvRequests_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        string decision = null;
        if (e.CommandName == "ApproveItem") decision = "Approve";
        if (e.CommandName == "RejectItem") decision = "Reject";
        if (e.CommandName == "ReturnItem") decision = "Return";
        if (decision == null) return;
        if (decision == "Approve" && !SecurityHelper.HasPermission("Workflow.Approve")) { ShowError("لا تملك صلاحية الاعتماد."); return; }
        if ((decision == "Reject" || decision == "Return") && !SecurityHelper.HasPermission("Workflow.Reject")) { ShowError("لا تملك صلاحية الرفض أو الإرجاع."); return; }
        try
        {
            ExecuteNonQuery("sp_ApprovalRequest_Decide",
                new SqlParameter("@ApprovalRequestId", id),
                new SqlParameter("@Decision", decision),
                new SqlParameter("@Comments", "تم تنفيذ الإجراء من صفحة اعتماد المشروع."),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم تنفيذ الإجراء بنجاح.");
            LoadProject();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private long? ParseLong(string value)
    {
        long result;
        if (long.TryParse(value, out result) && result > 0) return result;
        return null;
    }

    private void AppendStat(StringBuilder sb, string label, object value)
    {
        sb.Append("<div class='gsp-stat'><div class='gsp-stat-label'>");
        sb.Append(Server.HtmlEncode(label));
        sb.Append("</div><div class='gsp-stat-value'>");
        sb.Append(Server.HtmlEncode(Convert.ToString(value)));
        sb.Append("</div></div>");
    }

    private DataTable ExecuteTable(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private object ExecuteScalar(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            return cmd.ExecuteScalar();
        }
    }

    private void ExecuteNonQuery(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-success";
        litMessage.Text = Server.HtmlEncode(message);
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

}
