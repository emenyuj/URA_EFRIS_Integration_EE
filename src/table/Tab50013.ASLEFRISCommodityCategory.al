table 50013 "ASL.EFRIS.CommodityCategory"
{
    Caption = 'EFRIS Commodity Category';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[150])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; Rate; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Exclusion; Option)
        {
            OptionMembers = "Zero","Exempt","No Exclusion","Both";
            DataClassification = ToBeClassified;
        }
        field(5; Exempt; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; ExemptStartDate; Text[20])
        {
            Caption = 'Exempt Start Date';
            DataClassification = ToBeClassified;
        }
        field(7; ExemptEndDate; Text[20])
        {
            Caption = 'Exempt End Date';
            DataClassification = ToBeClassified;
        }
        field(8; ZeroRated; Boolean)
        {
            Caption = 'Zero Rated';
            DataClassification = ToBeClassified;
        }
        field(9; ZeroRatedStartDate; Text[20])
        {
            Caption = 'Zero Rated Start Date';
            DataClassification = ToBeClassified;
        }
        field(10; ZeroRatedEndDate; Text[20])
        {
            Caption = 'Zero Rated End Date';
            DataClassification = ToBeClassified;
        }
        field(11; Service; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Parent; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Level; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Enabled; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Leaf; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
