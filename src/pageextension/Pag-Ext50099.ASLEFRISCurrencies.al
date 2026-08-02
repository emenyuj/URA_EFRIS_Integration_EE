pageextension 50099 "ASL.EFRIS.Currencies" extends "Currencies"
{
    layout
    {
        addafter(Description)
        {
            field("ASL.EFRIS.EFRISCurrencyCode"; Rec."ASL.EFRIS.EFRISCurrencyCode")
            {
            }
            field("ASL.EFRIS.EFRISCurrencyName"; Rec."ASL.EFRIS.EFRISCurrencyName")
            {
            }
        }
    }
}
