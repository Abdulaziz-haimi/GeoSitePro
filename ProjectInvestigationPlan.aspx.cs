using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ProjectInvestigationPlan : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long CurrentPlanId
    {
        get { object v = ViewState["CurrentPlanId"]; long id; return v != null && long.TryParse(Convert.ToString(v), out id) ? id : 0; }
        set { ViewState["CurrentPlanId"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("ProjectInvestigationPlan.View");
        if (!IsPostBack)
        {
            ApplyPermissions();
            LoadProjects();
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            LoadSelectedProject();
        }
    }

    private void ApplyPermissions()
    {
        btnGenerate.Visible = SecurityHelper.HasPermission("ProjectInvestigationPlan.Generate");
        btnApprove.Visible = SecurityHelper.HasPermission("ProjectInvestigationPlan.Approve");
    }

    private long SelectedProjectId
    {
        get
        {
            long id;
            return long.TryParse(ddlProject.SelectedValue, out id) ? id : 0;
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
                cmd.Parameters.AddWithValue("@SearchText", DBNull.Value);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlProject.DataSource = dt;
                ddlProject.DataTextField = "ProjectName";
                ddlProject.DataValueField = "ProjectId";
                ddlProject.DataBind();
                ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void ddlProject_SelectedIndexChanged(object sender, EventArgs e) { LoadSelectedProject(); }
    protected void btnLoadProject_Click(object sender, EventArgs e) { LoadSelectedProject(); }

    private void LoadSelectedProject()
    {
        HideMessage();
        CurrentPlanId = 0;
        pnlProject.Visible = false;
        pnlGenerate.Visible = false;
        pnlPlans.Visible = false;
        pnlPlanItems.Visible = false;
        if (SelectedProjectId <= 0) return;
        LoadProjectBrief();
        LoadSuggestedTemplates();
        LoadPlans();
    }

    private void LoadProjectBrief()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectDashboard_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }
                DataRow r = ds.Tables[0].Rows[0];
                litProjectTitle.Text = Server.HtmlEncode(Convert.ToString(r["ProjectCode"]) + " - " + Convert.ToString(r["ProjectName"]));
                litProjectType.Text = Server.HtmlEncode(Convert.ToString(r["ProjectTypeNameAr"]));
                litCity.Text = Server.HtmlEncode(Convert.ToString(r["City"]));
                litArea.Text = Server.HtmlEncode(Convert.ToString(r["SiteAreaM2"]));
                litFloors.Text = Server.HtmlEncode(Convert.ToString(r["NumberOfFloors"]) + " / بدرومات: " + Convert.ToString(r["BasementCount"]));
                pnlProject.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadSuggestedTemplates()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationTemplates_Suggest", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlTemplate.DataSource = dt;
                ddlTemplate.DataTextField = "TemplateNameAr";
                ddlTemplate.DataValueField = "TemplateId";
                ddlTemplate.DataBind();
                if (ddlTemplate.Items.Count == 0) ddlTemplate.Items.Insert(0, new ListItem("لا يوجد قالب مناسب", ""));
                pnlGenerate.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadPlans()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlans_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvPlans.DataSource = dt;
                gvPlans.DataBind();
                pnlPlans.Visible = true;
                if (dt.Rows.Count > 0 && CurrentPlanId <= 0)
                {
                    long id;
                    if (long.TryParse(Convert.ToString(dt.Rows[0]["PlanId"]), out id)) LoadPlan(id);
                }
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("ProjectInvestigationPlan.Generate")) { ShowError("لا تملك صلاحية توليد خطة التحري."); return; }
        if (SelectedProjectId <= 0) { ShowError("اختر المشروع أولًا."); return; }
        long templateId;
        if (!long.TryParse(ddlTemplate.SelectedValue, out templateId)) templateId = 0;
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlan_Generate", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", SelectedProjectId);
                cmd.Parameters.AddWithValue("@TemplateId", templateId > 0 ? (object)templateId : DBNull.Value);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open();
                object result = cmd.ExecuteScalar();
                long planId;
                if (result != null && long.TryParse(Convert.ToString(result), out planId)) CurrentPlanId = planId;
            }
            ShowSuccess("تم توليد خطة التحري بنجاح. راجع البنود وعدّلها قبل الاعتماد.");
            LoadPlans();
            if (CurrentPlanId > 0) LoadPlan(CurrentPlanId);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvPlans_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long planId;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out planId)) return;
        if (e.CommandName == "ViewPlan") LoadPlan(planId);
    }

    private void LoadPlan(long planId)
    {
        try
        {
            CurrentPlanId = planId;
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlan_GetById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PlanId", planId);
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                if (dt.Rows.Count == 0) { ShowError("الخطة غير موجودة."); return; }
                DataRow r = dt.Rows[0];
                litPlanTitle.Text = Server.HtmlEncode(Convert.ToString(r["PlanTitle"]));
                litPlanMeta.Text = Server.HtmlEncode("الإصدار: " + Convert.ToString(r["RevisionNo"]) + " | الحالة: " + Convert.ToString(r["PlanStatusNameAr"]) + " | القالب: " + Convert.ToString(r["TemplateNameAr"]));
                btnApprove.Visible = SecurityHelper.HasPermission("ProjectInvestigationPlan.Approve") && !(r["IsApproved"] != DBNull.Value && Convert.ToBoolean(r["IsApproved"]));
            }
            LoadPlanItems(planId);
            pnlPlanItems.Visible = true;
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadPlanItems(long planId)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlanItems_Get", con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@PlanId", planId);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            gvPlanItems.DataSource = dt;
            gvPlanItems.DataBind();
        }
    }

    protected void gvPlanItems_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "SaveItem") return;
        if (!SecurityHelper.HasPermission("ProjectInvestigationPlan.Edit")) { ShowError("لا تملك صلاحية تعديل خطة التحري."); return; }
        long planItemId;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out planItemId)) return;
        GridViewRow row = ((LinkButton)e.CommandSource).NamingContainer as GridViewRow;
        if (row == null) return;
        TextBox txtQty = row.FindControl("txtPlannedQuantity") as TextBox;
        TextBox txtSpacing = row.FindControl("txtPlannedSpacingM") as TextBox;
        TextBox txtDepth = row.FindControl("txtPlannedDepthM") as TextBox;
        TextBox txtNotes = row.FindControl("txtEngineerNotes") as TextBox;
        CheckBox chkAccepted = row.FindControl("chkIsAccepted") as CheckBox;
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlanItem_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PlanItemId", planItemId);
                cmd.Parameters.AddWithValue("@PlannedQuantity", DataHelper.DbValue(ParseDecimal(txtQty == null ? null : txtQty.Text)));
                cmd.Parameters.AddWithValue("@PlannedSpacingM", DataHelper.DbValue(ParseDecimal(txtSpacing == null ? null : txtSpacing.Text)));
                cmd.Parameters.AddWithValue("@PlannedDepthM", DataHelper.DbValue(ParseDecimal(txtDepth == null ? null : txtDepth.Text)));
                cmd.Parameters.AddWithValue("@IsAccepted", chkAccepted == null || chkAccepted.Checked);
                cmd.Parameters.AddWithValue("@EngineerNotes", DataHelper.DbValue(txtNotes == null ? null : txtNotes.Text));
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم حفظ البند.");
            LoadPlan(CurrentPlanId);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnApprove_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("ProjectInvestigationPlan.Approve")) { ShowError("لا تملك صلاحية اعتماد الخطة."); return; }
        if (CurrentPlanId <= 0) { ShowError("اختر خطة أولًا."); return; }
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectInvestigationPlan_Approve", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PlanId", CurrentPlanId);
                cmd.Parameters.AddWithValue("@ApprovalNotes", DBNull.Value);
                cmd.Parameters.AddWithValue("@UserId", SecurityHelper.CurrentUserId);
                con.Open(); cmd.ExecuteNonQuery();
            }
            ShowSuccess("تم اعتماد خطة التحري.");
            LoadPlans();
            LoadPlan(CurrentPlanId);
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private decimal? ParseDecimal(string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return null;
        decimal d;
        if (decimal.TryParse(text.Trim(), out d)) return d;
        return null;
    }

    private void SetSelected(DropDownList ddl, object value)
    {
        if (value == null || value == DBNull.Value) return;
        ListItem item = ddl.Items.FindByValue(Convert.ToString(value));
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private void HideMessage()
    {
        pnlMessage.Visible = false;
        litMessage.Text = string.Empty;
    }

    private void ShowSuccess(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-success";
        litMessage.Text = message;
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }
}
