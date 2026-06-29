<%@ Page Title="لوحة التحكم" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">لوحة التحكم - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">لوحة التحكم</h1><div class="gsp-page-subtitle">Sprint 5: ملخص المشاريع والجسات والنتائج المعملية والتقارير، مع تفعيل الإدارة والصلاحيات.</div></div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkNewProject" runat="server" NavigateUrl="~/Projects.aspx?action=new" CssClass="gsp-btn gsp-btn-primary">إضافة مشروع</asp:HyperLink><asp:HyperLink ID="lnkProjects" runat="server" NavigateUrl="~/Projects.aspx" CssClass="gsp-btn gsp-btn-secondary">عرض المشاريع</asp:HyperLink></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message gsp-message-danger"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي المشاريع</div><div class="gsp-stat-value"><asp:Literal ID="litTotalProjects" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">المشاريع النشطة</div><div class="gsp-stat-value"><asp:Literal ID="litActiveProjects" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي الجسات</div><div class="gsp-stat-value"><asp:Literal ID="litTotalBoreholes" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">نتائج المختبر</div><div class="gsp-stat-value"><asp:Literal ID="litTotalLabTests" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">التقارير الفنية</div><div class="gsp-stat-value"><asp:Literal ID="litTotalReports" runat="server" Text="0" /></div></div>
  </div>
  <br />
  <div class="gsp-grid gsp-grid-2">
    <div class="gsp-card"><h2 class="gsp-card-title">آخر المشاريع</h2><div class="gsp-table-wrap">
      <asp:GridView ID="gvRecentProjects" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مشاريع حتى الآن.">
        <Columns>
          <asp:TemplateField HeaderText="كود المشروع"><ItemTemplate><a href='<%# "ProjectDetails.aspx?ProjectId=" + Eval("ProjectId") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("ProjectCode"))) %></a></ItemTemplate></asp:TemplateField>
          <asp:BoundField DataField="ProjectName" HeaderText="اسم المشروع" />
          <asp:BoundField DataField="ClientName" HeaderText="العميل" />
          <asp:BoundField DataField="ProjectStatusNameAr" HeaderText="الحالة" />
        </Columns>
      </asp:GridView>
    </div></div>
    <div class="gsp-card"><h2 class="gsp-card-title">المشاريع حسب الحالة</h2><div class="gsp-table-wrap">
      <asp:GridView ID="gvProjectStatus" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بيانات.">
        <Columns><asp:BoundField DataField="ProjectStatusNameAr" HeaderText="الحالة" /><asp:BoundField DataField="ProjectCount" HeaderText="العدد" /></Columns>
      </asp:GridView>
    </div></div>
  </div>
</div>
</asp:Content>
