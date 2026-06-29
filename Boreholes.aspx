<%@ Page Title="الجسات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Boreholes.aspx.cs" Inherits="Boreholes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">الجسات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">الجسات Boreholes</h1>
      <div class="gsp-page-subtitle">إدخال وتعديل بيانات الجسات الفعلية وربطها بالمشروع تمهيدًا لسجل الجسة والعينات.</div>
    </div>
    <div class="gsp-actions">
      <asp:Button ID="btnNew" runat="server" Text="إضافة جسة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" />
      <asp:HyperLink ID="lnkProjects" runat="server" NavigateUrl="~/Projects.aspx" CssClass="gsp-btn gsp-btn-secondary">المشاريع</asp:HyperLink>
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة جسة" /></h2>
    <asp:HiddenField ID="hfBoreholeId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">كود الجسة <span class="gsp-required">*</span></label><asp:TextBox ID="txtBoreholeCode" runat="server" CssClass="gsp-input" placeholder="BH-01" /></div>
      <div><label class="gsp-label">العمق المخطط م</label><asp:TextBox ID="txtPlannedDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">العمق الفعلي م <span class="gsp-required">*</span></label><asp:TextBox ID="txtActualDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Easting</label><asp:TextBox ID="txtEasting" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">Northing</label><asp:TextBox ID="txtNorthing" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">المنسوب Elevation م</label><asp:TextBox ID="txtElevationM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">طريقة الحفر</label><asp:DropDownList ID="ddlDrillingMethod" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">حالة الجسة</label><asp:DropDownList ID="ddlBoreholeStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">عمق المياه الجوفية م</label><asp:TextBox ID="txtGroundwaterDepthM" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ البداية</label><asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ النهاية</label><asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">مهندس الحقل</label><asp:TextBox ID="txtFieldEngineer" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نشطة؟</label><asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text=" نعم" /></div>
      <div class="full"><label class="gsp-label">وصف الموقع</label><asp:TextBox ID="txtLocationDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">سبب التوقف / نهاية الحفر</label><asp:TextBox ID="txtTerminationReason" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">ملاحظات</label><asp:TextBox ID="txtNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" />
      <asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث الجسات</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="كود الجسة، المشروع، المهندس..." /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة الجسات</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvBoreholes" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد جسات." OnRowCommand="gvBoreholes_RowCommand">
        <Columns>
          <asp:BoundField DataField="BoreholeCode" HeaderText="كود الجسة" />
          <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
          <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
          <asp:BoundField DataField="ActualDepthM" HeaderText="العمق م" DataFormatString="{0:N2}" />
          <asp:BoundField DataField="DrillingMethodNameAr" HeaderText="طريقة الحفر" />
          <asp:BoundField DataField="BoreholeStatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="GroundwaterDepthM" HeaderText="المياه م" DataFormatString="{0:N2}" />
          <asp:TemplateField HeaderText="نشطة"><ItemTemplate><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "gsp-badge gsp-badge-success" : "gsp-badge gsp-badge-danger" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "نشطة" : "موقوفة" %></span></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("BoreholeId") %>' />
            <asp:HyperLink runat="server" Text="السجل" CssClass="gsp-btn gsp-btn-primary" NavigateUrl='<%# "BoreholeLog.aspx?ProjectId=" + Eval("ProjectId") + "&BoreholeId=" + Eval("BoreholeId") %>' />
            <asp:HyperLink runat="server" Text="العينات" CssClass="gsp-btn gsp-btn-secondary" NavigateUrl='<%# "Samples.aspx?ProjectId=" + Eval("ProjectId") + "&BoreholeId=" + Eval("BoreholeId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("BoreholeId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذه الجسة؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
