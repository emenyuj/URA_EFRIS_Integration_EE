page 50016 "ASL.EFRIS.SalesInvoiceErrors"
{
    Caption = 'EFRIS Sales Invoice Errors';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Invoice Header";
    SourceTableView = where("ASL.EFRIS.UploadStatus" = const(Error));

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the record.';
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ToolTip = 'Specifies the number of the customer that you send or sent the invoice or credit memo to.';
                    ApplicationArea = All;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    ToolTip = 'Specifies the name of the customer that the invoice was sent to.';
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
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Retry)
            {
                Caption = 'Post to EFRIS';
                ApplicationArea = All;

                trigger OnAction()
                var
                    EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                begin
                    if EFRISInterface.PostSalesInvoice(Rec, false) then
                        Message(ErrInvoiceToEFRISSuccess, Rec."No.")
                    else
                        Message(EFRISInterface.GetLastErrorMessage());
                end;
            }
        }
    }
    var
        ErrInvoiceToEFRISSuccess: TextConst ENU = 'Sales Invoice No %1 successfully posted to EFRIS';
}
