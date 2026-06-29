<%@ Page Title="اعتماد المشروع" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProjectApproval.aspx.cs" Inherits="ProjectApproval" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">اعتماد المشروع - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">اعتماد المشروع Project Approval</h1>
      <div class="gsp-page-subtitle">إنشاء طلبات مراجعة واعتماد للمشروع أو التقرير أو الحزمة الفنية، ومتابعة حالتها قبل الإصدار النهائي.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>

  <div class="gsp-card">
    <h2 class="gsp-card-title">اختيار المشروع</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">المشروع</label><asp:DropDownList ID="ddlProject" runat="server" CssClass="gsp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProject_SelectedIndexChanged" /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
    </div>
  </div>

  <asp:Panel ID="pnlProject" runat="server" Visible="false">
    <asp:Literal ID="litSummary" runat="server" />

    <div class="gsp-card">
      <h2 class="gsp-card-title">إنشاء طلب اعتماد جديد</h2>
      <div class="gsp-form-grid">
        <div><label class="gsp-label">نوع الكيان</label><asp:DropDownList ID="ddlEntityType" runat="server" CssClass="gsp-select"><asp:ListItem Text="Project" Value="PROJECT" /><asp:ListItem Text="Technical Report" Value="TECHNICAL_REPORT" /><asp:ListItem Text="Print Package" Value="PRINT_PACKAGE" /><asp:ListItem Text="Investigation Plan" Value="INVESTIGATION_PLAN" /></asp:DropDownList></div>
        <div><label class="gsp-label">مرحلة سير العمل</label><asp:DropDownList ID="ddlWorkflowStep" runat="server" CssClass="gsp-select" /></div>
        <div><label class="gsp-label">الأولوية</label><asp:DropDownList ID="ddlPriority" runat="server" CssClass="gsp-select"><asp:ListItem Text="Normal" Value="Normal" /><asp:ListItem Text="High" Value="High" /><asp:ListItem Text="Urgent" Value="Urgent" /><asp:ListItem Text="Low" Value="Low" /></asp:DropDownList></div>
        <div><label class="gsp-label">رقم الكيان اختياري</label><asp:TextBox ID="txtEntityId" runat="server" CssClass="gsp-input" placeholder="مثلاً ReportId" /></div>
        <div class="full"><label class="gsp-label">عنوان الطلب <span class="gsp-required">*</span></label><asp:TextBox ID="txtRequestTitle" runat="server" CssClass="gsp-input" /></div>
        <div class="full"><label class="gsp-label">وصف الطلب</label><asp:TextBox ID="txtRequestDescription" runat="server" CssClass="gsp-textarea" TextMode="MultiLine" /></div>
        <div class="full gsp-actions"><asp:Button ID="btnCreateRequest" runat="server" Text="إنشاء طلب اعتماد" CssClass="gsp-btn gsp-btn-success" OnClick="btnCreateRequest_Click" /></div>
      </div>
    </div>

    <div class="gsp-card">
      <h2 class="gsp-card-title">طلبات المشروع</h2>
      <div class="gsp-table-wrap">
        <asp:GridView ID="gvRequests" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد طلبات اعتماد لهذا المشروع." OnRowCommand="gvRequests_RowCommand">
          <Columns>
            <asp:BoundField DataField="ApprovalRequestId" HeaderText="#" />
            <asp:BoundField DataField="EntityType" HeaderText="الكيان" />
            <asp:BoundField DataField="RequestTitle" HeaderText="عنوان الطلب" />
            <asp:BoundField DataField="CurrentStepName" HeaderText="المرحلة" />
            <asp:BoundField DataField="Priority" HeaderText="الأولوية" />
            <asp:BoundField DataField="Status" HeaderText="الحالة" />
            <asp:BoundField DataField="RequestedByName" HeaderText="طلب بواسطة" />
            <asp:BoundField DataField="DecidedByName" HeaderText="قرار بواسطة" />
            <asp:BoundField DataField="DecidedAt" HeaderText="تاريخ القرار" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
            <asp:TemplateField HeaderText="إجراءات">
              <ItemTemplate>
                <asp:LinkButton ID="btnApprove" runat="server" CssClass="gsp-btn gsp-btn-success" Text="اعتماد" CommandName="ApproveItem" CommandArgument='<%# Eval("ApprovalRequestId") %>' Visible='<%# Convert.ToString(Eval("Status")) == "Pending" %>' />
                <asp:LinkButton ID="btnReturn" runat="server" CssClass="gsp-btn gsp-btn-warning" Text="إرجاع" CommandName="ReturnItem" CommandArgument='<%# Eval("ApprovalRequestId") %>' Visible='<%# Convert.ToString(Eval("Status")) == "Pending" %>' />
                <asp:LinkButton ID="btnReject" runat="server" CssClass="gsp-btn gsp-btn-danger" Text="رفض" CommandName="RejectItem" CommandArgument='<%# Eval("ApprovalRequestId") %>' Visible='<%# Convert.ToString(Eval("Status")) == "Pending" %>' />
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </asp:Panel>
</div>
</asp:Content>
