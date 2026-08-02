page 50015 "ASL.EFRIS.PndngItemLedgEntries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Ledger Entry";
    SourceTableView = where("ASL.EFRIS.UploadStatus" = filter(Pending | Error));
    Caption = 'EFRIS: Pending Item Ledger Entries';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the entry''s posting date.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies which type of transaction that the entry is created from.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item in the entry.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the entry.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of the item in the item entry.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadStatus"; Rec."ASL.EFRIS.UploadStatus")
                {
                    ToolTip = 'Specifies the value of the EFRIS Upload Status field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadErrorCode"; Rec."ASL.EFRIS.UploadErrorCode")
                {
                    ToolTip = 'Specifies the value of the EFRIS Upload Error Code field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadErrorMessage"; Rec."ASL.EFRIS.UploadErrorMessage")
                {
                    ToolTip = 'Specifies the value of the EFRIS Upload Error Message field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadErrorAction"; Rec."ASL.EFRIS.UploadErrorAction")
                {
                    ToolTip = 'Specifies the value of the EFRIS Upload Error Action field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.JournalTemplateName"; Rec."ASL.EFRIS.JournalTemplateName")
                {
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.JournalBatchName"; Rec."ASL.EFRIS.JournalBatchName")
                {
                    ToolTip = 'Specifies the value of the Journal Batch Name field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.TransactionNo"; Rec."ASL.EFRIS.TransactionNo")
                {
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Process)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    ProcessInventory: Report "ASL.EFRIS.ProcessInventory";
                begin
                    ProcessInventory.SetRunFromErrorsPage(true);
                    ProcessInventory.RunModal();
                end;
            }
        }
    }
}
