<%@ Page Title="خطة تحري المشروع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectInvestigationPlan.aspx.cs" Inherits="ProjectInvestigationPlan" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">خطة تحري المشروع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">خطة تحري المشروع Project Investigation Plan</h1>
      <div class="gsp-page-subtitle">توليد خطة جسات وعينات واختبارات حسب نوع المشروع، ثم تعديلها واعتمادها من المهندس.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkTemplates" runat="server" NavigateUrl="~/InvestigationTemplates.aspx" CssClass="gsp-btn gsp-btn-secondary">مكتبة القوالب</asp:HyperLink></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoadProject" runat="server" Text="تحميل" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoadProject_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litProjectTitle" runat="server" /></h2>
    <div class="gsp-table-wrap">
      <table class="gsp-table">
        <tr><th>نوع المشروع</th><td><asp:Literal ID="litProjectType" runat="server" /></td><th>المدينة</th><td><asp:Literal ID="litCity" runat="server" /></td></tr>
        <tr><th>المساحة</th><td><asp:Literal ID="litArea" runat="server" /></td><th>الأدوار</th><td><asp:Literal ID="litFloors" runat="server" /></td></tr>
      </table>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlGenerate" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">توليد خطة من قالب</h2>
    <p class="gsp-muted">اختر القالب المناسب. عند تركه على القالب المقترح، سيختار النظام القالب الأقرب لنوع المشروع ومرحلة التحري.</p>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">القالب المقترح</label><asp:DropDownList ID="ddlTemplate" runat="server" CssClass="gsp-select" /></div>
      <div style="align-self:end"><asp:Button ID="btnGenerate" runat="server" Text="توليد خطة تحري" CssClass="gsp-btn gsp-btn-success" OnClick="btnGenerate_Click" /></div>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlPlans" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">خطط التحري السابقة والحالية</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvPlans" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد خطط بعد." OnRowCommand="gvPlans_RowCommand">
        <Columns>
          <asp:BoundField DataField="RevisionNo" HeaderText="الإصدار" />
          <asp:BoundField DataField="PlanTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="TemplateNameAr" HeaderText="القالب" />
          <asp:BoundField DataField="PlanStatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="ItemCount" HeaderText="البنود" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشطة" ReadOnly="true" />
          <asp:CheckBoxField DataField="IsApproved" HeaderText="معتمدة" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton ID="btnViewPlan" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-secondary" CommandName="ViewPlan" CommandArgument='<%# Eval("PlanId") %>' />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlPlanItems" runat="server" Visible="false" CssClass="gsp-card">
    <div class="gsp-page-header">
      <div><h2 class="gsp-card-title"><asp:Literal ID="litPlanTitle" runat="server" /></h2><p class="gsp-muted"><asp:Literal ID="litPlanMeta" runat="server" /></p></div>
      <div class="gsp-actions"><asp:Button ID="btnApprove" runat="server" Text="اعتماد الخطة" CssClass="gsp-btn gsp-btn-warning" OnClick="btnApprove_Click" /></div>
    </div>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvPlanItems" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود." OnRowCommand="gvPlanItems_RowCommand">
        <Columns>
          <asp:BoundField DataField="ItemCategoryNameAr" HeaderText="التصنيف" />
          <asp:BoundField DataField="ItemTitleAr" HeaderText="البند" />
          <asp:BoundField DataField="RecommendationText" HeaderText="التوصية" />
          <asp:TemplateField HeaderText="العدد"><ItemTemplate><asp:TextBox ID="txtPlannedQuantity" runat="server" CssClass="gsp-input" Text='<%# Eval("PlannedQuantity") %>' /></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="التباعد م"><ItemTemplate><asp:TextBox ID="txtPlannedSpacingM" runat="server" CssClass="gsp-input" Text='<%# Eval("PlannedSpacingM") %>' /></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="العمق م"><ItemTemplate><asp:TextBox ID="txtPlannedDepthM" runat="server" CssClass="gsp-input" Text='<%# Eval("PlannedDepthM") %>' /></ItemTemplate></asp:TemplateField>
          <asp:BoundField DataField="FrequencyRule" HeaderText="التكرار" />
          <asp:BoundField DataField="StandardReference" HeaderText="المعيار" />
          <asp:TemplateField HeaderText="مقبول"><ItemTemplate><asp:CheckBox ID="chkIsAccepted" runat="server" Checked='<%# Eval("IsAccepted") %>' /></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="ملاحظات المهندس"><ItemTemplate><asp:TextBox ID="txtEngineerNotes" runat="server" CssClass="gsp-input" Text='<%# Eval("EngineerNotes") %>' /></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="حفظ"><ItemTemplate><asp:LinkButton ID="btnSaveItem" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" CommandName="SaveItem" CommandArgument='<%# Eval("PlanItemId") %>' /></ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </asp:Panel>
</div>
</asp:Content>
