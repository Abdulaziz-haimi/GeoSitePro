using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ReportEditor : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long ReportId { get { return DataHelper.GetQueryId(Request, "ReportId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Reports.Edit");
        if (!IsPostBack)
        {
            if (ReportId <= 0) { ShowError("رقم التقرير غير صحيح."); return; }
            lnkPrint.NavigateUrl = "~/ReportPrint.aspx?ReportId=" + ReportId;
            LoadLookups();
            LoadReportHeader();
            LoadSections();
        }
    }

    private void LoadLookups()
    {
        BindLookup(ddlSectionType, "ReportSectionType", true);
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

    private void LoadReportHeader()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", ReportId);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("التقرير غير موجود."); return; }
                DataRow r = dt.Rows[0];
                litReportTitle.Text = Server.HtmlEncode(Convert.ToString(r["ReportTitle"]));
                litReportMeta.Text = Server.HtmlEncode(Convert.ToString(r["ReportNo"]) + " - " + Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["ProjectName"]));
                lnkBack.NavigateUrl = "~/Reports.aspx?ProjectId=" + Convert.ToString(r["ProjectId"]);
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadSections()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ReportSections_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", ReportId);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvSections.DataSource = dt;
                gvSections.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnGenerateDefault_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Reports.Generate")) { ShowError("لا تملك صلاحية توليد أقسام التقرير."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Report_GenerateDefaultSections", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportId", ReportId);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم توليد الأقسام الناقصة من بيانات المشروع.");
            LoadSections();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnAddSection_Click(object sender, EventArgs e)
    {
        ClearSectionForm();
        litSectionFormTitle.Text = "إضافة قسم";
        pnlSectionForm.Visible = true;
    }

    protected void btnCancelSection_Click(object sender, EventArgs e)
    {
        pnlSectionForm.Visible = false;
        ClearSectionForm();
        HideMessage();
    }

    protected void btnSaveSection_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtSectionTitle.Text)) { ShowError("عنوان القسم مطلوب."); return; }
        int sortOrder;
        if (!string.IsNullOrWhiteSpace(txtSortOrder.Text) && !int.TryParse(txtSortOrder.Text, out sortOrder)) { ShowError("ترتيب العرض يجب أن يكون رقمًا صحيحًا."); return; }
        try
        {
            long id; long.TryParse(hfSectionId.Value, out id);
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ReportSection_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportSectionId", id > 0 ? (object)id : DBNull.Value);
                cmd.Parameters.AddWithValue("@ReportId", ReportId);
                cmd.Parameters.AddWithValue("@SectionTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlSectionType)));
                cmd.Parameters.AddWithValue("@SectionTitle", DataHelper.DbValue(txtSectionTitle.Text));
                cmd.Parameters.AddWithValue("@SectionContent", DataHelper.DbValue(txtSectionContent.Text));
                cmd.Parameters.AddWithValue("@SortOrder", DataHelper.DbValue(ParseInt(txtSortOrder.Text)));
                cmd.Parameters.AddWithValue("@IsIncluded", chkIsIncluded.Checked);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteScalar();
            }
            ShowSuccess("تم حفظ القسم بنجاح.");
            pnlSectionForm.Visible = false;
            LoadSections();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvSections_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadSectionForEdit(id);
        else if (e.CommandName == "DeleteItem") DeleteSection(id);
    }

    private void LoadSectionForEdit(long id)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ReportSection_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportSectionId", id);
                DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("القسم غير موجود."); return; }
                DataRow r = dt.Rows[0];
                hfSectionId.Value = Convert.ToString(r["ReportSectionId"]);
                SetSelected(ddlSectionType, r["SectionTypeId"]);
                txtSectionTitle.Text = Convert.ToString(r["SectionTitle"]);
                txtSectionContent.Text = Convert.ToString(r["SectionContent"]);
                txtSortOrder.Text = Convert.ToString(r["SortOrder"]);
                chkIsIncluded.Checked = r["IsIncluded"] != DBNull.Value && Convert.ToBoolean(r["IsIncluded"]);
                litSectionFormTitle.Text = "تحرير قسم";
                pnlSectionForm.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteSection(long id)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ReportSection_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ReportSectionId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حذف القسم."); LoadSections();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ClearSectionForm()
    {
        hfSectionId.Value = string.Empty;
        if (ddlSectionType.Items.Count > 0) ddlSectionType.SelectedIndex = 0;
        txtSectionTitle.Text = string.Empty;
        txtSectionContent.Text = string.Empty;
        txtSortOrder.Text = string.Empty;
        chkIsIncluded.Checked = true;
    }

    private int? ParseInt(string value) { int i; return int.TryParse(value, out i) ? (int?)i : null; }
    private void SetSelected(DropDownList ddl, object value) { if (ddl == null || value == DBNull.Value || value == null) return; ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) ddl.SelectedValue = item.Value; }
    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
    private void HideMessage() { pnlMessage.Visible = false; litMessage.Text = string.Empty; }
}
