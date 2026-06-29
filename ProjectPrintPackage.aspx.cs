using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;

public partial class ProjectPrintPackage : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }
    private long ProjectId { get { return DataHelper.GetQueryId(Request, "ProjectId"); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequirePermission("PrintOutputs.Print");
        if (!IsPostBack) RenderPackage();
    }

    private void RenderPackage()
    {
        if (ProjectId <= 0) { ShowError("رقم المشروع غير صحيح."); return; }
        try
        {
            DataTable header = ExecuteTable("sp_Print_ProjectHeader", new SqlParameter("@ProjectId", ProjectId));
            if (header.Rows.Count == 0) { ShowError("المشروع غير موجود."); return; }

            StringBuilder sb = new StringBuilder();
            DataRow h = header.Rows[0];
            sb.Append("<div class='log-title'><div><h1 class='print-title'>GeoSite Pro - حزمة طباعة المشروع</h1>");
            sb.Append("<div class='print-subtitle'>" + Html(h["ProjectCode"]) + " - " + Html(h["ProjectName"]) + "</div></div>");
            sb.Append("<div><span class='badge'>Generated: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm") + "</span></div></div>");

            sb.Append("<div class='section'><h2>1. بيانات المشروع Project Information</h2>");
            sb.Append(MetaTable(h, new string[,] {
                {"كود المشروع", "ProjectCode"}, {"اسم المشروع", "ProjectName"}, {"العميل", "ClientName"}, {"نوع المشروع", "ProjectTypeNameAr"},
                {"نوع المنشأ", "StructureTypeNameAr"}, {"مرحلة التحري", "InvestigationStageNameAr"}, {"المدينة", "City"}, {"الموقع", "LocationName"},
                {"المساحة م²", "SiteAreaM2"}, {"الأدوار/البدرومات", "FloorsBasements"}, {"تاريخ البداية", "ProjectStartDate"}, {"تاريخ النهاية", "ProjectEndDate"}
            }));
            sb.Append("</div>");

            AppendDataSection(sb, "2. ملخص الجسات Boreholes Summary", ExecuteTable("sp_Print_Boreholes_Index", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"BoreholeCode","ActualDepthM","Easting","Northing","ElevationM","GroundwaterDepthM","FieldEngineer","StartDate","EndDate"});
            AppendDataSection(sb, "3. العينات Samples Register", ExecuteTable("sp_Print_ProjectSamples", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"BoreholeCode","SampleCode","FromDepthM","ToDepthM","SampleType","SampleQuality","TakenDate","RequiredTests"});
            AppendDataSection(sb, "4. ملخص SPT", ExecuteTable("sp_Print_ProjectSPT", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"BoreholeCode","TestDepthM","BlowCount1","BlowCount2","BlowCount3","NValue","CorrectedN","TestDate"});
            AppendDataSection(sb, "5. المياه الجوفية Groundwater", ExecuteTable("sp_Print_ProjectGroundwater", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"BoreholeCode","ObservationDate","DepthToWaterM","ObservationType","CasingDepthM","StabilizedAfterHours"});
            AppendDataSection(sb, "6. نتائج المختبر Lab Results", ExecuteTable("sp_Print_ProjectLabResults", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"BoreholeCode","SampleCode","LabTestType","TestStandard","TestDate","NumericValue","Unit","ResultValue","IsApprovedText"});
            AppendDataSection(sb, "7. فهرس التقارير Technical Reports", ExecuteTable("sp_Print_ProjectReports", new SqlParameter("@ProjectId", ProjectId)),
                new string[] {"ReportNo","ReportTitle","ReportType","ReportStatus","RevisionNo","IssueDate","PreparedBy","ApprovedBy"});

            sb.Append("<div class='footer-note'>هذه الحزمة مخصصة للمراجعة والطباعة من النظام. الاعتماد الرسمي يتطلب مراجعة المهندس المختص وتوقيع/ختم الجهة المخولة.</div>");
            litPackage.Text = sb.ToString();
        }
        catch (Exception ex) { ShowError(Server.HtmlEncode(ex.Message)); }
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
