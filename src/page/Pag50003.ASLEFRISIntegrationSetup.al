page 50003 "ASL.EFRIS.IntegrationSetup"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Sales & Receivables Setup";
    Caption = 'EFRIS Integration Setup';

    layout
    {
        area(Content)
        {
            group("System Setup")
            {
                field(ServerUrl; Rec."ASL.EFRIS.ServerUrl")
                {
                    ApplicationArea = All;
                    Caption = 'Server URL';
                }
                field(DeviceNo; Rec."ASL.EFRIS.DeviceNo")
                {
                    ApplicationArea = All;
                    Caption = 'Device No.';
                }
                field(WSVersion; Rec."ASL.EFRIS.WSVersion")
                {
                    ApplicationArea = All;
                    Caption = 'WS Version';
                }
                field(SystemDictionaryVersion; Rec."ASL.EFRIS.SysDictionaryVersion")
                {
                }
                field(CommodityCategoryVersion; Rec."ASL.EFRIS.CmdtyCategoryVersion")
                {
                }
                field(LogLevel; Rec."ASL.EFRIS.LogLevel")
                {
                    ApplicationArea = All;
                }
            }
            group(General)
            {
                field(TIN; Rec."ASL.EFRIS.TIN")
                {
                    ApplicationArea = All;
                }
                field(BRN; Rec."ASL.EFRIS.BRN")
                {
                    ApplicationArea = All;
                }
                field(TaxPayerID; Rec."ASL.EFRIS.TaxPayerID")
                {
                    Caption = 'TaxPayer ID';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.LegalName"; Rec."ASL.EFRIS.LegalName")
                {
                    ToolTip = 'Specifies the value of the Legal Name field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.BusinessName"; Rec."ASL.EFRIS.BusinessName")
                {
                    ToolTip = 'Specifies the value of the Business Name field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.E-Mail"; Rec."ASL.EFRIS.E-Mail")
                {
                    ToolTip = 'Specifies the value of the E-Mail field.';
                    ApplicationArea = All;
                }
                field("Integration Start Date"; Rec."ASL.EFRIS.IntegrationStartDate")
                {
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.LCYEFRISCurrencyCode"; Rec."ASL.EFRIS.LCYEFRISCurrencyCode")
                {
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.LCYEFRISCurrencyName"; Rec."ASL.EFRIS.LCYEFRISCurrencyName")
                {
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.InvoiceIndustryCode"; Rec."ASL.EFRIS.InvoiceIndustryCode")
                {
                    Caption = 'Invoice Industry Code';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.InvoicePaymentMode"; Rec."ASL.EFRIS.InvoicePaymentMode")
                {
                    Caption = 'Invoice Payment Mode';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadOnPosting"; Rec."ASL.EFRIS.UploadOnPosting")
                {
                    Caption = 'Upload On Posting';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.ValidateCustTIN"; Rec."ASL.EFRIS.ValidateCustTIN")
                {
                    Caption = 'Validate Customer';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Get TCS Info")
            {
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    TCSInfo: JsonToken;
                    SelectToken: JsonToken;
                    TaxPayerInfo: JsonObject;
                    CompanyInfo: Record "Company Information";
                begin
                    if (Rec."ASL.EFRIS.ServerUrl" <> '') and ((Rec."ASL.EFRIS.TIN" = '') or (Rec."ASL.EFRIS.BRN" = '') or (Rec."ASL.EFRIS.LegalName" = '')) then begin
                        if not EFRISInterface.GetTCSInfo(TCSInfo) then Error(GetLastErrorText());
                        if TCSInfo.SelectToken('TIN', SelectToken) then Rec."ASL.EFRIS.TIN" := SelectToken.AsValue().AsText();
                        if TCSInfo.SelectToken('deviceNo', SelectToken) then Rec."ASL.EFRIS.DeviceNo" := SelectToken.AsValue().AsText();
                        if TCSInfo.SelectToken('wsVersion', SelectToken) then Rec."ASL.EFRIS.WSVersion" := SelectToken.AsValue().AsText();
                        Rec.Modify();
                        EFRISInterface.GetTaxPayerInfo(Rec."ASL.EFRIS.TIN", TaxPayerInfo);
                        if TaxPayerInfo.SelectToken('ninBrn', SelectToken) then Rec."ASL.EFRIS.BRN" := SelectToken.AsValue().AsText();
                        if TaxPayerInfo.SelectToken('legalName', SelectToken) then Rec."ASL.EFRIS.LegalName" := SelectToken.AsValue().AsText();
                        if TaxPayerInfo.SelectToken('businessName', SelectToken) then Rec."ASL.EFRIS.BusinessName" := SelectToken.AsValue().AsText();
                        CompanyInfo.Get();
                        Rec."ASL.EFRIS.E-Mail" := CompanyInfo."E-Mail";
                        Rec.Modify();
                    end;
                end;
            }
            action(UpdateSysDictionary)
            {
                ApplicationArea = All;
                Caption = 'Update System Dictionary';
                Image = Download;

                trigger OnAction()
                var
                begin
                    UpdateSystemDictionary();
                end;
            }
        }
    }
    var
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        MsgSysDictionaryUptoDate: TextConst ENU = 'EFRIS System Dictionary Up to date';

    trigger OnAfterGetRecord()
    var
    begin
    end;

    procedure UpdateSystemDictionary()
    var
        SystemDictionary: JsonToken;
        SysDictionaryEntryToken: JsonToken;
        SystemDictionaryEntries: JsonArray;
        SystemDictionaryEntry: JsonToken;
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
        EFRISCountry: Record "ASL.EFRIS.Country";
        EFRISCurrency: Record "ASL.EFRIS.Currency";
        EFRISPayWay: Record "ASL.EFRIS.PayWay";
        EFRISUnit: Record "ASL.EFRIS.Unit";
        EFRISSector: Record "ASL.EFRIS.Sector";
        SysDictionaryVersion: Code[15];
        EFRISSysDictionaryVersion: Code[15];
        EntriesCount: Integer;
        ExportUnitsCount: Integer;
        I: Integer;
        ValueToken: JsonToken;
        EntryCode: Code[10];
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Countries   #1#############\';
        ProgressDialogTextLine2: Label 'Currencies  #2#############\';
        ProgressDialogTextLine3: Label 'PayWays     #3#############\';
        ProgressDialogTextLine4: Label 'Units       #4#############\';
        ProgressDialogTextLine5: Label 'Sectors     #5#############\';
    begin
        EFRISIntegrationSetup.Get();
        SysDictionaryVersion := EFRISIntegrationSetup."ASL.EFRIS.SysDictionaryVersion";
        EFRISSysDictionaryVersion := EFRISInterface.GetSysDictionaryVersion();
        // if system dictionary is up to date, exit
        if (SysDictionaryVersion <> '') and (SysDictionaryVersion = EFRISSysDictionaryVersion) then begin
            Message(MsgSysDictionaryUptoDate);
            exit;
        end;
        if not EFRISInterface.GetSystemDictionary(SystemDictionary) then Error(EFRISInterface.GetLastErrorMessage()); // call failed failed. exit with error
                                                                                                                      // update system dictionary
        ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2 + ProgressDialogTextLine3 + ProgressDialogTextLine4 + ProgressDialogTextLine5);
        // countries
        if SystemDictionary.SelectToken('countryCode ', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            EntriesCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(1, StrSubstNo('%1 of %2', I, EntriesCount));
                    if not EFRISCountry.Get(EntryCode) then begin
                        // country not in table. insert
                        EFRISCountry.Init();
                        EFRISCountry.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISCountry.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISCountry.Description := ValueToken.AsValue().AsText();
                        EFRISCountry.Insert();
                    end;
                end;
                I += 1;
            until I = EntriesCount;
        end;
        // currencies
        if SystemDictionary.SelectToken('currencyType', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            EntriesCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(2, StrSubstNo('%1 of %2', I, EntriesCount));
                    if not EFRISCurrency.Get(EntryCode) then begin
                        // currency not in table. insert
                        EFRISCurrency.Init();
                        EFRISCurrency.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISCurrency.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISCurrency.Description := ValueToken.AsValue().AsText();
                        EFRISCurrency.Insert();
                    end;
                end;
                I += 1;
            until I = EntriesCount;
        end;
        // payways
        if SystemDictionary.SelectToken('payWay ', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            EntriesCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(3, StrSubstNo('%1 of %2', I, EntriesCount));
                    if not EFRISPayWay.Get(EntryCode) then begin
                        // payway not in table. insert
                        EFRISPayWay.Init();
                        EFRISPayWay.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISPayWay.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISPayWay.Description := ValueToken.AsValue().AsText();
                        EFRISPayWay.Insert();
                    end;
                end;
                I += 1;
            until I = EntriesCount;
        end;
        // units
        if SystemDictionary.SelectToken('rateUnit', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            EntriesCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(4, StrSubstNo('%1 of %2', I, EntriesCount));
                    if not EFRISUnit.Get(EntryCode) then begin
                        // unit not in table. insert
                        EFRISUnit.Init();
                        EFRISUnit.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISUnit.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISUnit.Description := ValueToken.AsValue().AsText();
                        EFRISUnit.Insert();
                    end;
                end;
                I += 1;
            until I = EntriesCount;
        end;
        // export units
        if SystemDictionary.SelectToken('exportRateUnit', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            ExportUnitsCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(4, StrSubstNo('%1 of %2', EntriesCount + I, EntriesCount + ExportUnitsCount));
                    if EFRISUnit.Get(EntryCode) then begin
                        // update existing
                        EFRISUnit.ExportUnit := true;
                        if SystemDictionaryEntry.SelectToken('validPeriodFrom', ValueToken) then EFRISUnit.ExportUnitValidFrom := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('periodTo', ValueToken) then EFRISUnit.ExportUnitValidTo := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('status', ValueToken) then EFRISUnit.ExportUnitStatus := ValueToken.AsValue().AsText();
                        EFRISUnit.Modify();
                    end
                    else begin
                        // unit not in table. insert
                        EFRISUnit.Init();
                        EFRISUnit.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISUnit.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISUnit.Description := ValueToken.AsValue().AsText();
                        EFRISUnit.ExportUnit := true;
                        if SystemDictionaryEntry.SelectToken('validPeriodFrom', ValueToken) then EFRISUnit.ExportUnitValidFrom := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('periodTo', ValueToken) then EFRISUnit.ExportUnitValidTo := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('status', ValueToken) then EFRISUnit.ExportUnitStatus := ValueToken.AsValue().AsText();
                        EFRISUnit.Insert();
                    end;
                end;
                I += 1;
            until I = ExportUnitsCount;
        end;
        // sectors
        if SystemDictionary.SelectToken('sector', SysDictionaryEntryToken) then begin
            SystemDictionaryEntries := SysDictionaryEntryToken.AsArray();
            EntriesCount := SystemDictionaryEntries.Count;
            I := 0;
            repeat
                SystemDictionaryEntries.Get(I, SystemDictionaryEntry);
                if SystemDictionaryEntry.SelectToken('value', ValueToken) then begin
                    EntryCode := ValueToken.AsValue().AsText();
                    ProgressDialog.Update(5, StrSubstNo('%1 of %2', I, EntriesCount));
                    if not EFRISUnit.Get(EntryCode) then begin
                        // sector not in table. insert
                        EFRISSector.Init();
                        EFRISSector.Code := EntryCode;
                        if SystemDictionaryEntry.SelectToken('name', ValueToken) then EFRISSector.Name := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('description', ValueToken) then EFRISSector.Description := ValueToken.AsValue().AsText();
                        if SystemDictionaryEntry.SelectToken('parentClass', ValueToken) then EFRISSector.Parent := ValueToken.AsValue().AsText();
                        EFRISSector.Insert();
                    end;
                end;
                I += 1;
            until I = EntriesCount;
        end;
        EFRISIntegrationSetup."ASL.EFRIS.SysDictionaryVersion" := EFRISSysDictionaryVersion;
        EFRISIntegrationSetup.Modify();
    end;
}
