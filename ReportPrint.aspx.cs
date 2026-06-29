using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class ReportPrint : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long ReportId { get { return DataHelper.GetQueryId(Request, "ReportId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Reports.View");
        if (!IsPostBack)
        {
            if (ReportId <= 0) { ShowError("رقم التقرير غير صحيح."); return; }
            lnkBack.NavigateUrl = "~/ReportEditor.aspx?ReportId=" + ReportId;
            LoadReport();
        }
    }

    private void LoadReport()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_GetFullData", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", ReportId);
                DataSet ds = new DataSet(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("التقرير غير موجود."); return; }
                BindHeader(ds.Tables[0].Rows[0]);
                if (ds.Tables.Count > 1) { rptSections.DataSource = ds.Tables[1]; rptSections.DataBind(); }
                if (ds.Tables.Count > 2) { gvBoreholes.DataSource = ds.Tables[2]; gvBoreholes.DataBind(); }
                if (ds.Tables.Count > 3) { gvLayers.DataSource = ds.Tables[3]; gvLayers.DataBind(); }
                if (ds.Tables.Count > 4) { gvSPT.DataSource = ds.Tables[4]; gvSPT.DataBind(); }
                if (ds.Tables.Count > 5) { gvGroundwater.DataSource = ds.Tables[5]; gvGroundwater.DataBind(); }
                if (ds.Tables.Count > 6) { gvSamples.DataSource = ds.Tables[6]; gvSamples.DataBind(); }
                if (ds.Tables.Count > 7) { gvLabResults.DataSource = ds.Tables[7]; gvLabResults.DataBind(); }
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindHeader(DataRow r)
    {
        litReportTitle.Text = Server.HtmlEncode(Convert.ToString(r["ReportTitle"]));
        litReportMeta.Text = Server.HtmlEncode(Convert.ToString(r["ReportTypeNameAr"]) + " - " + Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["ProjectName"]));
        litReportNo.Text = Server.HtmlEncode(Convert.ToString(r["ReportNo"]));
        litRevisionNo.Text = Server.HtmlEncode(Convert.ToString(r["RevisionNo"]));
        litIssueDate.Text = FormatDate(r["IssueDate"]);
        litPreparedBy.Text = Server.HtmlEncode(Convert.ToString(r["PreparedBy"]));
        litReviewedBy.Text = Server.HtmlEncode(Convert.ToString(r["ReviewedBy"]));
        litApprovedBy.Text = Server.HtmlEncode(Convert.ToString(r["ApprovedBy"]));
        litExecutiveSummary.Text = Server.HtmlEncode(Convert.ToString(r["ExecutiveSummary"]));
        litProjectInfo.Text = Server.HtmlEncode(
            "Project Code: " + Convert.ToString(r["ProjectCode"]) + "\n" +
            "Project Name: " + Convert.ToString(r["ProjectName"]) + "\n" +
            "Client: " + Convert.ToString(r["ClientName"]) + "\n" +
            "City: " + Convert.ToString(r["City"]) + "\n" +
            "Location: " + Convert.ToString(r["LocationName"]) + "\n" +
            "Site Area: " + Convert.ToString(r["SiteAreaM2"]) + " m²\n" +
            "Floors / Basements: " + Convert.ToString(r["NumberOfFloors"]) + " / " + Convert.ToString(r["BasementCount"]));
    }

    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private void ShowError(string message) { pnlMessage.Visible = true; litMessage.Text = message; }
}
