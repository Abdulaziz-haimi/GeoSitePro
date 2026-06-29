<%@ Page Title="تبادل البيانات" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DataExchange.aspx.cs" Inherits="DataExchange" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">تبادل البيانات - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">تبادل البيانات Data Exchange</h1>
      <div class="gsp-page-subtitle">تصدير بيانات المشروع بصيغ CSV جاهزة للمراجعة، Excel، أو النقل إلى أنظمة خارجية.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnRefresh" runat="server" Text="تحديث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnRefresh_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false">
    <asp:Literal ID="litOverview" runat="server" />
    <div class="gsp-card">
      <h2 class="gsp-card-title">تنزيل ملفات CSV</h2>
      <p class="gsp-muted">كل زر يولّد ملف CSV مباشر من قاعدة البيانات. يمكن فتح الملف في Excel أو استخدامه كملف وسيط للتدقيق أو التكامل.</p>
      <div class="gsp-actions">
        <asp:HyperLink ID="lnkExportBoreholes" runat="server" CssClass="gsp-btn gsp-btn-primary">Boreholes CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportLayers" runat="server" CssClass="gsp-btn gsp-btn-primary">Borehole Layers CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportSamples" runat="server" CssClass="gsp-btn gsp-btn-primary">Samples CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportSPT" runat="server" CssClass="gsp-btn gsp-btn-primary">SPT CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportGroundwater" runat="server" CssClass="gsp-btn gsp-btn-primary">Groundwater CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportLab" runat="server" CssClass="gsp-btn gsp-btn-primary">Lab Results CSV</asp:HyperLink>
        <asp:HyperLink ID="lnkExportReports" runat="server" CssClass="gsp-btn gsp-btn-secondary">Reports Index CSV</asp:HyperLink>
      </div>
    </div>

    <div class="gsp-card">
      <h2 class="gsp-card-title">سجل عمليات التصدير</h2>
      <div class="gsp-table-wrap">
        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد عمليات تصدير مسجلة.">
          <Columns>
            <asp:BoundField DataField="DatasetCode" HeaderText="Dataset" />
            <asp:BoundField DataField="ExportFormat" HeaderText="الصيغة" />
            <asp:BoundField DataField="FileName" HeaderText="الملف" />
            <asp:BoundField DataField="RowCount" HeaderText="عدد الصفوف" />
            <asp:BoundField DataField="Status" HeaderText="الحالة" />
            <asp:BoundField DataField="RequestedByName" HeaderText="بواسطة" />
            <asp:BoundField DataField="RequestedAt" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </asp:Panel>
</div>
</asp:Content>
