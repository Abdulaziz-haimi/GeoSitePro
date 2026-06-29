using System;
public partial class DeskStudy : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("DeskStudy.View");
    }
}
