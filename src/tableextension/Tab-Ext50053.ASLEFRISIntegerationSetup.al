tableextension 50053 "ASL.EFRIS.IntegerationSetup" extends "Sales & Receivables Setup"
{
    Caption = 'EFRIS Integration Setup';

    fields
    {
        field(70615581; "ASL.EFRIS.ServerUrl"; text[255])
        {
            Caption = 'Server URL';
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.TIN"; text[20])
        {
            Caption = 'TIN';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.BRN"; Text[50])
        {
            Caption = 'BRN';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615584; "ASL.EFRIS.DeviceNo"; Text[50])
        {
            Caption = 'Device No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615585; "ASL.EFRIS.TaxPayerID"; Text[50])
        {
            Caption = 'Tax Payer ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615586; "ASL.EFRIS.LegalName"; Text[50])
        {
            Caption = 'Legal Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615587; "ASL.EFRIS.BusinessName"; Text[50])
        {
            Caption = 'Business Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615588; "ASL.EFRIS.E-Mail"; Text[50])
        {
            Caption = 'E-Mail';
            DataClassification = ToBeClassified;
        }
        field(70615591; "ASL.EFRIS.WSVersion"; Text[50])
        {
            Caption = 'WS Version';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615592; "ASL.EFRIS.IntegrationStartDate"; Date)
        {
            Caption = 'Integration Start Date';
            DataClassification = ToBeClassified;
        }
        field(70615593; "ASL.EFRIS.CrNoteMaxInvDays"; Integer)
        {
            Caption = 'Credit Note Maximum Invoicing Days';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615594; "ASL.EFRIS.CrNoteValPcntLimit"; Integer)
        {
            Caption = 'Credit Not Value Percent Limit';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615596; "ASL.EFRIS.SysDictionaryVersion"; Code[15])
        {
            Caption = 'System Dictionary Version';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615597; "ASL.EFRIS.CmdtyCategoryVersion"; Code[15])
        {
            Caption = 'Commodity Category Version';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615598; "ASL.EFRIS.LCYEFRISCurrencyCode"; Code[10])
        {
            Caption = 'LCY EFRIS Currency Code';
            DataClassification = ToBeClassified;
            TableRelation = "ASL.EFRIS.Currency".Code;

            trigger OnValidate()
            var
                EFRISCurrency: Record "ASL.EFRIS.Currency";
            begin
                EFRISCurrency.Get("ASL.EFRIS.LCYEFRISCurrencyCode");
                "ASL.EFRIS.LCYEFRISCurrencyName" := EFRISCurrency.Name;
            end;
        }
        field(70615599; "ASL.EFRIS.LCYEFRISCurrencyName"; Text[50])
        {
            Caption = 'LCY EFRIS Currency Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615600; "ASL.EFRIS.InvoiceIndustryCode"; Enum "ASL.EFRIS.InvoiceIndustryCode")
        {
            Caption = 'Invoice Industry Code';
            DataClassification = ToBeClassified;
        }
        field(70615601; "ASL.EFRIS.InvoicePaymentMode"; Enum "ASL.EFRIS.PaymentMode")
        {
            Caption = 'Invoice Payment Mode';
            DataClassification = ToBeClassified;
        }
        field(70615602; "ASL.EFRIS.CrNotesContactName"; Text[150])
        {
            Caption = 'Cr. Notes Contact Name';
            DataClassification = ToBeClassified;
        }
        field(70615603; "ASL.EFRIS.CrNotesContactMobile"; Text[30])
        {
            Caption = 'Cr. Notes Contact Mobile';
            DataClassification = ToBeClassified;
        }
        field(70615604; "ASL.EFRIS.CrNotesContactEmail"; Text[50])
        {
            Caption = 'Cr. Notes Contact Email';
            DataClassification = ToBeClassified;
        }
        field(70615606; "ASL.EFRIS.UploadOnPosting"; Boolean)
        {
            Caption = 'Upload On Posting';
            DataClassification = ToBeClassified;
        }
        field(70615607; "ASL.EFRIS.LogLevel"; Enum "ASL.EFRIS.LogLevel")
        {
            Caption = 'Log Level';
            DataClassification = ToBeClassified;
        }
        field(70615608; "ASL.EFRIS.ValidateCustTIN"; Boolean)
        {
            Caption = 'Validate Cust. TIN';
            DataClassification = ToBeClassified;
        }
    }
}
