<%@ Page Title="فحص جودة المشروع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectQualityCheck.aspx.cs" Inherits="ProjectQualityCheck" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">فحص جودة المشروع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">فحص الجودة والمعايير Project QA/QC</h1><div class="gsp-page-subtitle">قائمة تحقق للمشروع: الجسات، العينات، SPT، المياه الجوفية، النتائج المعملية، والتقارير قبل الاعتماد.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة بند فحص" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة بند فحص" /></h2>
    <asp:HiddenField ID="hfQualityCheckId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">منطقة الفحص</label><asp:DropDownList ID="ddlCheckArea" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">بند الفحص <span class="gsp-required">*</span></label><asp:TextBox ID="txtChecklistItem" runat="server" CssClass="gsp-input" placeholder="مثال: تم تسجيل عمق الجسة الفعلي وطريقة الحفر وسبب الإنهاء" /></div>
      <div><label class="gsp-label">مرجع المعيار/الإجراء</label><asp:TextBox ID="txtRequirementReference" runat="server" CssClass="gsp-input" placeholder="ASTM / ISO / BS / Internal SOP" /></div>
      <div><label class="gsp-label">الخطورة</label><asp:DropDownList ID="ddlSeverity" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">المسؤول</label><asp:TextBox ID="txtResponsiblePerson" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ الاستحقاق</label><asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ الإغلاق</label><asp:TextBox ID="txtClosedDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">معتمد؟</label><asp:CheckBox ID="chkIsApproved" runat="server" Text=" نعم، تمت المراجعة" /></div>
      <div class="full"><label class="gsp-label">الدليل / Evidence</label><asp:TextBox ID="txtEvidenceText" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">الإجراء التصحيحي</label><asp:TextBox ID="txtCorrectiveAction" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtRemarks" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث بنود الجودة</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة فحص الجودة</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvQualityChecks" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود فحص." OnRowCommand="gvQualityChecks_RowCommand">
        <Columns>
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="CheckAreaNameAr" HeaderText="منطقة الفحص" />
          <asp:BoundField DataField="ChecklistItem" HeaderText="البند" />
          <asp:BoundField DataField="RequirementReference" HeaderText="المرجع" />
          <asp:BoundField DataField="SeverityNameAr" HeaderText="الخطورة" />
          <asp:BoundField DataField="StatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="ResponsiblePerson" HeaderText="المسؤول" />
          <asp:BoundField DataField="DueDate" HeaderText="الاستحقاق" DataFormatString="{0:yyyy-MM-dd}" />
          <asp:CheckBoxField DataField="IsApproved" HeaderText="معتمد" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("QualityCheckId") %>' />
            <asp:LinkButton runat="server" Text="اعتماد" CssClass="gsp-btn gsp-btn-success" CommandName="ApproveItem" CommandArgument='<%# Eval("QualityCheckId") %>' OnClientClick="return confirm('اعتماد بند الفحص؟');" />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("QualityCheckId") %>' OnClientClick="return confirm('حذف بند الفحص؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
