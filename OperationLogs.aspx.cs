using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class OperationLogs : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("OperationLogs.View");
        if (!IsPostBack) { BindLists(); BindGrid(); }
    }

    private void BindLists()
    {
        ddlLogLevel.Items.Clear();
        ddlLogLevel.Items.Add(new ListItem("كل المستويات", ""));
        ddlLogLevel.Items.Add("Info"); ddlLogLevel.Items.Add("Warning"); ddlLogLevel.Items.Add("Error"); ddlLogLevel.Items.Add("Critical");
    }

    protected void btnRefresh_Click(object sender, EventArgs e) { BindGrid(); }
    protected void btnSearch_Click(object sender, EventArgs e) { BindGrid(); }

    private void BindGrid()
    {
        try
        {
            gvOperationLogs.DataSource = ExecuteTable("sp_SystemOperationLogs_Get",
                new SqlParameter("@LogLevel", DataHelper.DbValue(ddlLogLevel.SelectedValue)),
                new SqlParameter("@ModuleName", DataHelper.DbValue(txtModule.Text)),
                new SqlParameter("@FromDate", (object)ParseDate(txtFromDate.Text) ?? DBNull.Value),
                new SqlParameter("@ToDate", (object)ParseDate(txtToDate.Text) ?? DBNull.Value));
            gvOperationLogs.DataBind();
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
