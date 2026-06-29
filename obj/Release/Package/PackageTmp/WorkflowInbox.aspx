<%@ Page Title="صندوق سير العمل" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WorkflowInbox.aspx.cs" Inherits="WorkflowInbox" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">صندوق سير العمل - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div>
      <h1 class="gsp-page-title">صندوق سير العمل Workflow Inbox</h1>
      <div class="gsp-page-subtitle">متابعة طلبات المراجعة والاعتماد للمشاريع والتقارير والبيانات الفنية، مع إجراءات اعتماد أو رفض أو إرجاع للمراجعة.</div>
    </div>
  </div>
  <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="gsp-message"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
  <div class="gsp-card">
    <h2 class="gsp-card-title">البحث والتصفية</h2>
    <div class="gsp-form-grid">
      <div><label class="gsp-label">الحالة</label><asp:DropDownList ID="ddlStatus" runat="server" CssClass="gsp-select"><asp:ListItem Text="كل الحالات" Value="" /><asp:ListItem Text="Pending" Value="Pending" /><asp:ListItem Text="Approved" Value="Approved" /><asp:ListItem Text="Rejected" Value="Rejected" /><asp:ListItem Text="Returned" Value="Returned" /></asp:DropDownList></div>
      <div><label class="gsp-label">بحث</label><asp:TextBox ID="txtSearch" runat="server" CssClass="gsp-input" placeholder="كود المشروع، اسم المشروع، عنوان الطلب..." /></div>
      <div style="align-self:end"><asp:Button ID="btnLoad" runat="server" Text="عرض" CssClass="gsp-btn gsp-btn-primary" OnClick="btnLoad_Click" /></div>
      <div style="align-self:end"><asp:Button ID="btnPending" runat="server" Text="المعلّقة فقط" CssClass="gsp-btn gsp-btn-warning" OnClick="btnPending_Click" /></div>
    </div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">طلبات الاعتماد</h2>
    <div class="gsp-table-wrap">
      <asp:GridView ID="gvInbox" runat="server" AutoGenerateColumns="False" CssClass="gsp-table" GridLines="None" EmptyDataText="لا توجد طلبات." OnRowCommand="gvInbox_RowCommand">
        <Columns>
          <asp:BoundField DataField="ApprovalRequestId" HeaderText="#" />
          <asp:BoundField DataField="ProjectCode" HeaderText="كود المشروع" />
          <asp:BoundField DataField="ProjectName" HeaderText="المشروع" />
          <asp:BoundField DataField="EntityType" HeaderText="الكيان" />
          <asp:BoundField DataField="RequestTitle" HeaderText="عنوان الطلب" />
          <asp:BoundField DataField="CurrentStepName" HeaderText="مرحلة المراجعة" />
          <asp:BoundField DataField="Priority" HeaderText="الأولوية" />
          <asp:BoundField DataField="Status" HeaderText="الحالة" />
          <asp:BoundField DataField="RequestedByName" HeaderText="طلب بواسطة" />
          <asp:BoundField DataField="RequestedAt" HeaderText="تاريخ الطلب" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
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
</div>
</asp:Content>
