page 50011 "ASL.EFRIS.ItemUploadErrors"
{
    Caption = 'EFRIS Item Upload Errors';
    PageType = List;
    CardPageID = "Item Card";
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Item;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CmdtCategoryCode; Rec."ASL.EFRIS.CmdtCategoryCode")
                {
                    ApplicationArea = All;
                }
                field(CmdtCategoryName; Rec."ASL.EFRIS.CmdtCategoryName")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UploadStatus; Rec."ASL.EFRIS.UploadStatus")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ItemId; Rec."ASL.EFRIS.ItemId")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UploadErrorCode; Rec."ASL.EFRIS.UploadErrorCode")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UploadErrorMessage; Rec."ASL.EFRIS.UploadErrorMessage")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UploadErrorAction; Rec."ASL.EFRIS.UploadErrorAction")
                {
                    ApplicationArea = All;
                }
                field(EFRISOpeningStock; Rec."Net Change")
                {
                    Caption = 'EFRIS Opening Stock';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OpenInvUploadStatus; Rec."ASL.EFRIS.OpenInvUploadStatus")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OpenInvUpldErrorCode; Rec."ASL.EFRIS.OpenInvUpldErrorCode")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OpnInvUpldErrMessage; Rec."ASL.EFRIS.OpnInvUpldErrMessage")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OpenInvUpldErrAction; Rec."ASL.EFRIS.OpenInvUpldErrAction")
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
            group("ASL.EFRIS.Actions")
            {
                Caption = 'EFRIS';
                Image = "TaxSetup";

                action("ASL.EFRIS.UploadItems")
                {
                    Caption = 'Upload Items';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Item: Record Item;
                    begin
                        CurrPage.SetSelectionFilter(Item);
                        if EFRISInterface.UploadItem(Item, false) then
                            Message('Items successuly uploaded to EFRIS')
                        else
                            Error('Items upload failed. Check log for details');
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
                        Item: Record Item;
                    begin
                        CurrPage.SetSelectionFilter(Item);
                        if Item.FindFirst() then begin
                            if EFRISInterface.GetEFRISItemDetails(Item) then begin
                                Message('EFRIS item details fetched')
                            end
                            else
                                Error('Failed to get items details from EFRIS. Check log for details');
                        end;
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
                        CurrPage.SetSelectionFilter(Item);
                        if Item.FindFirst() then begin
                            if EFRISInterface.UploadItem(Item, true) then
                                Message('EFRIS Item successuly updated')
                            else
                                Message('EFRIS Items update failed. Check log for details');
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
                        CurrPage.SetSelectionFilter(Item);
                        if Item.FindFirst() then begin
                            if EFRISInterface.PostOpeningStock(Item) then
                                Message('Items Opening Stock successuly posted to EFRIS')
                            else
                                Message('Items Opening Stock posting failed. Check log for details');
                        end;
                    end;
                }
                action("ASL.EFRIS.ProcessItems")
                {
                    Caption = 'Process Items';
                    ApplicationArea = All;
                    Image = Process;
                    RunObject = Report "ASL.EFRIS.ProcessItems";

                    trigger OnAction()
                    begin
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        EFRISSetup.get();
        if EFRISSetup."ASL.EFRIS.IntegrationStartDate" = 0D then Error(ErrIntegrationStartDateNotSet);
        OpeningStockAsAtDate := CalcDate('-1D', EFRISSetup."ASL.EFRIS.IntegrationStartDate");
        Rec.FilterGroup(2);
        Rec.SetRange("ASL.EFRIS.UploadStatus", Enum::"ASL.EFRIS.UploadStatus"::Error);
        Rec.SetFilter("Date Filter", StrSubstNo('..C%1', OpeningStockAsAtDate));
        Rec.FilterGroup(-1);
        Rec.SetRange("ASL.EFRIS.OpenInvUploadStatus", Enum::"ASL.EFRIS.UploadStatus"::Error);
    end;

    var
        OpeningStockAsAtDate: Date;
        ErrIntegrationStartDateNotSet: TextConst ENU = 'Integration Start Date not specified in EFRIS Integration Setup';
}
