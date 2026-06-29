<%@ Page Title="مصفوفة الاعتماد" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovalMatrix.aspx.cs" Inherits="ApprovalMatrix" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مصفوفة الاعتماد - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">مصفوفة سير العمل والاعتماد Approval Matrix</h1>
      <div class="gsp-page-subtitle">تعريف مراحل المراجعة والاعتماد لكل نوع كيان: مشروع، تقرير فني، خطة تحري، أو حزمة طباعة.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل مرحلة</h2>
    <asp:HiddenField ID="hfWorkflowStepId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">نوع الكيان</label><asp:DropDownList ID="ddlEntityType" runat="server" CssClass="gsp-select"><asp:ListItem Text="PROJECT" Value="PROJECT" /><asp:ListItem Text="TECHNICAL_REPORT" Value="TECHNICAL_REPORT" /><asp:ListItem Text="PRINT_PACKAGE" Value="PRINT_PACKAGE" /><asp:ListItem Text="INVESTIGATION_PLAN" Value="INVESTIGATION_PLAN" /><asp:ListItem Text="LAB_RESULTS" Value="LAB_RESULTS" /></asp:DropDownList></div>
      <div><label class="gsp-label">كود المرحلة <span class="gsp-required">*</span></label><asp:TextBox ID="txtStepCode" runat="server" CssClass="gsp-input" placeholder="مثلاً TECHNICAL_REVIEW" /></div>
      <div><label class="gsp-label">اسم المرحلة عربي <span class="gsp-required">*</span></label><asp:TextBox ID="txtStepNameAr" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اسم المرحلة إنجليزي</label><asp:TextBox ID="txtStepNameEn" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الصلاحية المطلوبة</label><asp:TextBox ID="txtRequiredPermission" runat="server" CssClass="gsp-input" placeholder="Workflow.Approve" /></div>
      <div><label class="gsp-label">الترتيب</label><asp:TextBox ID="txtSortOrder" runat="server" CssClass="gsp-input" Text="100" /></div>
      <div><asp:CheckBox ID="chkIsFinal" runat="server" Text="مرحلة نهائية" /></div>
      <div><asp:CheckBox ID="chkIsActive" runat="server" Text="نشطة" Checked="true" /></div>
      <div class="full gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ المرحلة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" /><asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">المراحل المعرفة</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">تصفية حسب نوع الكيان</label><asp:DropDownList ID="ddlFilterEntityType" runat="server" CssClass="gsp-select"><asp:ListItem Text="كل الأنواع" Value="" /><asp:ListItem Text="PROJECT" Value="PROJECT" /><asp:ListItem Text="TECHNICAL_REPORT" Value="TECHNICAL_REPORT" /><asp:ListItem Text="PRINT_PACKAGE" Value="PRINT_PACKAGE" /><asp:ListItem Text="INVESTIGATION_PLAN" Value="INVESTIGATION_PLAN" /><asp:ListItem Text="LAB_RESULTS" Value="LAB_RESULTS" /></asp:DropDownList></div>
      <div style="align-self:end"><asp:Button ID="btnFilter" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnFilter_Click" /></div>
    </div>
    <br />
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSteps" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مراحل." OnRowCommand="gvSteps_RowCommand">
        <Columns>
          <asp:BoundField DataField="WorkflowStepId" HeaderText="#" />
          <asp:BoundField DataField="EntityType" HeaderText="الكيان" />
          <asp:BoundField DataField="StepCode" HeaderText="الكود" />
          <asp:BoundField DataField="StepNameAr" HeaderText="المرحلة" />
          <asp:BoundField DataField="RequiredPermission" HeaderText="الصلاحية" />
          <asp:BoundField DataField="SortOrder" HeaderText="الترتيب" />
          <asp:CheckBoxField DataField="IsFinal" HeaderText="نهائية" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشطة" />
          <asp:TemplateField HeaderText="إجراء"><ItemTemplate><asp:LinkButton ID="btnEdit" runat="server" CssClass="gsp-btn gsp-btn-secondary" Text="تعديل" CommandName="EditItem" CommandArgument='<%# Eval("WorkflowStepId") %>' /></ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
