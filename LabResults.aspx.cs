using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class LabResults : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long QueryBoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }
    private long QuerySampleId { get { return DataHelper.GetQueryId(Request, "SampleId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("LabResults.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjectsDropDowns();
            LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadFilterBoreholes();
            if (QueryBoreholeId > 0) SetSelected(ddlFilterBorehole, QueryBoreholeId);
            LoadFilterSamples();
            if (QuerySampleId > 0) SetSelected(ddlFilterSample, QuerySampleId);
            LoadLabResults();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("LabResults.Create");
    }

    private void LoadProjectsDropDowns()
    {
        DataTable dt = GetProjects();
        BindProjectDropDown(ddlProject, dt, true);
        BindProjectDropDown(ddlFilterProject, dt, true);
    }

    private DataTable GetProjects()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private void BindProjectDropDown(DropDownList ddl, DataTable dt, bool addEmpty)
    {
        ddl.DataSource = dt;
        ddl.DataTextField = "ProjectName";
        ddl.DataValueField = "ProjectId";
        ddl.DataBind();
        if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadLookups()
    {
        BindLookup(ddlLabTestType, "LabTestType", true);
        BindLookup(ddlResultStatus, "LabResultStatus", true);
    }

    private void BindLookup(DropDownList ddl, string categoryCode, bool addEmpty)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryCode", categoryCode);
            cmd.Parameters.AddWithValue("@OnlyActive", true);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddl.DataSource = dt;
            ddl.DataTextField = "NameAr";
            ddl.DataValueField = "LookupItemId";
            ddl.DataBind();
            if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر --", ""));
        }
    }

    private void LoadFormBoreholes() { BindBoreholes(ddlBorehole, DataHelper.SelectedLong(ddlProject), true); }
    private void LoadFilterBoreholes() { BindBoreholes(ddlFilterBorehole, DataHelper.SelectedLong(ddlFilterProject), true); }

    private void BindBoreholes(DropDownList ddl, long? projectId, bool addEmpty)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Boreholes_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(projectId));
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddl.DataSource = dt;
            ddl.DataTextField = "BoreholeCode";
            ddl.DataValueField = "BoreholeId";
            ddl.DataBind();
            if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر الجسة --", ""));
        }
    }

    private void LoadFormSamples() { BindSamples(ddlSample, DataHelper.SelectedLong(ddlProject), DataHelper.SelectedLong(ddlBorehole), true); }
    private void LoadFilterSamples() { BindSamples(ddlFilterSample, DataHelper.SelectedLong(ddlFilterProject), DataHelper.SelectedLong(ddlFilterBorehole), true); }

    private void BindSamples(DropDownList ddl, long? projectId, long? boreholeId, bool addEmpty)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Samples_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(projectId));
            cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.DbValue(boreholeId));
            cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            ddl.DataSource = dt;
            ddl.DataTextField = "SampleCode";
            ddl.DataValueField = "SampleId";
            ddl.DataBind();
            if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر العينة --", ""));
        }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFormBoreholes(); LoadFormSamples(); }
    protected void ddlBorehole_SelectedIndexChanged(object sender, EventArgs e) { LoadFormSamples(); }
    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFilterBoreholes(); LoadFilterSamples(); LoadLabResults(); }
    protected void ddlFilterBorehole_SelectedIndexChanged(object sender, EventArgs e) { LoadFilterSamples(); LoadLabResults(); }
    protected void ddlFilterSample_SelectedIndexChanged(object sender, EventArgs e) { LoadLabResults(); }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadLabResults(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { txtSearch.Text = string.Empty; ddlFilterProject.SelectedIndex = 0; LoadFilterBoreholes(); LoadFilterSamples(); LoadLabResults(); }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); HideMessage(); }

    private void LoadLabResults()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LabResults_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
                cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterBorehole)));
                cmd.Parameters.AddWithValue("@SampleId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterSample)));
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvLabResults.DataSource = dt;
                gvLabResults.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("LabResults.Create")) { ShowError("لا تملك صلاحية إضافة نتيجة معملية."); return; }
        ClearForm();
        if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value);
        else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
        LoadFormBoreholes();
        if (DataHelper.SelectedLong(ddlFilterBorehole).HasValue) SetSelected(ddlBorehole, DataHelper.SelectedLong(ddlFilterBorehole).Value);
        else if (QueryBoreholeId > 0) SetSelected(ddlBorehole, QueryBoreholeId);
        LoadFormSamples();
        if (DataHelper.SelectedLong(ddlFilterSample).HasValue) SetSelected(ddlSample, DataHelper.SelectedLong(ddlFilterSample).Value);
        else if (QuerySampleId > 0) SetSelected(ddlSample, QuerySampleId);
        litFormTitle.Text = "إضافة نتيجة معملية";
        pnlForm.Visible = true;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long id; long.TryParse(hfLabTestResultId.Value, out id);
            bool isNew = id <= 0;
            if (isNew && !SecurityHelper.HasPermission("LabResults.Create")) { ShowError("لا تملك صلاحية إضافة نتيجة معملية."); return; }
            if (!isNew && !SecurityHelper.HasPermission("LabResults.Edit")) { ShowError("لا تملك صلاحية تعديل نتيجة معملية."); return; }

            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LabResult_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LabTestResultId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.SelectedLong(ddlBorehole).Value);
                cmd.Parameters.AddWithValue("@SampleId", DataHelper.SelectedLong(ddlSample).Value);
                cmd.Parameters.AddWithValue("@LabTestTypeId", DataHelper.SelectedLong(ddlLabTestType).Value);
                cmd.Parameters.AddWithValue("@TestCode", DataHelper.DbValue(txtTestCode.Text));
                cmd.Parameters.AddWithValue("@TestStandard", DataHelper.DbValue(txtTestStandard.Text));
                cmd.Parameters.AddWithValue("@TestDate", DataHelper.DbValue(ParseDate(txtTestDate.Text)));
                cmd.Parameters.AddWithValue("@ResultStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlResultStatus)));
                cmd.Parameters.AddWithValue("@NumericValue", DataHelper.DbValue(ParseDecimal(txtNumericValue.Text)));
                cmd.Parameters.AddWithValue("@Unit", DataHelper.DbValue(txtUnit.Text));
                cmd.Parameters.AddWithValue("@ResultValue", DataHelper.DbValue(txtResultValue.Text));
                cmd.Parameters.AddWithValue("@ResultText", DataHelper.DbValue(txtResultText.Text));
                cmd.Parameters.AddWithValue("@Technician", DataHelper.DbValue(txtTechnician.Text));
                cmd.Parameters.AddWithValue("@ReviewedBy", DataHelper.DbValue(txtReviewedBy.Text));
                cmd.Parameters.AddWithValue("@IsApproved", chkIsApproved.Checked);
                cmd.Parameters.AddWithValue("@Remarks", DataHelper.DbValue(txtRemarks.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                hfLabTestResultId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ النتيجة المعملية بنجاح.");
            pnlForm.Visible = false;
            SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value);
            LoadFilterBoreholes(); SetSelected(ddlFilterBorehole, DataHelper.SelectedLong(ddlBorehole).Value);
            LoadFilterSamples(); SetSelected(ddlFilterSample, DataHelper.SelectedLong(ddlSample).Value);
            LoadLabResults();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvLabResults_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadForEdit(id);
        else if (e.CommandName == "DeleteItem") DeleteLabResult(id);
        else if (e.CommandName == "ApproveItem") ApproveLabResult(id);
    }

    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("LabResults.Edit")) { ShowError("لا تملك صلاحية تعديل نتيجة معملية."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LabResult_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LabTestResultId", id);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("النتيجة غير موجودة."); return; }
                DataRow r = dt.Rows[0];
                hfLabTestResultId.Value = Convert.ToString(r["LabTestResultId"]);
                SetSelected(ddlProject, r["ProjectId"]); LoadFormBoreholes(); SetSelected(ddlBorehole, r["BoreholeId"]); LoadFormSamples(); SetSelected(ddlSample, r["SampleId"]);
                SetSelected(ddlLabTestType, r["LabTestTypeId"]); txtTestCode.Text = Convert.ToString(r["TestCode"]); txtTestStandard.Text = Convert.ToString(r["TestStandard"]);
                txtTestDate.Text = FormatDate(r["TestDate"]); SetSelected(ddlResultStatus, r["ResultStatusId"]);
                txtNumericValue.Text = FormatDecimal(r["NumericValue"]); txtUnit.Text = Convert.ToString(r["Unit"]); txtResultValue.Text = Convert.ToString(r["ResultValue"]);
                txtResultText.Text = Convert.ToString(r["ResultText"]); txtTechnician.Text = Convert.ToString(r["Technician"]); txtReviewedBy.Text = Convert.ToString(r["ReviewedBy"]);
                chkIsApproved.Checked = r["IsApproved"] != DBNull.Value && Convert.ToBoolean(r["IsApproved"]);
                txtRemarks.Text = Convert.ToString(r["Remarks"]);
                litFormTitle.Text = "تعديل نتيجة معملية"; pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteLabResult(long id)
    {
        if (!SecurityHelper.HasPermission("LabResults.Delete")) { ShowError("لا تملك صلاحية حذف نتيجة معملية."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LabResult_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LabTestResultId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف النتيجة منطقيًا."); LoadLabResults();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ApproveLabResult(long id)
    {
        if (!SecurityHelper.HasPermission("LabResults.Approve")) { ShowError("لا تملك صلاحية اعتماد نتيجة معملية."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_LabResult_Approve", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LabTestResultId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم اعتماد النتيجة المعملية."); LoadLabResults();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; }
        if (!DataHelper.SelectedLong(ddlBorehole).HasValue) { ShowError("اختيار الجسة مطلوب."); return false; }
        if (!DataHelper.SelectedLong(ddlSample).HasValue) { ShowError("اختيار العينة مطلوب."); return false; }
        if (!DataHelper.SelectedLong(ddlLabTestType).HasValue) { ShowError("نوع الاختبار مطلوب."); return false; }
        decimal? numericValue = ParseDecimal(txtNumericValue.Text);
        if (!string.IsNullOrWhiteSpace(txtNumericValue.Text) && !numericValue.HasValue) { ShowError("القيمة الرقمية يجب أن تكون رقمًا صحيحًا."); return false; }
        return true;
    }

    private void ClearForm()
    {
        hfLabTestResultId.Value = string.Empty;
        if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0;
        ddlBorehole.Items.Clear(); ddlBorehole.Items.Insert(0, new ListItem("-- اختر الجسة --", ""));
        ddlSample.Items.Clear(); ddlSample.Items.Insert(0, new ListItem("-- اختر العينة --", ""));
        if (ddlLabTestType.Items.Count > 0) ddlLabTestType.SelectedIndex = 0;
        txtTestCode.Text = string.Empty; txtTestStandard.Text = string.Empty; txtTestDate.Text = string.Empty;
        if (ddlResultStatus.Items.Count > 0) ddlResultStatus.SelectedIndex = 0;
        txtNumericValue.Text = string.Empty; txtUnit.Text = string.Empty; txtResultValue.Text = string.Empty; txtResultText.Text = string.Empty;
        txtTechnician.Text = string.Empty; txtReviewedBy.Text = string.Empty; chkIsApproved.Checked = false; txtRemarks.Text = string.Empty;
    }

    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.###"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
