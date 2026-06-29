<%@ Page Title="العينات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Samples.aspx.cs" Inherits="Samples" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">العينات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">العينات Samples</h1><div class="gsp-page-subtitle">تسجيل العينات المأخوذة من الجسات مع العمق، النوع، الجودة، والاختبارات المطلوبة.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة عينة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة عينة" /></h2>
    <asp:HiddenField ID="hfSampleId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlBorehole" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">كود العينة <span class="gsp-required">*</span></label><asp:TextBox ID="txtSampleCode" runat="server" CssClass="gsp-input" placeholder="BH-01/S-01" /></div>
      <div><label class="gsp-label">نوع العينة</label><asp:DropDownList ID="ddlSampleType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">من عمق م <span class="gsp-required">*</span></label><asp:TextBox ID="txtFromDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">إلى عمق م <span class="gsp-required">*</span></label><asp:TextBox ID="txtToDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">جودة العينة</label><asp:DropDownList ID="ddlSampleQuality" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">طول الاسترجاع م</label><asp:TextBox ID="txtRecoveryLengthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ أخذ العينة</label><asp:TextBox ID="txtTakenDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">مكان الحفظ</label><asp:TextBox ID="txtStorageLocation" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الوصف الحقلي</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">الاختبارات المطلوبة</label><asp:TextBox ID="txtRequiredTests" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" placeholder="Moisture Content, Sieve Analysis, Atterberg Limits..." /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث العينات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة</label><asp:DropDownList ID="ddlFilterBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterBorehole_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="كود العينة، الوصف، الاختبارات..." /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة العينات</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSamples" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد عينات." OnRowCommand="gvSamples_RowCommand">
        <Columns>
          <asp:BoundField DataField="SampleCode" HeaderText="كود العينة" />
          <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="FromDepthM" HeaderText="من" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="ToDepthM" HeaderText="إلى" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="SampleTypeNameAr" HeaderText="النوع" />
          <asp:BoundField DataField="SampleQualityNameAr" HeaderText="الجودة" />
          <asp:BoundField DataField="RequiredTests" HeaderText="الاختبارات المطلوبة" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("SampleId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("SampleId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذه العينة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
