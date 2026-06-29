<%@ Page Title="مرفقات المشروع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectDocuments.aspx.cs" Inherits="ProjectDocuments" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مرفقات المشروع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">مرفقات ووثائق المشروع Project Documents</h1><div class="gsp-page-subtitle">رفع وحفظ ملفات المشروع: خرائط، صور عينات، صور core boxes، نتائج مختبر، تقارير PDF، ومراسلات فنية.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة مرفق" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">إضافة مرفق</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الملف</label><asp:DropDownList ID="ddlDocumentType" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">عنوان الملف <span class="gsp-required">*</span></label><asp:TextBox ID="txtDocumentTitle" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">مرتبط بكيان</label><asp:TextBox ID="txtRelatedEntityName" runat="server" CssClass="gsp-input" placeholder="Borehole / Sample / LabResult / Report" /></div>
      <div><label class="gsp-label">رقم الكيان</label><asp:TextBox ID="txtRelatedEntityId" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الإصدار</label><asp:TextBox ID="txtVersionNo" runat="server" CssClass="gsp-input" Text="1" /></div>
      <div><label class="gsp-label">الملف <span class="gsp-required">*</span></label><asp:FileUpload ID="fuDocument" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="رفع وحفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
    <p class="gsp-muted">الامتدادات المسموحة: PDF, DOC, DOCX, XLS, XLSX, JPG, JPEG, PNG, CSV, TXT. الحد الأقصى 25MB.</p>
  </asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث المرفقات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الملف</label><asp:DropDownList ID="ddlFilterDocumentType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة المرفقات</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvDocuments" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مرفقات." OnRowCommand="gvDocuments_RowCommand">
      <Columns>
        <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
        <asp:BoundField DataField="DocumentTitle" HeaderText="العنوان" />
        <asp:BoundField DataField="DocumentTypeNameAr" HeaderText="النوع" />
        <asp:BoundField DataField="OriginalFileName" HeaderText="اسم الملف" />
        <asp:BoundField DataField="FileExtension" HeaderText="الامتداد" />
        <asp:BoundField DataField="FileSizeKB" HeaderText="الحجم KB" DataFormatString="{0:N1}" />
        <asp:BoundField DataField="UploadedAt" HeaderText="تاريخ الرفع" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
        <asp:CheckBoxField DataField="IsApproved" HeaderText="معتمد" ReadOnly="true" />
        <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
          <asp:LinkButton runat="server" Text="تنزيل" CssClass="gsp-btn gsp-btn-secondary" CommandName="DownloadItem" CommandArgument='<%# Eval("ProjectDocumentId") %>' />
          <asp:LinkButton runat="server" Text="اعتماد" CssClass="gsp-btn gsp-btn-success" CommandName="ApproveItem" CommandArgument='<%# Eval("ProjectDocumentId") %>' />
          <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ProjectDocumentId") %>' OnClientClick="return confirm('حذف المرفق؟');" />
        </ItemTemplate></asp:TemplateField>
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
