pageextension 50123 "PostedSalesInvoiceSubform EFR" extends "Posted Sales Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("ShortcutDimCode[8]")
        {
            field("Order Number"; Rec."Order Number")
            {
                ApplicationArea = All;
            }
            field("Total Weight"; Rec."Total Weight")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}