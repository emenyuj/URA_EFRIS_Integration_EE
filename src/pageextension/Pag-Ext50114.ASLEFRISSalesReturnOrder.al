pageextension 50114 "ASL.EFRIS.SalesReturnOrder" extends "Sales Return Order"
{
    layout
    {
        addafter("Sell-to")
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';

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
                }
            }
        }
    }
}
