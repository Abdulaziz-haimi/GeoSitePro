<%@ Page Title="الحسابات الجيوتقنية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EngineeringCalculations.aspx.cs" Inherits="EngineeringCalculations" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">الحسابات الجيوتقنية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">الحسابات الجيوتقنية Engineering Calculations</h1><div class="gsp-page-subtitle">حفظ حسابات فنية قابلة للمراجعة مثل N60، نسبة الرطوبة، PI، معاملات التدرج، والكثافة الجافة.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة حساب" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة حساب" /></h2>
    <asp:HiddenField ID="hfCalculationId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الحساب <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlCalculationType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">تاريخ الحساب</label><asp:TextBox ID="txtCalculationDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">العنوان</label><asp:TextBox ID="txtCalculationTitle" runat="server" CssClass="gsp-input" placeholder="مثال: SPT N60 at BH-01 / 6.0m" /></div>
      <div><label class="gsp-label">Input 1</label><asp:TextBox ID="txtInput1" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Input 2</label><asp:TextBox ID="txtInput2" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Input 3</label><asp:TextBox ID="txtInput3" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Input 4</label><asp:TextBox ID="txtInput4" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Input 5</label><asp:TextBox ID="txtInput5" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Input 6</label><asp:TextBox ID="txtInput6" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">النتيجة 1</label><asp:TextBox ID="txtResult1" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">النتيجة 2</label><asp:TextBox ID="txtResult2" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">النتيجة 3</label><asp:TextBox ID="txtResult3" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الوحدة</label><asp:TextBox ID="txtUnit" runat="server" CssClass="gsp-input" placeholder="%, blows, kN/m3" /></div>
      <div class="full"><label class="gsp-label">ملخص الحساب</label><asp:TextBox ID="txtResultSummary" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><label class="gsp-label">حسب بواسطة</label><asp:TextBox ID="txtCalculatedBy" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">راجع بواسطة</label><asp:TextBox ID="txtCheckedBy" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">معتمد؟</label><asp:CheckBox ID="chkIsApproved" runat="server" Text=" نعم" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnCalculate" runat="server" Text="احسب تلقائيًا" CssClass="gsp-btn gsp-btn-warning" OnClick="btnCalculate_Click" /><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
    <p class="gsp-muted">طريقة استخدام المدخلات: Moisture: Wc,Wwet,Wdry | Atterberg: LL,PL | SPT_N60: N,ER,CB,CR,CS | Sieve: D10,D30,D60 | DryDensity: BulkDensity,WaterContent%.</p>
  </asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث الحسابات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع الحساب</label><asp:DropDownList ID="ddlFilterCalculationType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClear" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">سجل الحسابات</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvCalculations" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد حسابات." OnRowCommand="gvCalculations_RowCommand">
      <Columns>
        <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
        <asp:BoundField DataField="CalculationTypeNameAr" HeaderText="نوع الحساب" />
        <asp:BoundField DataField="CalculationTitle" HeaderText="العنوان" />
        <asp:BoundField DataField="ResultSummary" HeaderText="الملخص" />
        <asp:BoundField DataField="Result1" HeaderText="R1" DataFormatString="{0:N3}" />
        <asp:BoundField DataField="Result2" HeaderText="R2" DataFormatString="{0:N3}" />
        <asp:BoundField DataField="Result3" HeaderText="R3" DataFormatString="{0:N3}" />
        <asp:BoundField DataField="Unit" HeaderText="الوحدة" />
        <asp:CheckBoxField DataField="IsApproved" HeaderText="معتمد" ReadOnly="true" />
        <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
          <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("CalculationId") %>' />
          <asp:LinkButton runat="server" Text="اعتماد" CssClass="gsp-btn gsp-btn-success" CommandName="ApproveItem" CommandArgument='<%# Eval("CalculationId") %>' OnClientClick="return confirm('اعتماد الحساب؟');" />
          <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("CalculationId") %>' OnClientClick="return confirm('حذف الحساب؟');" />
        </ItemTemplate></asp:TemplateField>
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
