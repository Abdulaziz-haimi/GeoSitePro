using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Projects : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Projects.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadLookups();
            LoadProjects();
            if (string.Equals(Request.QueryString["action"], "new", StringComparison.OrdinalIgnoreCase)) OpenNewProjectFormFromQuery();
            long editId = DataHelper.GetQueryId(Request, "edit");
            if (editId > 0) LoadProjectForEdit(editId);
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Projects.Create");
    }

    private void LoadLookups()
    {
        BindLookup(ddlProjectType, "ProjectType", true);
        BindLookup(ddlProjectStatus, "ProjectStatus", true);
        BindLookup(ddlStructureType, "StructureType", true);
        BindLookup(ddlInvestigationStage, "InvestigationStage", true);
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

    private void LoadProjects()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Projects_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvProjects.DataSource = dt;
                gvProjects.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        OpenNewProjectFormFromQuery();
    }

    private void OpenNewProjectFormFromQuery()
    {
        if (!SecurityHelper.HasPermission("Projects.Create")) { ShowError("لا تملك صلاحية إضافة مشروع جديد."); return; }
        ClearForm();
        hfProjectId.Value = string.Empty;
        litFormTitle.Text = "إضافة مشروع جديد";
        pnlForm.Visible = true;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        pnlForm.Visible = false;
        ClearForm();
        HideMessage();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadProjects();
    }

    protected void btnClearSearch_Click(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        LoadProjects();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!ValidateForm()) return;
        try
        {
            long projectId;
            long.TryParse(hfProjectId.Value, out projectId);
            bool isNew = projectId <= 0;
            if (isNew && !SecurityHelper.HasPermission("Projects.Create")) { ShowError("لا تملك صلاحية إضافة مشروع."); return; }
            if (!isNew && !SecurityHelper.HasPermission("Projects.Edit")) { ShowError("لا تملك صلاحية تعديل مشروع."); return; }

            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Project_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", projectId > 0 ? (object)projectId : DBNull.Value);
                cmd.Parameters.AddWithValue("@ProjectCode", txtProjectCode.Text.Trim());
                cmd.Parameters.AddWithValue("@ProjectName", txtProjectName.Text.Trim());
                cmd.Parameters.AddWithValue("@ProjectNameEn", DataHelper.DbValue(txtProjectNameEn.Text));
                cmd.Parameters.AddWithValue("@ClientName", DataHelper.DbValue(txtClientName.Text));
                cmd.Parameters.AddWithValue("@ProjectTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlProjectType)));
                cmd.Parameters.AddWithValue("@ProjectStatusId", DataHelper.DbValue(DataHelper.SelectedLong(ddlProjectStatus)));
                cmd.Parameters.AddWithValue("@StructureTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlStructureType)));
                cmd.Parameters.AddWithValue("@InvestigationStageId", DataHelper.DbValue(DataHelper.SelectedLong(ddlInvestigationStage)));
                cmd.Parameters.AddWithValue("@Country", DataHelper.DbValue(txtCountry.Text));
                cmd.Parameters.AddWithValue("@City", DataHelper.DbValue(txtCity.Text));
                cmd.Parameters.AddWithValue("@District", DataHelper.DbValue(txtDistrict.Text));
                cmd.Parameters.AddWithValue("@LocationName", DataHelper.DbValue(txtLocationName.Text));
                cmd.Parameters.AddWithValue("@Address", DataHelper.DbValue(txtAddress.Text));
                cmd.Parameters.AddWithValue("@SiteAreaM2", DataHelper.DbValue(ParseDecimal(txtSiteAreaM2.Text)));
                cmd.Parameters.AddWithValue("@NumberOfFloors", DataHelper.DbValue(ParseInt(txtNumberOfFloors.Text)));
                cmd.Parameters.AddWithValue("@BasementCount", DataHelper.DbValue(ParseInt(txtBasementCount.Text)));
                cmd.Parameters.AddWithValue("@ProjectStartDate", DataHelper.DbValue(ParseDate(txtProjectStartDate.Text)));
                cmd.Parameters.AddWithValue("@ProjectEndDate", DataHelper.DbValue(ParseDate(txtProjectEndDate.Text)));
                cmd.Parameters.AddWithValue("@ScopeOfWork", DataHelper.DbValue(txtScopeOfWork.Text));
                cmd.Parameters.AddWithValue("@GeneralNotes", DataHelper.DbValue(txtGeneralNotes.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                object result = cmd.ExecuteScalar();
                hfProjectId.Value = Convert.ToString(result);
            }
            ShowSuccess("تم حفظ المشروع بنجاح.");
            pnlForm.Visible = false;
            LoadProjects();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvProjects_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long projectId;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out projectId)) return;
        if (e.CommandName == "EditItem") LoadProjectForEdit(projectId);
        else if (e.CommandName == "DetailsItem") Response.Redirect("~/ProjectDetails.aspx?ProjectId=" + projectId);
        else if (e.CommandName == "DeleteItem") DeleteProject(projectId);
    }

    private void LoadProjectForEdit(long projectId)
    {
        if (!SecurityHelper.HasPermission("Projects.Edit")) { ShowError("لا تملك صلاحية تعديل المشروع."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Project_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", projectId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }
                DataRow r = dt.Rows[0];
                hfProjectId.Value = Convert.ToString(r["ProjectId"]);
                txtProjectCode.Text = Convert.ToString(r["ProjectCode"]);
                txtProjectName.Text = Convert.ToString(r["ProjectName"]);
                txtProjectNameEn.Text = Convert.ToString(r["ProjectNameEn"]);
                txtClientName.Text = Convert.ToString(r["ClientName"]);
                SetSelected(ddlProjectType, r["ProjectTypeId"]);
                SetSelected(ddlProjectStatus, r["ProjectStatusId"]);
                SetSelected(ddlStructureType, r["StructureTypeId"]);
                SetSelected(ddlInvestigationStage, r["InvestigationStageId"]);
                txtCountry.Text = Convert.ToString(r["Country"]);
                txtCity.Text = Convert.ToString(r["City"]);
                txtDistrict.Text = Convert.ToString(r["District"]);
                txtLocationName.Text = Convert.ToString(r["LocationName"]);
                txtAddress.Text = Convert.ToString(r["Address"]);
                txtSiteAreaM2.Text = Convert.ToString(r["SiteAreaM2"]);
                txtNumberOfFloors.Text = Convert.ToString(r["NumberOfFloors"]);
                txtBasementCount.Text = Convert.ToString(r["BasementCount"]);
                txtProjectStartDate.Text = FormatDate(r["ProjectStartDate"]);
                txtProjectEndDate.Text = FormatDate(r["ProjectEndDate"]);
                txtScopeOfWork.Text = Convert.ToString(r["ScopeOfWork"]);
                txtGeneralNotes.Text = Convert.ToString(r["GeneralNotes"]);
                chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                litFormTitle.Text = "تعديل مشروع";
                pnlForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteProject(long projectId)
    {
        if (!SecurityHelper.HasPermission("Projects.Delete")) { ShowError("لا تملك صلاحية حذف المشروع."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Project_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", projectId);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف المشروع منطقيًا.");
            LoadProjects();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private bool ValidateForm()
    {
        if (string.IsNullOrWhiteSpace(txtProjectCode.Text)) { ShowError("كود المشروع مطلوب."); return false; }
        if (string.IsNullOrWhiteSpace(txtProjectName.Text)) { ShowError("اسم المشروع مطلوب."); return false; }
        DateTime? start = ParseDate(txtProjectStartDate.Text);
        DateTime? end = ParseDate(txtProjectEndDate.Text);
        if (start.HasValue && end.HasValue && end.Value < start.Value) { ShowError("تاريخ النهاية لا يمكن أن يكون قبل تاريخ البداية."); return false; }
        return true;
    }

    private void ClearForm()
    {
        hfProjectId.Value = string.Empty; txtProjectCode.Text = string.Empty; txtProjectName.Text = string.Empty; txtProjectNameEn.Text = string.Empty; txtClientName.Text = string.Empty;
        ddlProjectType.SelectedIndex = 0; ddlProjectStatus.SelectedIndex = 0; ddlStructureType.SelectedIndex = 0; ddlInvestigationStage.SelectedIndex = 0;
        txtCountry.Text = "Saudi Arabia"; txtCity.Text = string.Empty; txtDistrict.Text = string.Empty; txtLocationName.Text = string.Empty; txtAddress.Text = string.Empty;
        txtSiteAreaM2.Text = string.Empty; txtNumberOfFloors.Text = string.Empty; txtBasementCount.Text = string.Empty; txtProjectStartDate.Text = string.Empty; txtProjectEndDate.Text = string.Empty;
        txtScopeOfWork.Text = string.Empty; txtGeneralNotes.Text = string.Empty; chkIsActive.Checked = true;
    }

    private decimal? ParseDecimal(string value) { decimal d; return decimal.TryParse(value, out d) ? (decimal?)d : null; }
    private int? ParseInt(string value) { int i; return int.TryParse(value, out i) ? (int?)i : null; }
    private DateTime? ParseDate(string value) { DateTime d; return DateTime.TryParse(value, out d) ? (DateTime?)d : null; }
    private string FormatDate(object value) { return value == DBNull.Value ? string.Empty : Convert.ToDateTime(value).ToString("yyyy-MM-dd"); }

    private void SetSelected(DropDownList ddl, object value)
    {
        if (value == DBNull.Value || value == null) { ddl.SelectedIndex = 0; return; }
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) ddl.SelectedValue = item.Value;
    }

    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
