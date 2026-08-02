pageextension 50118 "ASL.EFRIS.PostedSalesCrMemo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';

                group("ASL.EFRIS.Reason")
                {
                    Caption = 'Reason';

                    field("ASL.EFRIS.RefundReasonCode"; Rec."ASL.EFRIS.RefundReasonCode")
                    {
                        Caption = 'Refund Reason Code';
                        ToolTip = 'Specifies the value of the EFRIS Refund Reason Code field.';
                        ApplicationArea = All;
                    }
                    field("ASL.EFRIS.RefundReason"; Rec."ASL.EFRIS.RefundReason")
                    {
                        Caption = 'Refund Reason';
                        ToolTip = 'Specifies the value of the EFRIS Refund Reason field.';
                        ApplicationArea = All;
                    }
                    field("ASL.EFRIS.Remarks"; Rec."ASL.EFRIS.Remarks")
                    {
                        Caption = 'Remarks';
                        ToolTip = 'Specifies the value of the EFRIS Remarks field.';
                        ApplicationArea = All;
                    }
                    field("ASL.EFRIS.DeliveryTerms"; Rec."ASL.EFRIS.DeliveryTerms")
                    {
                        Caption = 'EFRIS Delivery Terms';
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                group("ASL.EFRIS.Upload Info")
                {
                    Caption = 'Upload Info';

                    field("ASL.EFRIS.UploadStatus"; Rec."ASL.EFRIS.UploadStatus")
                    {
                        Caption = 'Upload Status';
                    }
                    field("ASL.EFRIS.UploadTime"; Rec."ASL.EFRIS.ReferenceNo")
                    {
                        Caption = 'Reference No';
                    }
                    field("ASL.EFRIS.ApprovalStatus"; Rec."ASL.EFRIS.ApprovalStatus")
                    {
                        Caption = 'Approval Status';
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
                }
                group("ASL.EFRIS.Cancel")
                {
                    Caption = 'Cancel';

                    field("ASL.EFRIS.CancelReasonCode"; Rec."ASL.EFRIS.CancelReasonCode")
                    {
                        Caption = 'Cancel Reason Code';
                        ToolTip = 'Specifies the value of the EFRIS CancelReason Code field.';
                        ApplicationArea = All;
                    }
                    field("ASL.EFRIS.CancelOtherReason"; Rec."ASL.EFRIS.CancelOtherReason")
                    {
                        Caption = 'Cancel Reason';
                        ToolTip = 'Specifies the value of the EFRIS Cancel Other Reason field.';
                        ApplicationArea = All;
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
                    Caption = 'Send Cr. Note Application to EFRIS';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Success: Boolean;
                    begin
                        Success := EFRISInterface.SendCreditNoteApplication(Rec, false);
                        if Success then begin
                            Rec.Modify();
                            Message(EFRISInterface.GetLastErrorMessage())
                        end
                        else
                            Message(MsgCrNoteToEFRISSuccess);
                    end;
                }
                action("ASL.EFRIS.SyncApprovalStatus")
                {
                    Caption = 'Sync. Approval Status';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.SyncCrNoteApprovalStatus(Rec) then
                            Message(MsgSyncCrNoteStatusSuccess, Rec."ASL.EFRIS.ApprovalStatus")
                        else
                            Message(EFRISInterface.GetLastErrorMessage());
                    end;
                }
                action("ASL.EFRIS.VoidCreditNote")
                {
                    Caption = 'Void Credit Note';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.VoidCreditNote(Rec) then
                            Message(MsgVoidCrNoteSuccess)
                        else
                            Message(EFRISInterface.GetLastErrorMessage());
                    end;
                }
                action("ASL.EFRIS.CancelCreditNote")
                {
                    Caption = 'Cancel Credit Note';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.CancelApprovedCreditNote(Rec) then
                            Message(MsgCancelCrNoteSuccess)
                        else
                            Message(EFRISInterface.GetLastErrorMessage());
                    end;
                }
            }
        }
    }
    var
        MsgCrNoteToEFRISSuccess: TextConst ENU = 'Credit Note Application successfully sent to EFRIS';
        MsgSyncCrNoteStatusSuccess: TextConst ENU = 'Successfully Synchronized Credit Memo Status with EFRIS. Approval Status: %1';
        MsgVoidCrNoteSuccess: TextConst ENU = 'Successfully Voided Credit Memo';
        MsgCancelCrNoteSuccess: TextConst ENU = 'Successfully Canceled Credit Memo';
}
