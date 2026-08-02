report 50067 "ASL.EFRIS.ProcessItems"
{
    Caption = 'EFRIS: Process Items';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item;
        Item)
        {
            trigger OnPreDataItem()
            var
            begin
                ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
            end;

            trigger OnAfterGetRecord()
            var
                Result: Boolean;
            begin
                ItemCount += 1;
                ProgressDialog.Update(1, Item."No.");
                ProgressDialog.Update(2, ItemCount);
                case ProcessAction of
                    ProcessAction::"Upload Items to EFRIS":
                        Result := EFRISInterface.UploadItem(Item, false);
                    ProcessAction::"Update EFRIS Items":
                        Result := EFRISInterface.UploadItem(Item, true);
                    ProcessAction::"Get EFRIS Item Details":
                        begin
                            Result := EFRISInterface.GetEFRISItemDetails(Item);
                            if Result then Item.Modify();
                        end;
                    ProcessAction::"Post Opening Stock":
                        Result := EFRISInterface.PostOpeningStock(Item)
                end;
                if (not Result) then begin
                    if ProcessAction = ProcessAction::"Post Opening Stock" then
                        Item."ASL.EFRIS.OpnInvUpldErrMessage" := EFRISInterface.GetLastErrorMessage()
                    else
                        Item."ASL.EFRIS.UploadErrorMessage" := EFRISInterface.GetLastErrorMessage();
                    Item.Modify();
                    FailCount += 1;
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(ProcessAction; ProcessAction)
                    {
                        Caption = 'Process Action';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    var
    begin
        ItemCount := 0;
        FailCount := 0;
    end;

    trigger OnPostReport()
    var
        ProcessItem: Record Item;
    begin
        if FailCount > 0 then Message('Processing failed for some of the selected Items. Check Logs for details');
    end;

    var
        ProcessAction: Option "Upload Items to EFRIS","Update EFRIS Items","Get EFRIS Item Details","Post Opening Stock";
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        ItemCount: Integer;
        FailCount: Integer;
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Item No. #1##############\';
        ProgressDialogTextLine2: Label 'Count       #2###############';
}
