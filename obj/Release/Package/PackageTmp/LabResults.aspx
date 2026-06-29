<%@ Page Title="النتائج المعملية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabResults.aspx.cs" Inherits="LabResults" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">النتائج المعملية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">النتائج المعملية Lab Results</h1>
      <div class="gsp-page-subtitle">تسجيل نتائج الاختبارات المعملية وربطها بالمشروع والجسة والعينة، مع حالة المراجعة والاعتماد.</div>
    </div>
    <div class="gsp-actions">
      <asp:Button ID="btnNew" runat="server" Text="إضافة نتيجة معملية" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" />
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة نتيجة معملية" /></h2>
    <asp:HiddenField ID="hfLabTestResultId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBorehole_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">العينة <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlSample" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الاختبار <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlLabTestType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">كود الاختبار</label><asp:TextBox ID="txtTestCode" runat="server" CssClass="gsp-input" placeholder="LAB-001" /></div>
      <div><label class="gsp-label">المعيار / Standard</label><asp:TextBox ID="txtTestStandard" runat="server" CssClass="gsp-input" placeholder="ASTM / BS / AASHTO" /></div>
      <div><label class="gsp-label">تاريخ الاختبار</label><asp:TextBox ID="txtTestDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">حالة النتيجة</label><asp:DropDownList ID="ddlResultStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">القيمة الرقمية</label><asp:TextBox ID="txtNumericValue" runat="server" CssClass="gsp-input" placeholder="مثال: 18.5" /></div>
      <div><label class="gsp-label">الوحدة</label><asp:TextBox ID="txtUnit" runat="server" CssClass="gsp-input" placeholder="%, kPa, MPa, g/cm3" /></div>
      <div><label class="gsp-label">قيمة نصية / وصفية</label><asp:TextBox ID="txtResultValue" runat="server" CssClass="gsp-input" placeholder="CL, SP-SM, Non-plastic..." /></div>
      <div><label class="gsp-label">الفني</label><asp:TextBox ID="txtTechnician" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">راجع بواسطة</label><asp:TextBox ID="txtReviewedBy" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">معتمد؟</label><asp:CheckBox ID="chkIsApproved" runat="server" Text=" نعم، النتيجة معتمدة" /></div>
      <div class="full"><label class="gsp-label">تفاصيل النتيجة</label><asp:TextBox ID="txtResultText" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" placeholder="تفاصيل القراءة، جدول مختصر، ملاحظات جهاز الاختبار..." /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtRemarks" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" />
      <asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث النتائج المعملية</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة</label><asp:DropDownList ID="ddlFilterBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterBorehole_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">العينة</label><asp:DropDownList ID="ddlFilterSample" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterSample_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="كود الاختبار، العينة، الفني، المعيار..." /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة النتائج المعملية</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvLabResults" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد نتائج معملية." OnRowCommand="gvLabResults_RowCommand">
        <Columns>
          <asp:BoundField DataField="TestCode" HeaderText="كود الاختبار" />
          <asp:BoundField DataField="SampleCode" HeaderText="العينة" />
          <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="LabTestTypeNameAr" HeaderText="نوع الاختبار" />
          <asp:BoundField DataField="TestStandard" HeaderText="المعيار" />
          <asp:BoundField DataField="NumericValue" HeaderText="القيمة" DataFormatString="{0:N3}" />
          <asp:BoundField DataField="Unit" HeaderText="الوحدة" />
          <asp:BoundField DataField="ResultValue" HeaderText="نتيجة نصية" />
          <asp:BoundField DataField="ResultStatusNameAr" HeaderText="الحالة" />
          <asp:CheckBoxField DataField="IsApproved" HeaderText="معتمد" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("LabTestResultId") %>' />
            <asp:LinkButton runat="server" Text="اعتماد" CssClass="gsp-btn gsp-btn-success" CommandName="ApproveItem" CommandArgument='<%# Eval("LabTestResultId") %>' OnClientClick="return confirm('هل تريد اعتماد هذه النتيجة؟');" />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("LabTestResultId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذه النتيجة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
