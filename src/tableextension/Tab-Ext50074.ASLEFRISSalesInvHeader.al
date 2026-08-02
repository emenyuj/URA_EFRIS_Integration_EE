tableextension 50074 "ASL.EFRIS.SalesInvHeader" extends "Sales Invoice Header"
{
    Caption = 'Sales Inv. Header EFRIS Ext.';

    fields
    {
        field(70615581; "ASL.EFRIS.InvoiceIndustryCode"; Enum "ASL.EFRIS.InvoiceIndustryCode")
        {
            Caption = 'Invoice Industry Code';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.PaymentMode"; Enum "ASL.EFRIS.PaymentMode")
        {
            Caption = 'EFRIS Payment Mode';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615586; "ASL.EFRIS.VATDeemed"; Boolean)
        {
            Caption = 'VAT Deemed';
            DataClassification = ToBeClassified;
        }
        field(70615587; "ASL.EFRIS.VATExempt"; Boolean)
        {
            Caption = 'VAT Exempt';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70615591; "ASL.EFRIS.UploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Upload Status';
            Editable = false;
        }
        field(70615592; "ASL.EFRIS.UploadTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70615593; "ASL.EFRIS.UploadErrorCode"; Code[10])
        {
            Caption = 'EFRIS Upload Error Code';
            Editable = false;
        }
        field(70615594; "ASL.EFRIS.UploadErrorMessage"; Text[255])
        {
            Caption = 'EFRIS Upload Error Message';
            Editable = false;
        }
        field(70615595; "ASL.EFRIS.UploadErrorAction"; Enum "ASL.EFRIS.UploadErrorAction")
        {
            Caption = 'EFRIS Upload Error Action';
            Editable = false;
        }
        field(70615596; "ASL.EFRIS.InvoiceId"; Code[20])
        {
            Caption = 'EFRIS Invoice Id';
            Editable = false;
        }
        field(70615597; "ASL.EFRIS.InvoiceNo"; Code[20])
        {
            Caption = 'EFRIS Invoice No.';
            Editable = false;
        }
        field(70615598; "ASL.EFRIS.Antifakecode"; Code[25])
        {
            Caption = 'EFRIS Antifake code';
            Editable = false;
        }
        field(70615599; "ASL.EFRIS.QRCode"; Text[255])
        {
            Caption = 'EFRIS QR Code';
            Editable = false;
        }
        field(70615585; "ASL.EFRIS.Remarks"; Text[150])
        {
            Caption = 'EFRIS Remarks';
            DataClassification = ToBeClassified;
        }
        field(70615588; "ASL.EFRIS.DeliveryTerms"; Enum "ASL.EFRIS.DeliveryTermsCodeDes")
        {
            Caption = 'Delivery Terms';
            DataClassification = ToBeClassified;
        }
    }
}
