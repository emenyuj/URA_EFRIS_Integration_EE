table 50008 "ASL.EFRIS.Unit"
{
    Caption = 'EFRIS Unit of Measure';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; ExportUnit; Boolean)
        {
            Caption = 'Export Unit';
            DataClassification = ToBeClassified;
        }
        field(5; ExportUnitValidFrom; Text[20])
        {
            Caption = 'Export Unit Valid From';
            DataClassification = ToBeClassified;
        }
        field(6; ExportUnitValidTo; Text[20])
        {
            Caption = 'Export Unit Valid To';
            DataClassification = ToBeClassified;
        }
        field(7; ExportUnitStatus; Code[10])
        {
            Caption = 'Export Unit Status';
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
