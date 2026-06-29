using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class AuditLog : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("AuditLog.View");
        if (!IsPostBack)
        {
            LoadUsers();
            LoadAuditLog();
        }
    }

    private void LoadUsers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Users_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
                cmd.Parameters.AddWithValue("@IsActive", DBNull.Value);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlUser.DataSource = dt;
                ddlUser.DataTextField = "FullName";
                ddlUser.DataValueField = "UserId";
                ddlUser.DataBind();
                ddlUser.Items.Insert(0, new ListItem("-- كل المستخدمين --", ""));
            }
        }
        catch { ddlUser.Items.Clear(); ddlUser.Items.Insert(0, new ListItem("-- كل المستخدمين --", "")); }
    }

    private void LoadAuditLog()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_AuditLogs_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                cmd.Parameters.AddWithValue("@ActionType", DataHelper.DbValue(txtActionType.Text));
                cmd.Parameters.AddWithValue("@EntityName", DataHelper.DbValue(txtEntityName.Text));
                cmd.Parameters.AddWithValue("@UserId", DataHelper.DbValue(DataHelper.SelectedLong(ddlUser)));
                cmd.Parameters.AddWithValue("@DateFrom", DataHelper.DbValue(ParseDate(txtDateFrom.Text)));
                cmd.Parameters.AddWithValue("@DateTo", DataHelper.DbValue(ParseDate(txtDateTo.Text)));
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvAuditLog.DataSource = dt;
                gvAuditLog.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadAuditLog(); }
    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty; txtActionType.Text = string.Empty; txtEntityName.Text = string.Empty; txtDateFrom.Text = string.Empty; txtDateTo.Text = string.Empty;
        if (ddlUser.Items.Count > 0) ddlUser.SelectedIndex = 0;
        LoadAuditLog();
    }

    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
