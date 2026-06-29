using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public static class SecurityHelper
{
    public static bool IsAuthenticated
    {
        get { return CurrentUserId > 0; }
    }

    public static long CurrentUserId
    {
        get
        {
            object value = HttpContext.Current.Session["UserId"];
            if (value == null) return 0;
            long id;
            long.TryParse(Convert.ToString(value), out id);
            return id;
        }
    }

    public static string CurrentUsername
    {
        get
        {
            object value = HttpContext.Current.Session["Username"];
            return value == null ? string.Empty : Convert.ToString(value);
        }
    }

    public static string CurrentFullName
    {
        get
        {
            object value = HttpContext.Current.Session["FullName"];
            return value == null ? string.Empty : Convert.ToString(value);
        }
    }

    public static void SetUserSession(long userId, string username, string fullName, List<string> permissions)
    {
        HttpContext.Current.Session["UserId"] = userId;
        HttpContext.Current.Session["Username"] = username;
        HttpContext.Current.Session["FullName"] = fullName;
        HttpContext.Current.Session["Permissions"] = permissions ?? new List<string>();
    }

    public static void ClearUserSession()
    {
        HttpContext.Current.Session.Clear();
        HttpContext.Current.Session.Abandon();
    }

    public static void RequireLogin()
    {
        if (!IsAuthenticated)
        {
            string returnUrl = HttpContext.Current.Request.RawUrl;
            HttpContext.Current.Response.Redirect("~/Login.aspx?ReturnUrl=" + HttpUtility.UrlEncode(returnUrl), true);
        }
    }

    public static void RequirePermission(string permissionCode)
    {
        RequireLogin();
        if (!HasPermission(permissionCode))
            HttpContext.Current.Response.Redirect("~/AccessDenied.aspx", true);
    }

    public static bool HasPermission(string permissionCode)
    {
        if (string.IsNullOrWhiteSpace(permissionCode)) return false;
        object value = HttpContext.Current.Session["Permissions"];
        List<string> permissions = value as List<string>;
        if (permissions == null) return false;
        return permissions.Any(p => string.Equals(p, permissionCode, StringComparison.OrdinalIgnoreCase));
    }
}
