<%@ Page Title="قواعد التنبيهات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NotificationRules.aspx.cs" Inherits="NotificationRules" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">قواعد التنبيهات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">قواعد التنبيهات Notification Rules</h1>
      <div class="gsp-page-subtitle">إدارة قواعد التنبيه للأشياء المتأخرة أو التي تحتاج مراجعة أو اعتماد. هذه القواعد لا تغيّر المعايير، بل تساعد على المتابعة التشغيلية.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل قاعدة تنبيه</h2>
    <asp:HiddenField ID="hfNotificationRuleId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">كود القاعدة <span class="gsp-required">*</span></label><asp:TextBox ID="txtRuleCode" runat="server" CssClass="gsp-input" placeholder="مثلاً FOLLOWUP_OVERDUE" /></div>
      <div><label class="gsp-label">اسم القاعدة <span class="gsp-required">*</span></label><asp:TextBox ID="txtRuleNameAr" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نوع القاعدة</label><asp:DropDownList ID="ddlRuleType" runat="server" CssClass="gsp-select"><asp:ListItem Text="Follow-up Due" Value="FOLLOWUP_DUE" /><asp:ListItem Text="Follow-up Overdue" Value="FOLLOWUP_OVERDUE" /><asp:ListItem Text="Workflow Pending" Value="WORKFLOW_PENDING" /><asp:ListItem Text="Quality Check" Value="QUALITY_CHECK" /></asp:DropDownList></div>
      <div><label class="gsp-label">نوع الكيان</label><asp:DropDownList ID="ddlEntityType" runat="server" CssClass="gsp-select"><asp:ListItem Text="Follow-up" Value="FOLLOWUP" /><asp:ListItem Text="Workflow" Value="WORKFLOW" /><asp:ListItem Text="Project" Value="PROJECT" /><asp:ListItem Text="Report" Value="REPORT" /><asp:ListItem Text="Lab Result" Value="LAB_RESULT" /></asp:DropDownList></div>
      <div><label class="gsp-label">الأيام قبل/بعد الاستحقاق</label><asp:TextBox ID="txtDaysOffset" runat="server" CssClass="gsp-input" Text="0" /></div>
      <div><label class="gsp-label">الأهمية</label><asp:DropDownList ID="ddlSeverity" runat="server" CssClass="gsp-select"><asp:ListItem Text="Info" Value="Info" /><asp:ListItem Text="Warning" Value="Warning" /><asp:ListItem Text="Critical" Value="Critical" /></asp:DropDownList></div>
      <div class="full"><label class="gsp-label">قالب الرسالة</label><asp:TextBox ID="txtMessageTemplate" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" placeholder="مثال: يوجد بند متابعة مستحق للمشروع {ProjectCode}" /></div>
      <div><asp:CheckBox ID="chkIsActive" runat="server" Text="نشطة" Checked="true" /></div>
      <div class="full gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ القاعدة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" /><asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">القواعد الحالية</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvRules" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد قواعد." OnRowCommand="gvRules_RowCommand">
        <Columns>
          <asp:BoundField DataField="NotificationRuleId" HeaderText="#" />
          <asp:BoundField DataField="RuleCode" HeaderText="الكود" />
          <asp:BoundField DataField="RuleNameAr" HeaderText="الاسم" />
          <asp:BoundField DataField="RuleType" HeaderText="النوع" />
          <asp:BoundField DataField="EntityType" HeaderText="الكيان" />
          <asp:BoundField DataField="DaysOffset" HeaderText="الأيام" />
          <asp:BoundField DataField="Severity" HeaderText="الأهمية" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشطة" />
          <asp:TemplateField HeaderText="إجراء"><ItemTemplate><asp:LinkButton ID="btnEdit" runat="server" CssClass="gsp-btn gsp-btn-secondary" Text="تعديل" CommandName="EditItem" CommandArgument='<%# Eval("NotificationRuleId") %>' /></ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
