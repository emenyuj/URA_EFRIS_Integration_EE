pageextension 50096 "ASL.EFRIS.ItemList" extends "Item List"
{
    actions
    {
        addafter(Item)
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';
                Image = TaxSetup;

                action("ASL.EFRIS.ImportItemCommodityCategories")
                {
                    Caption = 'Import Commodity Categories';
                    ApplicationArea = All;
                    RunObject = XmlPort "ASL.EFRIS.ItemCmdtCategories";
                    Image = Import;

                    trigger OnAction()
                    begin
                    end;
                }
                action("ASL.EFRIS.ProcessItems")
                {
                    Caption = 'Process Items';
                    ApplicationArea = All;
                    RunObject = Report "ASL.EFRIS.ProcessItems";
                    Image = Process;

                    trigger OnAction()
                    begin
                    end;
                }
            }
        }
    }
}
