using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class InvestigationTemplates : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("InvestigationTemplates.View");
        if (!IsPostBack)
        {
            LoadProjectTypes();
            LoadTemplates();
        }
    }

    private void LoadProjectTypes()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_ProjectTypes_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                ddlProjectType.DataSource = dt;
                ddlProjectType.DataTextField = "NameAr";
                ddlProjectType.DataValueField = "LookupItemId";
                ddlProjectType.DataBind();
                ddlProjectType.Items.Insert(0, new ListItem("-- كل أنواع المشاريع --", ""));
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadTemplates()
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_InvestigationTemplates_Get", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectTypeId", DataHelper.DbValue(DataHelper.SelectedLong(ddlProjectType)));
                cmd.Parameters.AddWithValue("@SearchText", DataHelper.DbValue(txtSearch.Text));
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                gvTemplates.DataSource = dt;
                gvTemplates.DataBind();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        pnlDetails.Visible = false;
        LoadTemplates();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = string.Empty;
        if (ddlProjectType.Items.Count > 0) ddlProjectType.SelectedIndex = 0;
        pnlDetails.Visible = false;
        LoadTemplates();
    }

    protected void gvTemplates_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        long templateId;
        if (!long.TryParse(Convert.ToString(e.CommandArgument), out templateId)) return;
        if (e.CommandName == "Details") LoadTemplateDetails(templateId);
    }

    private void LoadTemplateDetails(long templateId)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_InvestigationTemplate_GetDetails", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TemplateId", templateId);
                DataSet ds = new DataSet();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(ds);
                if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                {
                    ShowError("القالب غير موجود.");
                    return;
                }
                DataRow r = ds.Tables[0].Rows[0];
                litTemplateTitle.Text = Server.HtmlEncode(Convert.ToString(r["TemplateNameAr"]) + " - " + Convert.ToString(r["ProjectTypeNameAr"]));
                litTemplateSummary.Text = Server.HtmlEncode(Convert.ToString(r["ApplicabilitySummary"]));
                gvTemplateItems.DataSource = ds.Tables.Count > 1 ? ds.Tables[1] : new DataTable();
                gvTemplateItems.DataBind();
                pnlDetails.Visible = true;
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gsp-message gsp-message-danger";
        litMessage.Text = message;
    }
}
