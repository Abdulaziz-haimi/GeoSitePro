using System;
public partial class LabTestResults : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("LabResults.View");
    }
}
