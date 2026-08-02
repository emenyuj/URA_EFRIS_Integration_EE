pageextension 50092 "ASL.EFRIS.ItemCard" extends "Item Card"
{
    layout
    {
        addafter("Costs & Posting")
        {
            group("ASL.EFRIS.Fields")
            {
                Caption = 'EFRIS';

                group("ASL.EFRIS.Setup")
                {
                    Caption = 'Setup';

                    field("ASL.EFRIS.CmdtCategoryCode"; Rec."ASL.EFRIS.CmdtCategoryCode")
                    {
                        Caption = 'Commodity Category Code';
                    }
                    field("ASL.EFRIS.CmdtCategoryName"; Rec."ASL.EFRIS.CmdtCategoryName")
                    {
                        Caption = 'Commodity Category Name';
                    }
                    field("ASL.EFRIS.PieceUnitOfMeasure"; Rec."ASL.EFRIS.PieceUnitOfMeasure")
                    {
                        Caption = 'Piece Unit Of Measure';
                    }
                }
                group("ASL.EFRIS.ItemUpload")
                {
                    Caption = 'Item Upload Status';

                    field("ASL.EFRIS.UploadStatus"; Rec."ASL.EFRIS.UploadStatus")
                    {
                        Caption = 'Upload Status';
                    }
                    field("ASL.EFRIS.ItemId"; Rec."ASL.EFRIS.ItemId")
                    {
                        Caption = 'Item Id';
                    }
                    field("ASL.EFRIS.UploadErrorCode"; Rec."ASL.EFRIS.UploadErrorCode")
                    {
                        Caption = 'Upload Error Code';
                    }
                    field("ASL.EFRIS.UploadErrorMessage"; Rec."ASL.EFRIS.UploadErrorMessage")
                    {
                        Caption = 'Upload Error Message';
                    }
                    field("ASL.EFRIS.UploadErrorAction"; Rec."ASL.EFRIS.UploadErrorAction")
                    {
                        Caption = 'Upload Error Action';
                    }
                }
                group("ASL.EFRIS.OpeningInventoryUpload")
                {
                    Caption = 'Opening Inventory Upload Status';

                    field("ASL.EFRIS.OpenInvUploadTime"; Rec."ASL.EFRIS.OpenInvUploadTime")
                    {
                        Caption = 'Opn. Inv. Upload Time';
                    }
                    field("ASL.EFRIS.OpenInvUploadStatus"; Rec."ASL.EFRIS.OpenInvUploadStatus")
                    {
                        Caption = 'Opn. Inv. Upload Status';
                    }
                    field("ASL.EFRIS.OpenInvUpldErrorCode"; Rec."ASL.EFRIS.OpenInvUpldErrorCode")
                    {
                        Caption = 'Opn. Inv. Upload Error Code';
                    }
                    field("ASL.EFRIS.OpnInvUpldErrMessage"; Rec."ASL.EFRIS.OpnInvUpldErrMessage")
                    {
                        Caption = 'Opn. Inv. Upload Error Message';
                    }
                    field("ASL.EFRIS.OpenInvUpldErrAction"; Rec."ASL.EFRIS.OpenInvUpldErrAction")
                    {
                        Caption = 'Opn. Inv. Upload Error Action';
                    }
                }
            }
        }
    }
    actions
    {
        addafter(ItemActionGroup)
        {
            group("ASL.EFRIS.Actions")
            {
                Caption = 'EFRIS';
                Image = "TaxSetup";

                action("ASL.EFRIS.UploadItem")
                {
                    Caption = 'Upload Item';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Item: Record Item;
                    begin
                        if Rec."ASL.EFRIS.ItemId" <> '' then begin
                            Message('Item already uploaded to EFRIS');
                            exit;
                        end;
                        Item.Reset();
                        Item.SetRange(Item."No.", Rec."No.");
                        if Item.FindFirst() then begin
                            if EFRISInterface.UploadItem(Item, false) then
                                Message('Item successuly uploaded to EFRIS')
                            else
                                Message('Item upload failed. ' + EFRISInterface.GetLastErrorMessage());
                        end;
                    end;
                }
                action("ASL.EFRIS.GetItemDetails")
                {
                    Caption = 'Get Item Details';
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.GetEFRISItemDetails(Rec) then begin
                            Rec.Modify();
                            Message('EFRIS item details fetched')
                        end
                        else
                            Message('Failed to get Item details from EFRIS. ' + EFRISInterface.GetLastErrorMessage());
                    end;
                }
                action("ASL.EFRIS.UpdateItem")
                {
                    Caption = 'Update Item';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Item: Record Item;
                    begin
                        if Rec."ASL.EFRIS.ItemId" = '' then begin
                            Error('Item not yet uploaded to EFRIS');
                            exit;
                        end;
                        Item.Reset();
                        Item.SetRange(Item."No.", Rec."No.");
                        if Item.FindFirst() then begin
                            if EFRISInterface.UploadItem(Item, true) then
                                Message('EFRIS Item successuly updated')
                            else
                                Message('EFRIS Item update failed. ' + EFRISInterface.GetLastErrorMessage());
                        end;
                    end;
                }
                action("ASL.EFRIS.PostOpeningStock")
                {
                    Caption = 'Post Opening Stock';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Item: Record Item;
                    begin
                        if Rec."ASL.EFRIS.ItemId" = '' then begin
                            Error('Item not yet uploaded to EFRIS');
                            exit;
                        end;
                        Item.Reset();
                        Item.SetRange(Item."No.", Rec."No.");
                        if Item.FindFirst() then begin
                            if Item."ASL.EFRIS.OpenInvUploadStatus" = Item."ASL.EFRIS.OpenInvUploadStatus"::Success then Error('Item Opening Stock already posted to EFRIS');
                            if EFRISInterface.PostOpeningStock(Item) then
                                Message('Item Opening Stock successuly posted to EFRIS')
                            else
                                Message('Item Opening Stock posting failed. ' + EFRISInterface.GetLastErrorMessage());
                        end;
                    end;
                }
            }
        }
    }
}
