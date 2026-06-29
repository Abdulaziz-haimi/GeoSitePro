<%@ Page Title="GIS/CAD Export" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GisCadExport.aspx.cs" Inherits="GisCadExport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">GIS/CAD Export - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">تصدير GIS / CAD</h1>
      <div class="gsp-page-subtitle">تجهيز نقاط الجسات والطبقات والمقاطع كملفات CSV يمكن تحويلها لاحقًا إلى GIS Shapefile/GeoPackage أو CAD DXF بواسطة QGIS/ArcGIS/Civil 3D.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnRefresh" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnRefresh_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false">
    <div class="gsp-card">
      <h2 class="gsp-card-title">ملفات GIS / CAD الأولية</h2>
      <p class="gsp-muted">هذه الملفات ليست DXF/Shapefile نهائيًا، لكنها CSV منظم يحتوي X/Y/Z والعمق والطبقات، ويمكن استيراده مباشرة في برامج GIS/CAD أو تحويله في Sprint لاحق.</p>
      <div class="gsp-actions">
        <asp:HyperLink ID="lnkGisPoints" runat="server" CssClass="gsp-btn gsp-btn-primary">GIS Borehole Points CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkGisLayers" runat="server" CssClass="gsp-btn gsp-btn-primary">GIS Layer Intervals CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkCadPoints" runat="server" CssClass="gsp-btn gsp-btn-secondary">CAD Point Schedule CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkCrossSectionLayers" runat="server" CssClass="gsp-btn gsp-btn-secondary">Cross Section Layers CSV</asp:HyperLink>
      </div>
    </div>

    <div class="gsp-grid gsp-grid-2">
      <div class="gsp-card">
        <h2 class="gsp-card-title">نقاط الجسات</h2>
        <div class="gsp-table-wrap"><asp:GridView ID="gvPoints" runat="server" AutoGenerateColumns="true" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد نقاط جسات." /></div>
      </div>
      <div class="gsp-card">
        <h2 class="gsp-card-title">المقاطع</h2>
        <div class="gsp-table-wrap"><asp:GridView ID="gvSections" runat="server" AutoGenerateColumns="true" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مقاطع." /></div>
      </div>
    </div>
  </asp:Panel>
</div>
</asp:Content>
