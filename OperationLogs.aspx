<%@ Page Title="سجل التشغيل" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationLogs.aspx.cs" Inherits="OperationLogs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">سجل التشغيل - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">سجل التشغيل</h1><div class="gsp-page-subtitle">سجل إداري تقني للأحداث التشغيلية المهمة، منفصل عن سجل التدقيق Audit Log.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnRefresh" runat="server" Text="تحديث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnRefresh_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">الفلاتر</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المستوى</label><asp:DropDownList ID="ddlLogLevel" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الموديول</label><asp:TextBox ID="txtModule" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">من تاريخ</label><asp:TextBox ID="txtFromDate" runat="server" CssClass="gsp-input" TextMode="Date" /></div>
      <div><label class="gsp-label">إلى تاريخ</label><asp:TextBox ID="txtToDate" runat="server" CssClass="gsp-input" TextMode="Date" /></div>
    </div>
    <br /><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" />
  </div>

  <div class="gsp-card"><h2 class="gsp-card-title">الأحداث</h2><div class="gsp-table-wrap"><asp:GridView ID="gvOperationLogs" runat="server" CssClass="gsp-table" AutoGenerateColumns="true" GridLines="None" /></div></div>
</div>
</asp:Content>
