using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ProductionReadiness : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("ProductionReadiness.View");
        if (!IsPostBack) { btnSeed.Visible = SecurityHelper.HasPermission("ProductionReadiness.Edit"); LoadLookups(); LoadReadiness(); }
    }
    private void LoadLookups() { BindLookup(ddlReadinessArea, GetLookup("ReadinessArea"), "-- اختر المحور --"); BindLookup(ddlReadinessStatus, GetLookup("ReadinessStatus"), "-- اختر الحالة --"); }
    private DataTable GetLookup(string category) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", category); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; } }
    private void BindLookup(DropDownList ddl, DataTable dt, string emptyText) { ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }
    private void LoadReadiness() { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProductionReadiness_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); gvReadiness.DataSource = dt; gvReadiness.DataBind(); } }
    protected void btnSeed_Click(object sender, EventArgs e) { ExecuteNoId("sp_ProductionReadiness_SeedDefaults"); LoadReadiness(); ShowSuccess("تمت إضافة قائمة الجاهزية الافتراضية."); }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("ProductionReadiness.Edit")) { ShowError("لا تملك صلاحية التعديل."); return; }
        if (string.IsNullOrWhiteSpace(txtCheckItem.Text)) { ShowError("اكتب بند الجاهزية."); return; }
        using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProductionReadiness_Save", con))
        { long id; cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ReadinessCheckId", long.TryParse(hfReadinessCheckId.Value, out id) ? (object)id : DBNull.Value); cmd.Parameters.AddWithValue("@ReadinessAreaId", DataHelper.DbValue(DataHelper.SelectedLong(ddlReadinessArea))); cmd.Parameters.AddWithValue("@CheckItem", DataHelper.DbValue(txtCheckItem.Text)); cmd.Parameters.AddWithValue("@ReadinessStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlReadinessStatus))); cmd.Parameters.AddWithValue("@Evidence", DataHelper.DbValue(txtEvidence.Text)); cmd.Parameters.AddWithValue("@Owner", DataHelper.DbValue(txtOwner.Text)); cmd.Parameters.AddWithValue("@ReviewedDate", DataHelper.DbValue(ParseDate(txtReviewedDate.Text))); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); }
        ClearForm(); LoadReadiness(); ShowSuccess("تم حفظ بند الجاهزية.");
    }
    protected void btnClearForm_Click(object sender, EventArgs e) { ClearForm(); }
    protected void gvReadiness_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadItem(id);
        if (e.CommandName == "DeleteItem") { if (!SecurityHelper.HasPermission("ProductionReadiness.Edit")) { ShowError("لا تملك صلاحية الحذف."); return; } ExecuteWithId("sp_ProductionReadiness_Delete", id); LoadReadiness(); ShowSuccess("تم حذف البند."); }
    }
    private void LoadItem(long id)
    { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_ProductionReadiness_GetById", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ReadinessCheckId", id); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); if (dt.Rows.Count == 0) return; DataRow r = dt.Rows[0]; hfReadinessCheckId.Value = Convert.ToString(r["ReadinessCheckId"]); SetSelected(ddlReadinessArea, r["ReadinessAreaId"]); SetSelected(ddlReadinessStatus, r["ReadinessStatusId"]); txtCheckItem.Text = Convert.ToString(r["CheckItem"]); txtEvidence.Text = Convert.ToString(r["Evidence"]); txtOwner.Text = Convert.ToString(r["Owner"]); txtReviewedDate.Text = FormatDate(r["ReviewedDate"]); } }
    private void ExecuteWithId(string proc, long id) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ReadinessCheckId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } }
    private void ExecuteNoId(string proc) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } }
    private void ClearForm() { hfReadinessCheckId.Value = ""; if (ddlReadinessArea.Items.Count > 0) ddlReadinessArea.SelectedIndex = 0; if (ddlReadinessStatus.Items.Count > 0) ddlReadinessStatus.SelectedIndex = 0; txtCheckItem.Text = txtEvidence.Text = txtOwner.Text = txtReviewedDate.Text = ""; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d.Date : null; }
    private string FormatDate(object value) { if (value == DBNull.Value || value == null) return ""; DateTime d; return DateTime.TryParse(Convert.ToString(value), out d) ? d.ToString("yyyy-MM-dd") : ""; }
    private void SetSelected(DropDownList ddl, object value) { ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; } }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
