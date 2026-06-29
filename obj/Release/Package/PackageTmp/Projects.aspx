<%@ Page Title="المشاريع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Projects.aspx.cs" Inherits="Projects" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">المشاريع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">المشاريع</h1><div class="gsp-page-subtitle">إضافة وتعديل وعرض مشاريع التحري الموقعي.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة مشروع" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة مشروع جديد" /></h2>
    <asp:HiddenField ID="hfProjectId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">كود المشروع <span class="gsp-required">*</span></label><asp:TextBox ID="txtProjectCode" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اسم المشروع <span class="gsp-required">*</span></label><asp:TextBox ID="txtProjectName" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اسم المشروع بالإنجليزية</label><asp:TextBox ID="txtProjectNameEn" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اسم العميل</label><asp:TextBox ID="txtClientName" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نوع المشروع</label><asp:DropDownList ID="ddlProjectType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">حالة المشروع</label><asp:DropDownList ID="ddlProjectStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع المنشأ</label><asp:DropDownList ID="ddlStructureType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">مرحلة التحري</label><asp:DropDownList ID="ddlInvestigationStage" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الدولة</label><asp:TextBox ID="txtCountry" runat="server" CssClass="gsp-input" Text="Saudi Arabia" /></div>
      <div><label class="gsp-label">المدينة</label><asp:TextBox ID="txtCity" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الحي / المنطقة</label><asp:TextBox ID="txtDistrict" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اسم الموقع</label><asp:TextBox ID="txtLocationName" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">المساحة م²</label><asp:TextBox ID="txtSiteAreaM2" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">عدد الأدوار</label><asp:TextBox ID="txtNumberOfFloors" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">عدد البدرومات</label><asp:TextBox ID="txtBasementCount" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">تاريخ البداية</label><asp:TextBox ID="txtProjectStartDate" runat="server" CssClass="gsp-input" TextMode="Date" /></div>
      <div><label class="gsp-label">تاريخ النهاية</label><asp:TextBox ID="txtProjectEndDate" runat="server" CssClass="gsp-input" TextMode="Date" /></div>
      <div><label class="gsp-label">نشط؟</label><asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text=" نعم" /></div>
      <div class="full"><label class="gsp-label">العنوان</label><asp:TextBox ID="txtAddress" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">نطاق العمل</label><asp:TextBox ID="txtScopeOfWork" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full"><label class="gsp-label">ملاحظات عامة</label><asp:TextBox ID="txtGeneralNotes" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /><asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" /></div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث المشاريع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="كود المشروع، الاسم، العميل، المدينة..." /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة المشاريع</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvProjects" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مشاريع." OnRowCommand="gvProjects_RowCommand">
        <Columns>
          <asp:TemplateField HeaderText="الكود"><ItemTemplate><a href='<%# "ProjectDetails.aspx?ProjectId=" + Eval("ProjectId") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("ProjectCode"))) %></a></ItemTemplate></asp:TemplateField>
          <asp:BoundField DataField="ProjectName" HeaderText="اسم المشروع" />
          <asp:BoundField DataField="ClientName" HeaderText="العميل" />
          <asp:BoundField DataField="ProjectTypeNameAr" HeaderText="النوع" />
          <asp:BoundField DataField="ProjectStatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="City" HeaderText="المدينة" />
          <asp:TemplateField HeaderText="نشط"><ItemTemplate><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "gsp-badge gsp-badge-success" : "gsp-badge gsp-badge-danger" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "نشط" : "موقوف" %></span></ItemTemplate></asp:TemplateField>
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("ProjectId") %>' />
            <asp:LinkButton runat="server" Text="تفاصيل" CssClass="gsp-btn gsp-btn-primary" CommandName="DetailsItem" CommandArgument='<%# Eval("ProjectId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ProjectId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذا المشروع؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
