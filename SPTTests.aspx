<%@ Page Title="اختبارات SPT" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SPTTests.aspx.cs" Inherits="SPTTests" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">اختبارات SPT - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">اختبارات SPT</h1><div class="gsp-page-subtitle">إدخال ضربات الاختراق القياسي لكل جسة وحساب N-Value من الضربتين الثانية والثالثة.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة اختبار SPT" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة اختبار SPT" /></h2>
    <asp:HiddenField ID="hfSPTTestId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlBorehole" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">عمق الاختبار م <span class="gsp-required">*</span></label><asp:TextBox ID="txtTestDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ الاختبار</label><asp:TextBox ID="txtTestDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الضربة الأولى N1</label><asp:TextBox ID="txtBlowCount1" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الضربة الثانية N2</label><asp:TextBox ID="txtBlowCount2" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الضربة الثالثة N3</label><asp:TextBox ID="txtBlowCount3" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">N-Value اختياري</label><asp:TextBox ID="txtNValue" runat="server" CssClass="gsp-input" placeholder="يُحسب تلقائيًا من N2+N3 عند تركه فارغًا" /></div>
      <div><label class="gsp-label">نسبة طاقة المطرقة %</label><asp:TextBox ID="txtHammerEnergyRatio" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">N المصحح</label><asp:TextBox ID="txtCorrectedN" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">طول الاسترجاع م</label><asp:TextBox ID="txtRecoveryLengthM" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث اختبارات SPT</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة</label><asp:DropDownList ID="ddlFilterBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterBorehole_SelectedIndexChanged" /></div>
      <div style="align-self:end;"><asp:Button ID="btnClearSearch" runat="server" Text="مسح الفلتر" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة اختبارات SPT</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSPTTests" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد اختبارات SPT." OnRowCommand="gvSPTTests_RowCommand">
        <Columns>
          <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="TestDepthM" HeaderText="العمق م" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="BlowCount1" HeaderText="N1" />
          <asp:BoundField DataField="BlowCount2" HeaderText="N2" />
          <asp:BoundField DataField="BlowCount3" HeaderText="N3" />
          <asp:BoundField DataField="NValue" HeaderText="N" />
          <asp:BoundField DataField="CorrectedN" HeaderText="N المصحح" DataFormatString="{0:N2}" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("SPTTestId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("SPTTestId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذا الاختبار؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
