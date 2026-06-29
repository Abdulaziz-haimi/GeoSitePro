<%@ Page Title="مركز التنبيهات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="Notifications" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مركز التنبيهات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">مركز التنبيهات Notifications Center</h1>
      <div class="gsp-page-subtitle">عرض التنبيهات غير المقروءة والتنبيهات الناتجة من طلبات الاعتماد وبنود المتابعة المستحقة أو المتأخرة.</div>
    </div>
    <div class="gsp-actions">
      <asp:Button ID="btnGenerate" runat="server" Text="توليد تنبيهات المتابعة" CssClass="gsp-btn gsp-btn-warning" OnClick="btnGenerate_Click" />
      <asp:Button ID="btnMarkAllRead" runat="server" Text="تعليم الكل كمقروء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnMarkAllRead_Click" />
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">البحث والتصفية</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="غير مقروءة" Value="Unread" /><asp:ListItem Text="مقروءة" Value="Read" /><asp:ListItem Text="مؤرشفة" Value="Archived" /><asp:ListItem Text="كل الحالات" Value="" /></asp:DropDownList></div>
      <div><label class="gsp-label">الأهمية</label><asp:DropDownList ID="ddlSeverity" runat="server" CssClass="gsp-select"><asp:ListItem Text="كل المستويات" Value="" /><asp:ListItem Text="Info" Value="Info" /><asp:ListItem Text="Warning" Value="Warning" /><asp:ListItem Text="Critical" Value="Critical" /></asp:DropDownList></div>
      <div><label class="gsp-label">بحث</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="عنوان التنبيه، المشروع، النص..." /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">غير مقروءة</div><div class="gsp-stat-value"><asp:Literal ID="litUnreadCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">حرجة</div><div class="gsp-stat-value"><asp:Literal ID="litCriticalCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">متأخرة</div><div class="gsp-stat-value"><asp:Literal ID="litOverdueCount" runat="server" Text="0" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">إجمالي التنبيهات</div><div class="gsp-stat-value"><asp:Literal ID="litTotalCount" runat="server" Text="0" /></div></div>
  </div>
  <br />

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة التنبيهات</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvNotifications" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد تنبيهات." OnRowCommand="gvNotifications_RowCommand">
        <Columns>
          <asp:BoundField DataField="NotificationId" HeaderText="#" />
          <asp:BoundField DataField="CreatedAt" HeaderText="تاريخ الإنشاء" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
          <asp:BoundField DataField="Severity" HeaderText="الأهمية" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="NotificationTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="NotificationBody" HeaderText="التفاصيل" />
          <asp:BoundField DataField="DueDate" HeaderText="تاريخ الاستحقاق" DataFormatString="{0:yyyy-MM-dd}" />
          <asp:BoundField DataField="Status" HeaderText="الحالة" />
          <asp:TemplateField HeaderText="إجراءات">
            <ItemTemplate>
              <asp:LinkButton ID="btnRead" runat="server" CssClass="gsp-btn gsp-btn-success" Text="مقروء" CommandName="ReadItem" CommandArgument='<%# Eval("NotificationId") %>' Visible='<%# Convert.ToString(Eval("Status")) == "Unread" %>' />
              <asp:LinkButton ID="btnArchive" runat="server" CssClass="gsp-btn gsp-btn-secondary" Text="أرشفة" CommandName="ArchiveItem" CommandArgument='<%# Eval("NotificationId") %>' />
            </ItemTemplate>
          </asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
