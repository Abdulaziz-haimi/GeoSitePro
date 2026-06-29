<%@ Page Title="تسجيل الدخول" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Login" %>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head runat="server">
    <meta charset="utf-8" />
    <title>تسجيل الدخول - GeoSite Pro</title>
    <style>
        body{margin:0;min-height:100vh;background:linear-gradient(135deg,#0f766e,#064e3b);font-family:"Segoe UI",Tahoma,Arial,sans-serif;direction:rtl;display:flex;align-items:center;justify-content:center}.login-card{width:430px;background:#fff;border-radius:18px;padding:32px;box-shadow:0 20px 60px rgba(0,0,0,.25);box-sizing:border-box}.brand{text-align:center;margin-bottom:26px}.brand-title{font-size:30px;font-weight:900;color:#0f766e;margin-bottom:6px}.brand-subtitle{color:#6b7280;font-size:14px;line-height:1.7}.form-group{margin-bottom:16px}label{display:block;font-weight:800;margin-bottom:7px;color:#374151}.input{width:100%;border:1px solid #d1d5db;border-radius:10px;padding:12px 13px;font-size:15px;box-sizing:border-box;outline:none}.input:focus{border-color:#0f766e;box-shadow:0 0 0 3px rgba(15,118,110,.12)}.btn{width:100%;border:0;border-radius:10px;padding:13px;background:#0f766e;color:#fff;font-size:15px;font-weight:900;cursor:pointer}.btn:hover{background:#115e59}.message{border-radius:10px;padding:12px;margin-bottom:16px;font-size:14px}.message-danger{background:#fee2e2;color:#991b1b;border:1px solid #fecaca}.hint{margin-top:18px;color:#6b7280;text-align:center;font-size:13px;line-height:1.7}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="login-card">
        <div class="brand">
            <div class="brand-title">GeoSite Pro</div>
            <div class="brand-subtitle">نظام إدارة مشاريع التحري الموقعي والتقارير الجيوتقنية</div>
        </div>
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="message message-danger"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
        <div class="form-group"><label>اسم الدخول</label><asp:TextBox ID="txtUsername" runat="server" CssClass="input" autocomplete="username" placeholder="admin" /></div>
        <div class="form-group"><label>كلمة المرور</label><asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" autocomplete="current-password" placeholder="••••••••" /></div>
        <asp:Button ID="btnLogin" runat="server" Text="تسجيل الدخول" CssClass="btn" OnClick="btnLogin_Click" />
        <div class="hint">الدخول التجريبي بعد تشغيل SQL: admin / Admin@123</div>
    </div>
</form>
</body>
</html>
