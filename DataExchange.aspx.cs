using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

public partial class DataExchange : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("DataExchange.View");
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
        DataTable dt;
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
        }
        ddlProject.DataSource = dt;
        ddlProject.DataTextField = "ProjectName";
        ddlProject.DataValueField = "ProjectId";
        ddlProject.DataBind();
        ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadPageData()
    {
        long? projectId = DataHelper.SelectedLong(ddlProject);
        pnlProject.Visible = projectId.HasValue;
        if (!projectId.HasValue)
        {
            litOverview.Text = "";
            gvHistory.DataSource = null;
            gvHistory.DataBind();
            return;
        }
        SetExportLinks(projectId.Value);
        LoadOverview(projectId.Value);
        LoadHistory(projectId.Value);
    }

    private void LoadOverview(long projectId)
    {
        DataTable dt = ExecuteTable("sp_DataExchange_ProjectOverview", new SqlParameter("@ProjectId", projectId));
        if (dt.Rows.Count == 0) { litOverview.Text = ""; return; }
        DataRow r = dt.Rows[0];
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='gsp-grid gsp-grid-4'>");
        AppendStat(sb, "المشروع", Html(r["ProjectCode"]) + "<br/><span class='gsp-muted'>" + Html(r["ProjectName"]) + "</span>");
        AppendStat(sb, "الجسات", Html(r["BoreholeCount"]));
        AppendStat(sb, "العينات", Html(r["SampleCount"]));
        AppendStat(sb, "SPT", Html(r["SPTCount"]));
        AppendStat(sb, "المياه الجوفية", Html(r["GroundwaterCount"]));
        AppendStat(sb, "نتائج المختبر", Html(r["LabResultCount"]));
        AppendStat(sb, "نقاط الخريطة", Html(r["LayoutPointCount"]));
        AppendStat(sb, "نظام الإحداثيات", Html(r["CoordinateSystem"]) + "<br/><span class='gsp-muted'>EPSG: " + Html(r["EPSGCode"]) + "</span>");
        sb.Append("</div>");
        litOverview.Text = sb.ToString();
    }

    private void AppendStat(StringBuilder sb, string label, object value)
    {
        sb.Append("<div class='gsp-stat'><div class='gsp-stat-label'>");
        sb.Append(Server.HtmlEncode(label));
        sb.Append("</div><div class='gsp-stat-value' style='font-size:18px'>");
        sb.Append(value);
        sb.Append("</div></div>");
    }

    private string Html(object value)
    {
        if (value == null || value == DBNull.Value) return "-";
        return Server.HtmlEncode(Convert.ToString(value));
    }

    private void LoadHistory(long projectId)
    {
        DataTable dt = ExecuteTable("sp_DataExportJobs_Get", new SqlParameter("@ProjectId", projectId));
        gvHistory.DataSource = dt;
        gvHistory.DataBind();
    }

    private void SetExportLinks(long projectId)
    {
        SetDownload(lnkExportBoreholes, projectId, "BOREHOLES");
        SetDownload(lnkExportLayers, projectId, "BOREHOLE_LAYERS");
        SetDownload(lnkExportSamples, projectId, "SAMPLES");
        SetDownload(lnkExportSPT, projectId, "SPT");
        SetDownload(lnkExportGroundwater, projectId, "GROUNDWATER");
        SetDownload(lnkExportLab, projectId, "LAB_RESULTS");
        SetDownload(lnkExportReports, projectId, "REPORTS_INDEX");
    }

    private void SetDownload(HyperLink link, long projectId, string dataset)
    {
        link.NavigateUrl = "~/DataExportDownload.aspx?ProjectId=" + projectId + "&Dataset=" + dataset;
        link.Target = "_blank";
        link.Visible = SecurityHelper.HasPermission("DataExchange.Export");
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

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }
}
