using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Roles : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Roles.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadRoles();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Roles.Create");
    }

    private void LoadRoles()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Roles_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                cmd.Parameters.AddWithValue("@IsActive", ParseNullableBool(ddlFilterStatus.SelectedValue));
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvRoles.DataSource = dt; gvRoles.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Roles.Create")) { ShowError("لا تملك صلاحية إضافة دور."); return; }
        ClearForm(); litFormTitle.Text = "إضافة دور"; pnlForm.Visible = true;
    }

    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadRoles(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { txtSearch.Text = string.Empty; ddlFilterStatus.SelectedIndex = 0; LoadRoles(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        long id; long.TryParse(hfRoleId.Value, out id);
        if (id <= 0 && !SecurityHelper.HasPermission("Roles.Create")) { ShowError("لا تملك صلاحية إضافة دور."); return; }
        if (id > 0 && !SecurityHelper.HasPermission("Roles.Edit")) { ShowError("لا تملك صلاحية تعديل دور."); return; }
        if (string.IsNullOrWhiteSpace(txtRoleName.Text)) { ShowError("اسم الدور مطلوب."); return; }

        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Role_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@RoleName", DataHelper.DbValue(txtRoleName.Text));
                cmd.Parameters.AddWithValue("@Description", DataHelper.DbValue(txtDescription.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open(); hfRoleId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ الدور بنجاح."); pnlForm.Visible = false; ClearForm(); LoadRoles();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvRoles_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadForEdit(id);
        else if (e.CommandName == "DeleteItem") DeleteRole(id);
    }

    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("Roles.Edit")) { ShowError("لا تملك صلاحية تعديل الدور."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Role_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleId", id);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("الدور غير موجود."); return; }
                DataRow r = dt.Rows[0];
                hfRoleId.Value = Convert.ToString(r["RoleId"]);
                txtRoleName.Text = Convert.ToString(r["RoleName"]);
                txtDescription.Text = Convert.ToString(r["Description"]);
                chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
                litFormTitle.Text = "تعديل دور"; pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteRole(long id)
    {
        if (!SecurityHelper.HasPermission("Roles.Delete")) { ShowError("لا تملك صلاحية حذف الدور."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Role_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoleId", id);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف الدور منطقيًا."); LoadRoles();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private object ParseNullableBool(string value) { if (string.IsNullOrWhiteSpace(value)) return DBNull.Value; return value == "1"; }
    private void ClearForm() { hfRoleId.Value = string.Empty; txtRoleName.Text = string.Empty; txtDescription.Text = string.Empty; chkIsActive.Checked = true; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
