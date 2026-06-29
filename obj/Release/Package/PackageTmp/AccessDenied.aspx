<%@ Page Title="غير مصرح" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="AccessDenied" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">غير مصرح - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-card" style="text-align:center;padding:45px;">
    <h1 class="gsp-page-title" style="color:#991b1b;">غير مصرح لك بالوصول</h1>
    <p style="font-size:16px;color:#4b5563;line-height:1.9;">لا تملك الصلاحية المطلوبة لفتح هذه الصفحة أو تنفيذ هذه العملية.</p>
    <a href="Dashboard.aspx" class="gsp-btn gsp-btn-primary">العودة إلى لوحة التحكم</a>
  </div>
</div>
</asp:Content>
