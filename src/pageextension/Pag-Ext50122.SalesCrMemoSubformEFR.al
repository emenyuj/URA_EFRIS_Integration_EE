pageextension 50122 "Sales Cr. Memo Subform EFR" extends "Sales Cr. Memo Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(ShortcutDimCode8)
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