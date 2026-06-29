<%@ Page Title="تفاصيل المشروع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectDetails.aspx.cs" Inherits="ProjectDetails" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">تفاصيل المشروع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title"><asp:Literal ID="litProjectName" runat="server" Text="تفاصيل المشروع" /></h1><div class="gsp-page-subtitle"><asp:Literal ID="litProjectMeta" runat="server" /></div></div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/Projects.aspx" CssClass="gsp-btn gsp-btn-secondary">العودة للمشاريع</asp:HyperLink><asp:HyperLink ID="lnkEdit" runat="server" CssClass="gsp-btn gsp-btn-primary">تعديل المشروع</asp:HyperLink></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message gsp-message-danger"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">الجسات المخططة</div><div class="gsp-stat-value"><asp:Literal ID="litBoreholePlanCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">الجسات الفعلية</div><div class="gsp-stat-value"><asp:Literal ID="litBoreholeCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">العينات</div><div class="gsp-stat-value"><asp:Literal ID="litSampleCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">نتائج المختبر</div><div class="gsp-stat-value"><asp:Literal ID="litLabTestCount" runat="server" Text="0" /></div></div>
  </div>
  <br />
  <div class="gsp-card">
    <h2 class="gsp-card-title">بيانات المشروع</h2>
    <div class="gsp-table-wrap">
      <table class="gsp-table">
        <tr><th>كود المشروع</th><td><asp:Literal ID="litProjectCode" runat="server" /></td><th>العميل</th><td><asp:Literal ID="litClientName" runat="server" /></td></tr>
        <tr><th>نوع المشروع</th><td><asp:Literal ID="litProjectType" runat="server" /></td><th>نوع المنشأ</th><td><asp:Literal ID="litStructureType" runat="server" /></td></tr>
        <tr><th>المدينة</th><td><asp:Literal ID="litCity" runat="server" /></td><th>الموقع</th><td><asp:Literal ID="litLocationName" runat="server" /></td></tr>
        <tr><th>المساحة</th><td><asp:Literal ID="litSiteArea" runat="server" /></td><th>الأدوار / البدرومات</th><td><asp:Literal ID="litFloors" runat="server" /></td></tr>
      </table>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">روابط المشروع الفنية</h2>
    <p class="gsp-muted">روابط مباشرة لكل بيانات المشروع: التحري الحقلي، المختبر، التقارير، الجودة، الحسابات، المرفقات، والتصدير.</p>
    <div class="gsp-actions">
      <asp:HyperLink ID="lnkProjectBoreholes" runat="server" CssClass="gsp-btn gsp-btn-primary">الجسات Boreholes</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectBoreholeLog" runat="server" CssClass="gsp-btn gsp-btn-secondary">سجل الجسة Borehole Log</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectSamples" runat="server" CssClass="gsp-btn gsp-btn-secondary">العينات Samples</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectSPT" runat="server" CssClass="gsp-btn gsp-btn-secondary">اختبارات SPT</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectGroundwater" runat="server" CssClass="gsp-btn gsp-btn-secondary">المياه الجوفية</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectLabResults" runat="server" CssClass="gsp-btn gsp-btn-success">النتائج المعملية</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectReports" runat="server" CssClass="gsp-btn gsp-btn-warning">التقارير الفنية</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectInvestigationPlan" runat="server" CssClass="gsp-btn gsp-btn-primary">خطة التحري حسب نوع المشروع</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectQuality" runat="server" CssClass="gsp-btn gsp-btn-secondary">فحص الجودة</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectSiteMap" runat="server" CssClass="gsp-btn gsp-btn-primary">خريطة الجسات</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectCrossSections" runat="server" CssClass="gsp-btn gsp-btn-secondary">المقاطع الجيوتقنية</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectCalculations" runat="server" CssClass="gsp-btn gsp-btn-secondary">الحسابات</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectDocuments" runat="server" CssClass="gsp-btn gsp-btn-secondary">المرفقات</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectExport" runat="server" CssClass="gsp-btn gsp-btn-secondary">التصدير</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectDataExchange" runat="server" CssClass="gsp-btn gsp-btn-primary">تبادل البيانات CSV</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectGisCad" runat="server" CssClass="gsp-btn gsp-btn-secondary">GIS/CAD</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectPrintableOutputs" runat="server" CssClass="gsp-btn gsp-btn-primary">مخرجات الطباعة</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectApproval" runat="server" CssClass="gsp-btn gsp-btn-warning">سير العمل والاعتماد</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectFollowUp" runat="server" CssClass="gsp-btn gsp-btn-danger">المتابعة والتنبيهات</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectRisks" runat="server" CssClass="gsp-btn gsp-btn-warning">سجل المخاطر</asp:HyperLink>
      <asp:HyperLink ID="lnkProjectKpis" runat="server" CssClass="gsp-btn gsp-btn-primary">مؤشرات الجودة</asp:HyperLink>
    </div>
  </div>
</div>
</asp:Content>
