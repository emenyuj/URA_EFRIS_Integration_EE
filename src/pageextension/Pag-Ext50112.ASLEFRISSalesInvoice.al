pageextension 50112 "ASL.EFRIS.SalesInvoice" extends "Sales Invoice"
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
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EFRIS Remarks field.';
            }
            field("ASL.EFRIS.DeliveryTerms"; Rec."ASL.EFRIS.DeliveryTerms")
            {
                Caption = 'EFRIS Delivery Terms';
                ApplicationArea = All;
            }
        }
    }
}
