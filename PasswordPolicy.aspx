<%@ Page Title="سياسة كلمة المرور" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PasswordPolicy.aspx.cs" Inherits="PasswordPolicy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">سياسة كلمة المرور والجلسات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">سياسة كلمة المرور والجلسات</h1><div class="gsp-page-subtitle">ضبط الحد الأدنى لقوة كلمة المرور، عدد محاولات الدخول، مدة القفل، وانتهاء الجلسة.</div></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">السياسة الحالية</h2>
    <asp:HiddenField ID="hfPolicyId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">الحد الأدنى للطول</label><asp:TextBox ID="txtMinLength" runat="server" CssClass="gsp-input" TextMode="Number" /></div>
      <div><label class="gsp-label">انتهاء كلمة المرور بالأيام</label><asp:TextBox ID="txtExpiryDays" runat="server" CssClass="gsp-input" TextMode="Number" /></div>
      <div><label class="gsp-label">أقصى محاولات فاشلة</label><asp:TextBox ID="txtMaxFailed" runat="server" CssClass="gsp-input" TextMode="Number" /></div>
      <div><label class="gsp-label">مدة قفل الحساب بالدقائق</label><asp:TextBox ID="txtLockoutMinutes" runat="server" CssClass="gsp-input" TextMode="Number" /></div>
      <div><label class="gsp-label">انتهاء الجلسة بالدقائق</label><asp:TextBox ID="txtSessionTimeout" runat="server" CssClass="gsp-input" TextMode="Number" /></div>
      <div><label class="gsp-label">سياسة Remember Me</label><asp:CheckBox ID="chkAllowRememberMe" runat="server" Text=" السماح بتذكر المستخدم" /></div>
      <div><asp:CheckBox ID="chkUpper" runat="server" Text=" يتطلب حرف كبير A-Z" /></div>
      <div><asp:CheckBox ID="chkLower" runat="server" Text=" يتطلب حرف صغير a-z" /></div>
      <div><asp:CheckBox ID="chkNumber" runat="server" Text=" يتطلب رقم" /></div>
      <div><asp:CheckBox ID="chkSpecial" runat="server" Text=" يتطلب رمز خاص" /></div>
      <div><asp:CheckBox ID="chkForceChange" runat="server" Text=" إجبار تغيير كلمة المرور الافتراضية" /></div>
      <div><asp:CheckBox ID="chkActive" runat="server" Text=" السياسة نشطة" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ السياسة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" />
      <asp:Button ID="btnReload" runat="server" Text="إعادة تحميل" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnReload_Click" />
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">ملاحظة تشغيلية</h2>
    <p class="gsp-muted">هذه السياسة تحفظ في قاعدة البيانات وتستخدم كمرجع تشغيلي. لتطبيقها بالكامل داخل تسجيل الدخول يجب ربطها لاحقًا بمنطق Login.aspx.cs عند الاختبار على Visual Studio.</p>
  </div>
</div>
</asp:Content>
