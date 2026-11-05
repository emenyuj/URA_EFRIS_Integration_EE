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
                field(ConnectionMode; Rec."ASL.EFRIS.ConnectionMode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how Business Central connects to EFRIS. Direct Online modes call the URA web service directly (no Offline Mode Enabler); requests are encrypted and signed in Business Central with the uploaded private key.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(ServerUrl; Rec."ASL.EFRIS.ServerUrl")
                {
                    ApplicationArea = All;
                    Caption = 'Server URL';
                    ToolTip = 'Direct mode: the full URA endpoint (test: https://efristest.ura.go.ug/efrisws/ws/taapp/getInformation, production: https://efrisws.ura.go.ug/ws/taapp/getInformation). Offline Enabler mode: the enabler base URL, e.g. http://127.0.0.1:9880.';
                }
                field(DeviceNo; Rec."ASL.EFRIS.DeviceNo")
                {
                    ApplicationArea = All;
                    Caption = 'Device No.';
                    ToolTip = 'Specifies the EFRIS device number assigned by URA (EFRIS portal > Device Management). In direct mode it must be entered manually.';
                }
                field(TINSetup; Rec."ASL.EFRIS.TIN")
                {
                    ApplicationArea = All;
                    Caption = 'TIN';
                    ToolTip = 'Specifies the taxpayer TIN registered for the device.';
                }
                field(WSVersion; Rec."ASL.EFRIS.WSVersion")
                {
                    ApplicationArea = All;
                    Caption = 'WS Version';
                    ToolTip = 'Specifies the client version sent in globalInfo.version (max 15 characters), e.g. 1.1.20191201.';
                }
                field(PrivateKeyStatus; PrivateKeyInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Private Key';
                    Editable = false;
                    Visible = IsDirectMode;
                    ToolTip = 'Shows the certificate whose private key is used to sign requests and decrypt the symmetric key. Its public key/thumbprint must be registered for the device on the EFRIS portal.';
                }
                field(SymmetricKeyStatus; SymmetricKeyInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Symmetric Key (T104)';
                    Editable = false;
                    Visible = IsDirectMode;
                    ToolTip = 'Shows when the AES symmetric key was last obtained from EFRIS. It is valid for 24 hours and is refreshed automatically.';
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
                Caption = 'Get Taxpayer Info';
                Image = Import;
                ToolTip = 'Direct mode: logs in to EFRIS (T103) and fills TIN details, legal and business name. Offline Enabler mode: reads TIN/device from the enabler (tcsInfo).';

                trigger OnAction()
                begin
                    if Rec.IsEFRISDirectMode() then
                        GetTaxpayerInfoDirect()
                    else
                        GetTaxpayerInfoFromEnabler();
                end;
            }
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection (T101)';
                Image = TestFile;
                ToolTip = 'Calls T101 (get server time) and compares it with the local time. EFRIS rejects requests whose time differs by more than 10 minutes.';

                trigger OnAction()
                var
                    ServerTime: Text;
                begin
                    CurrPage.SaveRecord();
                    if not EFRISInterface.GetServerTime(ServerTime) then
                        Error(EFRISInterface.GetLastErrorMessage());
                    Message(MsgServerTime, ServerTime, EFRISCrypto.GetRequestTime());
                end;
            }
            action(UploadPrivateKey)
            {
                ApplicationArea = All;
                Caption = 'Upload Private Key (.pfx)';
                Image = EncryptionKeys;
                ToolTip = 'Uploads the taxpayer RSA key pair (.pfx/.p12, 2048 bit) - the same file previously configured in the Offline Mode Enabler. It is stored in isolated storage.';

                trigger OnAction()
                var
                    KeyPasswordPage: Page "ASL.EFRIS.KeyPassword";
                    PfxInStream: InStream;
                    FileName: Text;
                    CertificateInfo: Text;
                begin
                    if not UploadIntoStream(SelectKeyFileTxt, '', KeyFileFilterTxt, FileName, PfxInStream) then exit;
                    if KeyPasswordPage.RunModal() <> Action::OK then exit;
                    CertificateInfo := EFRISCrypto.SavePrivateKey(PfxInStream, KeyPasswordPage.GetPassword());
                    UpdateKeyInfo();
                    Message(MsgKeyUploaded, CertificateInfo);
                end;
            }
            action(DownloadPublicCertificate)
            {
                ApplicationArea = All;
                Caption = 'Download Public Certificate';
                Image = Export;
                ToolTip = 'Downloads the public certificate (no private key) contained in the uploaded .pfx, to compare with or upload to the EFRIS portal for this device.';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    CertOutStream: OutStream;
                    CertInStream: InStream;
                    FileName: Text;
                begin
                    TempBlob.CreateOutStream(CertOutStream, TextEncoding::UTF8);
                    CertOutStream.WriteText(EFRISCrypto.GetPublicCertificatePem());
                    TempBlob.CreateInStream(CertInStream, TextEncoding::UTF8);
                    FileName := 'EFRIS_' + Rec."ASL.EFRIS.DeviceNo" + '_public.cer';
                    DownloadFromStream(CertInStream, 'Download public certificate', '', 'Certificate (*.cer)|*.cer', FileName);
                end;
            }
            action(DeletePrivateKey)
            {
                ApplicationArea = All;
                Caption = 'Remove Private Key';
                Image = Delete;
                ToolTip = 'Removes the stored private key and symmetric key.';

                trigger OnAction()
                begin
                    if not Confirm(ConfirmDeleteKeyQst, false) then exit;
                    EFRISCrypto.DeletePrivateKey();
                    UpdateKeyInfo();
                end;
            }
            action(RefreshSymmetricKey)
            {
                ApplicationArea = All;
                Caption = 'Refresh Symmetric Key (T104)';
                Image = Refresh;
                ToolTip = 'Requests a new AES key from EFRIS (T104) and decrypts it with the private key. This normally happens automatically every day.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    if not EFRISInterface.RefreshSymmetricKey() then
                        Error(EFRISInterface.GetLastErrorMessage());
                    UpdateKeyInfo();
                    Message(MsgSymmetricKeyRefreshed);
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
        EFRISCrypto: Codeunit "ASL.EFRIS.Crypto";
        MsgSysDictionaryUptoDate: TextConst ENU = 'EFRIS System Dictionary Up to date';
        MsgServerTime: Label 'Connected to EFRIS.\Server time: %1\Request time sent (UTC+3): %2', Comment = '%1 = server time, %2 = local request time';
        MsgKeyUploaded: Label 'Private key stored.\%1', Comment = '%1 = certificate details';
        MsgSymmetricKeyRefreshed: Label 'A new symmetric key was obtained from EFRIS.';
        MsgTaxpayerInfoUpdated: Label 'Taxpayer information updated from EFRIS (T103).';
        ErrDeviceMismatch: Label 'EFRIS returned device %1 but Device No. in setup is %2.', Comment = '%1 = device from EFRIS, %2 = device in setup';
        ConfirmDeleteKeyQst: Label 'Remove the stored EFRIS private key? Direct online integration will stop working until a key is uploaded again.';
        SelectKeyFileTxt: Label 'Select EFRIS private key file';
        KeyFileFilterTxt: Label 'Key store (*.pfx;*.p12)|*.pfx;*.p12|All files (*.*)|*.*', Locked = true;
        PrivateKeyInfo: Text;
        SymmetricKeyInfo: Text;
        IsDirectMode: Boolean;

    trigger OnAfterGetRecord()
    begin
        UpdateKeyInfo();
    end;

    local procedure UpdateKeyInfo()
    begin
        IsDirectMode := Rec.IsEFRISDirectMode();
        if EFRISCrypto.HasPrivateKey() then
            PrivateKeyInfo := EFRISCrypto.GetCertificateInfo()
        else
            PrivateKeyInfo := 'Not uploaded';
        SymmetricKeyInfo := EFRISInterface.GetSymmetricKeyStatus();
    end;

    local procedure GetTaxpayerInfoDirect()
    var
        LoginInfo: JsonToken;
        SelectToken: JsonToken;
        CompanyInfo: Record "Company Information";
    begin
        CurrPage.SaveRecord();
        if not EFRISInterface.GetLoginInfo(LoginInfo) then
            Error(EFRISInterface.GetLastErrorMessage());
        if LoginInfo.SelectToken('$.device.deviceNo', SelectToken) then
            if SelectToken.AsValue().AsText() <> Rec."ASL.EFRIS.DeviceNo" then
                Error(ErrDeviceMismatch, SelectToken.AsValue().AsText(), Rec."ASL.EFRIS.DeviceNo");
        if LoginInfo.SelectToken('$.taxpayer.tin', SelectToken) then Rec."ASL.EFRIS.TIN" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(Rec."ASL.EFRIS.TIN"));
        if LoginInfo.SelectToken('$.taxpayer.ninBrn', SelectToken) then Rec."ASL.EFRIS.BRN" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(Rec."ASL.EFRIS.BRN"));
        if LoginInfo.SelectToken('$.taxpayer.id', SelectToken) then Rec."ASL.EFRIS.TaxPayerID" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(Rec."ASL.EFRIS.TaxPayerID"));
        if LoginInfo.SelectToken('$.taxpayer.legalName', SelectToken) then Rec."ASL.EFRIS.LegalName" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(Rec."ASL.EFRIS.LegalName"));
        if LoginInfo.SelectToken('$.taxpayer.businessName', SelectToken) then Rec."ASL.EFRIS.BusinessName" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(Rec."ASL.EFRIS.BusinessName"));
        if Rec."ASL.EFRIS.E-Mail" = '' then begin
            CompanyInfo.Get();
            Rec."ASL.EFRIS.E-Mail" := CopyStr(CompanyInfo."E-Mail", 1, MaxStrLen(Rec."ASL.EFRIS.E-Mail"));
        end;
        Rec.Modify();
        UpdateKeyInfo();
        Message(MsgTaxpayerInfoUpdated);
    end;

    local procedure GetTaxpayerInfoFromEnabler()
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
