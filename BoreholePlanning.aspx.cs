using System;
public partial class BoreholePlanning : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("BoreholePlanning.View");
    }
}
