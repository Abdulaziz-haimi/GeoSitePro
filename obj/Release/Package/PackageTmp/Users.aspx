<%@ Page Title="إدارة المستخدمين" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="Users" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">إدارة المستخدمين - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">إدارة المستخدمين Users</h1>
      <div class="gsp-page-subtitle">إنشاء المستخدمين، تعديل بياناتهم، تفعيل/إيقاف الحساب، وتوزيع الأدوار داخل النظام.</div>
    </div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إضافة مستخدم" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" /></div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة مستخدم" /></h2>
    <asp:HiddenField ID="hfUserId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">اسم الدخول <span class="gsp-required">*</span></label><asp:TextBox ID="txtUsername" runat="server" CssClass="gsp-input" MaxLength="100" /></div>
      <div><label class="gsp-label">الاسم الكامل <span class="gsp-required">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="gsp-input" MaxLength="200" /></div>
      <div><label class="gsp-label">البريد الإلكتروني</label><asp:TextBox ID="txtEmail" runat="server" CssClass="gsp-input" MaxLength="200" TextMode="Email" /></div>
      <div><label class="gsp-label">الجوال</label><asp:TextBox ID="txtMobile" runat="server" CssClass="gsp-input" MaxLength="50" /></div>
      <div><label class="gsp-label">كلمة المرور <asp:Literal ID="litPasswordHint" runat="server" /></label><asp:TextBox ID="txtPassword" runat="server" CssClass="gsp-input" TextMode="Password" /></div>
      <div><label class="gsp-label">تأكيد كلمة المرور</label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="gsp-input" TextMode="Password" /></div>
      <div class="full"><label class="gsp-label">الحالة</label><asp:CheckBox ID="chkIsActive" runat="server" Text=" مستخدم نشط" Checked="true" /></div>
      <div class="full"><label class="gsp-label">الأدوار Roles</label><asp:CheckBoxList ID="cblRoles" runat="server" RepeatColumns="3" RepeatDirection="Horizontal" CssClass="gsp-checklist" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" />
      <asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث المستخدمين</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="اسم الدخول، الاسم، البريد، الجوال..." /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="الكل" Value="" /><asp:ListItem Text="نشط" Value="1" /><asp:ListItem Text="غير نشط" Value="0" /></asp:DropDownList></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة المستخدمين</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا يوجد مستخدمون." OnRowCommand="gvUsers_RowCommand">
        <Columns>
          <asp:BoundField DataField="Username" HeaderText="اسم الدخول" />
          <asp:BoundField DataField="FullName" HeaderText="الاسم الكامل" />
          <asp:BoundField DataField="Email" HeaderText="البريد" />
          <asp:BoundField DataField="Mobile" HeaderText="الجوال" />
          <asp:BoundField DataField="RoleNames" HeaderText="الأدوار" />
          <asp:CheckBoxField DataField="IsActive" HeaderText="نشط" ReadOnly="true" />
          <asp:BoundField DataField="LastLoginAt" HeaderText="آخر دخول" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("UserId") %>' />
            <asp:LinkButton runat="server" Text="Reset" CssClass="gsp-btn gsp-btn-warning" CommandName="ResetPassword" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('سيتم إعادة كلمة المرور إلى Admin@123. هل تريد المتابعة؟');" />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف هذا المستخدم منطقيًا؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
