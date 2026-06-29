using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class SecurityCenter : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Security.View");
        if (!IsPostBack)
        {
            BindLists();
            BindDashboard();
            BindEvents();
        }
    }

    private void BindLists()
    {
        ddlEventType.Items.Clear();
        string[] types = new string[] { "LOGIN_SUCCESS", "LOGIN_FAILED", "PASSWORD_CHANGE", "PERMISSION_CHANGE", "SESSION_TIMEOUT", "CONFIG_CHANGE", "SECURITY_REVIEW", "MANUAL_NOTE" };
        foreach (string t in types) ddlEventType.Items.Add(new ListItem(t, t));

        ddlSeverity.Items.Clear(); ddlFilterSeverity.Items.Clear();
        ddlFilterSeverity.Items.Add(new ListItem("كل المستويات", ""));
        string[] severities = new string[] { "Info", "Warning", "High", "Critical" };
        foreach (string s in severities)
        {
            ddlSeverity.Items.Add(new ListItem(s, s));
            ddlFilterSeverity.Items.Add(new ListItem(s, s));
        }
    }

    protected void btnRefresh_Click(object sender, EventArgs e) { BindDashboard(); BindEvents(); }
    protected void btnSearch_Click(object sender, EventArgs e) { BindEvents(); }

    protected void btnLogEvent_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Security.Manage");
        if (string.IsNullOrWhiteSpace(txtMessage.Text)) { ShowError("رسالة الحدث مطلوبة."); return; }
        try
        {
            ExecuteNonQuery("sp_SecurityEvent_Log",
                new SqlParameter("@EventType", ddlEventType.SelectedValue),
                new SqlParameter("@Severity", ddlSeverity.SelectedValue),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId > 0 ? (object)SecurityHelper.CurrentUserId : DBNull.Value),
                new SqlParameter("@Username", DataHelper.DbValue(txtUsername.Text)),
                new SqlParameter("@IpAddress", Request.UserHostAddress),
                new SqlParameter("@UserAgent", Request.UserAgent ?? string.Empty),
                new SqlParameter("@EntityName", DataHelper.DbValue(txtEntityName.Text)),
                new SqlParameter("@EntityId", DBNull.Value),
                new SqlParameter("@Message", txtMessage.Text.Trim()),
                new SqlParameter("@Details", DataHelper.DbValue(txtDetails.Text)));
            txtMessage.Text = ""; txtDetails.Text = ""; txtUsername.Text = ""; txtEntityName.Text = "";
            BindDashboard(); BindEvents(); ShowSuccess("تم حفظ الحدث الأمني.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindDashboard()
    {
        DataSet ds = ExecuteDataSet("sp_SecurityDashboard_Get");
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            DataRow r = ds.Tables[0].Rows[0];
            litEvents7.Text = Convert.ToString(r["EventsLast7Days"]);
            litCritical.Text = Convert.ToString(r["CriticalEvents"]);
            litFailedLogins.Text = Convert.ToString(r["FailedLogins"]);
            litOpenChecklist.Text = Convert.ToString(r["OpenProductionItems"]);
        }
    }

    private void BindEvents()
    {
        gvEvents.DataSource = ExecuteTable("sp_SecurityEvents_Get",
            new SqlParameter("@Severity", DataHelper.DbValue(ddlFilterSeverity.SelectedValue)),
            new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)),
            new SqlParameter("@Top", 100));
        gvEvents.DataBind();
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

    private DataSet ExecuteDataSet(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataSet ds = new DataSet();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
            return ds;
        }
    }

    private void ExecuteNonQuery(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open(); cmd.ExecuteNonQuery();
        }
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = Server.HtmlEncode(message);
    }
    private void ShowError(string message)
    {
        pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message;
    }
}
