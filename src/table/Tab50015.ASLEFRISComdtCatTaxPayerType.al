table 50015 "ASL.EFRIS.ComdtCatTaxPayerType"
{
    Caption = 'Commodity Category Tax Payer Type';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CustomerNo; Code[20])
        {
            TableRelation = Customer."No.";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; CommodityCategoryCode; Code[20])
        {
            TableRelation = "ASL.EFRIS.CommodityCategory".Code;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; CommodityCategoryTaxpayerType; Enum "ASL.EFRIS.TaxPayerType")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; CustomerNo, CommodityCategoryCode)
        {
            Clustered = true;
        }
    }
    var
        myInt: Integer;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
