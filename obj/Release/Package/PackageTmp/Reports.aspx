<%@ Page Title="التقارير الفنية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Reports" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">التقارير الفنية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">التقارير الفنية Technical Reports</h1>
      <div class="gsp-page-subtitle">إنشاء تقرير فني مرتبط بالمشروع، توليد أقسام تلقائية من بيانات الجسات والعينات والاختبارات، ثم فتح التقرير للتحرير أو الطباعة.</div>
    </div>
    <div class="gsp-actions">
      <asp:Button ID="btnNew" runat="server" Text="إضافة تقرير" CssClass="gsp-btn gsp-btn-primary" OnClick="btnNew_Click" />
    </div>
  </div>

  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="gsp-card">
    <h2 class="gsp-card-title"><asp:Literal ID="litFormTitle" runat="server" Text="إضافة تقرير فني" /></h2>
    <asp:HiddenField ID="hfReportId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">نوع التقرير</label><asp:DropDownList ID="ddlReportType" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">رقم التقرير</label><asp:TextBox ID="txtReportNo" runat="server" CssClass="gsp-input" placeholder="يولّد تلقائيًا عند تركه فارغًا" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlReportStatus" runat="server" CssClass="gsp-select" /></div>
      <div class="full"><label class="gsp-label">عنوان التقرير <span class="gsp-required">*</span></label><asp:TextBox ID="txtReportTitle" runat="server" CssClass="gsp-input" placeholder="Geotechnical Investigation Report" /></div>
      <div><label class="gsp-label">تاريخ الإصدار</label><asp:TextBox ID="txtIssueDate" runat="server" TextMode="Date" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">رقم المراجعة</label><asp:TextBox ID="txtRevisionNo" runat="server" CssClass="gsp-input" placeholder="Rev.0" /></div>
      <div><label class="gsp-label">أعد بواسطة</label><asp:TextBox ID="txtPreparedBy" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">راجع بواسطة</label><asp:TextBox ID="txtReviewedBy" runat="server" CssClass="gsp-input" /></div>
      <div><label class="gsp-label">اعتمد بواسطة</label><asp:TextBox ID="txtApprovedBy" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الملخص التنفيذي</label><asp:TextBox ID="txtExecutiveSummary" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" placeholder="اكتب ملخصًا أوليًا، ويمكن توليد أقسام التقرير لاحقًا." /></div>
      <div class="full"><label class="gsp-label">التوصيات</label><asp:TextBox ID="txtRecommendations" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
    </div>
    <br />
    <div class="gsp-actions">
      <asp:Button ID="btnSave" runat="server" Text="حفظ التقرير" CssClass="gsp-btn gsp-btn-success" OnClick="btnSave_Click" />
      <asp:Button ID="btnCancel" runat="server" Text="إلغاء" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnCancel_Click" CausesValidation="false" />
    </div>
  </asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بحث التقارير</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterProject_SelectedIndexChanged" /></div>
      <div><label class="gsp-label">بحث عام</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="رقم التقرير، العنوان، المشروع، أعد/راجع بواسطة..." /></div>
      <div style="align-self:end;"><asp:Button ID="btnSearch" runat="server" Text="بحث" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSearch_Click" /> <asp:Button ID="btnClearSearch" runat="server" Text="مسح" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClearSearch_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">قائمة التقارير</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvReports" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد تقارير." OnRowCommand="gvReports_RowCommand">
        <Columns>
          <asp:BoundField DataField="ReportNo" HeaderText="رقم التقرير" />
          <asp:BoundField DataField="ReportTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
          <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
          <asp:BoundField DataField="ReportTypeNameAr" HeaderText="النوع" />
          <asp:BoundField DataField="ReportStatusNameAr" HeaderText="الحالة" />
          <asp:BoundField DataField="RevisionNo" HeaderText="المراجعة" />
          <asp:BoundField DataField="IssueDate" HeaderText="تاريخ الإصدار" DataFormatString="{0:yyyy-MM-dd}" />
          <asp:BoundField DataField="SectionCount" HeaderText="الأقسام" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate>
            <asp:HyperLink runat="server" Text="تحرير" CssClass="gsp-btn gsp-btn-primary" NavigateUrl='<%# "ReportEditor.aspx?ReportId=" + Eval("ReportId") %>' />
            <asp:HyperLink runat="server" Text="طباعة" CssClass="gsp-btn gsp-btn-success" Target="_blank" NavigateUrl='<%# "ReportPrint.aspx?ReportId=" + Eval("ReportId") %>' />
            <asp:LinkButton runat="server" Text="تعديل" CssClass="gsp-btn gsp-btn-secondary" CommandName="EditItem" CommandArgument='<%# Eval("ReportId") %>' />
            <asp:LinkButton runat="server" Text="اعتماد" CssClass="gsp-btn gsp-btn-warning" CommandName="ApproveItem" CommandArgument='<%# Eval("ReportId") %>' OnClientClick="return confirm('هل تريد اعتماد التقرير؟');" />
            <asp:LinkButton runat="server" Text="حذف" CssClass="gsp-btn gsp-btn-danger" CommandName="DeleteItem" CommandArgument='<%# Eval("ReportId") %>' OnClientClick="return confirm('هل أنت متأكد من حذف التقرير؟');" />
          </ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
