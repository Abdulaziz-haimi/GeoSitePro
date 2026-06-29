using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Notifications : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Notifications.View");
        if (!IsPostBack)
        {
            LoadSummary();
            LoadNotifications();
            btnGenerate.Visible = SecurityHelper.HasPermission("Notifications.Generate");
        }
    }

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        LoadSummary();
        LoadNotifications();
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Notifications.Generate")) { ShowError("لا تملك صلاحية توليد التنبيهات."); return; }
        try
        {
            ExecuteNonQuery("sp_Notifications_Generate", new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم توليد تنبيهات المتابعة بنجاح.");
            LoadSummary();
            LoadNotifications();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnMarkAllRead_Click(object sender, EventArgs e)
    {
        try
        {
            ExecuteNonQuery("sp_Notifications_MarkAllRead", new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم تعليم كل التنبيهات كمقروءة.");
            LoadSummary();
            LoadNotifications();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadSummary()
    {
        try
        {
            DataTable dt = ExecuteTable("sp_Notifications_Summary", new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            litUnreadCount.Text = Convert.ToString(r["UnreadCount"]);
            litCriticalCount.Text = Convert.ToString(r["CriticalCount"]);
            litOverdueCount.Text = Convert.ToString(r["OverdueCount"]);
            litTotalCount.Text = Convert.ToString(r["TotalCount"]);
        }
        catch { }
    }

    private void LoadNotifications()
    {
        try
        {
            gvNotifications.DataSource = ExecuteTable("sp_Notifications_Get",
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId),
                new SqlParameter("@Status", DataHelper.DbValue(ddlStatus.SelectedValue)),
                new SqlParameter("@Severity", DataHelper.DbValue(ddlSeverity.SelectedValue)),
                new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)));
            gvNotifications.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvNotifications_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        string status = null;
        if (e.CommandName == "ReadItem") status = "Read";
        if (e.CommandName == "ArchiveItem") status = "Archived";
        if (status == null) return;
        try
        {
            ExecuteNonQuery("sp_Notification_UpdateStatus",
                new SqlParameter("@NotificationId", id),
                new SqlParameter("@Status", status),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            LoadSummary();
            LoadNotifications();
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
