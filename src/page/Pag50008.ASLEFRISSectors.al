page 50008 "ASL.EFRIS.Sectors"
{
    Caption = 'EFRIS Sectors';
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "ASL.EFRIS.Sector";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                end;
            }
        }
    }
    var
        myInt: Integer;
}
