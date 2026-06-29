using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class RolePermissions : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryRoleId { get { return DataHelper.GetQueryId(Request, "RoleId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Roles.Permissions");
        if (!IsPostBack)
        {
            LoadRoles();
            if (QueryRoleId > 0) SetSelected(ddlRole, QueryRoleId);
            LoadPermissions();
        }
    }

    private void LoadRoles()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Roles_Dropdown_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddlRole.DataSource = dt;
            ddlRole.DataTextField = "RoleName";
            ddlRole.DataValueField = "RoleId";
            ddlRole.DataBind();
            ddlRole.Items.Insert(0, new ListItem("-- اختر الدور --", ""));
        }
    }

    protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e) { LoadPermissions(); }

    private void LoadPermissions()
    {
        long? roleId = DataHelper.SelectedLong(ddlRole);
        if (!roleId.HasValue)
        {
            gvPermissions.DataSource = null;
            gvPermissions.DataBind();
            return;
        }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_RolePermissions_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleId", roleId.Value);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvPermissions.DataSource = dt;
                gvPermissions.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Roles.Permissions")) { ShowError("لا تملك صلاحية تعديل صلاحيات الأدوار."); return; }
        long? roleId = DataHelper.SelectedLong(ddlRole);
        if (!roleId.HasValue) { ShowError("اختر الدور أولًا."); return; }

        try
        {
            foreach (GridViewRow row in gvPermissions.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                long permissionId = Convert.ToInt64(gvPermissions.DataKeys[row.RowIndex].Value);
                CheckBox chk = row.FindControl("chkGranted") as CheckBox;
                bool granted = chk != null && chk.Checked;
                using (SqlConnection con = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand("sp_RolePermission_Save", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleId", roleId.Value);
                    cmd.Parameters.AddWithValue("@PermissionId", permissionId);
                    cmd.Parameters.AddWithValue("@IsGranted", granted);
                    cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                    con.Open(); cmd.ExecuteNonQuery();
                }
            }
            ShowSuccess("تم حفظ صلاحيات الدور بنجاح. سيحتاج المستخدمون لتسجيل الدخول مرة أخرى حتى تظهر الصلاحيات الجديدة في الجلسة.");
            LoadPermissions();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        if (value == null || value == DBNull.Value) return;
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
