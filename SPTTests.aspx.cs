using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class SPTTests : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long QueryBoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SPT.View");
        if (!IsPostBack)
        {
            ApplyPermissions(); LoadProjectsDropDowns();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadFilterBoreholes(); if (QueryBoreholeId > 0) SetSelected(ddlFilterBorehole, QueryBoreholeId);
            LoadSPTTests();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("SPT.Create"); }
    private void LoadProjectsDropDowns() { DataTable dt = GetProjects(); BindProjectDropDown(ddlProject, dt, true); BindProjectDropDown(ddlFilterProject, dt, true); }
    private DataTable GetProjects()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; }
    }
    private void BindProjectDropDown(DropDownList ddl, DataTable dt, bool addEmpty) { ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", "")); }
    private void LoadFormBoreholes() { BindBoreholes(ddlBorehole, DataHelper.SelectedLong(ddlProject), true); }
    private void LoadFilterBoreholes() { BindBoreholes(ddlFilterBorehole, DataHelper.SelectedLong(ddlFilterProject), true); }
    private void BindBoreholes(DropDownList ddl, long? projectId, bool addEmpty)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Boreholes_Get", con))
        { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(projectId)); cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddl.DataSource = dt; ddl.DataTextField = "BoreholeCode"; ddl.DataValueField = "BoreholeId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر الجسة --", "")); }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFormBoreholes(); }
    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFilterBoreholes(); LoadSPTTests(); }
    protected void ddlFilterBorehole_SelectedIndexChanged(object sender, EventArgs e) { LoadSPTTests(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { ddlFilterProject.SelectedIndex = 0; LoadFilterBoreholes(); LoadSPTTests(); }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }

    private void LoadSPTTests()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_SPTTests_Get", con))
            { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject))); cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterBorehole))); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); gvSPTTests.DataSource = dt; gvSPTTests.DataBind(); }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("SPT.Create")) { ShowError("لا تملك صلاحية إضافة اختبار SPT."); return; }
        ClearForm();
        if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value); else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
        LoadFormBoreholes();
        if (DataHelper.SelectedLong(ddlFilterBorehole).HasValue) SetSelected(ddlBorehole, DataHelper.SelectedLong(ddlFilterBorehole).Value); else if (QueryBoreholeId > 0) SetSelected(ddlBorehole, QueryBoreholeId);
        litFormTitle.Text = "إضافة اختبار SPT"; pnlForm.Visible = true;
    }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); HideMessage(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long id; long.TryParse(hfSPTTestId.Value, out id); bool isNew = id <= 0;
            if (isNew && !SecurityHelper.HasPermission("SPT.Create")) { ShowError("لا تملك صلاحية إضافة اختبار SPT."); return; }
            if (!isNew && !SecurityHelper.HasPermission("SPT.Edit")) { ShowError("لا تملك صلاحية تعديل اختبار SPT."); return; }
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_SPTTest_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SPTTestId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.SelectedLong(ddlBorehole).Value);
                cmd.Parameters.AddWithValue("@TestDepthM", ParseDecimal(txtTestDepthM.Text).Value);
                cmd.Parameters.AddWithValue("@BlowCount1", DataHelper.DbValue(ParseInt(txtBlowCount1.Text)));
                cmd.Parameters.AddWithValue("@BlowCount2", DataHelper.DbValue(ParseInt(txtBlowCount2.Text)));
                cmd.Parameters.AddWithValue("@BlowCount3", DataHelper.DbValue(ParseInt(txtBlowCount3.Text)));
                cmd.Parameters.AddWithValue("@NValue", DataHelper.DbValue(ParseInt(txtNValue.Text)));
                cmd.Parameters.AddWithValue("@HammerEnergyRatio", DataHelper.DbValue(ParseDecimal(txtHammerEnergyRatio.Text)));
                cmd.Parameters.AddWithValue("@CorrectedN", DataHelper.DbValue(ParseDecimal(txtCorrectedN.Text)));
                cmd.Parameters.AddWithValue("@RecoveryLengthM", DataHelper.DbValue(ParseDecimal(txtRecoveryLengthM.Text)));
                cmd.Parameters.AddWithValue("@TestDate", DataHelper.DbValue(ParseDate(txtTestDate.Text)));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); hfSPTTestId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ اختبار SPT بنجاح."); pnlForm.Visible = false;
            SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value); LoadFilterBoreholes(); SetSelected(ddlFilterBorehole, DataHelper.SelectedLong(ddlBorehole).Value); LoadSPTTests();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvSPTTests_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadForEdit(id); else if (e.CommandName == "DeleteItem") DeleteSPT(id);
    }

    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("SPT.Edit")) { ShowError("لا تملك صلاحية تعديل اختبار SPT."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_SPTTest_GetById", con))
            { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SPTTestId", id); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); if (dt.Rows.Count == 0) { ShowError("الاختبار غير موجود."); return; } DataRow r = dt.Rows[0]; hfSPTTestId.Value = Convert.ToString(r["SPTTestId"]); SetSelected(ddlProject, r["ProjectId"]); LoadFormBoreholes(); SetSelected(ddlBorehole, r["BoreholeId"]); txtTestDepthM.Text = FormatDecimal(r["TestDepthM"]); txtBlowCount1.Text = Convert.ToString(r["BlowCount1"]); txtBlowCount2.Text = Convert.ToString(r["BlowCount2"]); txtBlowCount3.Text = Convert.ToString(r["BlowCount3"]); txtNValue.Text = Convert.ToString(r["NValue"]); txtHammerEnergyRatio.Text = FormatDecimal(r["HammerEnergyRatio"]); txtCorrectedN.Text = FormatDecimal(r["CorrectedN"]); txtRecoveryLengthM.Text = FormatDecimal(r["RecoveryLengthM"]); txtTestDate.Text = FormatDate(r["TestDate"]); txtNotes.Text = Convert.ToString(r["Notes"]); litFormTitle.Text = "تعديل اختبار SPT"; pnlForm.Visible = true; }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteSPT(long id)
    {
        if (!SecurityHelper.HasPermission("SPT.Delete")) { ShowError("لا تملك صلاحية حذف اختبار SPT."); return; }
        try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_SPTTest_Delete", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SPTTestId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } ShowSuccess("تم حذف اختبار SPT منطقيًا."); LoadSPTTests(); }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; }
        if (!DataHelper.SelectedLong(ddlBorehole).HasValue) { ShowError("اختيار الجسة مطلوب."); return false; }
        decimal? depth = ParseDecimal(txtTestDepthM.Text); if (!depth.HasValue || depth.Value < 0) { ShowError("عمق الاختبار مطلوب ويجب أن يكون رقمًا أكبر أو يساوي صفر."); return false; }
        return true;
    }
    private void ClearForm() { hfSPTTestId.Value = string.Empty; if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; ddlBorehole.Items.Clear(); ddlBorehole.Items.Insert(0, new ListItem("-- اختر الجسة --", "")); txtTestDepthM.Text = string.Empty; txtBlowCount1.Text = string.Empty; txtBlowCount2.Text = string.Empty; txtBlowCount3.Text = string.Empty; txtNValue.Text = string.Empty; txtHammerEnergyRatio.Text = string.Empty; txtCorrectedN.Text = string.Empty; txtRecoveryLengthM.Text = string.Empty; txtTestDate.Text = string.Empty; txtNotes.Text = string.Empty; }
    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private int? ParseInt(string value) { int i; return int.TryParse(value, out i) ? (int?)i : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.##"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
