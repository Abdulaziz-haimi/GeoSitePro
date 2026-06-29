using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

public partial class Login : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && SecurityHelper.IsAuthenticated)
            Response.Redirect("~/Dashboard.aspx");
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        HideMessage();
        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text;

        if (string.IsNullOrWhiteSpace(username)) { ShowError("اسم الدخول مطلوب."); return; }
        if (string.IsNullOrWhiteSpace(password)) { ShowError("كلمة المرور مطلوبة."); return; }

        try
        {
            DataSet ds = GetLoginData(username);
            if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                RecordFailedLogin(username, "اسم الدخول غير موجود.");
                ShowError("بيانات الدخول غير صحيحة.");
                return;
            }

            DataRow userRow = ds.Tables[0].Rows[0];
            bool isActive = userRow["IsActive"] != DBNull.Value && Convert.ToBoolean(userRow["IsActive"]);
            if (!isActive) { ShowError("هذا المستخدم غير نشط."); return; }

            if (!PasswordHasher.VerifyPassword(password, Convert.ToString(userRow["PasswordHash"]), Convert.ToString(userRow["PasswordSalt"])))
            {
                RecordFailedLogin(username, "كلمة مرور غير صحيحة.");
                ShowError("بيانات الدخول غير صحيحة.");
                return;
            }

            long userId = Convert.ToInt64(userRow["UserId"]);
            string fullName = Convert.ToString(userRow["FullName"]);
            List<string> permissions = new List<string>();

            if (ds.Tables.Count > 1)
            {
                foreach (DataRow row in ds.Tables[1].Rows)
                {
                    string code = Convert.ToString(row["PermissionCode"]);
                    if (!string.IsNullOrWhiteSpace(code)) permissions.Add(code);
                }
            }

            SecurityHelper.SetUserSession(userId, username, fullName, permissions);
            RecordSuccessfulLogin(userId, username);

            string returnUrl = Request.QueryString["ReturnUrl"];
            if (!string.IsNullOrWhiteSpace(returnUrl) && IsLocalUrl(returnUrl)) Response.Redirect(returnUrl, false);
            else Response.Redirect("~/Dashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            ShowError(Server.HtmlEncode(ex.Message));
        }
    }

    private DataSet GetLoginData(string username)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Login", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Username", username);
            DataSet ds = new DataSet();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
            return ds;
        }
    }

    private void RecordSuccessfulLogin(long userId, string username)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.Users SET LastLoginAt = SYSDATETIME() WHERE UserId = @UserId;
INSERT INTO dbo.UserSessions(UserId, SessionToken, LoginAt, IpAddress, UserAgent, IsActive)
VALUES(@UserId, @SessionToken, SYSDATETIME(), @IpAddress, @UserAgent, 1);
INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, IpAddress, UserAgent)
VALUES(@UserId, @Username, N'Login', N'Users', CONVERT(NVARCHAR(100), @UserId), N'تم تسجيل الدخول بنجاح.', @IpAddress, @UserAgent);", con))
        {
            cmd.Parameters.AddWithValue("@UserId", userId);
            cmd.Parameters.AddWithValue("@Username", username);
            cmd.Parameters.AddWithValue("@SessionToken", Session.SessionID);
            cmd.Parameters.AddWithValue("@IpAddress", GetIpAddress());
            cmd.Parameters.AddWithValue("@UserAgent", GetUserAgent());
            con.Open(); cmd.ExecuteNonQuery();
        }
    }

    private void RecordFailedLogin(string username, string reason)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.AuditLogs(UserId, Username, ActionType, EntityName, EntityId, ActionDescription, IpAddress, UserAgent)
VALUES(NULL, @Username, N'Login', N'Users', NULL, @Reason, @IpAddress, @UserAgent);", con))
            {
                cmd.Parameters.AddWithValue("@Username", username);
                cmd.Parameters.AddWithValue("@Reason", reason);
                cmd.Parameters.AddWithValue("@IpAddress", GetIpAddress());
                cmd.Parameters.AddWithValue("@UserAgent", GetUserAgent());
                con.Open(); cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private string GetIpAddress()
    {
        string forwarded = Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!string.IsNullOrWhiteSpace(forwarded)) return forwarded.Split(',')[0].Trim();
        return Request.UserHostAddress ?? string.Empty;
    }

    private string GetUserAgent()
    {
        string ua = Request.UserAgent ?? string.Empty;
        return ua.Length > 1000 ? ua.Substring(0, 1000) : ua;
    }

    private bool IsLocalUrl(string url)
    {
        if (string.IsNullOrWhiteSpace(url)) return false;
        return (url.StartsWith("/") && !url.StartsWith("//") && !url.StartsWith("/\\")) || url.StartsWith("~/");
    }

    private void ShowError(string message) { pnlMessage.Visible = true; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
