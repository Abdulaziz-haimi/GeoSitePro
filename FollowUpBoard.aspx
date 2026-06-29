<%@ Page Title="لوحة المتابعة" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FollowUpBoard.aspx.cs" Inherits="FollowUpBoard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">لوحة المتابعة - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">لوحة المتابعة Follow-up Board</h1>
      <div class="gsp-page-subtitle">إنشاء ومتابعة بنود الاستكمال والمراجعة: بيانات ناقصة، تقرير يحتاج مراجعة، نتائج مختبر غير معتمدة، أو إجراء مطلوب من مهندس محدد.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">إضافة / تعديل بند متابعة</h2>
    <asp:HiddenField ID="hfFollowUpItemId" runat="server" />
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع <span class="gsp-required">*</span></label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">مرتبط بـ</label><asp:DropDownList ID="ddlRelatedEntityType" runat="server" CssClass="gsp-select"><asp:ListItem Text="Project" Value="PROJECT" /><asp:ListItem Text="Borehole" Value="BOREHOLE" /><asp:ListItem Text="Sample" Value="SAMPLE" /><asp:ListItem Text="SPT" Value="SPT" /><asp:ListItem Text="Lab Result" Value="LAB_RESULT" /><asp:ListItem Text="Report" Value="REPORT" /><asp:ListItem Text="Approval" Value="APPROVAL" /></asp:DropDownList></div>
      <div class="full"><label class="gsp-label">عنوان البند <span class="gsp-required">*</span></label><asp:TextBox ID="txtTitle" runat="server" CssClass="gsp-input" /></div>
      <div class="full"><label class="gsp-label">الوصف</label><asp:TextBox ID="txtDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
      <div><label class="gsp-label">تاريخ الاستحقاق</label><asp:TextBox ID="txtDueDate" runat="server" CssClass="gsp-input" placeholder="yyyy-mm-dd" /></div>
      <div><label class="gsp-label">الأولوية</label><asp:DropDownList ID="ddlPriority" runat="server" CssClass="gsp-select"><asp:ListItem Text="Normal" Value="Normal" /><asp:ListItem Text="High" Value="High" /><asp:ListItem Text="Urgent" Value="Urgent" /><asp:ListItem Text="Low" Value="Low" /></asp:DropDownList></div>
      <div><label class="gsp-label">مكلف إلى</label><asp:DropDownList ID="ddlAssignedTo" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">رقم الكيان اختياري</label><asp:TextBox ID="txtRelatedEntityId" runat="server" CssClass="gsp-input" /></div>
      <div class="full gsp-actions"><asp:Button ID="btnSave" runat="server" Text="حفظ بند المتابعة" CssClass="gsp-btn gsp-btn-primary" OnClick="btnSave_Click" /><asp:Button ID="btnClear" runat="server" Text="تفريغ" CssClass="gsp-btn gsp-btn-secondary" OnClick="btnClear_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">البحث والتصفية</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlFilterProject" runat="server" CssClass="gsp-select" /></div>
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="المفتوحة" Value="Open" /><asp:ListItem Text="المغلقة" Value="Closed" /><asp:ListItem Text="كل الحالات" Value="" /></asp:DropDownList></div>
      <div><label class="gsp-label">بحث</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <div class="gsp-card">
    <h2 class="gsp-card-title">بنود المتابعة</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvFollowUps" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد بنود متابعة." OnRowCommand="gvFollowUps_RowCommand">
        <Columns>
          <asp:BoundField DataField="FollowUpItemId" HeaderText="#" />
          <asp:BoundField DataField="ProjectCode" HeaderText="المشروع" />
          <asp:BoundField DataField="ItemTitle" HeaderText="العنوان" />
          <asp:BoundField DataField="RelatedEntityType" HeaderText="مرتبط بـ" />
          <asp:BoundField DataField="Priority" HeaderText="الأولوية" />
          <asp:BoundField DataField="Status" HeaderText="الحالة" />
          <asp:BoundField DataField="AssignedToName" HeaderText="مكلف إلى" />
          <asp:BoundField DataField="DueDate" HeaderText="الاستحقاق" DataFormatString="{0:yyyy-MM-dd}" />
          <asp:BoundField DataField="DaysLate" HeaderText="أيام التأخير" />
          <asp:TemplateField HeaderText="إجراءات"><ItemTemplate><asp:LinkButton ID="btnEdit" runat="server" CssClass="gsp-btn gsp-btn-secondary" Text="تعديل" CommandName="EditItem" CommandArgument='<%# Eval("FollowUpItemId") %>' /><asp:LinkButton ID="btnClose" runat="server" CssClass="gsp-btn gsp-btn-success" Text="إغلاق" CommandName="CloseItem" CommandArgument='<%# Eval("FollowUpItemId") %>' Visible='<%# Convert.ToString(Eval("Status")) != "Closed" %>' /></ItemTemplate></asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>
  </div>
</div>
</asp:Content>
