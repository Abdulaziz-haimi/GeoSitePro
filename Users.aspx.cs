using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Users : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Users.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadRolesChecklist();
            LoadUsers();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Users.Create");
    }

    private void LoadRolesChecklist()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Roles_Dropdown_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            cblRoles.DataSource = dt;
            cblRoles.DataTextField = "RoleName";
            cblRoles.DataValueField = "RoleId";
            cblRoles.DataBind();
        }
    }

    private void LoadUsers()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Users_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                cmd.Parameters.AddWithValue("@IsActive", ParseNullableBool(ddlFilterStatus.SelectedValue));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvUsers.DataSource = dt;
                gvUsers.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Users.Create")) { ShowError("لا تملك صلاحية إضافة مستخدم."); return; }
        ClearForm();
        litFormTitle.Text = "إضافة مستخدم";
        litPasswordHint.Text = "<span class='gsp-required'>*</span>";
        pnlForm.Visible = true;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        pnlForm.Visible = false;
        ClearForm();
    }

    protected void btnSearch_Click(object sender, EventArgs e) { LoadUsers(); }

    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        ddlFilterStatus.SelectedIndex = 0;
        LoadUsers();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        long id;
        long.TryParse(hfUserId.Value, out id);
        bool isNew = id <= 0;
        if (isNew && !SecurityHelper.HasPermission("Users.Create")) { ShowError("لا تملك صلاحية إضافة مستخدم."); return; }
        if (!isNew && !SecurityHelper.HasPermission("Users.Edit")) { ShowError("لا تملك صلاحية تعديل مستخدم."); return; }
        if (!ValidateForm(isNew)) return;

        string passwordHash = null;
        string passwordSalt = null;
        if (!string.IsNullOrWhiteSpace(txtPassword.Text))
            PasswordHasher.CreatePasswordHash(txtPassword.Text, out passwordHash, out passwordSalt);

        try
        {
            long savedUserId;
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_User_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@Username", DataHelper.DbValue(txtUsername.Text));
                cmd.Parameters.AddWithValue("@FullName", DataHelper.DbValue(txtFullName.Text));
                cmd.Parameters.AddWithValue("@Email", DataHelper.DbValue(txtEmail.Text));
                cmd.Parameters.AddWithValue("@Mobile", DataHelper.DbValue(txtMobile.Text));
                cmd.Parameters.AddWithValue("@PasswordHash", string.IsNullOrWhiteSpace(passwordHash) ? (object)DBNull.Value : passwordHash);
                cmd.Parameters.AddWithValue("@PasswordSalt", string.IsNullOrWhiteSpace(passwordSalt) ? (object)DBNull.Value : passwordSalt);
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open();
                savedUserId = Convert.ToInt64(cmd.ExecuteScalar());
            }

            SaveUserRoles(savedUserId);
            ShowSuccess("تم حفظ بيانات المستخدم والأدوار بنجاح.");
            pnlForm.Visible = false;
            ClearForm();
            LoadUsers();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadForEdit(id);
        else if (e.CommandName == "DeleteItem") DeleteUser(id);
        else if (e.CommandName == "ResetPassword") ResetPassword(id);
    }

    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("Users.Edit")) { ShowError("لا تملك صلاحية تعديل المستخدم."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_User_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", id);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المستخدم غير موجود."); return; }
                DataRow r = ds.Tables[0].Rows[0];
                hfUserId.Value = Convert.ToString(r["UserId"]);
                txtUsername.Text = Convert.ToString(r["Username"]);
                txtFullName.Text = Convert.ToString(r["FullName"]);
                txtEmail.Text = Convert.ToString(r["Email"]);
                txtMobile.Text = Convert.ToString(r["Mobile"]);
                chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
                txtPassword.Text = string.Empty;
                txtConfirmPassword.Text = string.Empty;
                ClearRoleSelection();
                if (ds.Tables.Count > 1)
                {
                    foreach (DataRow rr in ds.Tables[1].Rows)
                    {
                        ListItem item = cblRoles.Items.FindByValue(Convert.ToString(rr["RoleId"]));
                        if (item != null) item.Selected = true;
                    }
                }
                litFormTitle.Text = "تعديل مستخدم";
                litPasswordHint.Text = "<span class='gsp-muted'>(اتركها فارغة للإبقاء على كلمة المرور الحالية)</span>";
                pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void SaveUserRoles(long userId)
    {
        foreach (ListItem item in cblRoles.Items)
        {
            long roleId;
            if (!long.TryParse(item.Value, out roleId)) continue;
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_UserRole_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TargetUserId", userId);
                cmd.Parameters.AddWithValue("@RoleId", roleId);
                cmd.Parameters.AddWithValue("@IsAssigned", item.Selected);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
        }
    }

    private void DeleteUser(long id)
    {
        if (!SecurityHelper.HasPermission("Users.Delete")) { ShowError("لا تملك صلاحية حذف المستخدم."); return; }
        if (id == SecurityHelper.CurrentUserId) { ShowError("لا يمكن حذف المستخدم الحالي أثناء تسجيل الدخول."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_User_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", id);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف المستخدم منطقيًا.");
            LoadUsers();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ResetPassword(long id)
    {
        if (!SecurityHelper.HasPermission("Users.ResetPassword")) { ShowError("لا تملك صلاحية إعادة تعيين كلمة المرور."); return; }
        try
        {
            string hash, salt;
            PasswordHasher.CreatePasswordHash("Admin@123", out hash, out salt);
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_User_ResetPassword", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", id);
                cmd.Parameters.AddWithValue("@PasswordHash", hash);
                cmd.Parameters.AddWithValue("@PasswordSalt", salt);
                cmd.Parameters.AddWithValue("@ActorUserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تمت إعادة كلمة المرور إلى: Admin@123");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm(bool isNew)
    {
        if (string.IsNullOrWhiteSpace(txtUsername.Text)) { ShowError("اسم الدخول مطلوب."); return false; }
        if (string.IsNullOrWhiteSpace(txtFullName.Text)) { ShowError("الاسم الكامل مطلوب."); return false; }
        if (isNew && string.IsNullOrWhiteSpace(txtPassword.Text)) { ShowError("كلمة المرور مطلوبة عند إنشاء مستخدم جديد."); return false; }
        if (!string.IsNullOrWhiteSpace(txtPassword.Text) && txtPassword.Text != txtConfirmPassword.Text) { ShowError("كلمة المرور وتأكيدها غير متطابقين."); return false; }
        return true;
    }

    private object ParseNullableBool(string value)
    {
        if (string.IsNullOrWhiteSpace(value)) return DBNull.Value;
        return value == "1";
    }

    private void ClearForm()
    {
        hfUserId.Value = string.Empty;
        txtUsername.Text = string.Empty; txtFullName.Text = string.Empty; txtEmail.Text = string.Empty; txtMobile.Text = string.Empty;
        txtPassword.Text = string.Empty; txtConfirmPassword.Text = string.Empty; chkIsActive.Checked = true;
        ClearRoleSelection();
    }

    private void ClearRoleSelection()
    {
        foreach (ListItem item in cblRoles.Items) item.Selected = false;
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message;
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message;
    }
}
