using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

public partial class PrintableOutputs : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("PrintOutputs.View");
        if (!IsPostBack)
        {
            LoadProjects();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadProjectOutputs();
        }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadProjectOutputs(); }
    protected void btnLoad_Click(object sender, EventArgs e) { LoadProjectOutputs(); }

    private void LoadProjects()
    {
        DataTable dt = ExecuteTable("sp_Projects_Get", new SqlParameter("@SearchText", DBNull.Value));
        ddlProject.DataSource = dt;
        ddlProject.DataTextField = "ProjectName";
        ddlProject.DataValueField = "ProjectId";
        ddlProject.DataBind();
        ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadProjectOutputs()
    {
        long? projectId = DataHelper.SelectedLong(ddlProject);
        pnlProject.Visible = projectId.HasValue;
        if (!projectId.HasValue) return;

        lnkProjectPackage.NavigateUrl = "~/ProjectPrintPackage.aspx?ProjectId=" + projectId.Value;
        lnkAllBoreholeLogs.NavigateUrl = "~/BoreholeLogPrint.aspx?ProjectId=" + projectId.Value;
        lnkProjectPackage.Visible = SecurityHelper.HasPermission("PrintOutputs.Print");
        lnkAllBoreholeLogs.Visible = SecurityHelper.HasPermission("PrintOutputs.Print");

        LoadOverview(projectId.Value);
        gvBoreholes.DataSource = ExecuteTable("sp_Print_Boreholes_Index", new SqlParameter("@ProjectId", projectId.Value));
        gvBoreholes.DataBind();
    }

    private void LoadOverview(long projectId)
    {
        DataTable dt = ExecuteTable("sp_Print_ProjectOverview", new SqlParameter("@ProjectId", projectId));
        if (dt.Rows.Count == 0) { litOverview.Text = ""; return; }
        DataRow r = dt.Rows[0];
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='gsp-grid gsp-grid-4'>");
        AppendStat(sb, "المشروع", Html(r["ProjectCode"]) + "<br/><span class='gsp-muted'>" + Html(r["ProjectName"]) + "</span>");
        AppendStat(sb, "الجسات", Html(r["BoreholeCount"]));
        AppendStat(sb, "الطبقات", Html(r["LayerCount"]));
        AppendStat(sb, "العينات", Html(r["SampleCount"]));
        AppendStat(sb, "SPT", Html(r["SPTCount"]));
        AppendStat(sb, "المياه", Html(r["GroundwaterCount"]));
        AppendStat(sb, "المختبر", Html(r["LabResultCount"]));
        AppendStat(sb, "التقارير", Html(r["ReportCount"]));
        sb.Append("</div><br/>");
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
