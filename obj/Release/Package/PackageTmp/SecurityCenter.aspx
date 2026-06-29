<%@ Page Title="مركز الأمان" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SecurityCenter.aspx.cs" Inherits="SecurityCenter" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مركز الأمان - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">مركز الأمان Security Center</h1><div class="gsp-page-subtitle">متابعة أحداث الأمان، سياسة الدخول، وحالة الجاهزية الأمنية قبل نشر النظام للإنتاج.</div></div>
    <div class="gsp-actions"><asp:Button ID="btnRefresh" runat="server" Text="تحديث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnRefresh_Click" /></div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-grid gsp-grid-4">
    <div class="gsp-stat"><div class="gsp-stat-label">أحداث آخر 7 أيام</div><div class="gsp-stat-value"><asp:Literal ID="litEvents7" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">أحداث حرجة</div><div class="gsp-stat-value"><asp:Literal ID="litCritical" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">فشل تسجيل الدخول</div><div class="gsp-stat-value"><asp:Literal ID="litFailedLogins" runat="server" /></div></div>
    <div class="gsp-stat"><div class="gsp-stat-label">عناصر إنتاج غير مكتملة</div><div class="gsp-stat-value"><asp:Literal ID="litOpenChecklist" runat="server" /></div></div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">تسجيل حدث أمني يدوي</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">نوع الحدث</label><asp:DropDownList ID="ddlEventType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الأهمية</label><asp:DropDownList ID="ddlSeverity" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">المستخدم / اسم الدخول</label><asp:TextBox ID="txtUsername" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">الكيان المرتبط</label><asp:TextBox ID="txtEntityName" runat="server" CssClass="gsp-input" placeholder="مثال: Users, Reports, Login" /></div>
      <div class="full"><label class="gsp-label">الرسالة</label><asp:TextBox ID="txtMessage" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">تفاصيل</label><asp:TextBox ID="txtDetails" runat="server" TextMode="MultiLine" CssClass="gsp-textarea" /></div>
    </div>
    <br />
    <div class="gsp-actions"><asp:Button ID="btnLogEvent" runat="server" Text="حفظ الحدث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLogEvent_Click" /></div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">آخر أحداث الأمان</h2>
    <div class="gsp-actions">
      <asp:DropDownList ID="ddlFilterSeverity" runat="server" CssClass="gsp-select" style="max-width:200px" />
      <asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" style="max-width:280px" placeholder="بحث" />
      <asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnSearch_Click" />
    </div>
    <br />
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvEvents" runat="server" CssClass="gsp-table" AutoGenerateColumns="false" GridLines="None">
        <Columns>
          <asp:BoundField DataField="CreatedAt" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
          <asp:BoundField DataField="Severity" HeaderText="الأهمية" />
          <asp:BoundField DataField="EventType" HeaderText="نوع الحدث" />
          <asp:BoundField DataField="Username" HeaderText="المستخدم" />
          <asp:BoundField DataField="IpAddress" HeaderText="IP" />
          <asp:BoundField DataField="Message" HeaderText="الرسالة" />
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
