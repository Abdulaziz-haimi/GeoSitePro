<%@ Page Title="مركز النسخ الاحتياطي" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BackupCenter.aspx.cs" Inherits="BackupCenter" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مركز النسخ الاحتياطي - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">مركز النسخ الاحتياطي</h1><div class="gsp-page-subtitle">تسجيل طلبات النسخ الاحتياطي وتوليد أمر SQL آمن ينفذه مسؤول قاعدة البيانات من SQL Server Management Studio.</div></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">طلب نسخة احتياطية</h2>
    <p class="gsp-muted">ملاحظة: لأسباب أمنية، الصفحة لا تنفذ BACKUP DATABASE مباشرة من الويب؛ بل تحفظ الطلب وتولد أمر SQL قابل للمراجعة والتنفيذ من مسؤول قاعدة البيانات.</p>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">نوع النسخة</label><asp:DropDownList ID="ddlBackupType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">مسار الحفظ على السيرفر</label><asp:TextBox ID="txtBackupPath" runat="server" CssClass="gsp-input" Text="C:\GeoSiteProBackups" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnCreateBackupRequest" runat="server" Text="إنشاء طلب نسخة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnCreateBackupRequest_Click" />
      <asp:Button ID="btnGenerateCommand" runat="server" Text="توليد أمر SQL فقط" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnGenerateCommand_Click" />
    </div>
    <br />
    <asp:Panel ID="pnlCommand" runat="server" Visible="false" CssClass="gsp-card" style="background:#f9fafb">
      <h3 class="gsp-card-title">أمر SQL المقترح</h3>
      <pre style="white-space:pre-wrap;direction:ltr;text-align:left"><asp:Literal ID="litBackupCommand" runat="server" /></pre>
    </asp:Panel>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">طلبات النسخ الاحتياطي</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvBackupJobs" runat="server" CssClass="gsp-table" AutoGenerateColumns="true" GridLines="None" /></div>
  </div>
</div>
</asp:Content>
