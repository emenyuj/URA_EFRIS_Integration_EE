report 50069 "ASL.EFRIS.ProcessSalesInvoices"
{
    Caption = 'EFRIS: Process Sales Invoices';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesInvoiceHeader;
        "Sales Invoice Header")
        {
            trigger OnPreDataItem()
            var
            begin
                if ProcessingAction = ProcessingAction::"Post Invoices To EFRIS" then begin
                    SalesInvoiceHeader.SetFilter(SalesInvoiceHeader."ASL.EFRIS.UploadStatus", StrSubstNo('%1|%2', Enum::"ASL.EFRIS.UploadStatus"::" ", Enum::"ASL.EFRIS.UploadStatus"::Error));
                    SalesInvoiceHeader.SetFilter(SalesInvoiceHeader."ASL.EFRIS.UploadErrorAction", StrSubstNo('%1|%2', Enum::"ASL.EFRIS.UploadErrorAction"::" ", Enum::"ASL.EFRIS.UploadErrorAction"::Retry));
                end;
                ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
            end;

            trigger OnAfterGetRecord()
            var
                Success: Boolean;
            begin
                InvoiceCount += 1;
                ProgressDialog.Update(1, SalesInvoiceHeader."No.");
                ProgressDialog.Update(2, InvoiceCount);
                if ProcessingAction = ProcessingAction::"Post Invoices To EFRIS" then
                    Success := EFRISInterface.PostSalesInvoice(SalesInvoiceHeader, false)
                else
                    Success := EFRISInterface.GetEFRISInvoiceDetails(SalesInvoiceHeader);
                if Success then
                    SalesInvoiceHeader.Modify()
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
        ProcessingAction: Option "Post Invoices To EFRIS","Get EFRIS Invoice Details";
        InvoiceCount: Integer;
        FailCount: Integer;
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Invoice No. #1##############\';
        ProgressDialogTextLine2: Label 'Count       #2###############';
}
