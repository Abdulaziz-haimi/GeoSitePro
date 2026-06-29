<%@ Page Title="صلاحيات الأدوار" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RolePermissions.aspx.cs" Inherits="RolePermissions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">صلاحيات الأدوار - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">صلاحيات الأدوار Role Permissions</h1>
      <div class="gsp-page-subtitle">تحديد ما يستطيع كل دور رؤيته أو تعديله داخل النظام.</div>
    </div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkBackRoles" runat="server" NavigateUrl="~/Roles.aspx" CssClass="gsp-btn gsp-btn-secondary">رجوع للأدوار</asp:HyperLink></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار الدور</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">الدور</label><asp:DropDownList ID="ddlRole" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged" /></div>
      <div style="align-self:end;"><asp:Button ID="btnSave" runat="server" Text="حفظ الصلاحيات" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة الصلاحيات</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvPermissions" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="اختر دورًا لعرض الصلاحيات." DataKeyNames="PermissionId">
        <Columns>
          <asp:TemplateField HeaderText="منح"><ItemTemplate><asp:CheckBox ID="chkGranted" runat="server" Checked='<%# Convert.ToBoolean(Eval("IsGranted")) %>' /></ItemTemplate></asp:TemplateField>
          <asp:BoundField DataField="ModuleName" HeaderText="الموديول" />
          <asp:BoundField DataField="PermissionCode" HeaderText="كود الصلاحية" />
          <asp:BoundField DataField="PermissionNameAr" HeaderText="الاسم العربي" />
          <asp:BoundField DataField="PermissionNameEn" HeaderText="الاسم الإنجليزي" />
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
