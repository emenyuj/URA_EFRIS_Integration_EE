report 50070 "ASL.EFRIS.ProcessSalesCrMemos"
{
    Caption = 'EFRIS: Process Sales Cr. Memos';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesCrMemoHeader;
        "Sales Cr.Memo Header")
        {
            trigger OnPreDataItem()
            var
            begin
                if ProcessingAction = ProcessingAction::"Send Cr. Note Application to EFRIS" then begin
                    SalesCrMemoHeader.SetFilter(SalesCrMemoHeader."ASL.EFRIS.UploadStatus", StrSubstNo('%1|%2', Enum::"ASL.EFRIS.UploadStatus"::" ", Enum::"ASL.EFRIS.UploadStatus"::Error));
                    SalesCrMemoHeader.SetFilter(SalesCrMemoHeader."ASL.EFRIS.UploadErrorAction", StrSubstNo('%1|%2', Enum::"ASL.EFRIS.UploadErrorAction"::" ", Enum::"ASL.EFRIS.UploadErrorAction"::Retry));
                end;
                ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
            end;

            trigger OnAfterGetRecord()
            var
                Success: Boolean;
            begin
                InvoiceCount += 1;
                ProgressDialog.Update(1, SalesCrMemoHeader."No.");
                ProgressDialog.Update(2, InvoiceCount);
                if ProcessingAction = ProcessingAction::"Send Cr. Note Application to EFRIS" then
                    Success := EFRISInterface.SendCreditNoteApplication(SalesCrMemoHeader, false)
                else
                    Success := EFRISInterface.SyncCrNoteApprovalStatus(SalesCrMemoHeader);
                if Success then
                    SalesCrMemoHeader.Modify()
                else
                    FailCount += 1;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(ProcessingAction; ProcessingAction)
                    {
                        ApplicationArea = All;
                        Caption = 'Processing Action';
                    }
                }
            }
        }
    }
    var
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        ProcessingAction: Option "Send Cr. Note Application to EFRIS","Sync. Cr. Note Approval Status";
        InvoiceCount: Integer;
        FailCount: Integer;
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Invoice No. #1##############\';
        ProgressDialogTextLine2: Label 'Count       #2###############';
}
