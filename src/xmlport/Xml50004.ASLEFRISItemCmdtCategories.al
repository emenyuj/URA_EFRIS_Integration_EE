xmlport 50004 "ASL.EFRIS.ItemCmdtCategories"
{
    Caption = 'EFRIS Item Commodity Categories';

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Item;
            Item)
            {
                AutoUpdate = true;

                fieldelement("No.";
                Item."No.")
                {
                }
                fieldelement("ASL.EFRIS.CmdtCategoryCode";
                Item."ASL.EFRIS.CmdtCategoryCode")
                {
                }
                trigger OnBeforeInsertRecord()
                var
                begin
                    Item.Validate("ASL.EFRIS.CmdtCategoryCode");
                end;
            }
        }
    }
}
