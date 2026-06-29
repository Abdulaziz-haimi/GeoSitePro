<%@ Page Title="مركز التصدير" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ExportCenter.aspx.cs" Inherits="ExportCenter" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مركز التصدير - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">مركز التصدير Export Center</h1><div class="gsp-page-subtitle">إنشاء حزم تصدير للمشروع تشمل الجسات، العينات، SPT، المياه الجوفية، النتائج المعملية، التقارير، والمرفقات.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="حزمة تصدير جديدة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">إعداد حزمة تصدير</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الحزمة</label><asp:DropDownList ID="ddlPackageType" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">عنوان الحزمة</label><asp:TextBox ID="txtPackageTitle" runat="server" CssClass="gsp-input" placeholder="Final GIR Package / Borehole Log Package" /></div>
      <div class="full gsp-checklist">
        <asp:CheckBox ID="chkBoreholes" runat="server" Text="الجسات" Checked="true" />
        <asp:CheckBox ID="chkSamples" runat="server" Text="العينات" Checked="true" />
        <asp:CheckBox ID="chkSPT" runat="server" Text="SPT" Checked="true" />
        <asp:CheckBox ID="chkGroundwater" runat="server" Text="المياه الجوفية" Checked="true" />
        <asp:CheckBox ID="chkLabResults" runat="server" Text="نتائج المختبر" Checked="true" />
        <asp:CheckBox ID="chkReports" runat="server" Text="التقارير" Checked="true" />
        <asp:CheckBox ID="chkDocuments" runat="server" Text="المرفقات" Checked="true" />
      </div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ الحزمة" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث حزم التصدير</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">حزم التصدير</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvExports" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد حزم تصدير." OnRowCommand="gvExports_RowCommand">
      <Columns>
        <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
        <asp:BoundField DataField="PackageTitle" HeaderText="العنوان" />
        <asp:BoundField DataField="PackageTypeNameAr" HeaderText="النوع" />
        <asp:BoundField DataField="PackageStatusNameAr" HeaderText="الحالة" />
        <asp:BoundField DataField="CreatedAt" HeaderText="تاريخ الإنشاء" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
        <asp:BoundField DataField="GeneratedAt" HeaderText="تاريخ التجهيز" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
        <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
          <asp:HyperLink runat="server" Text="فتح التقارير" CssClass="gsp-btn gsp-btn-secondary" NavigateUrl='<%# "~/Reports.aspx?ProjectId=" + Eval("ProjectId") %>' />
          <asp:LinkButton runat="server" Text="تعليم كجاهزة" CssClass="gsp-btn gsp-btn-success" CommandName="MarkGenerated" CommandArgument='<%# Eval("ExportPackageId") %>' />
          <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ExportPackageId") %>' OnClientClick="return confirm('حذف حزمة التصدير؟');" />
        </ItemTemplate></asp:TemplateField>
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
