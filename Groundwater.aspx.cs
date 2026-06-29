using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Groundwater : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long QueryBoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Groundwater.View");
        if (!IsPostBack)
        {
            ApplyPermissions(); LoadProjectsDropDowns(); LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadFilterBoreholes(); if (QueryBoreholeId > 0) SetSelected(ddlFilterBorehole, QueryBoreholeId);
            LoadGroundwater();
        }
    }

    private void ApplyPermissions() { btnNew.Visible = SecurityHelper.HasPermission("Groundwater.Create"); }
    private void LoadProjectsDropDowns() { DataTable dt = GetProjects(); BindProjectDropDown(ddlProject, dt, true); BindProjectDropDown(ddlFilterProject, dt, true); }
    private DataTable GetProjects() { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); return dt; } }
    private void BindProjectDropDown(DropDownList ddl, DataTable dt, bool addEmpty) { ddl.DataSource = dt; ddl.DataTextField = "ProjectName"; ddl.DataValueField = "ProjectId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", "")); }
    private void LoadLookups() { BindLookup(ddlObservationType, "GroundwaterObservationType", true); }
    private void BindLookup(DropDownList ddl, string categoryCode, bool addEmpty) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@CategoryCode", categoryCode); cmd.Parameters.AddWithValue("@OnlyActive", true); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddl.DataSource = dt; ddl.DataTextField = "NameAr"; ddl.DataValueField = "LookupItemId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر --", "")); } }
    private void LoadFormBoreholes() { BindBoreholes(ddlBorehole, DataHelper.SelectedLong(ddlProject), true); }
    private void LoadFilterBoreholes() { BindBoreholes(ddlFilterBorehole, DataHelper.SelectedLong(ddlFilterProject), true); }
    private void BindBoreholes(DropDownList ddl, long? projectId, bool addEmpty) { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_Boreholes_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(projectId)); cmd.Parameters.AddWithValue("@SearchText", DBNull.Value); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); ddl.DataSource = dt; ddl.DataTextField = "BoreholeCode"; ddl.DataValueField = "BoreholeId"; ddl.DataBind(); if (addEmpty) ddl.Items.Insert(0, new ListItem("-- اختر الجسة --", "")); } }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFormBoreholes(); }
    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadFilterBoreholes(); LoadGroundwater(); }
    protected void ddlFilterBorehole_SelectedIndexChanged(object sender, EventArgs e) { LoadGroundwater(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { ddlFilterProject.SelectedIndex = 0; LoadFilterBoreholes(); LoadGroundwater(); }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }

    private void LoadGroundwater()
    {
        try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_GroundwaterObservations_Get", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject))); cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterBorehole))); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); gvGroundwater.DataSource = dt; gvGroundwater.DataBind(); } }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("Groundwater.Create")) { ShowError("لا تملك صلاحية إضافة قراءة مياه جوفية."); return; }
        ClearForm(); if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value); else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId); LoadFormBoreholes(); if (DataHelper.SelectedLong(ddlFilterBorehole).HasValue) SetSelected(ddlBorehole, DataHelper.SelectedLong(ddlFilterBorehole).Value); else if (QueryBoreholeId > 0) SetSelected(ddlBorehole, QueryBoreholeId); litFormTitle.Text = "إضافة قراءة مياه جوفية"; pnlForm.Visible = true;
    }
    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; ClearForm(); HideMessage(); }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long id; long.TryParse(hfGroundwaterObservationId.Value, out id); bool isNew = id <= 0;
            if (isNew && !SecurityHelper.HasPermission("Groundwater.Create")) { ShowError("لا تملك صلاحية إضافة قراءة مياه جوفية."); return; }
            if (!isNew && !SecurityHelper.HasPermission("Groundwater.Edit")) { ShowError("لا تملك صلاحية تعديل القراءة."); return; }
            using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_GroundwaterObservation_Save", con))
            { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@GroundwaterObservationId", id > 0 ? (object)id : DBNull.Value); cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value); cmd.Parameters.AddWithValue("@BoreholeId", DataHelper.SelectedLong(ddlBorehole).Value); cmd.Parameters.AddWithValue("@ObservationDate", DataHelper.DbValue(ParseDate(txtObservationDate.Text))); cmd.Parameters.AddWithValue("@DepthToWaterM", ParseDecimal(txtDepthToWaterM.Text).Value); cmd.Parameters.AddWithValue("@ObservationTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlObservationType))); cmd.Parameters.AddWithValue("@CasingDepthM", DataHelper.DbValue(ParseDecimal(txtCasingDepthM.Text))); cmd.Parameters.AddWithValue("@StabilizedAfterHours", DataHelper.DbValue(ParseDecimal(txtStabilizedAfterHours.Text))); cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text)); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); hfGroundwaterObservationId.Value = Convert.ToString(cmd.ExecuteScalar()); }
            ShowSuccess("تم حفظ قراءة المياه الجوفية بنجاح."); pnlForm.Visible = false; SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value); LoadFilterBoreholes(); SetSelected(ddlFilterBorehole, DataHelper.SelectedLong(ddlBorehole).Value); LoadGroundwater();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    protected void gvGroundwater_RowCommand(object sender, GridViewCommandEventArgs e) { long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return; if (e.CommandName == "EditItem") LoadForEdit(id); else if (e.CommandName == "DeleteItem") DeleteGroundwater(id); }
    private void LoadForEdit(long id)
    {
        if (!SecurityHelper.HasPermission("Groundwater.Edit")) { ShowError("لا تملك صلاحية تعديل القراءة."); return; }
        try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_GroundwaterObservation_GetById", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@GroundwaterObservationId", id); DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt); if (dt.Rows.Count == 0) { ShowError("القراءة غير موجودة."); return; } DataRow r = dt.Rows[0]; hfGroundwaterObservationId.Value = Convert.ToString(r["GroundwaterObservationId"]); SetSelected(ddlProject, r["ProjectId"]); LoadFormBoreholes(); SetSelected(ddlBorehole, r["BoreholeId"]); txtObservationDate.Text = FormatDate(r["ObservationDate"]); txtDepthToWaterM.Text = FormatDecimal(r["DepthToWaterM"]); SetSelected(ddlObservationType, r["ObservationTypeId"]); txtCasingDepthM.Text = FormatDecimal(r["CasingDepthM"]); txtStabilizedAfterHours.Text = FormatDecimal(r["StabilizedAfterHours"]); txtNotes.Text = Convert.ToString(r["Notes"]); litFormTitle.Text = "تعديل قراءة مياه جوفية"; pnlForm.Visible = true; } }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }
    private void DeleteGroundwater(long id) { if (!SecurityHelper.HasPermission("Groundwater.Delete")) { ShowError("لا تملك صلاحية حذف القراءة."); return; } try { using (SqlConnection con = new SqlConnection(ConnStr)) using (SqlCommand cmd = new SqlCommand("sp_GroundwaterObservation_Delete", con)) { cmd.CommandType = CommandType.StoredProcedure; cmd.Parameters.AddWithValue("@GroundwaterObservationId", id); cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId); con.Open(); cmd.ExecuteNonQuery(); } ShowSuccess("تم حذف القراءة منطقيًا."); LoadGroundwater(); } catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); } }
    private bool ValidateForm() { if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; } if (!DataHelper.SelectedLong(ddlBorehole).HasValue) { ShowError("اختيار الجسة مطلوب."); return false; } decimal? depth = ParseDecimal(txtDepthToWaterM.Text); if (!depth.HasValue || depth.Value < 0) { ShowError("عمق المياه مطلوب ويجب أن يكون رقمًا أكبر أو يساوي صفر."); return false; } return true; }
    private void ClearForm() { hfGroundwaterObservationId.Value = string.Empty; if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0; ddlBorehole.Items.Clear(); ddlBorehole.Items.Insert(0, new ListItem("-- اختر الجسة --", "")); txtObservationDate.Text = DateTime.Today.ToString("yyyy-MM-dd"); txtDepthToWaterM.Text = string.Empty; if (ddlObservationType.Items.Count > 0) ddlObservationType.SelectedIndex = 0; txtCasingDepthM.Text = string.Empty; txtStabilizedAfterHours.Text = string.Empty; txtNotes.Text = string.Empty; }
    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.##"); }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
