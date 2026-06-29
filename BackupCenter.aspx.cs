using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;

public partial class BackupCenter : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Backup.View");
        if (!IsPostBack) { BindLists(); BindJobs(); }
    }

    private void BindLists()
    {
        ddlBackupType.Items.Clear();
        ddlBackupType.Items.Add("FULL");
        ddlBackupType.Items.Add("DIFFERENTIAL");
        ddlBackupType.Items.Add("LOG");
        ddlBackupType.Items.Add("EXPORT_PACKAGE");
    }

    protected void btnCreateBackupRequest_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Backup.Create");
        try
        {
            string cmd = BuildBackupCommand();
            DataTable dt = ExecuteTable("sp_BackupJob_Create",
                new SqlParameter("@BackupType", ddlBackupType.SelectedValue),
                new SqlParameter("@BackupPath", txtBackupPath.Text.Trim()),
                new SqlParameter("@Description", DataHelper.DbValue(txtDescription.Text)),
                new SqlParameter("@BackupCommand", cmd),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            BindJobs();
            pnlCommand.Visible = true; litBackupCommand.Text = Server.HtmlEncode(cmd);
            ShowSuccess("تم إنشاء طلب النسخ الاحتياطي وتوليد أمر SQL.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnGenerateCommand_Click(object sender, EventArgs e)
    {
        try { pnlCommand.Visible = true; litBackupCommand.Text = Server.HtmlEncode(BuildBackupCommand()); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private string BuildBackupCommand()
    {
        string backupPath = string.IsNullOrWhiteSpace(txtBackupPath.Text) ? @"C:\GeoSiteProBackups" : txtBackupPath.Text.Trim().TrimEnd('\\');
        string stamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string typ = ddlBackupType.SelectedValue;
        string ext = typ == "EXPORT_PACKAGE" ? ".zip" : ".bak";
        string file = backupPath + "\\GeoSitePro_" + typ + "_" + stamp + ext;
        if (typ == "LOG")
            return "BACKUP LOG [GeoSitePro] TO DISK = N'" + file.Replace("'", "''") + "' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;";
        if (typ == "DIFFERENTIAL")
            return "BACKUP DATABASE [GeoSitePro] TO DISK = N'" + file.Replace("'", "''") + "' WITH DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM, STATS = 10;";
        if (typ == "EXPORT_PACKAGE")
            return "-- Export package is generated from GeoSitePro Export Center. Suggested file: " + file;
        return "BACKUP DATABASE [GeoSitePro] TO DISK = N'" + file.Replace("'", "''") + "' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;";
    }

    private void BindJobs()
    {
        gvBackupJobs.DataSource = ExecuteTable("sp_BackupJobs_Get");
        gvBackupJobs.DataBind();
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
