<%@ Page Title="المعايير الفنية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Standards.aspx.cs" Inherits="Standards" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">المعايير الفنية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">المعايير الفنية Standards Library</h1>
      <div class="gsp-page-subtitle">إدارة المراجع والمعايير المستخدمة في الجسات، أخذ العينات، الاختبارات الحقلية والمعملية، والتقارير.</div>
    </div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة معيار" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة معيار" /></h2>
    <asp:HiddenField ID="hfStandardId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">كود المعيار <span class="gsp-required">*</span></label><asp:TextBox ID="txtStandardCode" runat="server" CssClass="gsp-input" placeholder="ASTM D1586 / ISO 22475-1" /></div>
      <div><label class="gsp-label">الجهة / Organization</label><asp:TextBox ID="txtOrganization" runat="server" CssClass="gsp-input" placeholder="ASTM / ISO / BS / AASHTO" /></div>
      <div class="full"><label class="gsp-label">عنوان المعيار <span class="gsp-required">*</span></label><asp:TextBox ID="txtStandardTitle" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">التصنيف</label><asp:DropDownList ID="ddlCategory" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع المعيار</label><asp:TextBox ID="txtStandardType" runat="server" CssClass="gsp-input" placeholder="Field / Lab / Reporting / QA" /></div>
      <div><label class="gsp-label">السنة / الإصدار</label><asp:TextBox ID="txtVersionYear" runat="server" CssClass="gsp-input" placeholder="2021" /></div>
      <div><label class="gsp-label">نشط؟</label><asp:CheckBox ID="chkIsActive" runat="server" Text=" نعم" Checked="true" /></div>
      <div class="full"><label class="gsp-label">ملخص الاستخدام داخل النظام</label><asp:TextBox ID="txtScopeSummary" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtRemarks" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث المعايير</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">التصنيف</label><asp:DropDownList ID="ddlFilterCategory" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="ASTM, ISO, SPT, Sampling..." /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة المعايير</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvStandards" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد معايير." OnRowCommand="gvStandards_RowCommand">
        <Columns>
          <asp:BoundField DataField="StandardCode" HeaderText="الكود" />
          <asp:BoundField DataField="StandardTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="Organization" HeaderText="الجهة" />
          <asp:BoundField DataField="CategoryNameAr" HeaderText="التصنيف" />
          <asp:BoundField DataField="VersionYear" HeaderText="السنة" />
          <asp:BoundField DataField="StandardType" HeaderText="النوع" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشط" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("StandardId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("StandardId") %>' OnClientClick="return confirm('هل تريد حذف هذا المعيار؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
