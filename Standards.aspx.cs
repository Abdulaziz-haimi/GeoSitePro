using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class Standards : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Standards.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadCategories();
            LoadStandards();
        }
    }

    private void ApplyPermissions()
    {
        btnNew.Visible = SecurityHelper.HasPermission("Standards.Create");
    }

    private void LoadCategories()
    {
        DataTable dt = GetLookup("StandardCategory");
        BindLookup(ddlCategory, dt, true, "-- اختر التصنيف --");
        BindLookup(ddlFilterCategory, dt, true, "-- كل التصنيفات --");
    }

    private DataTable GetLookup(string category)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Lookups_GetByCategory", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryCode", category);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private void BindLookup(DropDownList ddl, DataTable dt, bool addEmpty, string emptyText)
    {
        ddl.DataSource = dt;
        ddl.DataTextField = "NameAr";
        ddl.DataValueField = "LookupItemId";
        ddl.DataBind();
        if (addEmpty) ddl.Items.Insert(0, new ListItem(emptyText, ""));
    }

    private void LoadStandards()
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Standards_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@CategoryId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterCategory)));
            cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            gvStandards.DataSource = dt;
            gvStandards.DataBind();
        }
    }

    protected void btnNew_Click(object sender, EventArgs e)
    {
        ClearForm();
        pnlForm.Visible = true;
        litFormTitle.Text = "إضافة معيار";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission(string.IsNullOrEmpty(hfStandardId.Value) ? "Standards.Create" : "Standards.Edit"))
        {
            ShowError("لا تملك صلاحية الحفظ."); return;
        }
        if (string.IsNullOrWhiteSpace(txtStandardCode.Text) || string.IsNullOrWhiteSpace(txtStandardTitle.Text))
        {
            ShowError("كود المعيار والعنوان مطلوبان."); return;
        }
        int year; int? versionYear = int.TryParse(txtVersionYear.Text, out year) ? (int?)year : null;
        long id; long? standardId = long.TryParse(hfStandardId.Value, out id) ? (long?)id : null;
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Standard_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StandardId", DataHelper.DbValue(standardId));
                cmd.Parameters.AddWithValue("@StandardCode", DataHelper.DbValue(txtStandardCode.Text));
                cmd.Parameters.AddWithValue("@StandardTitle", DataHelper.DbValue(txtStandardTitle.Text));
                cmd.Parameters.AddWithValue("@Organization", DataHelper.DbValue(txtOrganization.Text));
                cmd.Parameters.AddWithValue("@CategoryId", DataHelper.DbValue(DataHelper.SelectedLong(ddlCategory)));
                cmd.Parameters.AddWithValue("@VersionYear", DataHelper.DbValue(versionYear));
                cmd.Parameters.AddWithValue("@StandardType", DataHelper.DbValue(txtStandardType.Text));
                cmd.Parameters.AddWithValue("@ScopeSummary", DataHelper.DbValue(txtScopeSummary.Text));
                cmd.Parameters.AddWithValue("@Remarks", DataHelper.DbValue(txtRemarks.Text));
                cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            pnlForm.Visible = false;
            LoadStandards();
            ShowSuccess("تم حفظ المعيار بنجاح.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnCancel_Click(object sender, EventArgs e) { pnlForm.Visible = false; }
    protected void btnSearch_Click(object sender, EventArgs e) { LoadStandards(); }
    protected void btnClear_Click(object sender, EventArgs e) { txtSearch.Text = ""; ddlFilterCategory.SelectedIndex = 0; LoadStandards(); }

    protected void gvStandards_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadStandard(id);
        if (e.CommandName == "DeleteItem") DeleteStandard(id);
    }

    private void LoadStandard(long id)
    {
        if (!SecurityHelper.HasPermission("Standards.Edit")) { ShowError("لا تملك صلاحية التعديل."); return; }
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_Standard_GetById", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@StandardId", id);
            DataTable dt = new DataTable(); using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            if (dt.Rows.Count == 0) { ShowError("المعيار غير موجود."); return; }
            DataRow r = dt.Rows[0];
            hfStandardId.Value = Convert.ToString(r["StandardId"]);
            txtStandardCode.Text = Convert.ToString(r["StandardCode"]);
            txtStandardTitle.Text = Convert.ToString(r["StandardTitle"]);
            txtOrganization.Text = Convert.ToString(r["Organization"]);
            SetSelected(ddlCategory, r["CategoryId"]);
            txtVersionYear.Text = Convert.ToString(r["VersionYear"]);
            txtStandardType.Text = Convert.ToString(r["StandardType"]);
            txtScopeSummary.Text = Convert.ToString(r["ScopeSummary"]);
            txtRemarks.Text = Convert.ToString(r["Remarks"]);
            chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
            litFormTitle.Text = "تعديل معيار";
            pnlForm.Visible = true;
        }
    }

    private void DeleteStandard(long id)
    {
        if (!SecurityHelper.HasPermission("Standards.Delete")) { ShowError("لا تملك صلاحية الحذف."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_Standard_Delete", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StandardId", id);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            LoadStandards(); ShowSuccess("تم حذف المعيار.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ClearForm()
    {
        hfStandardId.Value = ""; txtStandardCode.Text = ""; txtStandardTitle.Text = ""; txtOrganization.Text = ""; txtVersionYear.Text = ""; txtStandardType.Text = ""; txtScopeSummary.Text = ""; txtRemarks.Text = ""; chkIsActive.Checked = true; if (ddlCategory.Items.Count > 0) ddlCategory.SelectedIndex = 0;
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value)); if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private void ShowSuccess(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-success"; litMessage.Text = message; }
    private void ShowError(string message) { pnlMessage.Visible = true; pnlMessage.CssClass = "gsp-message gsp-message-danger"; litMessage.Text = message; }
}
