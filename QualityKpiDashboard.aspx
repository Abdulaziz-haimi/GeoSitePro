<%@ Page Title="مؤشرات الجودة" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QualityKpiDashboard.aspx.cs" Inherits="QualityKpiDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مؤشرات الجودة - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">مؤشرات الجودة Quality KPI Dashboard</h1>
      <div class="gsp-page-subtitle">توليد ومراجعة مؤشرات جودة المشروع بناءً على اكتمال البيانات، الاعتمادات، المتابعة، والمخاطر المفتوحة.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkExecutive" runat="server" NavigateUrl="~/ExecutiveDashboard.aspx" CssClass="gsp-btn gsp-btn-secondary">لوحة المؤشرات</asp:HyperLink></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">توليد المؤشرات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div style="align-self:end"><asp:Button ID="btnGenerate" runat="server" Text="توليد Snapshot" CssClass="gsp-btn gsp-btn-primary" OnClick="btnGenerate_Click" /></div>
    </div>
    <p class="gsp-muted">اترك المشروع على “كل المشاريع” لتوليد Snapshot لجميع المشاريع. المؤشر إرشادي داخلي وليس بديلًا عن مراجعة المهندس.</p>
  </div>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">متوسط الجودة</div><div class="gsp-stat-value"><asp:Literal ID="litAvgScore" runat="server" Text="0" />%</div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">مشاريع أقل من 70%</div><div class="gsp-stat-value"><asp:Literal ID="litLowScoreCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">متابعة مفتوحة</div><div class="gsp-stat-value"><asp:Literal ID="litOpenFollowUps" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">مخاطر عالية</div><div class="gsp-stat-value"><asp:Literal ID="litHighRisks" runat="server" Text="0" /></div></div>
  </div>
  <br />

  <div class="gsp-card">
    <h2 class="gsp-card-title">آخر مؤشرات الجودة</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvKpis" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مؤشرات. اضغط توليد Snapshot.">
      <Columns>
        <asp:BoundField DataField="SnapshotDate" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd}" />
        <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
        <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
        <asp:BoundField DataField="QualityScore" HeaderText="الجودة %" />
        <asp:BoundField DataField="TotalBoreholes" HeaderText="جسات" />
        <asp:BoundField DataField="TotalSamples" HeaderText="عينات" />
        <asp:BoundField DataField="TotalLabResults" HeaderText="مختبر" />
        <asp:BoundField DataField="ApprovedLabResults" HeaderText="مختبر معتمد" />
        <asp:BoundField DataField="OpenFollowUps" HeaderText="متابعة" />
        <asp:BoundField DataField="OverdueFollowUps" HeaderText="متأخرة" />
        <asp:BoundField DataField="PendingApprovals" HeaderText="اعتمادات" />
        <asp:BoundField DataField="HighRisks" HeaderText="مخاطر عالية" />
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
