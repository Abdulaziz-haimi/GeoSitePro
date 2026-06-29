USE GeoSitePro;
GO

/* Sprint 12 verification. These result sets should be empty if Sprint 12 is installed correctly. */

SELECT MissingTable
FROM (VALUES
    (N'WorkflowSteps'),
    (N'ApprovalRequests'),
    (N'ApprovalRequestHistory')
) V(MissingTable)
WHERE OBJECT_ID(N'dbo.' + V.MissingTable, N'U') IS NULL;

SELECT MissingProcedure
FROM (VALUES
    (N'sp_WorkflowSteps_Get'),
    (N'sp_WorkflowStep_GetById'),
    (N'sp_WorkflowStep_Save'),
    (N'sp_ApprovalRequest_Create'),
    (N'sp_ApprovalRequests_Get'),
    (N'sp_ApprovalRequest_Decide'),
    (N'sp_ApprovalDashboard_Get')
) V(MissingProcedure)
WHERE OBJECT_ID(N'dbo.' + V.MissingProcedure, N'P') IS NULL;

SELECT MissingPermission
FROM (VALUES
    (N'Workflow.View'),
    (N'Workflow.Create'),
    (N'Workflow.Approve'),
    (N'Workflow.Reject'),
    (N'Workflow.Matrix')
) V(MissingPermission)
WHERE NOT EXISTS(SELECT 1 FROM dbo.Permissions P WHERE P.PermissionCode=V.MissingPermission AND ISNULL(P.IsDeleted,0)=0);
GO

PRINT N'Sprint 12 verification completed.';
GO
