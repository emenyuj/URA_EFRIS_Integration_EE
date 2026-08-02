table 50014 "ASL.EFRIS.Log"
{
    Caption = 'EFRIS Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            AutoIncrement = true;
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(2; "Time"; DateTime)
        {
            Caption = 'Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(3; Level; enum "ASL.EFRIS.LogLevel")
        {
            Caption = 'Level';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(4; "Message"; Text[1024])
        {
            Caption = 'Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(5; RequestInterfaceCode; enum "ASL.EFRIS.InterfaceCode")
        {
            Caption = 'Request Interface Code';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(6; RequestContent; Blob)
        {
            Caption = 'Request Content';
            DataClassification = ToBeClassified;
        }
        field(7; ResponseCode; Text[20])
        {
            Caption = 'Request Code';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(8; ResponseMessage; Blob)
        {
            Caption = 'Response Message';
            DataClassification = ToBeClassified;
        }
        field(9; ResponseContent; Blob)
        {
            Caption = 'Response Content';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Timestamp; "Time")
        {
        }
    }
}
