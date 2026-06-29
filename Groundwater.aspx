<%@ Page Title="المياه الجوفية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Groundwater.aspx.cs" Inherits="Groundwater" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">المياه الجوفية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">قراءات المياه الجوفية</h1><div class="gsp-page-subtitle">تسجيل مناسيب المياه داخل الجسات مع وقت الاستقرار ونوع القراءة.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة قراءة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة قراءة مياه جوفية" /></h2>
    <asp:HiddenField ID="hfGroundwaterObservationId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlBorehole" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">تاريخ القراءة</label><asp:TextBox ID="txtObservationDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">عمق المياه من سطح الأرض م <span class="gsp-required">*</span></label><asp:TextBox ID="txtDepthToWaterM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نوع القراءة</label><asp:DropDownList ID="ddlObservationType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">عمق التغليف Casing م</label><asp:TextBox ID="txtCasingDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">زمن الاستقرار بالساعة</label><asp:TextBox ID="txtStabilizedAfterHours" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث القراءات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة</label><asp:DropDownList ID="ddlFilterBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterBorehole_SelectedIndexChanged" /></div>
      <div style="align-self:end;"><asp:Button ID="btnClearSearch" runat="server" Text="مسح الفلتر" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة قراءات المياه الجوفية</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvGroundwater" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد قراءات." OnRowCommand="gvGroundwater_RowCommand">
        <Columns>
          <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="ObservationDate" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd}" />
          <asp:BoundField DataField="DepthToWaterM" HeaderText="عمق المياه م" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="ObservationTypeNameAr" HeaderText="نوع القراءة" />
          <asp:BoundField DataField="StabilizedAfterHours" HeaderText="الاستقرار ساعة" DataFormatString="{0:N2}" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("GroundwaterObservationId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("GroundwaterObservationId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذه القراءة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
