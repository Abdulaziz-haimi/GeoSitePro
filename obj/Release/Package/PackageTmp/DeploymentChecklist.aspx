<%@ Page Title="قائمة جاهزية النشر" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DeploymentChecklist.aspx.cs" Inherits="DeploymentChecklist" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">قائمة جاهزية النشر - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">قائمة جاهزية النشر Production Deployment Checklist</h1><div class="gsp-page-subtitle">قائمة تحقق قبل رفع النظام على سيرفر إنتاج: أمان، قاعدة بيانات، نسخ احتياطي، اختبار، وتقارير.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnSeed" runat="server" Text="إضافة البنود الافتراضية" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnSeed_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي البنود</div><div class="gsp-stat-value"><asp:Literal ID="litTotal" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">مكتمل</div><div class="gsp-stat-value"><asp:Literal ID="litCompleted" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">غير مكتمل</div><div class="gsp-stat-value"><asp:Literal ID="litOpen" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">جاهزية الإنتاج</div><div class="gsp-stat-value"><asp:Literal ID="litScore" runat="server" /></div></div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل بند</h2>
    <asp:HiddenField ID="hfItemId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المجال</label><asp:DropDownList ID="ddlArea" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الكود</label><asp:TextBox ID="txtItemCode" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">العنوان</label><asp:TextBox ID="txtItemTitle" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الوصف</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlStatus" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">المسؤول</label><asp:TextBox ID="txtResponsible" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">أدلة / ملاحظات</label><asp:TextBox ID="txtEvidence" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><asp:CheckBox ID="chkRequired" runat="server" Text=" مطلوب للإنتاج" Checked="true" /></div>
      <div><asp:CheckBox ID="chkActive" runat="server" Text=" نشط" Checked="true" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ البند" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" />
      <asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" />
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة البنود</h2>
    <div class="gsp-actions">
      <asp:DropDownList ID="ddlFilterArea" runat="server" CssClass="gsp-select" style="max-width:220px" />
      <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select" style="max-width:220px" />
      <asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnSearch_Click" />
    </div>
    <br />
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvItems" runat="server" CssClass="gsp-table" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvItems_RowCommand">
        <Columns>
          <asp:BoundField DataField="Area" HeaderText="المجال" />
          <asp:BoundField DataField="ItemCode" HeaderText="الكود" />
          <asp:BoundField DataField="ItemTitle" HeaderText="البند" />
          <asp:BoundField DataField="Status" HeaderText="الحالة" />
          <asp:BoundField DataField="RequiredText" HeaderText="مطلوب" />
          <asp:BoundField DataField="ResponsiblePerson" HeaderText="المسؤول" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditRow" CommandArgument='<%# Eval("ItemId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("ItemId") %>' OnClientClick="return confirm('هل تريد حذف البند؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
