using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class PasswordPolicy : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Security.Policy");
        if (!IsPostBack) LoadPolicy();
    }

    protected void btnReload_Click(object sender, EventArgs e) { LoadPolicy(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Security.Policy");
        try
        {
            ExecuteScalar("sp_PasswordPolicy_Save",
                new SqlParameter("@PolicyId", ParseLong(hfPolicyId.Value).HasValue ? (object)ParseLong(hfPolicyId.Value).Value : DBNull.Value),
                new SqlParameter("@MinLength", ParseInt(txtMinLength.Text, 10)),
                new SqlParameter("@RequireUppercase", chkUpper.Checked),
                new SqlParameter("@RequireLowercase", chkLower.Checked),
                new SqlParameter("@RequireNumber", chkNumber.Checked),
                new SqlParameter("@RequireSpecial", chkSpecial.Checked),
                new SqlParameter("@ExpiryDays", ParseInt(txtExpiryDays.Text, 90)),
                new SqlParameter("@MaxFailedAttempts", ParseInt(txtMaxFailed.Text, 5)),
                new SqlParameter("@LockoutMinutes", ParseInt(txtLockoutMinutes.Text, 15)),
                new SqlParameter("@SessionTimeoutMinutes", ParseInt(txtSessionTimeout.Text, 30)),
                new SqlParameter("@AllowRememberMe", chkAllowRememberMe.Checked),
                new SqlParameter("@ForceChangeDefaultPassword", chkForceChange.Checked),
                new SqlParameter("@IsActive", chkActive.Checked),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            LoadPolicy(); ShowSuccess("تم حفظ سياسة الأمان.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadPolicy()
    {
        DataTable dt = ExecuteTable("sp_PasswordPolicy_Get");
        if (dt.Rows.Count == 0) return;
        DataRow r = dt.Rows[0];
        hfPolicyId.Value = Convert.ToString(r["PolicyId"]);
        txtMinLength.Text = Convert.ToString(r["MinLength"]);
        chkUpper.Checked = Convert.ToBoolean(r["RequireUppercase"]);
        chkLower.Checked = Convert.ToBoolean(r["RequireLowercase"]);
        chkNumber.Checked = Convert.ToBoolean(r["RequireNumber"]);
        chkSpecial.Checked = Convert.ToBoolean(r["RequireSpecial"]);
        txtExpiryDays.Text = Convert.ToString(r["ExpiryDays"]);
        txtMaxFailed.Text = Convert.ToString(r["MaxFailedAttempts"]);
        txtLockoutMinutes.Text = Convert.ToString(r["LockoutMinutes"]);
        txtSessionTimeout.Text = Convert.ToString(r["SessionTimeoutMinutes"]);
        chkAllowRememberMe.Checked = Convert.ToBoolean(r["AllowRememberMe"]);
        chkForceChange.Checked = Convert.ToBoolean(r["ForceChangeDefaultPassword"]);
        chkActive.Checked = Convert.ToBoolean(r["IsActive"]);
    }

    private DataTable ExecuteTable(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt;
        }
    }

    private object ExecuteScalar(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open(); return cmd.ExecuteScalar();
        }
    }

    private int ParseInt(string value, int defaultValue) { int v; return int.TryParse(value, out v) ? v : defaultValue; }
    private long? ParseLong(string value) { long v; if (long.TryParse(value, out v) && v > 0) return v; return null; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = Server.HtmlEncode(message); }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
