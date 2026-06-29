using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI.WebControls;

public partial class Site : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequireLogin();
        if (!IsPostBack)
        {
            litCurrentUser.Text = Server.HtmlEncode(SecurityHelper.CurrentFullName);
            ApplyNavigationPermissions();
            MarkActiveLink();
        }
    }

    private void ApplyNavigationPermissions()
    {
        lnkDashboard.Visible = SecurityHelper.HasPermission("Dashboard.View");
        lnkProjects.Visible = SecurityHelper.HasPermission("Projects.View");
        lnkBoreholes.Visible = SecurityHelper.HasPermission("Boreholes.View");
        lnkBoreholeLog.Visible = SecurityHelper.HasPermission("BoreholeLog.View");
        lnkSamples.Visible = SecurityHelper.HasPermission("Samples.View");
        lnkSPTTests.Visible = SecurityHelper.HasPermission("SPT.View");
        lnkGroundwater.Visible = SecurityHelper.HasPermission("Groundwater.View");
        lnkLabResults.Visible = SecurityHelper.HasPermission("LabResults.View");
        lnkReports.Visible = SecurityHelper.HasPermission("Reports.View");
        lnkStandards.Visible = SecurityHelper.HasPermission("Standards.View");
        lnkQualityChecks.Visible = SecurityHelper.HasPermission("QualityChecks.View");
        lnkCalculations.Visible = SecurityHelper.HasPermission("Calculations.View");
        lnkSiteMap.Visible = SecurityHelper.HasPermission("SiteMap.View");
        lnkCrossSections.Visible = SecurityHelper.HasPermission("CrossSections.View");
        lnkInvestigationTemplates.Visible = SecurityHelper.HasPermission("InvestigationTemplates.View");
        lnkProjectInvestigationPlan.Visible = SecurityHelper.HasPermission("ProjectInvestigationPlan.View");
        lnkDataExchange.Visible = SecurityHelper.HasPermission("DataExchange.View");
        lnkGisCadExport.Visible = SecurityHelper.HasPermission("GisCadExport.View");
        lnkPrintableOutputs.Visible = SecurityHelper.HasPermission("PrintOutputs.View");
        lnkProjectDocuments.Visible = SecurityHelper.HasPermission("ProjectDocuments.View");
        lnkExportCenter.Visible = SecurityHelper.HasPermission("ExportCenter.View");
        lnkProductionReadiness.Visible = SecurityHelper.HasPermission("ProductionReadiness.View");
        lnkUsers.Visible = SecurityHelper.HasPermission("Users.View");
        lnkRoles.Visible = SecurityHelper.HasPermission("Roles.View");
        lnkRolePermissions.Visible = SecurityHelper.HasPermission("Roles.Permissions");
        lnkAuditLog.Visible = SecurityHelper.HasPermission("AuditLog.View");
    }

    private void MarkActiveLink()
    {
        string currentPath = VirtualPathUtility.ToAppRelative(Request.Path);
        SetActive(lnkDashboard, currentPath);
        SetActive(lnkProjects, currentPath);
        SetActive(lnkBoreholes, currentPath);
        SetActive(lnkBoreholeLog, currentPath);
        SetActive(lnkSamples, currentPath);
        SetActive(lnkSPTTests, currentPath);
        SetActive(lnkGroundwater, currentPath);
        SetActive(lnkLabResults, currentPath);
        SetActive(lnkReports, currentPath);
        SetActive(lnkStandards, currentPath);
        SetActive(lnkQualityChecks, currentPath);
        SetActive(lnkCalculations, currentPath);
        SetActive(lnkSiteMap, currentPath);
        SetActive(lnkCrossSections, currentPath);
        SetActive(lnkInvestigationTemplates, currentPath);
        SetActive(lnkProjectInvestigationPlan, currentPath);
        SetActive(lnkDataExchange, currentPath);
        SetActive(lnkGisCadExport, currentPath);
        SetActive(lnkPrintableOutputs, currentPath);
        SetActive(lnkProjectDocuments, currentPath);
        SetActive(lnkExportCenter, currentPath);
        SetActive(lnkProductionReadiness, currentPath);
        SetActive(lnkUsers, currentPath);
        SetActive(lnkRoles, currentPath);
        SetActive(lnkRolePermissions, currentPath);
        SetActive(lnkAuditLog, currentPath);
    }

    private void SetActive(HyperLink link, string currentPath)
    {
        if (link == null) return;
        string linkPath = VirtualPathUtility.ToAppRelative(link.NavigateUrl);
        link.CssClass = string.Equals(currentPath, linkPath, StringComparison.OrdinalIgnoreCase) ? "nav-link active" : "nav-link";
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        RecordLogout();
        SecurityHelper.ClearUserSession();
        Response.Redirect("~/Login.aspx");
    }

    private void RecordLogout()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.UserSessions SET LogoutAt = SYSDATETIME(), IsActive = 0
WHERE UserId = @UserId AND SessionToken = @SessionToken AND IsActive = 1;
INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription)
VALUES(@UserId, @Username, N'Logout', N'Users', CONVERT(NVARCHAR(100), @UserId), N'تم تسجيل الخروج.');", con))
            {
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                cmd.Parameters.AddWithValue("@Username", SecurityHelper.CurrentUsername);
                cmd.Parameters.AddWithValue("@SessionToken", Session.SessionID);
                con.Open(); cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }
}
