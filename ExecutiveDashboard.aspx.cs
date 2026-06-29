using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class ExecutiveDashboard : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("ExecutiveDashboard.View");
        if (!IsPostBack) LoadDashboard();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    private void LoadDashboard()
    {
        try
        {
            DataSet ds = ExecuteDataSet("sp_ExecutiveDashboard_GetSummary");
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) BindSummary(ds.Tables[0].Rows[0]);
            if (ds.Tables.Count > 1) { gvTopRisks.DataSource = ds.Tables[1]; gvTopRisks.DataBind(); }
            if (ds.Tables.Count > 2) { gvQualityScores.DataSource = ds.Tables[2]; gvQualityScores.DataBind(); }
            if (ds.Tables.Count > 3) { gvAttention.DataSource = ds.Tables[3]; gvAttention.DataBind(); }
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void BindSummary(DataRow r)
    {
        litTotalProjects.Text = DataHelper.ToInt(r, "TotalProjects").ToString();
        litActiveProjects.Text = DataHelper.ToInt(r, "ActiveProjects").ToString();
        litTotalBoreholes.Text = DataHelper.ToInt(r, "TotalBoreholes").ToString();
        litTotalLabResults.Text = DataHelper.ToInt(r, "TotalLabResults").ToString();
        litPendingApprovals.Text = DataHelper.ToInt(r, "PendingApprovals").ToString();
        litOverdueFollowUps.Text = DataHelper.ToInt(r, "OverdueFollowUps").ToString();
        litHighRisks.Text = DataHelper.ToInt(r, "HighRisks").ToString();
        litAverageQualityScore.Text = DataHelper.ToInt(r, "AverageQualityScore").ToString();
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
