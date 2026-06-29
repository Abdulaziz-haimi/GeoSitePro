<%@ Page Title="قوالب التحري" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InvestigationTemplates.aspx.cs" Inherits="InvestigationTemplates" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">قوالب التحري - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">قوالب التحري حسب نوع المشروع</h1>
      <div class="gsp-page-subtitle">مكتبة قوالب إرشادية قابلة للتعديل: مبانٍ، أبراج، طرق، جسور، سدود، أنفاق، مطارات، موانئ، منحدرات وغيرها.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkPlan" runat="server" NavigateUrl="~/ProjectInvestigationPlan.aspx" CssClass="gsp-btn gsp-btn-primary">توليد خطة لمشروع</asp:HyperLink></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث القوالب</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">نوع المشروع</label><asp:DropDownList ID="ddlProjectType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="Building, Road, Tower, SPT..." /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة القوالب</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvTemplates" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد قوالب." OnRowCommand="gvTemplates_RowCommand">
        <Columns>
          <asp:BoundField DataField="TemplateCode" HeaderText="كود القالب" />
          <asp:BoundField DataField="TemplateNameAr" HeaderText="اسم القالب" />
          <asp:BoundField DataField="ProjectTypeNameAr" HeaderText="نوع المشروع" />
          <asp:BoundField DataField="RiskLevelNameAr" HeaderText="الخطورة" />
          <asp:BoundField DataField="DefaultBoreholeCount" HeaderText="جسات مبدئية" />
          <asp:BoundField DataField="DefaultMinDepthM" HeaderText="عمق مبدئي م" />
          <asp:BoundField DataField="DefaultSPTIntervalM" HeaderText="SPT م" />
          <asp:BoundField DataField="ItemCount" HeaderText="بنود" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton ID="btnDetails" runat="server" Text="عرض البنود" CssClass="gsp-btn gsp-btn-secondary" CommandName="Details" CommandArgument='<%# Eval("TemplateId") %>' />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>

  <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litTemplateTitle" runat="server" /></h2>
    <p class="gsp-muted"><asp:Literal ID="litTemplateSummary" runat="server" /></p>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvTemplateItems" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود في هذا القالب.">
        <Columns>
          <asp:BoundField DataField="ItemCategoryNameAr" HeaderText="التصنيف" />
          <asp:BoundField DataField="ItemTitleAr" HeaderText="البند" />
          <asp:BoundField DataField="RecommendationText" HeaderText="التوصية" />
          <asp:BoundField DataField="MinQuantity" HeaderText="العدد" />
          <asp:BoundField DataField="SpacingMeters" HeaderText="التباعد م" />
          <asp:BoundField DataField="MinDepthM" HeaderText="العمق م" />
          <asp:BoundField DataField="FrequencyRule" HeaderText="التكرار" />
          <asp:BoundField DataField="StandardReference" HeaderText="المعيار" />
          <asp:CheckBoxField DataField="IsMandatory" HeaderText="إلزامي" ReadOnly="true" />
        </Columns>
      </asp:GridView>
    </div>
  </asp:Panel>
</div>
</asp:Content>
