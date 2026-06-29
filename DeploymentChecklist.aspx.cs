using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class DeploymentChecklist : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("DeploymentChecklist.View");
        if (!IsPostBack) { BindLists(); ClearForm(); BindSummary(); BindGrid(); }
    }

    private void BindLists()
    {
        string[] areas = new string[] { "Security", "Database", "Backup", "Deployment", "Testing", "Performance", "Reporting", "Workflow", "DataProtection", "Operations" };
        ddlArea.Items.Clear(); ddlFilterArea.Items.Clear(); ddlFilterArea.Items.Add(new ListItem("كل المجالات", ""));
        foreach (string a in areas) { ddlArea.Items.Add(new ListItem(a, a)); ddlFilterArea.Items.Add(new ListItem(a, a)); }
        string[] statuses = new string[] { "Not Started", "In Progress", "Completed", "Blocked", "Not Applicable" };
        ddlStatus.Items.Clear(); ddlFilterStatus.Items.Clear(); ddlFilterStatus.Items.Add(new ListItem("كل الحالات", ""));
        foreach (string s in statuses) { ddlStatus.Items.Add(new ListItem(s, s)); ddlFilterStatus.Items.Add(new ListItem(s, s)); }
    }

    protected void btnSeed_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("DeploymentChecklist.Manage");
        try { ExecuteNonQuery("sp_DeploymentChecklist_SeedDefaults", new SqlParameter("@UserId", SecurityHelper.CurrentUserId)); BindSummary(); BindGrid(); ShowSuccess("تمت إضافة البنود الافتراضية أو تحديثها."); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("DeploymentChecklist.Manage");
        if (string.IsNullOrWhiteSpace(txtItemCode.Text) || string.IsNullOrWhiteSpace(txtItemTitle.Text)) { ShowError("الكود والعنوان مطلوبان."); return; }
        try
        {
            ExecuteScalar("sp_DeploymentChecklist_Save",
                new SqlParameter("@ItemId", ParseLong(hfItemId.Value).HasValue ? (object)ParseLong(hfItemId.Value).Value : DBNull.Value),
                new SqlParameter("@Area", ddlArea.SelectedValue),
                new SqlParameter("@ItemCode", txtItemCode.Text.Trim()),
                new SqlParameter("@ItemTitle", txtItemTitle.Text.Trim()),
                new SqlParameter("@Description", DataHelper.DbValue(txtDescription.Text)),
                new SqlParameter("@RequiredForProduction", chkRequired.Checked),
                new SqlParameter("@Status", ddlStatus.SelectedValue),
                new SqlParameter("@EvidenceNotes", DataHelper.DbValue(txtEvidence.Text)),
                new SqlParameter("@ResponsiblePerson", DataHelper.DbValue(txtResponsible.Text)),
                new SqlParameter("@IsActive", chkActive.Checked),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ClearForm(); BindSummary(); BindGrid(); ShowSuccess("تم حفظ البند.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }
    protected void btnSearch_Click(object sender, EventArgs e) { BindGrid(); }

    protected void gvItems_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditRow") LoadForEdit(id);
        if (e.CommandName == "DeleteRow") DeleteItem(id);
    }

    private void LoadForEdit(long id)
    {
        DataTable dt = ExecuteTable("sp_DeploymentChecklist_GetById", new SqlParameter("@ItemId", id));
        if (dt.Rows.Count == 0) { ShowError("لم يتم العثور على البند."); return; }
        DataRow r = dt.Rows[0];
        hfItemId.Value = Convert.ToString(r["ItemId"]);
        SetSelected(ddlArea, r["Area"]); txtItemCode.Text = Convert.ToString(r["ItemCode"]); txtItemTitle.Text = Convert.ToString(r["ItemTitle"]);
        txtDescription.Text = Convert.ToString(r["Description"]); SetSelected(ddlStatus, r["Status"]); txtEvidence.Text = Convert.ToString(r["EvidenceNotes"]);
        txtResponsible.Text = Convert.ToString(r["ResponsiblePerson"]); chkRequired.Checked = Convert.ToBoolean(r["RequiredForProduction"]); chkActive.Checked = Convert.ToBoolean(r["IsActive"]);
    }

    private void DeleteItem(long id)
    {
        SecurityHelper.RequirePermission("DeploymentChecklist.Manage");
        try { ExecuteNonQuery("sp_DeploymentChecklist_Delete", new SqlParameter("@ItemId", id), new SqlParameter("@UserId", SecurityHelper.CurrentUserId)); BindSummary(); BindGrid(); ShowSuccess("تم حذف البند."); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindSummary()
    {
        DataTable dt = ExecuteTable("sp_DeploymentChecklist_Summary");
        if (dt.Rows.Count == 0) return;
        DataRow r = dt.Rows[0];
        litTotal.Text = Convert.ToString(r["TotalItems"]); litCompleted.Text = Convert.ToString(r["CompletedItems"]); litOpen.Text = Convert.ToString(r["OpenItems"]); litScore.Text = Convert.ToString(r["ReadinessScore"]) + "%";
    }

    private void BindGrid()
    {
        gvItems.DataSource = ExecuteTable("sp_DeploymentChecklist_Get", new SqlParameter("@Area", DataHelper.DbValue(ddlFilterArea.SelectedValue)), new SqlParameter("@Status", DataHelper.DbValue(ddlFilterStatus.SelectedValue)));
        gvItems.DataBind();
    }

    private void ClearForm()
    {
        hfItemId.Value = ""; txtItemCode.Text = ""; txtItemTitle.Text = ""; txtDescription.Text = ""; txtEvidence.Text = ""; txtResponsible.Text = ""; chkRequired.Checked = true; chkActive.Checked = true;
        if (ddlArea.Items.Count > 0) ddlArea.SelectedIndex = 0; if (ddlStatus.Items.Count > 0) ddlStatus.SelectedIndex = 0;
    }

    private void SetSelected(DropDownList ddl, object value) { ListItem li = ddl.Items.FindByValue(Convert.ToString(value)); if (li != null) { ddl.ClearSelection(); li.Selected = true; } }
    private long? ParseLong(string value) { long v; if (long.TryParse(value, out v) && v > 0) return v; return null; }

    private DataTable ExecuteTable(string proc, params SqlParameter[] parameters) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; if (parameters != null) cmd.Parameters.AddRange(parameters); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; } }
    private object ExecuteScalar(string proc, params SqlParameter[] parameters) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; if (parameters != null) cmd.Parameters.AddRange(parameters); con.Open(); return cmd.ExecuteScalar(); } }
    private void ExecuteNonQuery(string proc, params SqlParameter[] parameters) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; if (parameters != null) cmd.Parameters.AddRange(parameters); con.Open(); cmd.ExecuteNonQuery(); } }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = Server.HtmlEncode(message); }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
