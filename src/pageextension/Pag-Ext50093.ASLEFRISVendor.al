pageextension 50093 "ASL.EFRIS.Vendor" extends "Vendor Card"
{
    layout
    {
        addafter("Tax Area Code")
        {
            field("ASL.EFRIS.TIN"; Rec."ASL.EFRIS.TIN")
            {
            }
        }
    }
}
