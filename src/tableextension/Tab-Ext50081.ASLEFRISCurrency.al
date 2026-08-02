tableextension 50081 "ASL.EFRIS.Currency" extends Currency
{
    Caption = 'Currency EFRIS Ext.';

    fields
    {
        field(70615571; "ASL.EFRIS.EFRISCurrencyCode"; Code[20])
        {
            Caption = 'EFRIS Currency Code';
            DataClassification = ToBeClassified;
            TableRelation = "ASL.EFRIS.Currency".Code;

            trigger OnValidate()
            var
                EFRISCurrency: Record "ASL.EFRIS.Currency";
            begin
                EFRISCurrency.Get("ASL.EFRIS.EFRISCurrencyCode");
                "ASL.EFRIS.EFRISCurrencyName" := EFRISCurrency.Name;
            end;
        }
        field(70615572; "ASL.EFRIS.EFRISCurrencyName"; Text[50])
        {
            Caption = 'EFRIS Currency Name';
            DataClassification = ToBeClassified;
        }
    }
}
