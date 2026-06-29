<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProjectPrintPackage.aspx.cs" Inherits="ProjectPrintPackage" %>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head runat="server"><meta charset="utf-8" /><title>حزمة طباعة المشروع - GeoSite Pro</title>
<style>
body{font-family:"Segoe UI",Tahoma,Arial,sans-serif;margin:0;background:#f3f4f6;color:#111827;direction:rtl}.print-shell{max-width:1100px;margin:20px auto;background:#fff;border:1px solid #ddd;padding:28px}.print-title{font-size:26px;font-weight:900;color:#0f766e;margin:0}.print-subtitle{color:#6b7280;margin-top:6px}.print-actions{margin:0 0 18px;display:flex;gap:8px}.btn{border:0;border-radius:8px;padding:9px 14px;font-weight:900;text-decoration:none;cursor:pointer}.btn-primary{background:#0f766e;color:#fff}.btn-secondary{background:#e5e7eb;color:#111827}.section{margin-top:22px;page-break-inside:avoid}.section h2{font-size:18px;color:#115e59;border-bottom:2px solid #0f766e;padding-bottom:6px;margin:0 0 10px}.data-table{width:100%;border-collapse:collapse;font-size:12px;margin-bottom:10px}.data-table th{background:#f3f4f6;font-weight:900;text-align:right}.data-table th,.data-table td{border:1px solid #d1d5db;padding:7px;vertical-align:top}.meta-table{width:100%;border-collapse:collapse;font-size:13px}.meta-table th{width:16%;background:#f9fafb;text-align:right}.meta-table th,.meta-table td{border:1px solid #d1d5db;padding:8px}.muted{color:#6b7280}.page-break{page-break-after:always}.log-title{display:flex;justify-content:space-between;gap:12px;border-bottom:3px solid #0f766e;padding-bottom:10px;margin-bottom:12px}.badge{display:inline-block;border-radius:999px;padding:4px 9px;background:#e5e7eb;font-weight:900;font-size:12px}.footer-note{margin-top:24px;border-top:1px solid #ddd;padding-top:10px;font-size:11px;color:#6b7280}@media print{body{background:#fff}.print-shell{margin:0;border:0;padding:0;max-width:none}.print-actions{display:none}.section{break-inside:avoid}.page-break{page-break-after:always}@page{size:A4;margin:12mm}}
</style>
</head>
<body><form id="form1" runat="server"><div class="print-shell">
<div class="print-actions"><button type="button" class="btn btn-primary" onclick="window.print()">طباعة / حفظ PDF</button><a class="btn btn-secondary" href="PrintableOutputs.aspx">العودة</a></div>
<asp:Panel ID="pnlMessage" runat="server" Visible="false"><asp:Literal ID="litMessage" runat="server" /></asp:Panel>
<asp:Literal ID="litPackage" runat="server" />
</div></form></body></html>
