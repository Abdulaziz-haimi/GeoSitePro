using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Samples : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long QueryBoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Samples.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjectsDropDowns();
            LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadFilterBoreholes();
            if (QueryBoreholeId > 0) SetSelected(ddlFilterBorehole, QueryBoreholeId);
            LoadSamples();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("Samples.Create"); }

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
        ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind();
        if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void LoadLookups()
    {
        BindLookup(ddlSampleType, "SampleType", true);
        BindLookup(ddlSampleQuality, "SampleQuality", true);
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
            ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind();
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
            ddl.DataSource = dt; ddl.DataTextField = "BoreholeCode"; ddl.DataValueField = "BoreholeId"; ddl.DataBind();
            if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر الجسة --", ""));
        }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFormBoreholes(); }
    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFilterBoreholes(); LoadSamples(); }
    protected void ddlFilterBorehole_SelectedIndexChanged(object sender, EventArgs e) { LoadSamples(); }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadSamples(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { txtSearch.Text = string.Empty; ddlFilterProject.SelectedIndex = 0; LoadFilterBoreholes(); LoadSamples(); }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }

    private void LoadSamples()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Samples_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
                cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterBorehole)));
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvSamples.DataSource = dt; gvSamples.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("Samples.Create")) { ShowError("لا تملك صلاحية إضافة عينة."); return; }
        ClearForm();
        if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value);
        else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
        LoadFormBoreholes();
        if (DataHelper.SelectedLong(ddlFilterBorehole).HasValue) SetSelected(ddlBorehole, DataHelper.SelectedLong(ddlFilterBorehole).Value);
        else if (QueryBoreholeId > 0) SetSelected(ddlBorehole, QueryBoreholeId);
        litFormTitle.Text = "إضافة عينة";
        pnlForm.Visible = true;
    }

    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); HideMessage(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long sampleId; long.TryParse(hfSampleId.Value, out sampleId);
            bool isNew = sampleId <= 0;
            if (isNew && !SecurityHelper.HasPermission("Samples.Create")) { ShowError("لا تملك صلاحية إضافة عينة."); return; }
            if (!isNew && !SecurityHelper.HasPermission("Samples.Edit")) { ShowError("لا تملك صلاحية تعديل العينة."); return; }

            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Sample_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SampleId", sampleId > 0 ? (object)sampleId : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.SelectedLong(ddlBorehole).Value);
                cmd.Parameters.AddWithValue("@SampleCode", txtSampleCode.Text.Trim());
                cmd.Parameters.AddWithValue("@FromDepthM", ParseDecimal(txtFromDepthM.Text).Value);
                cmd.Parameters.AddWithValue("@ToDepthM", ParseDecimal(txtToDepthM.Text).Value);
                cmd.Parameters.AddWithValue("@SampleTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSampleType)));
                cmd.Parameters.AddWithValue("@SampleQualityId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSampleQuality)));
                cmd.Parameters.AddWithValue("@RecoveryLengthM", DataHelper.DbValue(ParseDecimal(txtRecoveryLengthM.Text)));
                cmd.Parameters.AddWithValue("@Description", DataHelper.DbValue(txtDescription.Text));
                cmd.Parameters.AddWithValue("@TakenDate", DataHelper.DbValue(ParseDate(txtTakenDate.Text)));
                cmd.Parameters.AddWithValue("@RequiredTests", DataHelper.DbValue(txtRequiredTests.Text));
                cmd.Parameters.AddWithValue("@StorageLocation", DataHelper.DbValue(txtStorageLocation.Text));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); hfSampleId.Value = Convert.ToString(cmd.ExecuteScalar());
            }
            ShowSuccess("تم حفظ العينة بنجاح.");
            pnlForm.Visible = false;
            SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value);
            LoadFilterBoreholes(); SetSelected(ddlFilterBorehole, DataHelper.SelectedLong(ddlBorehole).Value);
            LoadSamples();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvSamples_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long sampleId; if (!long.TryParse(Convert.ToString(e.CommandArgument), out sampleId)) return;
        if (e.CommandName == "EditItem") LoadForEdit(sampleId);
        else if (e.CommandName == "DeleteItem") DeleteSample(sampleId);
    }

    private void LoadForEdit(long sampleId)
    {
        if (!SecurityHelper.HasPermission("Samples.Edit")) { ShowError("لا تملك صلاحية تعديل العينة."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Sample_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SampleId", sampleId);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("العينة غير موجودة."); return; }
                DataRow r = dt.Rows[0];
                hfSampleId.Value = Convert.ToString(r["SampleId"]);
                SetSelected(ddlProject, r["ProjectId"]); LoadFormBoreholes(); SetSelected(ddlBorehole, r["BoreholeId"]);
                txtSampleCode.Text = Convert.ToString(r["SampleCode"]);
                txtFromDepthM.Text = FormatDecimal(r["FromDepthM"]); txtToDepthM.Text = FormatDecimal(r["ToDepthM"]);
                SetSelected(ddlSampleType, r["SampleTypeId"]); SetSelected(ddlSampleQuality, r["SampleQualityId"]);
                txtRecoveryLengthM.Text = FormatDecimal(r["RecoveryLengthM"]); txtDescription.Text = Convert.ToString(r["Description"]);
                txtTakenDate.Text = FormatDate(r["TakenDate"]); txtRequiredTests.Text = Convert.ToString(r["RequiredTests"]);
                txtStorageLocation.Text = Convert.ToString(r["StorageLocation"]); txtNotes.Text = Convert.ToString(r["Notes"]);
                litFormTitle.Text = "تعديل عينة"; pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteSample(long sampleId)
    {
        if (!SecurityHelper.HasPermission("Samples.Delete")) { ShowError("لا تملك صلاحية حذف العينة."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Sample_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SampleId", sampleId);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف العينة منطقيًا."); LoadSamples();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; }
        if (!DataHelper.SelectedLong(ddlBorehole).HasValue) { ShowError("اختيار الجسة مطلوب."); return false; }
        if (string.IsNullOrWhiteSpace(txtSampleCode.Text)) { ShowError("كود العينة مطلوب."); return false; }
        decimal? fromDepth = ParseDecimal(txtFromDepthM.Text); decimal? toDepth = ParseDecimal(txtToDepthM.Text);
        if (!fromDepth.HasValue || fromDepth.Value < 0) { ShowError("عمق البداية يجب أن يكون رقمًا صحيحًا أكبر أو يساوي صفر."); return false; }
        if (!toDepth.HasValue || toDepth.Value <= fromDepth.Value) { ShowError("عمق النهاية يجب أن يكون أكبر من عمق البداية."); return false; }
        return true;
    }

    private void ClearForm()
    {
        hfSampleId.Value = string.Empty; if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; ddlBorehole.Items.Clear(); ddlBorehole.Items.Insert(0, new ListItem("-- اختر الجسة --", ""));
        txtSampleCode.Text = string.Empty; txtFromDepthM.Text = string.Empty; txtToDepthM.Text = string.Empty;
        if (ddlSampleType.Items.Count > 0) ddlSampleType.SelectedIndex = 0; if (ddlSampleQuality.Items.Count > 0) ddlSampleQuality.SelectedIndex = 0;
        txtRecoveryLengthM.Text = string.Empty; txtDescription.Text = string.Empty; txtTakenDate.Text = string.Empty; txtRequiredTests.Text = string.Empty; txtStorageLocation.Text = string.Empty; txtNotes.Text = string.Empty;
    }

    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.##"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
