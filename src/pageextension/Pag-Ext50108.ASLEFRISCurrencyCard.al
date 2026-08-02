pageextension 50108 "ASL.EFRIS.CurrencyCard" extends "Currency Card"
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
