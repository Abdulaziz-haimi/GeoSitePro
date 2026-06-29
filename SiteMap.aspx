<%@ Page Title="خريطة الموقع والجسات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SiteMap.aspx.cs" Inherits="SiteMapPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">خريطة الموقع والجسات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.gsp-map-canvas{background:#f8fafc;border:1px solid #dbe4ef;border-radius:14px;overflow:auto;padding:10px;min-height:420px}.gsp-svg-map{width:100%;min-width:760px;height:520px;background:#fff;border-radius:10px}.gsp-map-note{font-size:12px;color:#64748b;margin-top:8px}.gsp-point-label{font-weight:800;font-size:12px}.gsp-mini{font-size:12px;color:#64748b}.gsp-chip{display:inline-block;background:#eef2ff;color:#3730a3;border-radius:999px;padding:4px 9px;font-size:12px;font-weight:800;margin:2px}
</style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">خريطة الموقع والجسات Site Map & Borehole Layout</h1>
      <div class="gsp-page-subtitle">عرض مكاني مبسط للجسات المخططة والفعلية اعتمادًا على Easting/Northing، مع حفظ إعدادات نظام الإحداثيات وحدود الموقع.</div>
    </div>
    <div class="gsp-actions">
      <asp:HyperLink ID="lnkCrossSections" runat="server" NavigateUrl="~/CrossSections.aspx" CssClass="gsp-btn gsp-btn-secondary">المقاطع Cross Sections</asp:HyperLink>
      <asp:HyperLink ID="lnkProjects" runat="server" NavigateUrl="~/Projects.aspx" CssClass="gsp-btn gsp-btn-secondary">المشاريع</asp:HyperLink>
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="تحميل الخريطة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false" CssClass="gsp-card">
    <div class="gsp-page-header">
      <div><h2 class="gsp-card-title"><asp:Literal ID="litProjectTitle" runat="server" /></h2><p class="gsp-muted"><asp:Literal ID="litProjectMeta" runat="server" /></p></div>
      <div class="gsp-actions">
        <asp:Button ID="btnGenerateActual" runat="server" Text="توليد من الجسات الفعلية" CssClass="gsp-btn gsp-btn-success" OnClick="btnGenerateActual_Click" />
        <asp:Button ID="btnGeneratePlan" runat="server" Text="توليد نقاط من خطة التحري" CssClass="gsp-btn gsp-btn-warning" OnClick="btnGeneratePlan_Click" />
      </div>
    </div>
    <div>
      <span class="gsp-chip">الجسات الفعلية: <asp:Literal ID="litActualCount" runat="server" Text="0" /></span>
      <span class="gsp-chip">نقاط الخريطة: <asp:Literal ID="litLayoutCount" runat="server" Text="0" /></span>
      <span class="gsp-chip">نقاط ناقصة الإحداثيات: <asp:Literal ID="litMissingCoordCount" runat="server" Text="0" /></span>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlSettings" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">إعدادات الخريطة والإحداثيات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">Coordinate System</label><asp:TextBox ID="txtCoordinateSystem" runat="server" CssClass="gsp-input" placeholder="مثال: UTM Zone 38N / WGS84" /></div>
      <div><label class="gsp-label">EPSG Code</label><asp:TextBox ID="txtEPSG" runat="server" CssClass="gsp-input" placeholder="مثال: EPSG:32638" /></div>
      <div><label class="gsp-label">Origin Easting</label><asp:TextBox ID="txtOriginEasting" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Origin Northing</label><asp:TextBox ID="txtOriginNorthing" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Scale denominator</label><asp:TextBox ID="txtScaleDenominator" runat="server" CssClass="gsp-input" placeholder="مثال: 500" /></div>
      <div><label class="gsp-label">North angle deg</label><asp:TextBox ID="txtNorthAngle" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">Site boundary text</label><asp:TextBox ID="txtBoundaryText" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" placeholder="اختياري: أدخل نقاط حدود الموقع كنص، مثل E,N لكل سطر" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtMapNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div style="align-self:end"><asp:Button ID="btnSaveSettings" runat="server" Text="حفظ الإعدادات" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSaveSettings_Click" /></div>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlMap" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">خريطة الجسات المبسطة</h2>
    <div class="gsp-map-canvas"><asp:Literal ID="litMapSvg" runat="server" /></div>
    <div class="gsp-map-note">هذه الخريطة مخصصة للمراجعة والتخطيط داخل النظام. الاعتماد النهائي يحتاج مخطط مساحي/GIS رسمي عند توفره.</div>
  </asp:Panel>

  <asp:Panel ID="pnlAddPoint" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل نقطة جسة مخططة</h2>
    <asp:HiddenField ID="hfPointId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">Code</label><asp:TextBox ID="txtPointCode" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Source</label><asp:DropDownList ID="ddlPointSource" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">Easting</label><asp:TextBox ID="txtPointEasting" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Northing</label><asp:TextBox ID="txtPointNorthing" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Elevation m</label><asp:TextBox ID="txtPointElevation" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Planned depth m</label><asp:TextBox ID="txtPointDepth" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtPointNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div style="align-self:end" class="gsp-actions"><asp:Button ID="btnSavePoint" runat="server" Text="حفظ النقطة" CssClass="gsp-btn gsp-btn-success" OnClick="btnSavePoint_Click" /><asp:Button ID="btnClearPoint" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearPoint_Click" /></div>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlPoints" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">نقاط الجسات على الخريطة</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvPoints" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد نقاط بعد." OnRowCommand="gvPoints_RowCommand">
        <Columns>
          <asp:BoundField DataField="BoreholeCode" HeaderText="الكود" />
          <asp:BoundField DataField="SourceTypeNameAr" HeaderText="المصدر" />
          <asp:BoundField DataField="Easting" HeaderText="E" DataFormatString="{0:N3}" />
          <asp:BoundField DataField="Northing" HeaderText="N" DataFormatString="{0:N3}" />
          <asp:BoundField DataField="ElevationM" HeaderText="Z" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="PlannedDepthM" HeaderText="Depth" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="Notes" HeaderText="ملاحظات" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton ID="btnEditPoint" runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditPoint" CommandArgument='<%# Eval("LayoutPointId") %>' />
            <asp:LinkButton ID="btnDeletePoint" runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeletePoint" CommandArgument='<%# Eval("LayoutPointId") %>' OnClientClick="return confirm('حذف النقطة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </asp:Panel>
</div>
</asp:Content>
