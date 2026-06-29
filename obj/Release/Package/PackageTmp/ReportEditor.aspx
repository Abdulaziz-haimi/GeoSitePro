<%@ Page Title="تحرير التقرير" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReportEditor.aspx.cs" Inherits="ReportEditor" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">تحرير التقرير - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title"><asp:Literal ID="litReportTitle" runat="server" Text="تحرير التقرير" /></h1>
      <div class="gsp-page-subtitle"><asp:Literal ID="litReportMeta" runat="server" /></div>
    </div>
    <div class="gsp-actions">
      <asp:HyperLink ID="lnkBack" runat="server" NavigateUrl="~/Reports.aspx" CssClass="gsp-btn gsp-btn-secondary">العودة للتقارير</asp:HyperLink>
      <asp:HyperLink ID="lnkPrint" runat="server" CssClass="gsp-btn gsp-btn-success" Target="_blank">طباعة التقرير</asp:HyperLink>
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إجراءات التقرير</h2>
    <p class="gsp-muted">التوليد التلقائي يضيف الأقسام الناقصة فقط ويحافظ على أي أقسام قمت بتحريرها سابقًا.</p>
    <div class="gsp-actions">
      <asp:Button ID="btnGenerateDefault" runat="server" Text="توليد الأقسام تلقائيًا" CssClass="gsp-btn gsp-btn-primary" OnClick="btnGenerateDefault_Click" />
      <asp:Button ID="btnAddSection" runat="server" Text="إضافة قسم يدوي" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnAddSection_Click" />
    </div>
  </div>

  <asp:Panel ID="pnlSectionForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litSectionFormTitle" runat="server" Text="إضافة قسم" /></h2>
    <asp:HiddenField ID="hfSectionId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">نوع القسم</label><asp:DropDownList ID="ddlSectionType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">ترتيب العرض</label><asp:TextBox ID="txtSortOrder" runat="server" CssClass="gsp-input" placeholder="10" /></div>
      <div class="full"><label class="gsp-label">عنوان القسم <span class="gsp-required">*</span></label><asp:TextBox ID="txtSectionTitle" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">محتوى القسم</label><asp:TextBox ID="txtSectionContent" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" style="min-height:220px" /></div>
      <div class="full"><asp:CheckBox ID="chkIsIncluded" runat="server" Text=" تضمين هذا القسم في نسخة الطباعة" Checked="true" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSaveSection" runat="server" Text="حفظ القسم" CssClass="gsp-btn gsp-btn-success" OnClick="btnSaveSection_Click" />
      <asp:Button ID="btnCancelSection" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancelSection_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">أقسام التقرير</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSections" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد أقسام. استخدم زر توليد الأقسام تلقائيًا." OnRowCommand="gvSections_RowCommand">
        <Columns>
          <asp:BoundField DataField="SortOrder" HeaderText="الترتيب" />
          <asp:BoundField DataField="SectionTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="SectionTypeNameAr" HeaderText="النوع" />
          <asp:CheckBoxField DataField="IsIncluded" HeaderText="يطبع" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تحرير" CssClass="gsp-btn gsp-btn-primary" CommandName="EditItem" CommandArgument='<%# Eval("ReportSectionId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ReportSectionId") %>' OnClientClick="return confirm('هل تريد حذف هذا القسم؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
