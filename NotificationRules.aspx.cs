using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class NotificationRules : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Notifications.Manage");
        if (!IsPostBack) LoadRules();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtRuleCode.Text) || string.IsNullOrWhiteSpace(txtRuleNameAr.Text)) { ShowError("كود القاعدة واسمها مطلوبان."); return; }
        int daysOffset; if (!int.TryParse(txtDaysOffset.Text, out daysOffset)) daysOffset = 0;
        long id = 0; long.TryParse(hfNotificationRuleId.Value, out id);
        try
        {
            ExecuteScalar("sp_NotificationRule_Save",
                new SqlParameter("@NotificationRuleId", id == 0 ? (object)DBNull.Value : id),
                new SqlParameter("@RuleCode", txtRuleCode.Text.Trim()),
                new SqlParameter("@RuleNameAr", txtRuleNameAr.Text.Trim()),
                new SqlParameter("@RuleType", ddlRuleType.SelectedValue),
                new SqlParameter("@EntityType", ddlEntityType.SelectedValue),
                new SqlParameter("@DaysOffset", daysOffset),
                new SqlParameter("@Severity", ddlSeverity.SelectedValue),
                new SqlParameter("@MessageTemplate", DataHelper.DbValue(txtMessageTemplate.Text)),
                new SqlParameter("@IsActive", chkIsActive.Checked),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم حفظ قاعدة التنبيه.");
            ClearForm();
            LoadRules();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    private void LoadRules()
    {
        try
        {
            gvRules.DataSource = ExecuteTable("sp_NotificationRules_Get", new SqlParameter("@RuleType", DBNull.Value));
            gvRules.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvRules_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (e.CommandName != "EditItem" || !long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        try
        {
            DataTable dt = ExecuteTable("sp_NotificationRule_GetById", new SqlParameter("@NotificationRuleId", id));
            if (dt.Rows.Count > 0) BindForm(dt.Rows[0]);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindForm(DataRow r)
    {
        hfNotificationRuleId.Value = Convert.ToString(r["NotificationRuleId"]);
        txtRuleCode.Text = Convert.ToString(r["RuleCode"]);
        txtRuleNameAr.Text = Convert.ToString(r["RuleNameAr"]);
        SetSelected(ddlRuleType, r["RuleType"]);
        SetSelected(ddlEntityType, r["EntityType"]);
        txtDaysOffset.Text = Convert.ToString(r["DaysOffset"]);
        SetSelected(ddlSeverity, r["Severity"]);
        txtMessageTemplate.Text = Convert.ToString(r["MessageTemplate"]);
        chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
    }

    private void ClearForm()
    {
        hfNotificationRuleId.Value = ""; txtRuleCode.Text = ""; txtRuleNameAr.Text = ""; txtMessageTemplate.Text = ""; txtDaysOffset.Text = "0"; chkIsActive.Checked = true;
        ddlRuleType.SelectedValue = "FOLLOWUP_DUE"; ddlEntityType.SelectedValue = "FOLLOWUP"; ddlSeverity.SelectedValue = "Info";
    }

    private DataTable ExecuteTable(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private object ExecuteScalar(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            return cmd.ExecuteScalar();
        }
    }

    private void ExecuteNonQuery(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-success";
        litMessage.Text = Server.HtmlEncode(message);
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

}
