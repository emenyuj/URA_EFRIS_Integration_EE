pageextension 50109 "ASL.EFRIS.SalesOrder" extends "Sales Order"
{
    layout
    {
        addafter("VAT Bus. Posting Group")
        {
            field("ASL.EFRIS.VAT Deemed"; Rec."ASL.EFRIS.VATDeemed")
            {
                ToolTip = 'Specifies the value of the VAT Deemed field.';
                ApplicationArea = All;
            }
            field("ASL.EFRIS.VAT Exempt"; Rec."ASL.EFRIS.VATExempt")
            {
                ToolTip = 'Specifies the value of the VAT Exempt field.';
                ApplicationArea = All;
            }
        }
        addafter("Payment Terms Code")
        {
            field("ASL.EFRIS.InvoiceIndustryCode"; Rec."ASL.EFRIS.InvoiceIndustryCode")
            {
                ToolTip = 'Specifies the value of the Invoice Industry Code field.';
                ApplicationArea = All;
            }
            field("ASL.EFRIS.PaymentMode"; Rec."ASL.EFRIS.PaymentMode")
            {
                ToolTip = 'Specifies the value of the EFRIS Payment Mode field.';
                ApplicationArea = All;
            }
            field("ASL.EFRIS.Remarks"; Rec."ASL.EFRIS.Remarks")
            {
                Caption = 'EFRIS Remarks';
                ApplicationArea = All;
            }
            field("ASL.EFRIS.DeliveryTerms"; Rec."ASL.EFRIS.DeliveryTerms")
            {
                Caption = 'EFRIS Delivery Terms';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter("Archive Document")
        {
            action(Projects)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = ProductDesign;
                Visible = false;
                trigger OnAction()
                var
                    EFRISINterface: Codeunit "ASL.EFRIS.EFRISInterface";
                begin
                    // EFRISINterface.TestThisOut();
                end;
            }
        }
    }
}
