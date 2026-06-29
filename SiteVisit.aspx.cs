using System;
public partial class SiteVisit : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SiteVisit.View");
    }
}
