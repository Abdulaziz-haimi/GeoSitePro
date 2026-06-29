<%@ Page Title="الاختبارات المعملية" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabTestResults.aspx.cs" Inherits="LabTestResults" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">الاختبارات المعملية - GeoSite Pro</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="gsp-page">
  <div class="gsp-page-header">
    <div><h1 class="gsp-page-title">الاختبارات المعملية</h1><div class="gsp-page-subtitle">هذه الصفحة مرتبطة حاليًا بصفحة النتائج المعملية الرئيسية في Sprint 3.</div></div>
    <div class="gsp-actions"><asp:HyperLink ID="lnkLabResults" runat="server" NavigateUrl="~/LabResults.aspx" CssClass="gsp-btn gsp-btn-primary">فتح النتائج المعملية</asp:HyperLink></div>
  </div>
  <div class="gsp-card">
    <h2 class="gsp-card-title">Sprint 3</h2>
    <p class="gsp-muted">استخدم صفحة النتائج المعملية لإضافة وتعديل وحذف واعتماد نتائج الاختبارات وربطها بالعينات.</p>
  </div>
</div>
</asp:Content>
