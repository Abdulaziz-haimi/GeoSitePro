<%@ Page Title="سجل التدقيق" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AuditLog.aspx.cs" Inherits="AuditLog" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">سجل التدقيق - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">سجل التدقيق Audit Log</h1>
      <div class="gsp-page-subtitle">متابعة عمليات الدخول، الإضافة، التعديل، الحذف، والاعتماد داخل النظام.</div>
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">فلاتر البحث</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="المستخدم، الوصف، الكيان، رقم السجل..." /></div>
      <div><label class="gsp-label">نوع العملية</label><asp:TextBox ID="txtActionType" runat="server" CssClass="gsp-input" placeholder="Login, Insert, Update, Delete..." /></div>
      <div><label class="gsp-label">الكيان</label><asp:TextBox ID="txtEntityName" runat="server" CssClass="gsp-input" placeholder="Projects, Users, Boreholes..." /></div>
      <div><label class="gsp-label">المستخدم</label><asp:DropDownList ID="ddlUser" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">من تاريخ</label><asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">إلى تاريخ</label><asp:TextBox ID="txtDateTo" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">آخر العمليات</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvAuditLog" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد سجلات تدقيق.">
        <Columns>
          <asp:BoundField DataField="ActionDate" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
          <asp:BoundField DataField="Username" HeaderText="المستخدم" />
          <asp:BoundField DataField="ActionType" HeaderText="العملية" />
          <asp:BoundField DataField="EntityName" HeaderText="الكيان" />
          <asp:BoundField DataField="EntityId" HeaderText="رقم السجل" />
          <asp:BoundField DataField="ActionDescription" HeaderText="الوصف" />
          <asp:BoundField DataField="IpAddress" HeaderText="IP" />
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
