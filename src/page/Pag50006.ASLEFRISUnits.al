page 50006 "ASL.EFRIS.Units"
{
    Caption = 'EFRIS Units';
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "ASL.EFRIS.Unit";
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
                field(ExportUnit; Rec.ExportUnit)
                {
                    ApplicationArea = All;
                }
                field(ExportUnitValidFrom; Rec.ExportUnitValidFrom)
                {
                    ApplicationArea = All;
                }
                field(ExportUnitValidTo; Rec.ExportUnitValidTo)
                {
                    ApplicationArea = All;
                }
                field(ExportUnitStatus; Rec.ExportUnitStatus)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
