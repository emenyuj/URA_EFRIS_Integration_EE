pageextension 50117 "ASL.EFRIS.SalesCreditMemo" extends "Sales Credit Memo"
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
                    ToolTip = 'Specifies the value of the EFRIS Refund Reason Code field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.RefundReason"; Rec."ASL.EFRIS.RefundReason")
                {
                    ToolTip = 'Specifies the value of the EFRIS Refund Reason field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.Remarks"; Rec."ASL.EFRIS.Remarks")
                {
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

    actions
    {
        addafter("F&unctions")
        {
            group("ASL.EFRIS.&EFRIS")
            {
                Caption = 'EFRIS';
                Image = PostTaxInvoice;
                action(UpdateOrderNo)
                {
                    Caption = 'Update Order Number';
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        EfrisEvents: Codeunit "ASL.EFRIS.EventHandlers";
                    begin
                        EfrisEvents.UpdateSalesCreditMemoLinesOrderNumber(Rec)
                    end;
                }
            }
        }
    }
}
