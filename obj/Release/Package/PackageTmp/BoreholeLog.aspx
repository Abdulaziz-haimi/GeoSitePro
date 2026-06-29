<%@ Page Title="سجل الجسة" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BoreholeLog.aspx.cs" Inherits="BoreholeLog" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">سجل الجسة - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">سجل الجسة Borehole Log</h1><div class="gsp-page-subtitle">تجميع طبقات الجسة والعينات واختبارات SPT وقراءات المياه الجوفية في صفحة واحدة.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNewLayer" runat="server" Text="إضافة طبقة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNewLayer_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار الجسة</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">الجسة</label><asp:DropDownList ID="ddlBorehole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBorehole_SelectedIndexChanged" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlHeader" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title">بيانات الجسة</h2>
    <div class="gsp-table-wrap">
      <table class="gsp-table">
        <tr><th>كود الجسة</th><td><asp:Literal ID="litBoreholeCode" runat="server" /></td><th>المشروع</th><td><asp:Literal ID="litProject" runat="server" /></td></tr>
        <tr><th>العمق الفعلي</th><td><asp:Literal ID="litActualDepth" runat="server" /></td><th>طريقة الحفر</th><td><asp:Literal ID="litDrillingMethod" runat="server" /></td></tr>
        <tr><th>المنسوب</th><td><asp:Literal ID="litElevation" runat="server" /></td><th>المياه الجوفية</th><td><asp:Literal ID="litGroundwater" runat="server" /></td></tr>
      </table>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:HyperLink ID="lnkBoreholeEdit" runat="server" CssClass="gsp-btn gsp-btn-secondary">تعديل بيانات الجسة</asp:HyperLink>
      <asp:HyperLink ID="lnkSamples" runat="server" CssClass="gsp-btn gsp-btn-secondary">العينات</asp:HyperLink>
      <asp:HyperLink ID="lnkSPT" runat="server" CssClass="gsp-btn gsp-btn-secondary">SPT</asp:HyperLink>
      <asp:HyperLink ID="lnkGroundwater" runat="server" CssClass="gsp-btn gsp-btn-secondary">المياه الجوفية</asp:HyperLink>
    </div>
  </asp:Panel>

  <asp:Panel ID="pnlLayerForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litLayerFormTitle" runat="server" Text="إضافة طبقة" /></h2>
    <asp:HiddenField ID="hfLayerId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">من عمق م <span class="gsp-required">*</span></label><asp:TextBox ID="txtFromDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">إلى عمق م <span class="gsp-required">*</span></label><asp:TextBox ID="txtToDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نوع التربة/الصخر</label><asp:DropDownList ID="ddlSoilRockType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">USCS</label><asp:TextBox ID="txtUSCS" runat="server" CssClass="gsp-input" placeholder="SM, CL, GP..." /></div>
      <div><label class="gsp-label">اللون</label><asp:TextBox ID="txtColor" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">القوام / الكثافة</label><asp:TextBox ID="txtConsistencyDensity" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">حالة الرطوبة</label><asp:TextBox ID="txtMoistureCondition" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Recovery %</label><asp:TextBox ID="txtRecoveryPercent" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">RQD %</label><asp:TextBox ID="txtRQDPercent" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الوصف الهندسي</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSaveLayer" runat="server" Text="حفظ الطبقة" CssClass="gsp-btn gsp-btn-success" OnClick="btnSaveLayer_Click" /><asp:Button ID="btnCancelLayer" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancelLayer_Click" CausesValidation="false" /></div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">طبقات الجسة</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvLayers" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد طبقات مسجلة لهذه الجسة." OnRowCommand="gvLayers_RowCommand">
        <Columns>
          <asp:BoundField DataField="FromDepthM" HeaderText="من" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="ToDepthM" HeaderText="إلى" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="SoilRockTypeNameAr" HeaderText="النوع" />
          <asp:BoundField DataField="USCS" HeaderText="USCS" />
          <asp:BoundField DataField="Description" HeaderText="الوصف" />
          <asp:BoundField DataField="RecoveryPercent" HeaderText="Recovery %" DataFormatString="{0:N1}" />
          <asp:BoundField DataField="RQDPercent" HeaderText="RQD %" DataFormatString="{0:N1}" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditLayer" CommandArgument='<%# Eval("LayerId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteLayer" CommandArgument='<%# Eval("LayerId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذه الطبقة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>

  <div class="gsp-grid gsp-grid-2">
    <div class="gsp-card"><h2 class="gsp-card-title">العينات</h2><div class="gsp-table-wrap"><asp:GridView ID="gvSamples" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد عينات."><Columns><asp:BoundField DataField="SampleCode" HeaderText="الكود" /><asp:BoundField DataField="FromDepthM" HeaderText="من" DataFormatString="{0:N2}" /><asp:BoundField DataField="ToDepthM" HeaderText="إلى" DataFormatString="{0:N2}" /><asp:BoundField DataField="SampleTypeNameAr" HeaderText="النوع" /></Columns></asp:GridView></div></div>
    <div class="gsp-card"><h2 class="gsp-card-title">اختبارات SPT</h2><div class="gsp-table-wrap"><asp:GridView ID="gvSPT" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد اختبارات SPT."><Columns><asp:BoundField DataField="TestDepthM" HeaderText="العمق" DataFormatString="{0:N2}" /><asp:BoundField DataField="BlowCount1" HeaderText="N1" /><asp:BoundField DataField="BlowCount2" HeaderText="N2" /><asp:BoundField DataField="BlowCount3" HeaderText="N3" /><asp:BoundField DataField="NValue" HeaderText="N" /></Columns></asp:GridView></div></div>
    <div class="gsp-card"><h2 class="gsp-card-title">المياه الجوفية</h2><div class="gsp-table-wrap"><asp:GridView ID="gvGroundwater" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد قراءات مياه."><Columns><asp:BoundField DataField="ObservationDate" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd}" /><asp:BoundField DataField="DepthToWaterM" HeaderText="العمق" DataFormatString="{0:N2}" /><asp:BoundField DataField="ObservationTypeNameAr" HeaderText="النوع" /></Columns></asp:GridView></div></div>
  </div>
</div>
</asp:Content>
