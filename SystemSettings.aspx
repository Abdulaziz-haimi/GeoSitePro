<%@ Page Title="إعدادات النظام" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SystemSettings.aspx.cs" Inherits="SystemSettings" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">إعدادات النظام - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">إعدادات النظام</h1><div class="gsp-page-subtitle">إدارة الإعدادات التشغيلية العامة مثل مسار النسخ الاحتياطي، إعدادات التقارير، إعدادات الجودة، والتصدير.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnNew" runat="server" Text="إعداد جديد" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnNew_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بيانات الإعداد</h2>
    <asp:HiddenField ID="hfSettingId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">التصنيف</label><asp:DropDownList ID="ddlCategory" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">مفتاح الإعداد <span class="gsp-required">*</span></label><asp:TextBox ID="txtSettingKey" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">نوع البيانات</label><asp:DropDownList ID="ddlDataType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">القيمة</label><asp:TextBox ID="txtSettingValue" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الوصف</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><asp:CheckBox ID="chkIsEncrypted" runat="server" Text=" قيمة حساسة / مشفرة منطقيًا" /></div>
      <div><asp:CheckBox ID="chkIsActive" runat="server" Text=" نشط" Checked="true" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ الإعداد" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" />
      <asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" />
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة الإعدادات</h2>
    <div class="gsp-actions">
      <asp:DropDownList ID="ddlFilterCategory" runat="server" CssClass="gsp-select" style="max-width:230px" />
      <asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" style="max-width:280px" placeholder="بحث بالمفتاح أو الوصف" />
      <asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnSearch_Click" />
    </div>
    <br />
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvSettings" runat="server" CssClass="gsp-table" AutoGenerateColumns="false" GridLines="None" OnRowCommand="gvSettings_RowCommand">
        <Columns>
          <asp:BoundField DataField="Category" HeaderText="التصنيف" />
          <asp:BoundField DataField="SettingKey" HeaderText="المفتاح" />
          <asp:BoundField DataField="SettingValueMasked" HeaderText="القيمة" />
          <asp:BoundField DataField="DataType" HeaderText="النوع" />
          <asp:BoundField DataField="IsActiveText" HeaderText="الحالة" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditRow" CommandArgument='<%# Eval("SettingId") %>' />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteRow" CommandArgument='<%# Eval("SettingId") %>' OnClientClick="return confirm('هل تريد حذف هذا الإعداد؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
