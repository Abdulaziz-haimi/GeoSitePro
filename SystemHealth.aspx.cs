using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class SystemHealth : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SystemHealth.View");
        if (!IsPostBack) LoadHealth();
    }

    protected void btnRefresh_Click(object sender, EventArgs e) { LoadHealth(); }

    protected void btnLogHealthCheck_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SystemHealth.Run");
        try
        {
            ExecuteNonQuery("sp_SystemOperationLog_Create",
                new SqlParameter("@LogLevel", "Info"),
                new SqlParameter("@ModuleName", "SystemHealth"),
                new SqlParameter("@ActionName", "ManualHealthCheck"),
                new SqlParameter("@EntityName", "System"),
                new SqlParameter("@EntityId", DBNull.Value),
                new SqlParameter("@Message", "Manual system health check executed."),
                new SqlParameter("@Details", DBNull.Value),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            LoadHealth(); ShowSuccess("تم تسجيل فحص التشغيل.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadHealth()
    {
        try
        {
            DataSet ds = ExecuteDataSet("sp_SystemHealth_Get");
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow r = ds.Tables[0].Rows[0];
                litRequiredTables.Text = Convert.ToString(r["RequiredTables"]);
                litMissingTables.Text = Convert.ToString(r["MissingTables"]);
                litActiveSettings.Text = Convert.ToString(r["ActiveSettings"]);
                litBackupJobs.Text = Convert.ToString(r["BackupJobs"]);
            }
            if (ds.Tables.Count > 1) { gvHealthChecks.DataSource = ds.Tables[1]; gvHealthChecks.DataBind(); }
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

    private long? ParseLong(string value)
    {
        long v;
        if (long.TryParse(value, out v) && v > 0) return v;
        return null;
    }

    private DateTime? ParseDate(string value)
    {
        DateTime v;
        if (DateTime.TryParse(value, out v)) return v.Date;
        return null;
    }

}
