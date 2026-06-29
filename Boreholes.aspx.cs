using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Boreholes : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Boreholes.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjectsDropDowns();
            LoadLookups();
            if (QueryProjectId > 0) SetSelected(ddlFilterProject, QueryProjectId);
            LoadBoreholes();
            if (string.Equals(Request.QueryString["action"], "new", StringComparison.OrdinalIgnoreCase)) OpenNewForm();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Boreholes.Create");
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
        BindLookup(ddlDrillingMethod, "DrillingMethod", true);
        BindLookup(ddlBoreholeStatus, "BoreholeStatus", true);
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

    private void LoadBoreholes()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Boreholes_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject)));
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvBoreholes.DataSource = dt;
                gvBoreholes.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void ddlFilterProject_SelectedIndexChanged(object sender, EventArgs e) { LoadBoreholes(); }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadBoreholes(); }
    protected void btnClearSearch_Click(object sender, EventArgs e) { txtSearch.Text = string.Empty; ddlFilterProject.SelectedIndex = 0; LoadBoreholes(); }
    protected void btnNew_Click(object sender, EventArgs e) { OpenNewForm(); }

    private void OpenNewForm()
    {
        if (!SecurityHelper.HasPermission("Boreholes.Create")) { ShowError("لا تملك صلاحية إضافة جسة."); return; }
        ClearForm();
        if (DataHelper.SelectedLong(ddlFilterProject).HasValue) SetSelected(ddlProject, DataHelper.SelectedLong(ddlFilterProject).Value);
        else if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
        litFormTitle.Text = "إضافة جسة";
        pnlForm.Visible = true;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        pnlForm.Visible = false;
        ClearForm();
        HideMessage();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long boreholeId;
            long.TryParse(hfBoreholeId.Value, out boreholeId);
            bool isNew = boreholeId <= 0;
            if (isNew && !SecurityHelper.HasPermission("Boreholes.Create")) { ShowError("لا تملك صلاحية إضافة جسة."); return; }
            if (!isNew && !SecurityHelper.HasPermission("Boreholes.Edit")) { ShowError("لا تملك صلاحية تعديل الجسة."); return; }

            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Borehole_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BoreholeId", boreholeId > 0 ? (object)boreholeId : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectId", DataHelper.SelectedLong(ddlProject).Value);
                cmd.Parameters.AddWithValue("@BoreholeCode", txtBoreholeCode.Text.Trim());
                cmd.Parameters.AddWithValue("@PlannedDepthM", DataHelper.DbValue(ParseDecimal(txtPlannedDepthM.Text)));
                cmd.Parameters.AddWithValue("@ActualDepthM", DataHelper.DbValue(ParseDecimal(txtActualDepthM.Text)));
                cmd.Parameters.AddWithValue("@Easting", DataHelper.DbValue(ParseDecimal(txtEasting.Text)));
                cmd.Parameters.AddWithValue("@Northing", DataHelper.DbValue(ParseDecimal(txtNorthing.Text)));
                cmd.Parameters.AddWithValue("@ElevationM", DataHelper.DbValue(ParseDecimal(txtElevationM.Text)));
                cmd.Parameters.AddWithValue("@DrillingMethodId", DataHelper.DbValue(DataHelper.SelectedLong(ddlDrillingMethod)));
                cmd.Parameters.AddWithValue("@BoreholeStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlBoreholeStatus)));
                cmd.Parameters.AddWithValue("@StartDate", DataHelper.DbValue(ParseDate(txtStartDate.Text)));
                cmd.Parameters.AddWithValue("@EndDate", DataHelper.DbValue(ParseDate(txtEndDate.Text)));
                cmd.Parameters.AddWithValue("@GroundwaterDepthM", DataHelper.DbValue(ParseDecimal(txtGroundwaterDepthM.Text)));
                cmd.Parameters.AddWithValue("@LocationDescription", DataHelper.DbValue(txtLocationDescription.Text));
                cmd.Parameters.AddWithValue("@FieldEngineer", DataHelper.DbValue(txtFieldEngineer.Text));
                cmd.Parameters.AddWithValue("@TerminationReason", DataHelper.DbValue(txtTerminationReason.Text));
                cmd.Parameters.AddWithValue("@Notes", DataHelper.DbValue(txtNotes.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                object result = cmd.ExecuteScalar();
                hfBoreholeId.Value = Convert.ToString(result);
            }
            ShowSuccess("تم حفظ الجسة بنجاح.");
            pnlForm.Visible = false;
            if (DataHelper.SelectedLong(ddlProject).HasValue) SetSelected(ddlFilterProject, DataHelper.SelectedLong(ddlProject).Value);
            LoadBoreholes();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvBoreholes_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long boreholeId;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out boreholeId)) return;
        if (e.CommandName == "EditItem") LoadForEdit(boreholeId);
        else if (e.CommandName == "DeleteItem") DeleteBorehole(boreholeId);
    }

    private void LoadForEdit(long boreholeId)
    {
        if (!SecurityHelper.HasPermission("Boreholes.Edit")) { ShowError("لا تملك صلاحية تعديل الجسة."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Borehole_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BoreholeId", boreholeId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("الجسة غير موجودة."); return; }
                DataRow r = dt.Rows[0];
                hfBoreholeId.Value = Convert.ToString(r["BoreholeId"]);
                SetSelected(ddlProject, r["ProjectId"]);
                txtBoreholeCode.Text = Convert.ToString(r["BoreholeCode"]);
                txtPlannedDepthM.Text = FormatDecimal(r["PlannedDepthM"]);
                txtActualDepthM.Text = FormatDecimal(r["ActualDepthM"]);
                txtEasting.Text = FormatDecimal(r["Easting"]);
                txtNorthing.Text = FormatDecimal(r["Northing"]);
                txtElevationM.Text = FormatDecimal(r["ElevationM"]);
                SetSelected(ddlDrillingMethod, r["DrillingMethodId"]);
                SetSelected(ddlBoreholeStatus, r["BoreholeStatusId"]);
                txtStartDate.Text = FormatDate(r["StartDate"]);
                txtEndDate.Text = FormatDate(r["EndDate"]);
                txtGroundwaterDepthM.Text = FormatDecimal(r["GroundwaterDepthM"]);
                txtLocationDescription.Text = Convert.ToString(r["LocationDescription"]);
                txtFieldEngineer.Text = Convert.ToString(r["FieldEngineer"]);
                txtTerminationReason.Text = Convert.ToString(r["TerminationReason"]);
                txtNotes.Text = Convert.ToString(r["Notes"]);
                chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                litFormTitle.Text = "تعديل جسة";
                pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteBorehole(long boreholeId)
    {
        if (!SecurityHelper.HasPermission("Boreholes.Delete")) { ShowError("لا تملك صلاحية حذف الجسة."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Borehole_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BoreholeId", boreholeId);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف الجسة منطقيًا.");
            LoadBoreholes();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (!DataHelper.SelectedLong(ddlProject).HasValue) { ShowError("اختيار المشروع مطلوب."); return false; }
        if (string.IsNullOrWhiteSpace(txtBoreholeCode.Text)) { ShowError("كود الجسة مطلوب."); return false; }
        decimal? actualDepth = ParseDecimal(txtActualDepthM.Text);
        if (!actualDepth.HasValue || actualDepth.Value <= 0) { ShowError("العمق الفعلي يجب أن يكون رقمًا أكبر من صفر."); return false; }
        DateTime? start = ParseDate(txtStartDate.Text);
        DateTime? end = ParseDate(txtEndDate.Text);
        if (start.HasValue && end.HasValue && end.Value < start.Value) { ShowError("تاريخ نهاية الحفر لا يمكن أن يكون قبل تاريخ البداية."); return false; }
        return true;
    }

    private void ClearForm()
    {
        hfBoreholeId.Value = string.Empty;
        if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0;
        txtBoreholeCode.Text = string.Empty; txtPlannedDepthM.Text = string.Empty; txtActualDepthM.Text = string.Empty;
        txtEasting.Text = string.Empty; txtNorthing.Text = string.Empty; txtElevationM.Text = string.Empty;
        if (ddlDrillingMethod.Items.Count > 0) ddlDrillingMethod.SelectedIndex = 0;
        if (ddlBoreholeStatus.Items.Count > 0) ddlBoreholeStatus.SelectedIndex = 0;
        txtStartDate.Text = string.Empty; txtEndDate.Text = string.Empty; txtGroundwaterDepthM.Text = string.Empty;
        txtLocationDescription.Text = string.Empty; txtFieldEngineer.Text = string.Empty; txtTerminationReason.Text = string.Empty; txtNotes.Text = string.Empty;
        chkIsActive.Checked = true;
    }

    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }
    private string FormatDecimal(object value) { return value == DBNull.Value || value == null ? string.Empty : Convert.ToDecimal(value).ToString("0.##"); }

    private void SetSelected(DropDownList ddl, object value)
    {
        if (ddl == null || value == DBNull.Value || value == null) return;
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) ddl.SelectedValue = item.Value;
    }

    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
