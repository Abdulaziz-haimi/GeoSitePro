<%@ Page Title="جاهزية الإنتاج" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductionReadiness.aspx.cs" Inherits="ProductionReadiness" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">جاهزية الإنتاج - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">جاهزية الإنتاج Production Readiness</h1><div class="gsp-page-subtitle">قائمة تحقق تشغيلية قبل استخدام النظام رسميًا: الأمن، النسخ الاحتياطي، الاختبارات، الصلاحيات، التصدير، ومراجعة البيانات.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnSeed" runat="server" Text="إضافة قائمة افتراضية" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSeed_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تحديث بند جاهزية</h2>
    <asp:HiddenField ID="hfReadinessCheckId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المحور</label><asp:DropDownList ID="ddlReadinessArea" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlReadinessStatus" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">البند</label><asp:TextBox ID="txtCheckItem" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الدليل / الملاحظة</label><asp:TextBox ID="txtEvidence" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><label class="gsp-label">المسؤول</label><asp:TextBox ID="txtOwner" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ المراجعة</label><asp:TextBox ID="txtReviewedDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnClearForm" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearForm_Click" CausesValidation="false" /></div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة جاهزية الإنتاج</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvReadiness" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود." OnRowCommand="gvReadiness_RowCommand">
      <Columns>
        <asp:BoundField DataField="ReadinessAreaNameAr" HeaderText="المحور" />
        <asp:BoundField DataField="CheckItem" HeaderText="البند" />
        <asp:BoundField DataField="ReadinessStatusNameAr" HeaderText="الحالة" />
        <asp:BoundField DataField="Owner" HeaderText="المسؤول" />
        <asp:BoundField DataField="ReviewedDate" HeaderText="تاريخ المراجعة" DataFormatString="{0:yyyy-MM-dd}" />
        <asp:BoundField DataField="Evidence" HeaderText="الدليل" />
        <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
          <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("ReadinessCheckId") %>' />
          <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ReadinessCheckId") %>' OnClientClick="return confirm('حذف البند؟');" />
        </ItemTemplate></asp:TemplateField>
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
