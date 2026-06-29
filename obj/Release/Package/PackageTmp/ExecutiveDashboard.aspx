<%@ Page Title="لوحة المؤشرات التنفيذية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ExecutiveDashboard.aspx.cs" Inherits="ExecutiveDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">لوحة المؤشرات التنفيذية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">لوحة المؤشرات التنفيذية Executive Dashboard</h1>
      <div class="gsp-page-subtitle">ملخص إداري لحالة المشاريع، الجسات، المختبر، الاعتمادات، المتابعة، والمخاطر الفنية.</div>
    </div>
    <div class="gsp-actions">
      <asp:Button ID="btnRefresh" runat="server" Text="تحديث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnRefresh_Click" />
      <asp:HyperLink ID="lnkRisks" runat="server" NavigateUrl="~/ProjectRiskRegister.aspx" CssClass="gsp-btn gsp-btn-warning">سجل المخاطر</asp:HyperLink>
      <asp:HyperLink ID="lnkKpis" runat="server" NavigateUrl="~/QualityKpiDashboard.aspx" CssClass="gsp-btn gsp-btn-secondary">مؤشرات الجودة</asp:HyperLink>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message gsp-message-danger"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي المشاريع</div><div class="gsp-stat-value"><asp:Literal ID="litTotalProjects" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">المشاريع النشطة</div><div class="gsp-stat-value"><asp:Literal ID="litActiveProjects" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي الجسات</div><div class="gsp-stat-value"><asp:Literal ID="litTotalBoreholes" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">نتائج المختبر</div><div class="gsp-stat-value"><asp:Literal ID="litTotalLabResults" runat="server" Text="0" /></div></div>
  </div>
  <br />
  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">اعتمادات معلقة</div><div class="gsp-stat-value"><asp:Literal ID="litPendingApprovals" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">متابعة متأخرة</div><div class="gsp-stat-value"><asp:Literal ID="litOverdueFollowUps" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">مخاطر عالية</div><div class="gsp-stat-value"><asp:Literal ID="litHighRisks" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">متوسط جودة المشاريع</div><div class="gsp-stat-value"><asp:Literal ID="litAverageQualityScore" runat="server" Text="0" />%</div></div>
  </div>
  <br />

  <div class="gsp-grid gsp-grid-2">
    <div class="gsp-card">
      <h2 class="gsp-card-title">أعلى المشاريع من ناحية المخاطر</h2>
      <div class="gsp-table-wrap"><asp:GridView ID="gvTopRisks" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مخاطر مسجلة.">
        <Columns>
          <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
          <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
          <asp:BoundField DataField="OpenRisks" HeaderText="مخاطر مفتوحة" />
          <asp:BoundField DataField="HighRisks" HeaderText="عالية" />
          <asp:BoundField DataField="MaxRiskScore" HeaderText="أعلى درجة" />
        </Columns>
      </asp:GridView></div>
    </div>

    <div class="gsp-card">
      <h2 class="gsp-card-title">مؤشرات الجودة حسب المشروع</h2>
      <div class="gsp-table-wrap"><asp:GridView ID="gvQualityScores" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مؤشرات جودة.">
        <Columns>
          <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
          <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
          <asp:BoundField DataField="QualityScore" HeaderText="الجودة %" />
          <asp:BoundField DataField="OpenFollowUps" HeaderText="متابعة" />
          <asp:BoundField DataField="PendingApprovals" HeaderText="اعتمادات" />
        </Columns>
      </asp:GridView></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بنود تحتاج انتباه</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvAttention" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود عاجلة.">
      <Columns>
        <asp:BoundField DataField="ItemType" HeaderText="النوع" />
        <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
        <asp:BoundField DataField="Title" HeaderText="العنوان" />
        <asp:BoundField DataField="Status" HeaderText="الحالة" />
        <asp:BoundField DataField="DueDate" HeaderText="الاستحقاق" DataFormatString="{0:yyyy-MM-dd}" />
        <asp:BoundField DataField="Severity" HeaderText="الأهمية" />
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
