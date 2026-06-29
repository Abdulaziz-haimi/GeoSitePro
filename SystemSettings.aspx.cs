using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class SystemSettings : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SystemSettings.View");
        if (!IsPostBack)
        {
            BindLists();
            ClearForm();
            BindGrid();
        }
    }

    private void BindLists()
    {
        ddlCategory.Items.Clear(); ddlFilterCategory.Items.Clear();
        string[] cats = new string[] { "General", "Security", "Backup", "Reporting", "GISCAD", "Notifications", "Standards", "Quality", "Workflow" };
        ddlFilterCategory.Items.Add(new ListItem("كل التصنيفات", ""));
        foreach (string c in cats) { ddlCategory.Items.Add(new ListItem(c, c)); ddlFilterCategory.Items.Add(new ListItem(c, c)); }

        ddlDataType.Items.Clear();
        ddlDataType.Items.Add(new ListItem("Text", "Text"));
        ddlDataType.Items.Add(new ListItem("Number", "Number"));
        ddlDataType.Items.Add(new ListItem("Boolean", "Boolean"));
        ddlDataType.Items.Add(new ListItem("Date", "Date"));
        ddlDataType.Items.Add(new ListItem("Json", "Json"));
    }

    protected void btnNew_Click(object sender, EventArgs e) { ClearForm(); }
    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }
    protected void btnSearch_Click(object sender, EventArgs e) { BindGrid(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("SystemSettings.Manage");
        if (string.IsNullOrWhiteSpace(txtSettingKey.Text)) { ShowError("مفتاح الإعداد مطلوب."); return; }
        try
        {
            ExecuteScalar("sp_SystemSetting_Save",
                new SqlParameter("@SettingId", (object)ParseLong(hfSettingId.Value) ?? DBNull.Value),
                new SqlParameter("@Category", ddlCategory.SelectedValue),
                new SqlParameter("@SettingKey", txtSettingKey.Text.Trim()),
                new SqlParameter("@SettingValue", (object)txtSettingValue.Text.Trim() ?? DBNull.Value),
                new SqlParameter("@DataType", ddlDataType.SelectedValue),
                new SqlParameter("@Description", DataHelper.DbValue(txtDescription.Text)),
                new SqlParameter("@IsEncrypted", chkIsEncrypted.Checked),
                new SqlParameter("@IsActive", chkIsActive.Checked),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ClearForm(); BindGrid(); ShowSuccess("تم حفظ الإعداد بنجاح.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvSettings_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id; if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditRow") LoadForEdit(id);
        if (e.CommandName == "DeleteRow") DeleteSetting(id);
    }

    private void LoadForEdit(long id)
    {
        try
        {
            DataTable dt = ExecuteTable("sp_SystemSetting_GetById", new SqlParameter("@SettingId", id));
            if (dt.Rows.Count == 0) { ShowError("لم يتم العثور على الإعداد."); return; }
            DataRow r = dt.Rows[0];
            hfSettingId.Value = Convert.ToString(r["SettingId"]);
            SetSelected(ddlCategory, r["Category"]);
            txtSettingKey.Text = Convert.ToString(r["SettingKey"]);
            txtSettingValue.Text = Convert.ToString(r["SettingValue"]);
            SetSelected(ddlDataType, r["DataType"]);
            txtDescription.Text = Convert.ToString(r["Description"]);
            chkIsEncrypted.Checked = Convert.ToBoolean(r["IsEncrypted"]);
            chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void DeleteSetting(long id)
    {
        SecurityHelper.RequirePermission("SystemSettings.Manage");
        try
        {
            ExecuteNonQuery("sp_SystemSetting_Delete", new SqlParameter("@SettingId", id), new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            BindGrid(); ShowSuccess("تم حذف الإعداد.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindGrid()
    {
        gvSettings.DataSource = ExecuteTable("sp_SystemSettings_Get",
            new SqlParameter("@Category", DataHelper.DbValue(ddlFilterCategory.SelectedValue)),
            new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)));
        gvSettings.DataBind();
    }

    private void ClearForm()
    {
        hfSettingId.Value = ""; txtSettingKey.Text = ""; txtSettingValue.Text = ""; txtDescription.Text = "";
        chkIsEncrypted.Checked = false; chkIsActive.Checked = true;
        if (ddlCategory.Items.Count > 0) ddlCategory.SelectedIndex = 0;
        if (ddlDataType.Items.Count > 0) ddlDataType.SelectedIndex = 0;
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private DataTable ExecuteTable(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private DataSet ExecuteDataSet(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            DataSet ds = new DataSet();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
            return ds;
        }
    }

    private object ExecuteScalar(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            return cmd.ExecuteScalar();
        }
    }

    private void ExecuteNonQuery(string proc, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            con.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-success";
        litMessage.Text = Server.HtmlEncode(message);
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }

    private long? ParseLong(string value)
    {
        long v;
        if (long.TryParse(value, out v) && v > 0) return v;
        return null;
    }

    private DateTime? ParseDate(string value)
    {
        DateTime v;
        if (DateTime.TryParse(value, out v)) return v.Date;
        return null;
    }

}
