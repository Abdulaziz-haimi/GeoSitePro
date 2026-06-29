using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class WorkflowInbox : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Workflow.View");
        if (!IsPostBack)
        {
            ddlStatus.SelectedValue = "Pending";
            LoadInbox();
        }
    }

    protected void btnLoad_Click(object sender, EventArgs e) { LoadInbox(); }

    protected void btnPending_Click(object sender, EventArgs e)
    {
        ddlStatus.SelectedValue = "Pending";
        LoadInbox();
    }

    private void LoadInbox()
    {
        try
        {
            gvInbox.DataSource = ExecuteTable("sp_ApprovalRequests_Get",
                new SqlParameter("@ProjectId", DBNull.Value),
                new SqlParameter("@Status", DataHelper.DbValue(ddlStatus.SelectedValue)),
                new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)),
                new SqlParameter("@AssignedToUserId", DBNull.Value));
            gvInbox.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvInbox_RowCommand(object sender, GridViewCommandEventArgs e)
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
                new SqlParameter("@Comments", "تم تنفيذ الإجراء من صندوق سير العمل."),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم تنفيذ الإجراء بنجاح.");
            LoadInbox();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
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
