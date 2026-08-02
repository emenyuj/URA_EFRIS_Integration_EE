pageextension 50120 "ASL.EFRIS.VatProdPostingGrp" extends "VAT Product Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("ASL.EFRIS.TaxCategory"; Rec."ASL.EFRIS.TaxCategory")
            {
                ToolTip = 'Specifies the value of the EFRIS Tax Category field.';
                ApplicationArea = All;
            }
        }
    }
}
