<%@ Page Title="طباعة التقرير" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReportPrint.aspx.cs" Inherits="ReportPrint" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">طباعة التقرير - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<style>
@media print{.sidebar,.topbar,.no-print{display:none!important}.main{margin:0!important;width:100%!important}.content{padding:0!important}.gsp-print-sheet{box-shadow:none!important;border:0!important}.gsp-table th,.gsp-table td{font-size:11px}.print-page-break{page-break-before:always}}
.gsp-print-sheet{background:#fff;border:1px solid var(--border);border-radius:14px;padding:28px;box-shadow:0 8px 24px rgba(15,23,42,.05)}
.gsp-report-cover{text-align:center;padding:40px 10px;border-bottom:2px solid #111827;margin-bottom:22px}.gsp-report-title{font-size:30px;font-weight:900;color:#111827;margin:0 0 12px}.gsp-report-meta{color:#4b5563;font-weight:800}.gsp-section{margin-top:24px}.gsp-section h2{font-size:20px;border-bottom:1px solid #d1d5db;padding-bottom:8px;color:#111827}.gsp-section-content{white-space:pre-wrap;line-height:1.8;color:#111827}.gsp-print-actions{margin-bottom:16px}.gsp-small-table th{width:180px}
</style>
<div class="gsp-page">
  <div class="gsp-print-actions no-print gsp-actions">
    <asp:HyperLink ID="lnkBack" runat="server" CssClass="gsp-btn gsp-btn-secondary">العودة للتحرير</asp:HyperLink>
    <button type="button" class="gsp-btn gsp-btn-primary" onclick="window.print();">طباعة / Save as PDF</button>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message gsp-message-danger"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-print-sheet">
    <div class="gsp-report-cover">
      <h1 class="gsp-report-title"><asp:Literal ID="litReportTitle" runat="server" /></h1>
      <div class="gsp-report-meta"><asp:Literal ID="litReportMeta" runat="server" /></div>
    </div>

    <div class="gsp-grid gsp-grid-2">
      <div class="gsp-card"><h2 class="gsp-card-title">بيانات التقرير</h2><table class="gsp-table gsp-small-table">
        <tr><th>رقم التقرير</th><td><asp:Literal ID="litReportNo" runat="server" /></td></tr>
        <tr><th>المراجعة</th><td><asp:Literal ID="litRevisionNo" runat="server" /></td></tr>
        <tr><th>تاريخ الإصدار</th><td><asp:Literal ID="litIssueDate" runat="server" /></td></tr>
        <tr><th>أعد بواسطة</th><td><asp:Literal ID="litPreparedBy" runat="server" /></td></tr>
        <tr><th>راجع بواسطة</th><td><asp:Literal ID="litReviewedBy" runat="server" /></td></tr>
        <tr><th>اعتمد بواسطة</th><td><asp:Literal ID="litApprovedBy" runat="server" /></td></tr>
      </table></div>
      <div class="gsp-card"><h2 class="gsp-card-title">بيانات المشروع</h2><div class="gsp-section-content"><asp:Literal ID="litProjectInfo" runat="server" /></div></div>
    </div>

    <div class="gsp-section"><h2>الملخص التنفيذي</h2><div class="gsp-section-content"><asp:Literal ID="litExecutiveSummary" runat="server" /></div></div>

    <asp:Repeater ID="rptSections" runat="server">
      <ItemTemplate>
        <div class="gsp-section">
          <h2><%# Server.HtmlEncode(Convert.ToString(Eval("SectionTitle"))) %></h2>
          <div class="gsp-section-content"><%# Server.HtmlEncode(Convert.ToString(Eval("SectionContent"))) %></div>
        </div>
      </ItemTemplate>
    </asp:Repeater>

    <div class="gsp-section print-page-break"><h2>ملخص الجسات</h2><div class="gsp-table-wrap"><asp:GridView ID="gvBoreholes" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد جسات."><Columns>
      <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" /><asp:BoundField DataField="ActualDepthM" HeaderText="العمق الفعلي" DataFormatString="{0:N2}" /><asp:BoundField DataField="GroundwaterDepthM" HeaderText="منسوب المياه" DataFormatString="{0:N2}" /><asp:BoundField DataField="FieldEngineer" HeaderText="المهندس" /><asp:BoundField DataField="BoreholeStatusNameAr" HeaderText="الحالة" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>طبقات الجسات</h2><div class="gsp-table-wrap"><asp:GridView ID="gvLayers" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد طبقات."><Columns>
      <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" /><asp:BoundField DataField="DepthFromM" HeaderText="من" DataFormatString="{0:N2}" /><asp:BoundField DataField="DepthToM" HeaderText="إلى" DataFormatString="{0:N2}" /><asp:BoundField DataField="SoilDescription" HeaderText="الوصف" /><asp:BoundField DataField="USCS" HeaderText="USCS" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>اختبارات SPT</h2><div class="gsp-table-wrap"><asp:GridView ID="gvSPT" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد اختبارات SPT."><Columns>
      <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" /><asp:BoundField DataField="TestDepthM" HeaderText="العمق" DataFormatString="{0:N2}" /><asp:BoundField DataField="N1" HeaderText="N1" /><asp:BoundField DataField="N2" HeaderText="N2" /><asp:BoundField DataField="N3" HeaderText="N3" /><asp:BoundField DataField="NValue" HeaderText="N" /><asp:BoundField DataField="Remarks" HeaderText="ملاحظات" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>المياه الجوفية</h2><div class="gsp-table-wrap"><asp:GridView ID="gvGroundwater" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد قراءات مياه جوفية."><Columns>
      <asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" /><asp:BoundField DataField="ObservationDate" HeaderText="التاريخ" DataFormatString="{0:yyyy-MM-dd}" /><asp:BoundField DataField="DepthToWaterM" HeaderText="العمق إلى الماء" DataFormatString="{0:N2}" /><asp:BoundField DataField="Remarks" HeaderText="ملاحظات" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>العينات</h2><div class="gsp-table-wrap"><asp:GridView ID="gvSamples" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد عينات."><Columns>
      <asp:BoundField DataField="SampleCode" HeaderText="العينة" /><asp:BoundField DataField="BoreholeCode" HeaderText="الجسة" /><asp:BoundField DataField="DepthFromM" HeaderText="من" DataFormatString="{0:N2}" /><asp:BoundField DataField="DepthToM" HeaderText="إلى" DataFormatString="{0:N2}" /><asp:BoundField DataField="SampleTypeNameAr" HeaderText="النوع" /><asp:BoundField DataField="VisualDescription" HeaderText="الوصف" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>النتائج المعملية</h2><div class="gsp-table-wrap"><asp:GridView ID="gvLabResults" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد نتائج معملية."><Columns>
      <asp:BoundField DataField="SampleCode" HeaderText="العينة" /><asp:BoundField DataField="LabTestTypeNameAr" HeaderText="نوع الاختبار" /><asp:BoundField DataField="TestStandard" HeaderText="المعيار" /><asp:BoundField DataField="NumericValue" HeaderText="القيمة" DataFormatString="{0:N3}" /><asp:BoundField DataField="Unit" HeaderText="الوحدة" /><asp:BoundField DataField="ResultValue" HeaderText="نتيجة نصية" /><asp:CheckBoxField DataField="IsApproved" HeaderText="معتمد" ReadOnly="true" />
    </Columns></asp:GridView></div></div>

    <div class="gsp-section"><h2>ملاحظات</h2><div class="gsp-section-content">تم توليد هذه النسخة من GeoSite Pro. يجب مراجعة النتائج والتوصيات واعتمادها من المهندس المختص قبل الإصدار النهائي.</div></div>
  </div>
</div>
</asp:Content>
