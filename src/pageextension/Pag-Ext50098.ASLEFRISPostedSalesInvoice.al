pageextension 50098 "ASL.EFRIS.PostedSalesInvoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';

                group("ASL.EFRIS.Upload Info")
                {
                    Caption = 'Upload Info';

                    field("ASL.EFRIS.UploadStatus"; Rec."ASL.EFRIS.UploadStatus")
                    {
                        Caption = 'Upload Status';
                    }
                    field("ASL.EFRIS.UploadTime"; Rec."ASL.EFRIS.UploadTime")
                    {
                        Caption = 'Upload Time';
                    }
                    field("ASL.EFRIS.UploadErrorCode"; Rec."ASL.EFRIS.UploadErrorCode")
                    {
                        Caption = 'Upload Error Code';
                    }
                    field("ASL.EFRIS.UploadErrorMessage"; Rec."ASL.EFRIS.UploadErrorMessage")
                    {
                        Caption = 'Upload Error Message';
                    }
                    field("ASL.EFRIS.UploadErrorAction"; Rec."ASL.EFRIS.UploadErrorAction")
                    {
                        Caption = 'EFRIS Upload Error Action';
                    }
                }
                group("ASL.EFRIS.EFRIS Invoice Details")
                {
                    Caption = 'EFRIS Invoice Details';

                    field("ASL.EFRIS.InvoiceId"; Rec."ASL.EFRIS.InvoiceId")
                    {
                        Caption = 'Invoice Id';
                    }
                    field("ASL.EFRIS.InvoiceNo"; Rec."ASL.EFRIS.InvoiceNo")
                    {
                        Caption = 'Invoice No.';
                    }
                    field("ASL.EFRIS.Antifakecode"; Rec."ASL.EFRIS.Antifakecode")
                    {
                        Caption = 'Antifake code';
                    }
                    field("ASL.EFRIS.QRCode"; Rec."ASL.EFRIS.QRCode")
                    {
                        Caption = 'QR Code';
                    }
                    field("ASL.EFRIS.InvoiceIndustryCode"; Rec."ASL.EFRIS.InvoiceIndustryCode")
                    {
                        Caption = 'Invoice Industry Code';
                        Editable = false;
                    }
                    field("ASL.EFRIS.PaymentMode"; Rec."ASL.EFRIS.PaymentMode")
                    {
                        Caption = 'Payment Mode';
                        Editable = false;
                    }
                    field("ASL.EFRIS.DeliveryTerms"; Rec."ASL.EFRIS.DeliveryTerms")
                    {
                        Caption = 'EFRIS Delivery Terms';
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }
    actions
    {
        addafter("F&unctions")
        {
            group("ASL.EFRIS.&EFRIS")
            {
                Caption = 'EFRIS';
                Image = PostTaxInvoice;

                action("ASL.EFRIS.PostToEFRIS")
                {
                    Caption = 'Post To EFRIS';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Success: Boolean;
                    begin
                        Success := EFRISInterface.PostSalesInvoice(Rec, false);
                        if Success then begin
                            Rec.Modify();
                            Message(MsgInvToEFRISSuccess);
                        end
                        else
                            Message(EFRISInterface.GetLastErrorMessage())
                    end;
                }
                action("ASL.EFRIS.GetEFRISInvoiceDetails")
                {
                    Caption = 'Get EFRIS Invoice Details';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.FetchEFRISInvoiceDetails(Rec) then begin
                            Message(MsgInvFromEFRISSuccess);
                        end
                        else
                            Message(ErrInvFromEFRISFailed, Rec."No.");
                    end;
                }
                // action(UpdateOrderNo)
                // {
                //     Caption = 'Update Invoice Order Number';
                //     ApplicationArea = All;
                //     trigger OnAction()
                //     var
                //         EfrisEvents: Codeunit "ASL.EFRIS.EventHandlers";
                //     begin
                //         EfrisEvents.UpdateSalesInvoiceLinesOrderNumber(Rec)
                //     end;
                // }
                action(UpdateOrderNumber)
                {
                    Caption = 'Update Invoice Order Number';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EfrisInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        EfrisInterface.UpdateSalesInvoiceOrderNumber(Rec, false);
                    end;
                }
                action("Add Def. Ind. Category")
                {
                    trigger OnAction()
                    var
                        EfrisSetUp: Record "Sales & Receivables Setup";
                        SI: Record "Sales Invoice Header";
                    begin
                        EfrisSetUp.Get();
                        if SI.GET(Rec."No.") then begin
                            SI."ASL.EFRIS.InvoiceIndustryCode" := EfrisSetUp."ASL.EFRIS.InvoiceIndustryCode";
                            SI.Modify();
                        end;
                    end;
                }
            }
        }
    }
    var
        MsgInvToEFRISSuccess: TextConst ENU = 'Invoice Successfully Posted to EFRIS';
        MsgInvFromEFRISSuccess: TextConst ENU = 'EFRIS Invoice details successfully fetched';
        ErrInvFromEFRISFailed: TextConst ENU = 'Invoice No. %1 not found in EFRIS';
}
