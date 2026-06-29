<%@ Page Title="مخرجات الطباعة" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PrintableOutputs.aspx.cs" Inherits="PrintableOutputs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">مخرجات الطباعة - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">مخرجات الطباعة Print Outputs</h1>
      <div class="gsp-page-subtitle">تجميع مخرجات المشروع للطباعة: حزمة المشروع، سجل الجسات، ملخص العينات، SPT، المياه الجوفية، ونتائج المختبر.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض المخرجات" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false">
    <asp:Literal ID="litOverview" runat="server" />

    <div class="gsp-card">
      <h2 class="gsp-card-title">حزمة طباعة المشروع</h2>
      <p class="gsp-muted">هذه الحزمة مناسبة للمراجعة الداخلية أو الإرسال الأولي. يمكن طباعتها من المتصفح أو حفظها PDF.</p>
      <div class="gsp-actions">
        <asp:HyperLink ID="lnkProjectPackage" runat="server" CssClass="gsp-btn gsp-btn-primary" Target="_blank">طباعة حزمة المشروع</asp:HyperLink>
        <asp:HyperLink ID="lnkAllBoreholeLogs" runat="server" CssClass="gsp-btn gsp-btn-secondary" Target="_blank">طباعة كل سجلات الجسات</asp:HyperLink>
      </div>
    </div>

    <div class="gsp-card">
      <h2 class="gsp-card-title">سجلات الجسات Borehole Logs</h2>
      <div class="gsp-table-wrap">
        <asp:GridView ID="gvBoreholes" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد جسات لهذا المشروع.">
          <Columns>
            <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" />
            <asp:BoundField DataField="ActualDepthM" HeaderText="العمق" />
            <asp:BoundField DataField="Easting" HeaderText="Easting" />
            <asp:BoundField DataField="Northing" HeaderText="Northing" />
            <asp:BoundField DataField="ElevationM" HeaderText="Elevation" />
            <asp:BoundField DataField="GroundwaterDepthM" HeaderText="GWT" />
            <asp:HyperLinkField HeaderText="طباعة" Text="Borehole Log" DataNavigateUrlFields="ProjectId,BoreholeId" DataNavigateUrlFormatString="~/BoreholeLogPrint.aspx?ProjectId={0}&BoreholeId={1}" Target="_blank" />
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </asp:Panel>
</div>
</asp:Content>
