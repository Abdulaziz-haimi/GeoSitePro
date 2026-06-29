using System;
using System.Data;
using System.Web.UI.WebControls;

public static class DataHelper
{
    public static object DbValue(string value)
    {
        return string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim();
    }

    public static object DbValue(long? value)
    {
        return value.HasValue && value.Value > 0 ? (object)value.Value : DBNull.Value;
    }

    public static object DbValue(decimal? value)
    {
        return value.HasValue ? (object)value.Value : DBNull.Value;
    }

    public static object DbValue(int? value)
    {
        return value.HasValue ? (object)value.Value : DBNull.Value;
    }

    public static object DbValue(DateTime? value)
    {
        return value.HasValue ? (object)value.Value.Date : DBNull.Value;
    }

    public static long? SelectedLong(DropDownList ddl)
    {
        long id;
        if (ddl == null || string.IsNullOrWhiteSpace(ddl.SelectedValue)) return null;
        if (long.TryParse(ddl.SelectedValue, out id) && id > 0) return id;
        return null;
    }

    public static long GetQueryId(System.Web.HttpRequest request, string key)
    {
        long id;
        long.TryParse(request.QueryString[key], out id);
        return id;
    }

    public static int ToInt(DataRow row, string columnName)
    {
        if (row == null || !row.Table.Columns.Contains(columnName) || row[columnName] == DBNull.Value) return 0;
        int result;
        int.TryParse(Convert.ToString(row[columnName]), out result);
        return result;
    }
}
