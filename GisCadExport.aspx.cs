using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class GisCadExport : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("GisCadExport.View");
        if (!IsPostBack)
        {
            LoadProjects();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadPageData();
        }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadPageData(); }
    protected void btnRefresh_Click(object sender, EventArgs e) { LoadPageData(); }

    private void LoadProjects()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddlProject.DataSource = dt;
            ddlProject.DataTextField = "ProjectName";
            ddlProject.DataValueField = "ProjectId";
            ddlProject.DataBind();
            ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
        }
    }

    private void LoadPageData()
    {
        long? projectId = DataHelper.SelectedLong(ddlProject);
        pnlProject.Visible = projectId.HasValue;
        if (!projectId.HasValue) return;
        SetDownloadLinks(projectId.Value);
        gvPoints.DataSource = ExecuteTable("sp_Export_GIS_BoreholePoints", projectId.Value);
        gvPoints.DataBind();
        gvSections.DataSource = ExecuteTable("sp_Export_CrossSectionSummary", projectId.Value);
        gvSections.DataBind();
    }

    private void SetDownloadLinks(long projectId)
    {
        bool canExport = SecurityHelper.HasPermission("GisCadExport.Export");
        SetLink(lnkGisPoints, projectId, "GIS_BOREHOLE_POINTS", canExport);
        SetLink(lnkGisLayers, projectId, "GIS_LAYER_INTERVALS", canExport);
        SetLink(lnkCadPoints, projectId, "CAD_POINT_SCHEDULE", canExport);
        SetLink(lnkCrossSectionLayers, projectId, "CROSS_SECTION_LAYERS", canExport);
    }

    private void SetLink(HyperLink link, long projectId, string dataset, bool visible)
    {
        link.NavigateUrl = "~/DataExportDownload.aspx?ProjectId=" + projectId + "&Dataset=" + dataset;
        link.Target = "_blank";
        link.Visible = visible;
    }

    private DataTable ExecuteTable(string proc, long projectId)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", projectId);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }
}
