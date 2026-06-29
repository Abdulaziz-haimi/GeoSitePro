using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class QualityKpiDashboard : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long QueryProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("KpiDashboard.View");
        if (!IsPostBack)
        {
            BindProjects(ddlProject, true);
            if (QueryProjectId > 0) SetSelected(ddlProject, QueryProjectId);
            btnGenerate.Visible = SecurityHelper.HasPermission("KpiDashboard.Generate");
            LoadKpis();
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        if (!SecurityHelper.HasPermission("KpiDashboard.Generate")) { ShowError("لا تملك صلاحية توليد مؤشرات الجودة."); return; }
        try
        {
            ExecuteNonQuery("sp_QualityKpi_GenerateSnapshot",
                new SqlParameter("@ProjectId", DataHelper.DbValue(ParseLong(ddlProject.SelectedValue))),
                new SqlParameter("@UserId", SecurityHelper.CurrentUserId));
            ShowSuccess("تم توليد مؤشرات الجودة بنجاح.");
            LoadKpis();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void LoadKpis()
    {
        try
        {
            DataSet ds = ExecuteDataSet("sp_QualityKpi_Get", new SqlParameter("@ProjectId", DataHelper.DbValue(ParseLong(ddlProject.SelectedValue))));
            if (ds.Tables.Count > 0) { gvKpis.DataSource = ds.Tables[0]; gvKpis.DataBind(); }
            if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
            {
                DataRow r = ds.Tables[1].Rows[0];
                litAvgScore.Text = DataHelper.ToInt(r, "AvgScore").ToString();
                litLowScoreCount.Text = DataHelper.ToInt(r, "LowScoreCount").ToString();
                litOpenFollowUps.Text = DataHelper.ToInt(r, "OpenFollowUps").ToString();
                litHighRisks.Text = DataHelper.ToInt(r, "HighRisks").ToString();
            }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
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
