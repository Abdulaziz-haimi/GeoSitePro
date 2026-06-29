using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class Dashboard : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Dashboard.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadDashboard();
        }
    }

    private void ApplyPermissions()
    {
        lnkNewProject.Visible = SecurityHelper.HasPermission("Projects.Create");
        lnkProjects.Visible = SecurityHelper.HasPermission("Projects.View");
    }

    private void LoadDashboard()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Dashboard_GetSummary", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count > 0) BindSummary(ds.Tables[0]);
                if (ds.Tables.Count > 1) { gvRecentProjects.DataSource = ds.Tables[1]; gvRecentProjects.DataBind(); }
                if (ds.Tables.Count > 2) { gvProjectStatus.DataSource = ds.Tables[2]; gvProjectStatus.DataBind(); }
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindSummary(DataTable dt)
    {
        if (dt == null || dt.Rows.Count == 0) return;
        DataRow row = dt.Rows[0];
        litTotalProjects.Text = DataHelper.ToInt(row, "TotalProjects").ToString();
        litActiveProjects.Text = DataHelper.ToInt(row, "ActiveProjects").ToString();
        litTotalBoreholes.Text = DataHelper.ToInt(row, "TotalBoreholes").ToString();
        litTotalLabTests.Text = DataHelper.ToInt(row, "TotalLabTests").ToString();
        litTotalReports.Text = DataHelper.ToInt(row, "TotalReports").ToString();
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = message;
    }
}
