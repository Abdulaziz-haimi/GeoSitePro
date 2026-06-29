using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ApprovalMatrix : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Workflow.Matrix");
        if (!IsPostBack) LoadSteps();
    }

    protected void btnFilter_Click(object sender, EventArgs e) { LoadSteps(); }
    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    private void LoadSteps()
    {
        try
        {
            gvSteps.DataSource = ExecuteTable("sp_WorkflowSteps_Get", new SqlParameter("@EntityType", DataHelper.DbValue(ddlFilterEntityType.SelectedValue)));
            gvSteps.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Workflow.Matrix")) { ShowError("لا تملك صلاحية تعديل مصفوفة الاعتماد."); return; }
        if (string.IsNullOrWhiteSpace(txtStepCode.Text) || string.IsNullOrWhiteSpace(txtStepNameAr.Text)) { ShowError("كود المرحلة واسمها مطلوبان."); return; }
        try
        {
            ExecuteScalar("sp_WorkflowStep_Save",
                new SqlParameter("@WorkflowStepId", DataHelper.DbValue(ParseLong(hfWorkflowStepId.Value))),
                new SqlParameter("@EntityType", ddlEntityType.SelectedValue),
                new SqlParameter("@StepCode", txtStepCode.Text.Trim()),
                new SqlParameter("@StepNameAr", txtStepNameAr.Text.Trim()),
                new SqlParameter("@StepNameEn", DataHelper.DbValue(txtStepNameEn.Text)),
                new SqlParameter("@RequiredPermission", DataHelper.DbValue(txtRequiredPermission.Text)),
                new SqlParameter("@SortOrder", DataHelper.DbValue(ParseInt(txtSortOrder.Text))),
                new SqlParameter("@IsFinal", chkIsFinal.Checked),
                new SqlParameter("@IsActive", chkIsActive.Checked),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم حفظ المرحلة بنجاح.");
            ClearForm();
            LoadSteps();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvSteps_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName != "EditItem") return;
        try
        {
            DataTable dt = ExecuteTable("sp_WorkflowStep_GetById", new SqlParameter("@WorkflowStepId", id));
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            hfWorkflowStepId.Value = Convert.ToString(r["WorkflowStepId"]);
            SetSelected(ddlEntityType, r["EntityType"]);
            txtStepCode.Text = Convert.ToString(r["StepCode"]);
            txtStepNameAr.Text = Convert.ToString(r["StepNameAr"]);
            txtStepNameEn.Text = Convert.ToString(r["StepNameEn"]);
            txtRequiredPermission.Text = Convert.ToString(r["RequiredPermission"]);
            txtSortOrder.Text = Convert.ToString(r["SortOrder"]);
            chkIsFinal.Checked = Convert.ToBoolean(r["IsFinal"]);
            chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ClearForm()
    {
        hfWorkflowStepId.Value = string.Empty;
        txtStepCode.Text = txtStepNameAr.Text = txtStepNameEn.Text = txtRequiredPermission.Text = string.Empty;
        txtSortOrder.Text = "100";
        chkIsFinal.Checked = false;
        chkIsActive.Checked = true;
    }

    private long? ParseLong(string value)
    {
        long result;
        if (long.TryParse(value, out result) && result > 0) return result;
        return null;
    }

    private int? ParseInt(string value)
    {
        int result;
        if (int.TryParse(value, out result)) return result;
        return null;
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

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

}
