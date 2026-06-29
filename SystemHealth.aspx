<%@ Page Title="فحص صحة النظام" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SystemHealth.aspx.cs" Inherits="SystemHealth" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">فحص صحة النظام - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">فحص صحة النظام</h1><div class="gsp-page-subtitle">مراجعة سريعة لحالة الجداول الأساسية، الإعدادات، النسخ الاحتياطي، الاعتمادات، المتابعة، والمخاطر.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnRefresh" runat="server" Text="تحديث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnRefresh_Click" /><asp:Button ID="btnLogHealthCheck" runat="server" Text="تسجيل فحص تشغيل" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLogHealthCheck_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">الجداول المطلوبة</div><div class="gsp-stat-value"><asp:Literal ID="litRequiredTables" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">الجداول الناقصة</div><div class="gsp-stat-value"><asp:Literal ID="litMissingTables" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">الإعدادات النشطة</div><div class="gsp-stat-value"><asp:Literal ID="litActiveSettings" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">طلبات النسخ</div><div class="gsp-stat-value"><asp:Literal ID="litBackupJobs" runat="server" Text="0" /></div></div>
  </div>
  <br />
  <div class="gsp-card"><h2 class="gsp-card-title">نتائج الفحص</h2><div class="gsp-table-wrap"><asp:GridView ID="gvHealthChecks" runat="server" CssClass="gsp-table" AutoGenerateColumns="true" GridLines="None" /></div></div>
</div>
</asp:Content>
