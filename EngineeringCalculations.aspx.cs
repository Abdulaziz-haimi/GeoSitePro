using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI.WebControls;

public partial class EngineeringCalculations : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Calculations.View");
        if (!IsPostBack)
        {
            ApplyPermissions(); LoadProjects(); LoadLookups(); if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId); LoadCalculations();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("Calculations.Create"); }

    private void LoadProjects()
    {
        DataTable dt;
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
        }
        BindProject(ddlProject, dt, "-- اختر المشروع --"); BindProject(ddlFilterProject, dt, "-- كل المشاريع --");
    }

    private void BindProject(DropDownList ddl, DataTable dt, string emptyText)
    { ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }

    private void LoadLookups()
    {
        DataTable dt = GetLookup("CalculationType"); BindLookup(ddlCalculationType, dt, "-- اختر نوع الحساب --"); BindLookup(ddlFilterCalculationType, dt, "-- كل الحسابات --");
    }

    private DataTable GetLookup(string category)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", category);
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt;
        }
    }
    private void BindLookup(DropDownList ddl, DataTable dt, string emptyText)
    { ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); ddl.Items.Insert(0, new ListItem(emptyText, "")); }

    private void LoadCalculations()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_EngineeringCalculations_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
            cmd.Parameters.AddWithValue("@CalculationTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterCalculationType)));
            cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            gvCalculations.DataSource = dt; gvCalculations.DataBind();
        }
    }

    protected void btnNew_Click(object sender, EventArgs e) { ClearForm(); if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId); txtCalculationDate.Text = DateTime.Today.ToString("yyyy-MM-dd"); pnlForm.Visible = true; litFormTitle.Text = "إضافة حساب"; }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadCalculations(); }
    protected void btnClear_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterProject.SelectedIndex = 0; ddlFilterCalculationType.SelectedIndex = 0; LoadCalculations(); }

    protected void btnCalculate_Click(object sender, EventArgs e)
    {
        try { CalculateSelectedType(); ShowSuccess("تم الحساب. راجع النتائج ثم اضغط حفظ."); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void CalculateSelectedType()
    {
        string type = ddlCalculationType.SelectedItem == null ? "" : ddlCalculationType.SelectedItem.Text.ToLowerInvariant();
        decimal a = D(txtInput1.Text), b = D(txtInput2.Text), c = D(txtInput3.Text), d = D(txtInput4.Text), ee = D(txtInput5.Text), f = D(txtInput6.Text);
        if (type.Contains("moisture") || type.Contains("رطوبة"))
        {
            decimal drySoil = c - a; if (drySoil == 0) throw new Exception("وزن التربة الجافة لا يمكن أن يساوي صفرًا.");
            decimal moisture = ((b - c) / drySoil) * 100m; txtResult1.Text = F(moisture); txtUnit.Text = "%"; txtResultSummary.Text = "Moisture Content = ((Wet+Container - Dry+Container) / (Dry+Container - Container)) × 100 = " + F(moisture) + "%";
        }
        else if (type.Contains("atterberg") || type.Contains("pi") || type.Contains("لدونة"))
        {
            decimal pi = a - b; txtResult1.Text = F(pi); txtUnit.Text = "%"; txtResultSummary.Text = "Plasticity Index PI = LL - PL = " + F(pi) + "%";
        }
        else if (type.Contains("spt") || type.Contains("n60"))
        {
            if (ee == 0) ee = 1; if (d == 0) d = 1; if (c == 0) c = 1; decimal cs = f == 0 ? 1 : f; decimal n60 = a * (b / 60m) * c * d * ee * cs; txtResult1.Text = F(n60); txtUnit.Text = "blows/300mm"; txtResultSummary.Text = "N60 = N × (ER/60) × CB × CR × CS = " + F(n60);
        }
        else if (type.Contains("sieve") || type.Contains("cu") || type.Contains("تدرج"))
        {
            if (a == 0) throw new Exception("D10 لا يمكن أن يساوي صفرًا."); decimal cu = c / a; decimal cc = (b * b) / (a * c); txtResult1.Text = F(cu); txtResult2.Text = F(cc); txtUnit.Text = "ratio"; txtResultSummary.Text = "Cu = D60/D10 = " + F(cu) + "; Cc = D30²/(D10×D60) = " + F(cc);
        }
        else if (type.Contains("dry") || type.Contains("density") || type.Contains("كثافة"))
        {
            decimal dry = a / (1m + (b / 100m)); txtResult1.Text = F(dry); txtUnit.Text = "same as bulk density"; txtResultSummary.Text = "Dry Density = Bulk Density / (1 + w) = " + F(dry);
        }
        else
        {
            txtResultSummary.Text = "نوع الحساب غير معروف للحساب التلقائي. يمكن إدخال النتائج يدويًا وحفظها.";
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission(string.IsNullOrEmpty(hfCalculationId.Value) ? "Calculations.Create" : "Calculations.Edit")) { ShowError("لا تملك صلاحية الحفظ."); return; }
        if (DataHelper.SelectedLong(ddlProject) == null || DataHelper.SelectedLong(ddlCalculationType) == null) { ShowError("المشروع ونوع الحساب مطلوبان."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_EngineeringCalculation_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                long id; cmd.Parameters.AddWithValue("@CalculationId", long.TryParse(hfCalculationId.Value, out id) ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@CalculationTypeId", DataHelper.SelectedLong(ddlCalculationType).Value);
                cmd.Parameters.AddWithValue("@CalculationDate", DataHelper.DbValue(ParseDate(txtCalculationDate.Text)));
                cmd.Parameters.AddWithValue("@CalculationTitle", DataHelper.DbValue(txtCalculationTitle.Text));
                cmd.Parameters.AddWithValue("@Input1", DataHelper.DbValue(ParseDecimal(txtInput1.Text))); cmd.Parameters.AddWithValue("@Input2", DataHelper.DbValue(ParseDecimal(txtInput2.Text))); cmd.Parameters.AddWithValue("@Input3", DataHelper.DbValue(ParseDecimal(txtInput3.Text))); cmd.Parameters.AddWithValue("@Input4", DataHelper.DbValue(ParseDecimal(txtInput4.Text))); cmd.Parameters.AddWithValue("@Input5", DataHelper.DbValue(ParseDecimal(txtInput5.Text))); cmd.Parameters.AddWithValue("@Input6", DataHelper.DbValue(ParseDecimal(txtInput6.Text)));
                cmd.Parameters.AddWithValue("@Result1", DataHelper.DbValue(ParseDecimal(txtResult1.Text))); cmd.Parameters.AddWithValue("@Result2", DataHelper.DbValue(ParseDecimal(txtResult2.Text))); cmd.Parameters.AddWithValue("@Result3", DataHelper.DbValue(ParseDecimal(txtResult3.Text)));
                cmd.Parameters.AddWithValue("@Unit", DataHelper.DbValue(txtUnit.Text)); cmd.Parameters.AddWithValue("@ResultSummary", DataHelper.DbValue(txtResultSummary.Text)); cmd.Parameters.AddWithValue("@CalculatedBy", DataHelper.DbValue(txtCalculatedBy.Text)); cmd.Parameters.AddWithValue("@CheckedBy", DataHelper.DbValue(txtCheckedBy.Text)); cmd.Parameters.AddWithValue("@IsApproved", chkIsApproved.Checked); cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text)); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            pnlForm.Visible = false; LoadCalculations(); ShowSuccess("تم حفظ الحساب.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvCalculations_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadCalculation(id);
        if (e.CommandName == "ApproveItem") { if (!SecurityHelper.HasPermission("Calculations.Approve")) { ShowError("لا تملك صلاحية الاعتماد."); return; } ExecuteSimple("sp_EngineeringCalculation_Approve", id); LoadCalculations(); ShowSuccess("تم اعتماد الحساب."); }
        if (e.CommandName == "DeleteItem") { if (!SecurityHelper.HasPermission("Calculations.Delete")) { ShowError("لا تملك صلاحية الحذف."); return; } ExecuteSimple("sp_EngineeringCalculation_Delete", id); LoadCalculations(); ShowSuccess("تم حذف الحساب."); }
    }

    private void LoadCalculation(long id)
    {
        if (!SecurityHelper.HasPermission("Calculations.Edit")) { ShowError("لا تملك صلاحية التعديل."); return; }
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_EngineeringCalculation_GetById", con))
        {
            cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CalculationId", id); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            if (dt.Rows.Count == 0) { ShowError("الحساب غير موجود."); return; } DataRow r = dt.Rows[0];
            hfCalculationId.Value = Convert.ToString(r["CalculationId"]); SetSelected(ddlProject, r["ProjectId"]); SetSelected(ddlCalculationType, r["CalculationTypeId"]); txtCalculationDate.Text = FormatDate(r["CalculationDate"]); txtCalculationTitle.Text = Convert.ToString(r["CalculationTitle"]); txtInput1.Text = FObj(r["Input1"]); txtInput2.Text = FObj(r["Input2"]); txtInput3.Text = FObj(r["Input3"]); txtInput4.Text = FObj(r["Input4"]); txtInput5.Text = FObj(r["Input5"]); txtInput6.Text = FObj(r["Input6"]); txtResult1.Text = FObj(r["Result1"]); txtResult2.Text = FObj(r["Result2"]); txtResult3.Text = FObj(r["Result3"]); txtUnit.Text = Convert.ToString(r["Unit"]); txtResultSummary.Text = Convert.ToString(r["ResultSummary"]); txtCalculatedBy.Text = Convert.ToString(r["CalculatedBy"]); txtCheckedBy.Text = Convert.ToString(r["CheckedBy"]); chkIsApproved.Checked = r["IsApproved"] != DBNull.Value && Convert.ToBoolean(r["IsApproved"]); txtNotes.Text = Convert.ToString(r["Notes"]); litFormTitle.Text = "تعديل حساب"; pnlForm.Visible = true;
        }
    }

    private void ExecuteSimple(string proc, long id)
    { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand(proc, con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CalculationId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } }

    private decimal D(string value) { decimal x; return decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out x) || decimal.TryParse(value, out x) ? x : 0m; }
    private string F(decimal value) { return value.ToString("0.###", CultureInfo.InvariantCulture); }
    private string FObj(object value) { return value == null || value == DBNull.Value ? "" : Convert.ToDecimal(value).ToString("0.###", CultureInfo.InvariantCulture); }
    private decimal? ParseDecimal(string value) { if (string.IsNullOrWhiteSpace(value)) return null; decimal x; return decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out x) || decimal.TryParse(value, out x) ? (decimal?)x : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d.Date : null; }
    private string FormatDate(object value) { if (value == DBNull.Value || value == null) return ""; DateTime d; return DateTime.TryParse(Convert.ToString(value), out d) ? d.ToString("yyyy-MM-dd") : ""; }
    private void SetSelected(DropDownList ddl, object value) { ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; } }
    private void ClearForm() { hfCalculationId.Value = ""; if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; if (ddlCalculationType.Items.Count > 0) ddlCalculationType.SelectedIndex = 0; txtCalculationDate.Text = ""; txtCalculationTitle.Text = ""; txtInput1.Text = txtInput2.Text = txtInput3.Text = txtInput4.Text = txtInput5.Text = txtInput6.Text = ""; txtResult1.Text = txtResult2.Text = txtResult3.Text = txtUnit.Text = txtResultSummary.Text = txtCalculatedBy.Text = txtCheckedBy.Text = txtNotes.Text = ""; chkIsApproved.Checked = false; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
