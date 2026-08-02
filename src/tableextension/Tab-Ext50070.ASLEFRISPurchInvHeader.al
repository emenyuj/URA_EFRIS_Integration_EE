tableextension 50070 "ASL.EFRIS.PurchInvHeader" extends "Purch. Inv. Header"
{
    fields
    {
        field(70615581; "ASL.EFRIS.HasEFRISItems"; Boolean)
        {
            Caption = 'Has EFRIS Items';
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.VendorTIN"; Code[20])
        {
            Caption = 'Vendor TIN';
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.Import"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
