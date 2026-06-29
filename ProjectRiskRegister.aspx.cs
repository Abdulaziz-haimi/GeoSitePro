using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ProjectRiskRegister : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("Risks.View");
        if (!IsPostBack)
        {
            BindProjects(ddlProject, false);
            BindProjects(ddlFilterProject, true);
            BindUsers(ddlOwner);
            if (QueryProjectId > 0)
            {
                SetSelected(ddlProject, QueryProjectId);
                SetSelected(ddlFilterProject, QueryProjectId);
            }
            ApplyPermissions();
            LoadRisks();
        }
    }

    private void ApplyPermissions()
    {
        btnSave.Visible = SecurityHelper.HasPermission("Risks.Create") || SecurityHelper.HasPermission("Risks.Edit");
    }

    protected void btnLoad_Click(object sender, EventArgs e) { LoadRisks(); }
    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("Risks.Create") && !SecurityHelper.HasPermission("Risks.Edit")) { ShowError("لا تملك صلاحية حفظ المخاطر."); return; }
        if (string.IsNullOrWhiteSpace(ddlProject.SelectedValue) || string.IsNullOrWhiteSpace(txtRiskTitle.Text)) { ShowError("المشروع وعنوان الخطر حقول إلزامية."); return; }
        try
        {
            object id = ExecuteScalar("sp_ProjectRisk_Save",
                new SqlParameter("@RiskId", DataHelper.DbValue(ParseLong(hfRiskId.Value))),
                new SqlParameter("@ProjectId", DataHelper.DbValue(ParseLong(ddlProject.SelectedValue))),
                new SqlParameter("@RiskCode", DataHelper.DbValue(txtRiskCode.Text)),
                new SqlParameter("@RiskCategory", DataHelper.DbValue(ddlRiskCategory.SelectedValue)),
                new SqlParameter("@RiskTitle", txtRiskTitle.Text.Trim()),
                new SqlParameter("@RiskDescription", DataHelper.DbValue(txtRiskDescription.Text)),
                new SqlParameter("@ProbabilityLevel", DataHelper.DbValue(ParseInt(ddlProbability.SelectedValue))),
                new SqlParameter("@ImpactLevel", DataHelper.DbValue(ParseInt(ddlImpact.SelectedValue))),
                new SqlParameter("@MitigationPlan", DataHelper.DbValue(txtMitigationPlan.Text)),
                new SqlParameter("@OwnerUserId", DataHelper.DbValue(ParseLong(ddlOwner.SelectedValue))),
                new SqlParameter("@DueDate", DataHelper.DbValue(ParseDate(txtDueDate.Text))),
                new SqlParameter("@Status", ddlStatus.SelectedValue),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            hfRiskId.Value = Convert.ToString(id);
            ShowSuccess("تم حفظ الخطر بنجاح.");
            LoadRisks();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvRisks_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        if (e.CommandName == "EditItem") LoadRisk(id);
        if (e.CommandName == "CloseItem")
        {
            if (!SecurityHelper.HasPermission("Risks.Close")) { ShowError("لا تملك صلاحية إغلاق المخاطر."); return; }
            try
            {
                ExecuteNonQuery("sp_ProjectRisk_UpdateStatus", new SqlParameter("@RiskId", id), new SqlParameter("@Status", "Closed"), new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
                ShowSuccess("تم إغلاق الخطر.");
                LoadRisks();
            }
            catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
        }
    }

    private void LoadRisks()
    {
        try
        {
            gvRisks.DataSource = ExecuteTable("sp_ProjectRisks_Get",
                new SqlParameter("@ProjectId", DataHelper.DbValue(ParseLong(ddlFilterProject.SelectedValue))),
                new SqlParameter("@Status", DataHelper.DbValue(ddlFilterStatus.SelectedValue)),
                new SqlParameter("@RiskLevel", DataHelper.DbValue(ddlFilterRiskLevel.SelectedValue)),
                new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)));
            gvRisks.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadRisk(long id)
    {
        try
        {
            DataTable dt = ExecuteTable("sp_ProjectRisk_GetById", new SqlParameter("@RiskId", id));
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];
            hfRiskId.Value = Convert.ToString(r["RiskId"]);
            SetSelected(ddlProject, r["ProjectId"]);
            txtRiskCode.Text = Convert.ToString(r["RiskCode"]);
            SetSelected(ddlRiskCategory, r["RiskCategory"]);
            txtRiskTitle.Text = Convert.ToString(r["RiskTitle"]);
            txtRiskDescription.Text = Convert.ToString(r["RiskDescription"]);
            SetSelected(ddlProbability, r["ProbabilityLevel"]);
            SetSelected(ddlImpact, r["ImpactLevel"]);
            txtMitigationPlan.Text = Convert.ToString(r["MitigationPlan"]);
            SetSelected(ddlOwner, r["OwnerUserId"]);
            if (r["DueDate"] != DBNull.Value) txtDueDate.Text = Convert.ToDateTime(r["DueDate"]).ToString("yyyy-MM-dd");
            else txtDueDate.Text = "";
            SetSelected(ddlStatus, r["Status"]);
            ShowSuccess("تم تحميل الخطر للتعديل.");
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ClearForm()
    {
        hfRiskId.Value = "";
        txtRiskCode.Text = txtRiskTitle.Text = txtRiskDescription.Text = txtMitigationPlan.Text = txtDueDate.Text = "";
        ddlProbability.SelectedValue = "3";
        ddlImpact.SelectedValue = "3";
        ddlStatus.SelectedValue = "Open";
        if (ddlOwner.Items.Count > 0) ddlOwner.SelectedIndex = 0;
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

    private void BindProjects(DropDownList ddl, bool includeAll)
    {
        DataTable dt = ExecuteTable("sp_Projects_Lookup");
        ddl.DataTextField = "ProjectDisplay";
        ddl.DataValueField = "ProjectId";
        ddl.DataSource = dt;
        ddl.DataBind();
        if (includeAll) ddl.Items.Insert(0, new ListItem("كل المشاريع", ""));
        else ddl.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
    }

    private void BindUsers(DropDownList ddl)
    {
        DataTable dt = ExecuteTable("sp_Users_Lookup");
        ddl.DataTextField = "FullName";
        ddl.DataValueField = "UserId";
        ddl.DataSource = dt;
        ddl.DataBind();
        ddl.Items.Insert(0, new ListItem("-- غير محدد --", ""));
    }

    private int? ParseInt(string value)
    {
        int v;
        if (int.TryParse(value, out v)) return v;
        return null;
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

    private void SetSelected(DropDownList ddl, object value)
    {
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

}
