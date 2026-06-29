<%@ Page Title="المقاطع الجيوتقنية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CrossSections.aspx.cs" Inherits="CrossSections" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">المقاطع الجيوتقنية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.gsp-section-canvas{background:#fff;border:1px solid #dbe4ef;border-radius:14px;overflow:auto;padding:10px;min-height:450px}.gsp-svg-section{width:100%;min-width:980px;height:560px;background:#ffffff;border-radius:10px}.layer-fill-0{fill:#fde68a}.layer-fill-1{fill:#bfdbfe}.layer-fill-2{fill:#bbf7d0}.layer-fill-3{fill:#fecaca}.layer-fill-4{fill:#ddd6fe}.layer-fill-5{fill:#e5e7eb}
</style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">المقاطع الجيوتقنية Cross Sections</h1>
      <div class="gsp-page-subtitle">إنشاء مقطع مبسط من الجسات وطبقاتها المسجلة. المقطع يعرض ترتيب الجسات والطبقات والعمق، ويساعد على مراجعة التتابع الطبقي قبل التقرير النهائي.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkSiteMap" runat="server" NavigateUrl="~/SiteMap.aspx" CssClass="gsp-btn gsp-btn-secondary">خريطة الموقع</asp:HyperLink></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="تحميل" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litProjectTitle" runat="server" /></h2>
    <p class="gsp-muted"><asp:Literal ID="litProjectMeta" runat="server" /></p>
  </asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل مقطع</h2>
    <asp:HiddenField ID="hfSectionId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">Section Code</label><asp:TextBox ID="txtSectionCode" runat="server" CssClass="gsp-input" placeholder="A-A'" /></div>
      <div><label class="gsp-label">Section Name</label><asp:TextBox ID="txtSectionName" runat="server" CssClass="gsp-input" placeholder="مقطع عبر منتصف الموقع" /></div>
      <div><label class="gsp-label">Baseline Type</label><asp:DropDownList ID="ddlBaselineType" runat="server" CssClass="gsp-select"><asp:ListItem Value="EASTING" Text="ترتيب حسب Easting" /><asp:ListItem Value="NORTHING" Text="ترتيب حسب Northing" /><asp:ListItem Value="CUSTOM" Text="Custom manual chainage" /></asp:DropDownList></div>
      <div><label class="gsp-label">Status</label><asp:DropDownList ID="ddlSectionStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">Horizontal Scale</label><asp:TextBox ID="txtHorizontalScale" runat="server" CssClass="gsp-input" Text="500" /></div>
      <div><label class="gsp-label">Vertical Scale</label><asp:TextBox ID="txtVerticalScale" runat="server" CssClass="gsp-input" Text="100" /></div>
      <div><label class="gsp-label">Start Easting</label><asp:TextBox ID="txtStartEasting" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Start Northing</label><asp:TextBox ID="txtStartNorthing" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">End Easting</label><asp:TextBox ID="txtEndEasting" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">End Northing</label><asp:TextBox ID="txtEndNorthing" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div style="align-self:end" class="gsp-actions">
        <asp:Button ID="btnSaveSection" runat="server" Text="حفظ المقطع" CssClass="gsp-btn gsp-btn-success" OnClick="btnSaveSection_Click" />
        <asp:Button ID="btnGenerateBoreholes" runat="server" Text="ربط الجسات تلقائيًا" CssClass="gsp-btn gsp-btn-warning" OnClick="btnGenerateBoreholes_Click" />
        <asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" />
      </div>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlSections" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">قائمة المقاطع</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSections" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مقاطع بعد." OnRowCommand="gvSections_RowCommand">
        <Columns>
          <asp:BoundField DataField="SectionCode" HeaderText="الكود" />
          <asp:BoundField DataField="SectionName" HeaderText="الاسم" />
          <asp:BoundField DataField="BaselineType" HeaderText="Baseline" />
          <asp:BoundField DataField="SectionStatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="BoreholeCount" HeaderText="الجسات" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton ID="btnView" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" CommandName="ViewSection" CommandArgument='<%# Eval("CrossSectionId") %>' />
            <asp:LinkButton ID="btnEdit" runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditSection" CommandArgument='<%# Eval("CrossSectionId") %>' />
            <asp:LinkButton ID="btnDelete" runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteSection" CommandArgument='<%# Eval("CrossSectionId") %>' OnClientClick="return confirm('حذف المقطع؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlSectionView" runat="server" Visible="false" CssClass="gsp-card">
    <div class="gsp-page-header">
      <div><h2 class="gsp-card-title"><asp:Literal ID="litSectionTitle" runat="server" /></h2><p class="gsp-muted"><asp:Literal ID="litSectionMeta" runat="server" /></p></div>
      <div class="gsp-actions"><asp:Button ID="btnRefreshSection" runat="server" Text="تحديث الرسم" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnRefreshSection_Click" /></div>
    </div>
    <div class="gsp-section-canvas"><asp:Literal ID="litSectionSvg" runat="server" /></div>
    <br />
    <h3 class="gsp-card-title">الجسات المرتبطة بالمقطع</h3>
    <asp:GridView ID="gvSectionBoreholes" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد جسات مرتبطة.">
      <Columns>
        <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
        <asp:BoundField DataField="ChainageM" HeaderText="Chainage" DataFormatString="{0:N2}" />
        <asp:BoundField DataField="OffsetM" HeaderText="Offset" DataFormatString="{0:N2}" />
        <asp:BoundField DataField="ElevationM" HeaderText="Elevation" DataFormatString="{0:N2}" />
        <asp:BoundField DataField="ActualDepthM" HeaderText="Depth" DataFormatString="{0:N2}" />
      </Columns>
    </asp:GridView>
  </asp:Panel>
</div>
</asp:Content>
