using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

public partial class DataExportDownload : System.Web.UI.Page
{
    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["GeoSiteProConnection"].ConnectionString; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        SecurityHelper.RequireLogin();
        string dataset = (Request.QueryString["Dataset"] ?? "").Trim().ToUpperInvariant();
        long projectId = DataHelper.GetQueryId(Request, "ProjectId");
        if (projectId <= 0 || string.IsNullOrWhiteSpace(dataset)) WriteError("Invalid export request.");

        bool gis = dataset.StartsWith("GIS_") || dataset.StartsWith("CAD_") || dataset.StartsWith("CROSS_");
        string permission = gis ? "GisCadExport.Export" : "DataExchange.Export";
        SecurityHelper.RequirePermission(permission);

        ExportDefinition def;
        Dictionary<string, ExportDefinition> map = BuildMap();
        if (!map.TryGetValue(dataset, out def)) WriteError("Unsupported dataset: " + Server.HtmlEncode(dataset));

        DataTable dt = ExecuteExport(def.StoredProcedure, projectId);
        string fileName = BuildFileName(projectId, dataset, def.FileSuffix);
        SaveJob(projectId, dataset, "CSV", fileName, dt.Rows.Count, "Completed", null);
        WriteCsv(dt, fileName);
    }

    private Dictionary<string, ExportDefinition> BuildMap()
    {
        return new Dictionary<string, ExportDefinition>(StringComparer.OrdinalIgnoreCase)
        {
            { "BOREHOLES", new ExportDefinition("sp_Export_Boreholes_CSV", "boreholes") },
            { "BOREHOLE_LAYERS", new ExportDefinition("sp_Export_BoreholeLayers_CSV", "borehole_layers") },
            { "SAMPLES", new ExportDefinition("sp_Export_Samples_CSV", "samples") },
            { "SPT", new ExportDefinition("sp_Export_SPT_CSV", "spt") },
            { "GROUNDWATER", new ExportDefinition("sp_Export_Groundwater_CSV", "groundwater") },
            { "LAB_RESULTS", new ExportDefinition("sp_Export_LabResults_CSV", "lab_results") },
            { "REPORTS_INDEX", new ExportDefinition("sp_Export_ReportsIndex_CSV", "reports_index") },
            { "GIS_BOREHOLE_POINTS", new ExportDefinition("sp_Export_GIS_BoreholePoints", "gis_borehole_points") },
            { "GIS_LAYER_INTERVALS", new ExportDefinition("sp_Export_GIS_LayerIntervals", "gis_layer_intervals") },
            { "CAD_POINT_SCHEDULE", new ExportDefinition("sp_Export_CAD_PointSchedule", "cad_point_schedule") },
            { "CROSS_SECTION_LAYERS", new ExportDefinition("sp_Export_CrossSectionLayers", "cross_section_layers") }
        };
    }

    private DataTable ExecuteExport(string proc, long projectId)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(proc, con))
        {
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProjectId", projectId);
            DataTable dt = new DataTable();
            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }
    }

    private void SaveJob(long projectId, string dataset, string format, string fileName, int rowCount, string status, string notes)
    {
        try
        {
            using (SqlConnection con = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand("sp_DataExportJob_Save", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ProjectId", projectId);
                cmd.Parameters.AddWithValue("@DatasetCode", dataset);
                cmd.Parameters.AddWithValue("@ExportFormat", format);
                cmd.Parameters.AddWithValue("@FileName", fileName);
                cmd.Parameters.AddWithValue("@RowCount", rowCount);
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@RequestedBy", SecurityHelper.CurrentUserId);
                cmd.Parameters.AddWithValue("@Notes", string.IsNullOrWhiteSpace(notes) ? (object)DBNull.Value : notes);
                con.Open(); cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private string BuildFileName(long projectId, string dataset, string suffix)
    {
        return "GeoSitePro_Project_" + projectId + "_" + suffix + "_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv";
    }

    private void WriteCsv(DataTable dt, string fileName)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.ContentType = "text/csv; charset=utf-8";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
        Response.ContentEncoding = Encoding.UTF8;
        Response.BinaryWrite(Encoding.UTF8.GetPreamble());

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Columns.Count; i++)
        {
            if (i > 0) sb.Append(',');
            sb.Append(Csv(dt.Columns[i].ColumnName));
        }
        sb.AppendLine();

        foreach (DataRow row in dt.Rows)
        {
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append(Csv(row[i]));
            }
            sb.AppendLine();
        }

        Response.Write(sb.ToString());
        Response.Flush();
        Response.End();
    }

    private string Csv(object value)
    {
        if (value == null || value == DBNull.Value) return "";
        string s = Convert.ToString(value);
        s = s.Replace("\r\n", " ").Replace("\n", " ").Replace("\r", " ");
        if (s.Contains(",") || s.Contains("\"") || s.Contains(";")) s = "\"" + s.Replace("\"", "\"\"") + "\"";
        return s;
    }

    private void WriteError(string message)
    {
        Response.Clear();
        Response.ContentType = "text/plain; charset=utf-8";
        Response.Write(message);
        Response.End();
    }

    private class ExportDefinition
    {
        public string StoredProcedure { get; private set; }
        public string FileSuffix { get; private set; }
        public ExportDefinition(string storedProcedure, string fileSuffix)
        {
            StoredProcedure = storedProcedure;
            FileSuffix = fileSuffix;
        }
    }
}
