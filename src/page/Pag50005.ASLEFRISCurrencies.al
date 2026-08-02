page 50005 "ASL.EFRIS.Currencies"
{
  Caption = 'EFRIS Currencies';
  ApplicationArea = All;
  PageType = List;
  UsageCategory = Lists;
  SourceTable = "ASL.EFRIS.Currency";
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
        field("Code";Rec."Code")
        {
          ApplicationArea = All;
        }
        field(Name;Rec.Name)
        {
          ApplicationArea = All;
        }
        field(Description;Rec.Description)
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

        trigger OnAction()begin
        end;
      }
    }
  }
  var myInt: Integer;
}
