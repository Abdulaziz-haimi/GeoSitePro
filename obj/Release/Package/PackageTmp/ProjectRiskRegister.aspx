<%@ Page Title="سجل المخاطر" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectRiskRegister.aspx.cs" Inherits="ProjectRiskRegister" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">سجل المخاطر - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">سجل المخاطر الفنية Project Risk Register</h1>
      <div class="gsp-page-subtitle">تسجيل ومتابعة المخاطر الجيوتقنية والتشغيلية: مياه جوفية، طبقات ضعيفة، نقص بيانات، تأخر اعتماد، أو مخاطر تقرير.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/ExecutiveDashboard.aspx" CssClass="gsp-btn gsp-btn-secondary">لوحة المؤشرات</asp:HyperLink></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل خطر</h2>
    <asp:HiddenField ID="hfRiskId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">كود الخطر</label><asp:TextBox ID="txtRiskCode" runat="server" CssClass="gsp-input" placeholder="اختياري" /></div>
      <div><label class="gsp-label">فئة الخطر</label><asp:DropDownList ID="ddlRiskCategory" runat="server" CssClass="gsp-select"><asp:ListItem Text="Geotechnical" Value="Geotechnical" /><asp:ListItem Text="Groundwater" Value="Groundwater" /><asp:ListItem Text="Sampling" Value="Sampling" /><asp:ListItem Text="Laboratory" Value="Laboratory" /><asp:ListItem Text="Reporting" Value="Reporting" /><asp:ListItem Text="Approval" Value="Approval" /><asp:ListItem Text="Operational" Value="Operational" /></asp:DropDownList></div>
      <div><label class="gsp-label">المسؤول</label><asp:DropDownList ID="ddlOwner" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">عنوان الخطر <span class="gsp-required">*</span></label><asp:TextBox ID="txtRiskTitle" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">وصف الخطر</label><asp:TextBox ID="txtRiskDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><label class="gsp-label">احتمالية الحدوث 1-5</label><asp:DropDownList ID="ddlProbability" runat="server" CssClass="gsp-select"><asp:ListItem Text="1 - منخفض جدًا" Value="1" /><asp:ListItem Text="2 - منخفض" Value="2" /><asp:ListItem Text="3 - متوسط" Value="3" /><asp:ListItem Text="4 - مرتفع" Value="4" /><asp:ListItem Text="5 - مرتفع جدًا" Value="5" /></asp:DropDownList></div>
      <div><label class="gsp-label">الأثر 1-5</label><asp:DropDownList ID="ddlImpact" runat="server" CssClass="gsp-select"><asp:ListItem Text="1 - محدود" Value="1" /><asp:ListItem Text="2 - بسيط" Value="2" /><asp:ListItem Text="3 - متوسط" Value="3" /><asp:ListItem Text="4 - كبير" Value="4" /><asp:ListItem Text="5 - حرج" Value="5" /></asp:DropDownList></div>
      <div><label class="gsp-label">تاريخ الاستحقاق</label><asp:TextBox ID="txtDueDate" runat="server" CssClass="gsp-input" placeholder="yyyy-mm-dd" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="Open" Value="Open" /><asp:ListItem Text="Mitigating" Value="Mitigating" /><asp:ListItem Text="Closed" Value="Closed" /><asp:ListItem Text="Accepted" Value="Accepted" /></asp:DropDownList></div>
      <div class="full"><label class="gsp-label">خطة المعالجة Mitigation Plan</label><asp:TextBox ID="txtMitigationPlan" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div class="full gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ الخطر" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" /><asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">البحث والتصفية</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">مستوى الخطر</label><asp:DropDownList ID="ddlFilterRiskLevel" runat="server" CssClass="gsp-select"><asp:ListItem Text="كل المستويات" Value="" /><asp:ListItem Text="Low" Value="Low" /><asp:ListItem Text="Medium" Value="Medium" /><asp:ListItem Text="High" Value="High" /><asp:ListItem Text="Critical" Value="Critical" /></asp:DropDownList></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="المفتوحة" Value="Open" /><asp:ListItem Text="كل الحالات" Value="" /><asp:ListItem Text="Mitigating" Value="Mitigating" /><asp:ListItem Text="Closed" Value="Closed" /><asp:ListItem Text="Accepted" Value="Accepted" /></asp:DropDownList></div>
      <div><label class="gsp-label">بحث</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة المخاطر</h2>
    <div class="gsp-table-wrap"><asp:GridView ID="gvRisks" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد مخاطر." OnRowCommand="gvRisks_RowCommand">
      <Columns>
        <asp:BoundField DataField="RiskId" HeaderText="#" />
        <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
        <asp:BoundField DataField="RiskTitle" HeaderText="الخطر" />
        <asp:BoundField DataField="RiskCategory" HeaderText="الفئة" />
        <asp:BoundField DataField="ProbabilityLevel" HeaderText="P" />
        <asp:BoundField DataField="ImpactLevel" HeaderText="I" />
        <asp:BoundField DataField="RiskScore" HeaderText="Score" />
        <asp:BoundField DataField="RiskLevel" HeaderText="المستوى" />
        <asp:BoundField DataField="OwnerName" HeaderText="المسؤول" />
        <asp:BoundField DataField="DueDate" HeaderText="الاستحقاق" DataFormatString="{0:yyyy-MM-dd}" />
        <asp:BoundField DataField="Status" HeaderText="الحالة" />
        <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
          <asp:LinkButton ID="btnEdit" runat="server" CssClass="gsp-btn gsp-btn-secondary" Text="تعديل" CommandName="EditItem" CommandArgument='<%# Eval("RiskId") %>' />
          <asp:LinkButton ID="btnClose" runat="server" CssClass="gsp-btn gsp-btn-success" Text="إغلاق" CommandName="CloseItem" CommandArgument='<%# Eval("RiskId") %>' Visible='<%# Convert.ToString(Eval("Status")) != "Closed" %>' />
        </ItemTemplate></asp:TemplateField>
      </Columns>
    </asp:GridView></div>
  </div>
</div>
</asp:Content>
