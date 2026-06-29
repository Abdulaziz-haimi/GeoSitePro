using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class BoreholeLogPrint : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long ProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }
    private long BoreholeId { get { return DataHelper.GetQueryId(Request, "BoreholeId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("PrintOutputs.Print");
        if (!IsPostBack) RenderLogs();
    }

    private void RenderLogs()
    {
        if (ProjectId <= 0) { ShowError("رقم المشروع غير صحيح."); return; }
        try
        {
            List<long> boreholeIds = new List<long>();
            if (BoreholeId > 0) boreholeIds.Add(BoreholeId);
            else
            {
                DataTable index = ExecuteTable("sp_Print_Boreholes_Index", new SqlParameter("@ProjectId", ProjectId));
                foreach (DataRow r in index.Rows) boreholeIds.Add(Convert.ToInt64(r["BoreholeId"]));
            }

            if (boreholeIds.Count == 0) { ShowError("لا توجد جسات للطباعة في هذا المشروع."); return; }

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < boreholeIds.Count; i++)
            {
                AppendSingleLog(sb, boreholeIds[i]);
                if (i < boreholeIds.Count - 1) sb.Append("<div class='page-break'></div>");
            }
            litLogs.Text = sb.ToString();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
    }

    private void AppendSingleLog(StringBuilder sb, long boreholeId)
    {
        DataTable header = ExecuteTable("sp_Print_Borehole_Header", new SqlParameter("@ProjectId", ProjectId), new SqlParameter("@BoreholeId", boreholeId));
        if (header.Rows.Count == 0) return;
        DataRow h = header.Rows[0];
        sb.Append("<div class='log-title'><div><h1 class='print-title'>Borehole Log - سجل الجسة</h1>");
        sb.Append("<div class='print-subtitle'>" + Html(h["ProjectCode"]) + " - " + Html(h["ProjectName"]) + "</div></div>");
        sb.Append("<div><span class='badge'>" + Html(h["BoreholeCode"]) + "</span><br/><span class='muted'>Generated: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm") + "</span></div></div>");

        sb.Append("<div class='section'><h2>بيانات الجسة Borehole Information</h2>");
        sb.Append(MetaTable(h, new string[,] {
            {"كود الجسة", "BoreholeCode"}, {"العمق المخطط", "PlannedDepthM"}, {"العمق الفعلي", "ActualDepthM"}, {"طريقة الحفر", "DrillingMethod"},
            {"Easting", "Easting"}, {"Northing", "Northing"}, {"Elevation", "ElevationM"}, {"GWT", "GroundwaterDepthM"},
            {"تاريخ البداية", "StartDate"}, {"تاريخ النهاية", "EndDate"}, {"المهندس الحقلي", "FieldEngineer"}, {"سبب الإنهاء", "TerminationReason"}
        }));
        sb.Append("</div>");

        AppendDataSection(sb, "الطبقات Soil/Rock Layers", ExecuteTable("sp_Print_Borehole_Layers", new SqlParameter("@BoreholeId", boreholeId)),
            new string[] {"FromDepthM","ToDepthM","SoilRockType","USCS","Description","Color","ConsistencyDensity","MoistureCondition","RecoveryPercent","RQDPercent"});
        AppendDataSection(sb, "العينات Samples", ExecuteTable("sp_Print_Borehole_Samples", new SqlParameter("@BoreholeId", boreholeId)),
            new string[] {"SampleCode","FromDepthM","ToDepthM","SampleType","SampleQuality","RecoveryLengthM","TakenDate","RequiredTests"});
        AppendDataSection(sb, "اختبارات SPT", ExecuteTable("sp_Print_Borehole_SPT", new SqlParameter("@BoreholeId", boreholeId)),
            new string[] {"TestDepthM","BlowCount1","BlowCount2","BlowCount3","NValue","CorrectedN","RecoveryLengthM","TestDate"});
        AppendDataSection(sb, "المياه الجوفية Groundwater", ExecuteTable("sp_Print_Borehole_Groundwater", new SqlParameter("@BoreholeId", boreholeId)),
            new string[] {"ObservationDate","DepthToWaterM","ObservationType","CasingDepthM","StabilizedAfterHours","Notes"});
        sb.Append("<div class='footer-note'>يجب مراجعة سجل الجسة واعتماده من المهندس المختص قبل استخدامه في تقرير رسمي.</div>");
    }

    private void AppendDataSection(StringBuilder sb, string title, DataTable dt, string[] columns)
    {
        sb.Append("<div class='section'><h2>" + Server.HtmlEncode(title) + "</h2>");
        sb.Append(ToHtmlTable(dt, columns));
        sb.Append("</div>");
    }

    private string MetaTable(DataRow row, string[,] fields)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='meta-table'>");
        for (int i = 0; i < fields.GetLength(0); i += 2)
        {
            sb.Append("<tr>");
            AppendMetaCell(sb, row, fields[i,0], fields[i,1]);
            if (i + 1 < fields.GetLength(0)) AppendMetaCell(sb, row, fields[i+1,0], fields[i+1,1]);
            else sb.Append("<th></th><td></td>");
            sb.Append("</tr>");
        }
        sb.Append("</table>");
        return sb.ToString();
    }

    private void AppendMetaCell(StringBuilder sb, DataRow row, string label, string column)
    {
        sb.Append("<th>" + Server.HtmlEncode(label) + "</th><td>" + Html(row.Table.Columns.Contains(column) ? row[column] : null) + "</td>");
    }

    private string ToHtmlTable(DataTable dt, string[] columns)
    {
        if (dt == null || dt.Rows.Count == 0) return "<p class='muted'>لا توجد بيانات.</p>";
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='data-table'><thead><tr>");
        foreach (string c in columns) sb.Append("<th>" + Server.HtmlEncode(c) + "</th>");
        sb.Append("</tr></thead><tbody>");
        foreach (DataRow r in dt.Rows)
        {
            sb.Append("<tr>");
            foreach (string c in columns) sb.Append("<td>" + Html(dt.Columns.Contains(c) ? r[c] : null) + "</td>");
            sb.Append("</tr>");
        }
        sb.Append("</tbody></table>");
        return sb.ToString();
    }

    private string Html(object value)
    {
        if (value == null || value == DBNull.Value) return "-";
        if (value is DateTime) return ((DateTime)value).ToString("yyyy-MM-dd");
        return Server.HtmlEncode(Convert.ToString(value));
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

    private void ShowError(string message)
    {
        pnlMessage.Visible = true;
        litMessage.Text = "<div style='background:#fee2e2;color:#991b1b;border:1px solid #fecaca;border-radius:10px;padding:12px'>" + message + "</div>";
    }
}
