<%@ Page Title="إدارة الأدوار" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Roles.aspx.cs" Inherits="Roles" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">إدارة الأدوار - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">إدارة الأدوار Roles</h1>
      <div class="gsp-page-subtitle">إنشاء أدوار النظام وتعديلها ثم ربط كل دور بالصلاحيات المناسبة.</div>
    </div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة دور" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة دور" /></h2>
    <asp:HiddenField ID="hfRoleId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">اسم الدور <span class="gsp-required">*</span></label><asp:TextBox ID="txtRoleName" runat="server" CssClass="gsp-input" MaxLength="150" /></div>
      <div><label class="gsp-label">الحالة</label><asp:CheckBox ID="chkIsActive" runat="server" Text=" دور نشط" Checked="true" /></div>
      <div class="full"><label class="gsp-label">الوصف</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" MaxLength="500" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" />
      <asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث الأدوار</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="اسم الدور أو الوصف..." /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="الكل" Value="" /><asp:ListItem Text="نشط" Value="1" /><asp:ListItem Text="غير نشط" Value="0" /></asp:DropDownList></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة الأدوار</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvRoles" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد أدوار." OnRowCommand="gvRoles_RowCommand">
        <Columns>
          <asp:BoundField DataField="RoleName" HeaderText="اسم الدور" />
          <asp:BoundField DataField="Description" HeaderText="الوصف" />
          <asp:BoundField DataField="UserCount" HeaderText="المستخدمون" />
          <asp:BoundField DataField="PermissionCount" HeaderText="الصلاحيات" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشط" ReadOnly="true" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:HyperLink runat="server" Text="الصلاحيات" CssClass="gsp-btn gsp-btn-primary" NavigateUrl='<%# "~/RolePermissions.aspx?RoleId=" + Eval("RoleId") %>' />
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("RoleId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("RoleId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذا الدور منطقيًا؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
