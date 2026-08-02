table 50016 "ASL.EFRIS.VatProjects"
{

    fields
    {
        field(1; CustomerTIN; code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; commodityCategoryCode; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; projectId; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; projectName; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(5; unit; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; deemedExemptCode; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; currentQty; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; currentAmount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; serviceMark; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; customerNo; Code[30])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; CustomerTIN, customerNo, commodityCategoryCode, projectId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; projectId, projectName, commodityCategoryCode, customerNo, CustomerTIN)
        {

        }
        fieldgroup(Brick; projectId, projectName, commodityCategoryCode)
        {

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