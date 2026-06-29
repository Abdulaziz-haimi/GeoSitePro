using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class FollowUpBoard : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("FollowUp.View");
        if (!IsPostBack)
        {
            LoadProjects();
            LoadUsers();
            if (QueryProjectId > 0) { SetSelected(ddlProject, QueryProjectId); SetSelected(ddlFilterProject, QueryProjectId); }
            btnSave.Visible = SecurityHelper.HasPermission("FollowUp.Create");
            LoadFollowUps();
        }
    }

    private void LoadProjects()
    {
        DataTable dt = ExecuteTable("sp_Projects_Get", new SqlParameter("@SearchText", DBNull.Value));
        ddlProject.DataSource = dt; ddlProject.DataTextField = "ProjectName"; ddlProject.DataValueField = "ProjectId"; ddlProject.DataBind(); ddlProject.Items.Insert(0, new ListItem("-- اختر المشروع --", ""));
        ddlFilterProject.DataSource = dt; ddlFilterProject.DataTextField = "ProjectName"; ddlFilterProject.DataValueField = "ProjectId"; ddlFilterProject.DataBind(); ddlFilterProject.Items.Insert(0, new ListItem("كل المشاريع", ""));
    }

    private void LoadUsers()
    {
        DataTable dt = ExecuteTable("sp_Users_Get", new SqlParameter("@SearchText", DBNull.Value), new SqlParameter("@IsActive", true));
        ddlAssignedTo.DataSource = dt; ddlAssignedTo.DataTextField = "FullName"; ddlAssignedTo.DataValueField = "UserId"; ddlAssignedTo.DataBind(); ddlAssignedTo.Items.Insert(0, new ListItem("-- غير محدد --", ""));
    }

    protected void btnLoad_Click(object sender, EventArgs e) { LoadFollowUps(); }
    protected void btnClear_Click(object sender, EventArgs e) { ClearForm(); }

    private void LoadFollowUps()
    {
        try
        {
            gvFollowUps.DataSource = ExecuteTable("sp_FollowUpItems_Get",
                new SqlParameter("@ProjectId", DataHelper.DbValue(DataHelper.SelectedLong(ddlFilterProject))),
                new SqlParameter("@Status", DataHelper.DbValue(ddlFilterStatus.SelectedValue)),
                new SqlParameter("@AssignedToUserId", DBNull.Value),
                new SqlParameter("@SearchText", DataHelper.DbValue(txtSearch.Text)));
            gvFollowUps.DataBind();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("FollowUp.Create")) { ShowError("لا تملك صلاحية حفظ بنود المتابعة."); return; }
        long? projectId = DataHelper.SelectedLong(ddlProject);
        if (!projectId.HasValue) { ShowError("اختر المشروع."); return; }
        if (string.IsNullOrWhiteSpace(txtTitle.Text)) { ShowError("عنوان البند مطلوب."); return; }
        DateTime dueDate;
        object dueValue = DateTime.TryParse(txtDueDate.Text, out dueDate) ? (object)dueDate.Date : DBNull.Value;
        long itemId = 0; long.TryParse(hfFollowUpItemId.Value, out itemId);
        long relatedId = 0; object relatedValue = long.TryParse(txtRelatedEntityId.Text, out relatedId) && relatedId > 0 ? (object)relatedId : DBNull.Value;
        try
        {
            ExecuteScalar("sp_FollowUpItem_Save",
                new SqlParameter("@FollowUpItemId", itemId == 0 ? (object)DBNull.Value : itemId),
                new SqlParameter("@ProjectId", projectId.Value),
                new SqlParameter("@RelatedEntityType", ddlRelatedEntityType.SelectedValue),
                new SqlParameter("@RelatedEntityId", relatedValue),
                new SqlParameter("@ItemTitle", txtTitle.Text.Trim()),
                new SqlParameter("@ItemDescription", DataHelper.DbValue(txtDescription.Text)),
                new SqlParameter("@DueDate", dueValue),
                new SqlParameter("@Priority", ddlPriority.SelectedValue),
                new SqlParameter("@AssignedToUserId", DataHelper.DbValue(DataHelper.SelectedLong(ddlAssignedTo))),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم حفظ بند المتابعة.");
            ClearForm();
            LoadFollowUps();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void gvFollowUps_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long id;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
        try
        {
            if (e.CommandName == "EditItem")
            {
                DataTable dt = ExecuteTable("sp_FollowUpItem_GetById", new SqlParameter("@FollowUpItemId", id));
                if (dt.Rows.Count > 0) BindForm(dt.Rows[0]);
            }
            else if (e.CommandName == "CloseItem")
            {
                if (!SecurityHelper.HasPermission("FollowUp.Close")) { ShowError("لا تملك صلاحية إغلاق بند المتابعة."); return; }
                ExecuteNonQuery("sp_FollowUpItem_Close", new SqlParameter("@FollowUpItemId", id), new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
                ShowSuccess("تم إغلاق بند المتابعة.");
                LoadFollowUps();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindForm(DataRow r)
    {
        hfFollowUpItemId.Value = Convert.ToString(r["FollowUpItemId"]);
        SetSelected(ddlProject, r["ProjectId"]);
        SetSelected(ddlRelatedEntityType, r["RelatedEntityType"]);
        txtRelatedEntityId.Text = Convert.ToString(r["RelatedEntityId"]);
        txtTitle.Text = Convert.ToString(r["ItemTitle"]);
        txtDescription.Text = Convert.ToString(r["ItemDescription"]);
        txtDueDate.Text = r["DueDate"] == DBNull.Value ? "" : Convert.ToDateTime(r["DueDate"]).ToString("yyyy-MM-dd");
        SetSelected(ddlPriority, r["Priority"]);
        SetSelected(ddlAssignedTo, r["AssignedToUserId"]);
    }

    private void ClearForm()
    {
        hfFollowUpItemId.Value = ""; txtTitle.Text = ""; txtDescription.Text = ""; txtDueDate.Text = ""; txtRelatedEntityId.Text = "";
        if (ddlProject.Items.Count > 0) ddlProject.SelectedIndex = 0;
        if (ddlAssignedTo.Items.Count > 0) ddlAssignedTo.SelectedIndex = 0;
        ddlPriority.SelectedValue = "Normal"; ddlRelatedEntityType.SelectedValue = "PROJECT";
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
