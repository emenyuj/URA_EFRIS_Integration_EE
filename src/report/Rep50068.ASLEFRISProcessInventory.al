report 50068 "ASL.EFRIS.ProcessInventory"
{
    Caption = 'EFRIS: Process Inventory';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(EntriesType; EntriesType)
                    {
                        ApplicationArea = All;
                        Caption = 'Entries Type';
                    }
                    field(DocumentNo; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';

                        trigger OnLookup(var Txt: Text): Boolean
                        var
                            ItemLedgerEntries: Page "Item Ledger Entries";
                            SelectedItemLdgEntry: Record "Item Ledger Entry";
                            LookupItemLedgerEntry: Record "Item Ledger Entry";
                        begin
                            SetItemLedgerEntryFilters(LookupItemLedgerEntry, false);
                            ItemLedgerEntries.SetRecord(LookupItemLedgerEntry);
                            ItemLedgerEntries.SetTableView(LookupItemLedgerEntry);
                            ItemLedgerEntries.LookupMode := true;
                            if ItemLedgerEntries.RunModal() = Action::LookupOK then begin
                                ItemLedgerEntries.GetRecord(SelectedItemLdgEntry);
                                DocumentNo := SelectedItemLdgEntry."Document No.";
                            end;
                        end;
                    }
                    field(FromPostingDate; FromPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From Posting Date';

                        trigger OnValidate()
                        var
                        begin
                            EFRISSetup.Get();
                            if FromPostingDate < EFRISSetup."ASL.EFRIS.IntegrationStartDate" then Error(ErrFromDateBeforeIntgnStartDate);
                        end;
                    }
                    field(ToPostingDate; ToPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To Posting Date';

                        trigger OnValidate()
                        var
                        begin
                            EFRISSetup.Get();
                            if ToPostingDate < EFRISSetup."ASL.EFRIS.IntegrationStartDate" then Error(ErrFromDateBeforeIntgnStartDate);
                        end;
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        RunFromErrorsPage: Boolean;
        EFRISSetup: Record "Sales & Receivables Setup";
        FromPostingDate: Date;
        ToPostingDate: Date;
        EntriesType: Option Adjustments,Production,Purchases;
        DocumentNo: Code[20];
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        ErrFromDateBeforeIntgnStartDate: TextConst ENU = 'From Posting Date must not be before the Integration Start Date specified in EFRIS Integration Setup';
        ErrToDateBeforeIntgnStartDate: TextConst ENU = 'To Posting Date must not be before the Integration Start Date specified in EFRIS Integration Setup';

    trigger OnInitReport()
    var
    begin
        EFRISSetup.Get();
        if (FromPostingDate = 0D) or (FromPostingDate > EFRISSetup."ASL.EFRIS.IntegrationStartDate") then FromPostingDate := EFRISSetup."ASL.EFRIS.IntegrationStartDate";
    end;

    trigger OnPostReport()
    var
        ItemLedgerEntries: Record "Item Ledger Entry";
        ItemLedgerEntryErrors: Page "ASL.EFRIS.PndngItemLedgEntries";
    begin
        SetItemLedgerEntryFilters(ItemLedgerEntries, true);
        if not ItemLedgerEntries.FindSet then Error('No matching pending Item Ledger Entries found');
        case EFRISInterface.UpdateInventoryEntries(ItemLedgerEntries) of
            Enum::"ASL.EFRIS.ProcessInvExitStatus"::"No Matching entries":
                Message('No matching pending Item Ledger Entries found');
            Enum::"ASL.EFRIS.ProcessInvExitStatus"::Success:
                Message('Successfully updated inventory');
            Enum::"ASL.EFRIS.ProcessInvExitStatus"::Error:
                begin
                    Message(EFRISInterface.GetLastErrorMessage());
                    if not RunFromErrorsPage then ItemLedgerEntryErrors.Run();
                end;
        end;
    end;

    local procedure SetItemLedgerEntryFilters(var FilterItemLedgerEntry: Record "Item Ledger Entry";
    SetDocNoFilter: Boolean)
    var
    begin
        FilterItemLedgerEntry.Reset();
        if (FromPostingDate <> 0D) or (ToPostingDate <> 0D) then begin
            if (FromPostingDate <> 0D) and (ToPostingDate <> 0D) then
                FilterItemLedgerEntry.SetRange("Posting Date", FromPostingDate, ToPostingDate)
            else
                if FromPostingDate <> 0D then
                    FilterItemLedgerEntry.SetRange("Posting Date", FromPostingDate, Today)
                else
                    if ToPostingDate <> 0D then FilterItemLedgerEntry.SetRange("Posting Date", 0D, ToPostingDate);
        end;
        case EntriesType of
            EntriesType::Purchases:
                FilterItemLedgerEntry.SetRange("Entry Type", Enum::"Item Ledger Entry Type"::Purchase);
            EntriesType::Production:
                begin
                    FilterItemLedgerEntry.SetFilter("Entry Type", StrSubstNo('%1|%2|%3|%4', Enum::"Item Ledger Entry Type"::Consumption, Enum::"Item Ledger Entry Type"::"Assembly Consumption", Enum::"Item Ledger Entry Type"::Output, Enum::"Item Ledger Entry Type"::"Assembly Output"))
                end;
            EntriesType::Adjustments:
                begin
                    FilterItemLedgerEntry.SetFilter("Entry Type", StrSubstNo('%1|%2', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Enum::"Item Ledger Entry Type"::"Negative Adjmt."));
                end;
        end;
        if SetDocNoFilter then begin
            if DocumentNo <> '' then FilterItemLedgerEntry.SetRange("Document No.", DocumentNo);
        end;
        FilterItemLedgerEntry.SetFilter("ASL.EFRIS.UploadStatus", StrSubStno('<>%1', Enum::"ASL.EFRIS.UploadStatus"::Success));
    end;

    procedure SetRunFromErrorsPage(RunFrmErrPage: Boolean)
    var
    begin
        RunFromErrorsPage := RunFrmErrPage;
    end;
}
