using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class ProjectDetails : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long ProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Projects.View");
        if (!IsPostBack)
        {
            if (ProjectId <= 0) { ShowError("رقم المشروع غير صحيح."); return; }
            lnkEdit.NavigateUrl = "~/Projects.aspx?edit=" + ProjectId;
            lnkProjectBoreholes.NavigateUrl = "~/Boreholes.aspx?ProjectId=" + ProjectId;
            lnkProjectBoreholeLog.NavigateUrl = "~/BoreholeLog.aspx?ProjectId=" + ProjectId;
            lnkProjectSamples.NavigateUrl = "~/Samples.aspx?ProjectId=" + ProjectId;
            lnkProjectSPT.NavigateUrl = "~/SPTTests.aspx?ProjectId=" + ProjectId;
            lnkProjectGroundwater.NavigateUrl = "~/Groundwater.aspx?ProjectId=" + ProjectId;
            lnkProjectLabResults.NavigateUrl = "~/LabResults.aspx?ProjectId=" + ProjectId;
            lnkProjectReports.NavigateUrl = "~/Reports.aspx?ProjectId=" + ProjectId;
            lnkProjectInvestigationPlan.NavigateUrl = "~/ProjectInvestigationPlan.aspx?ProjectId=" + ProjectId;
            lnkProjectQuality.NavigateUrl = "~/ProjectQualityCheck.aspx?ProjectId=" + ProjectId;
            lnkProjectSiteMap.NavigateUrl = "~/SiteMap.aspx?ProjectId=" + ProjectId;
            lnkProjectCrossSections.NavigateUrl = "~/CrossSections.aspx?ProjectId=" + ProjectId;
            lnkProjectCalculations.NavigateUrl = "~/EngineeringCalculations.aspx?ProjectId=" + ProjectId;
            lnkProjectDocuments.NavigateUrl = "~/ProjectDocuments.aspx?ProjectId=" + ProjectId;
            lnkProjectExport.NavigateUrl = "~/ExportCenter.aspx?ProjectId=" + ProjectId;
            lnkProjectDataExchange.NavigateUrl = "~/DataExchange.aspx?ProjectId=" + ProjectId;
            lnkProjectGisCad.NavigateUrl = "~/GisCadExport.aspx?ProjectId=" + ProjectId;
            lnkProjectPrintableOutputs.NavigateUrl = "~/PrintableOutputs.aspx?ProjectId=" + ProjectId;
            lnkProjectApproval.NavigateUrl = "~/ProjectApproval.aspx?ProjectId=" + ProjectId;
            lnkProjectFollowUp.NavigateUrl = "~/FollowUpBoard.aspx?ProjectId=" + ProjectId;
            lnkProjectRisks.NavigateUrl = "~/ProjectRiskRegister.aspx?ProjectId=" + ProjectId;
            lnkProjectKpis.NavigateUrl = "~/QualityKpiDashboard.aspx?ProjectId=" + ProjectId;
            LoadProject();
        }
    }

    private void LoadProject()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectDashboard_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", ProjectId);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }
                BindHeader(ds.Tables[0].Rows[0]);
                if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0) BindCounts(ds.Tables[1].Rows[0]);
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindHeader(DataRow r)
    {
        litProjectName.Text = Server.HtmlEncode(Convert.ToString(r["ProjectName"]));
        litProjectMeta.Text = Server.HtmlEncode(Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["City"]) + " - " + Convert.ToString(r["LocationName"]));
        litProjectCode.Text = Server.HtmlEncode(Convert.ToString(r["ProjectCode"]));
        litClientName.Text = Server.HtmlEncode(Convert.ToString(r["ClientName"]));
        litProjectType.Text = Server.HtmlEncode(Convert.ToString(r["ProjectTypeNameAr"]));
        litStructureType.Text = Server.HtmlEncode(Convert.ToString(r["StructureTypeNameAr"]));
        litCity.Text = Server.HtmlEncode(Convert.ToString(r["City"]));
        litLocationName.Text = Server.HtmlEncode(Convert.ToString(r["LocationName"]));
        litSiteArea.Text = Server.HtmlEncode(Convert.ToString(r["SiteAreaM2"]));
        litFloors.Text = Server.HtmlEncode(Convert.ToString(r["NumberOfFloors"]) + " / " + Convert.ToString(r["BasementCount"]));
    }

    private void BindCounts(DataRow r)
    {
        litBoreholePlanCount.Text = DataHelper.ToInt(r, "BoreholePlanCount").ToString();
        litBoreholeCount.Text = DataHelper.ToInt(r, "BoreholeCount").ToString();
        litSampleCount.Text = DataHelper.ToInt(r, "SampleCount").ToString();
        litLabTestCount.Text = DataHelper.ToInt(r, "LabTestCount").ToString();
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = message;
    }
}
