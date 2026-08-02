tableextension 50064 "ASL.EFRIS.Customer" extends Customer
{
    Caption = 'Customer EFRIS Ext.';

    fields
    {
        field(70615581; "ASL.EFRIS.TIN"; Code[20])
        {
            Caption = 'TIN';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                TaxPayerInfo: JsonObject;
                SelectToken: JsonToken;
                BusinessName: Text[500];
                LegalName: Text[500];
                NameMatches: Boolean;
                SetUp: Record "Sales & Receivables Setup";
            begin
                SetUp.Get();
                if SetUp."ASL.EFRIS.ValidateCustTIN" = true then begin
                    if Rec."ASL.EFRIS.TIN" = '' then exit;
                    EFRISInterface.GetTaxPayerInfo(Rec."ASL.EFRIS.TIN", TaxPayerInfo);
                    // compare EFRIS legal name for TIN with any of Name, Business Name or Legal Name
                    if TaxPayerInfo.SelectToken('legalName', SelectToken) then begin
                        LegalName := SelectToken.AsValue().AsText();
                        if Rec."ASL.EFRIS.LegalName" <> '' then NameMatches := LowerCase(Rec."ASL.EFRIS.LegalName") = LowerCase(LegalName);
                        if not NameMatches and (Rec."ASL.EFRIS.BusinessName" <> '') then NameMatches := LowerCase(Rec."ASL.EFRIS.BusinessName") = LowerCase(LegalName);
                        if not NameMatches then NameMatches := LowerCase(Rec.Name) = LowerCase(LegalName);
                    end;
                    if not NameMatches then begin
                        // compare EFRIS business name for TIN with any of Name, Business Name or Legal Name
                        if TaxPayerInfo.SelectToken('businessName', SelectToken) then begin
                            BusinessName := SelectToken.AsValue().AsText();
                            if Rec."ASL.EFRIS.LegalName" <> '' then NameMatches := LowerCase(Rec."ASL.EFRIS.LegalName") = LowerCase(BusinessName);
                            if not NameMatches and (Rec."ASL.EFRIS.BusinessName" <> '') then NameMatches := LowerCase(Rec."ASL.EFRIS.BusinessName") = LowerCase(BusinessName);
                            if not NameMatches then NameMatches := LowerCase(Rec.Name) = LowerCase(BusinessName);
                        end;
                    end;
                    if not NameMatches then Error(ErrTINForTaxPayerWithDifferentName, Rec."ASL.EFRIS.TIN", BusinessName);
                    UpdateTaxPayerInfo(TaxPayerInfo);
                end;
            end;
        }
        field(70615582; "ASL.EFRIS.NINBRN"; Code[30])
        {
            Caption = 'NIN/BRN';
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.PassportNo"; Code[30])
        {
            Caption = 'Passport No';
            DataClassification = ToBeClassified;
        }
        field(70615584; "ASL.EFRIS.LegalName"; Text[500])
        {
            Caption = 'Legal Name';
            DataClassification = ToBeClassified;
        }
        field(70615585; "ASL.EFRIS.BusinessName"; Text[500])
        {
            Caption = 'Business Name';
            DataClassification = ToBeClassified;
        }
        field(70615586; "ASL.EFRIS.TaxPayerKind"; Enum "ASL.EFRIS.TaxPayerKind")
        {
            Caption = 'Tax Payer Kind';
            DataClassification = ToBeClassified;
        }
        field(70615587; "ASL.EFRIS.ContactNumber"; Text[20])
        {
            Caption = 'Contact Number';
            DataClassification = ToBeClassified;
        }
        field(70615588; "ASL.EFRIS.ContactMobile"; Text[20])
        {
            Caption = 'Contact Mobile';
            DataClassification = ToBeClassified;
        }
        field(70615589; "ASL.EFRIS.ContactEmail"; Text[30])
        {
            Caption = 'Contact Email';
            DataClassification = ToBeClassified;
        }
        field(70615590; "ASL.EFRIS.BuyerType"; Enum "ASL.EFRIS.BuyerType")
        {
            Caption = 'Buyer Type';
            DataClassification = ToBeClassified;
        }
        field(70615591; "ASL.EFRIS.Citizenship"; Text[100])
        {
            Caption = 'Citizenship';
            DataClassification = ToBeClassified;
        }
        field(70615592; "ASL.EFRIS.Sector"; Code[20])
        {
            Caption = 'Sector';
            DataClassification = ToBeClassified;
            TableRelation = "ASL.EFRIS.Sector".Code;
        }
        field(70615593; "ASL.EFRIS.InvoiceIndustryCode"; Enum "ASL.EFRIS.InvoiceIndustryCode")
        {
            Caption = 'Invoice Industry Code';
            DataClassification = ToBeClassified;
        }
        field(70615594; "ASL.EFRIS.InvoicePaymentMode"; Enum "ASL.EFRIS.PaymentMode")
        {
            Caption = 'Invoice Payment Mode';
            DataClassification = ToBeClassified;
        }
        field(70615595; "ASL.EFRIS.Deemed"; Boolean)
        {
            Caption = 'Deemed';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                if "ASL.EFRIS.Deemed" and ("ASL.EFRIS.BuyerType" <> "ASL.EFRIS.BuyerType"::"B2B/B2G") then Error('EFRIS.BuyerType must be ''B2B/B2G'' for Deemed');
            end;
        }
        field(70615596; "ASL.EFRIS.TaxPayerType"; Enum "ASL.EFRIS.TaxPayerType")
        {
            Caption = 'Tax Payer Type';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70615597; "ASL.EFRIS.TaxExemptType"; Enum "ASL.EFRIS.TaxExemptType")
        {
            Caption = 'Tax Exempt Type';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    var
        ErrTINForTaxPayerWithDifferentName: TextConst ENU = 'The TIN %1 is registered for %2';

    procedure RefreshTaxPayerInfo()
    var
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        TaxPayerInfo: JsonObject;
    begin
        if Rec."ASL.EFRIS.TIN" <> '' then begin
            EFRISInterface.GetTaxPayerInfo(Rec."ASL.EFRIS.TIN", TaxPayerInfo);
            UpdateTaxPayerInfo(TaxPayerInfo);
            Rec.Modify();
        end;
    end;

    local procedure UpdateTaxPayerInfo(var TaxPayerInfo: JsonObject)
    var
        SelectToken: JsonToken;
    begin
        if TaxPayerInfo.SelectToken('legalName', SelectToken) then Rec."ASL.EFRIS.LegalName" := SelectToken.AsValue().AsText();
        if TaxPayerInfo.SelectToken('businessName', SelectToken) then Rec."ASL.EFRIS.BusinessName" := SelectToken.AsValue().AsText();
        if TaxPayerInfo.SelectToken('ninBrn', SelectToken) then Rec."ASL.EFRIS.NINBRN" := SelectToken.AsValue().AsText();
        if TaxPayerInfo.SelectToken('taxpayerType', SelectToken) then Rec."ASL.EFRIS.TaxPayerKind" := Enum::"ASL.EFRIS.TaxPayerKind".FromInteger(SelectToken.AsValue().AsInteger());
    end;
}
