tableextension 50075 "ASL.EFRIS.Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(70615583; "ASL.EFRIS.RefundReasonCode"; Enum "ASL.EFRIS.RefundReasonCode")
        {
            Caption = 'EFRIS RefundReasonCode';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615584; "ASL.EFRIS.RefundReason"; Text[150])
        {
            Caption = 'EFRIS Refund Reason';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615585; "ASL.EFRIS.Remarks"; Text[150])
        {
            Caption = 'EFRIS Remarks';
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
        field(70615588; "ASL.EFRIS.DeliveryTerms"; Enum "ASL.EFRIS.DeliveryTermsCodeDes")
        {
            Caption = 'Delivery Terms';
            DataClassification = ToBeClassified;
        }
        field(70615591; "ASL.EFRIS.CancelReasonCode"; Enum "ASL.EFRIS.CrNtCancelReasonCode")
        {
            Caption = 'EFRIS Cancel Reason Code';
            DataClassification = ToBeClassified;
        }
        field(70615592; "ASL.EFRIS.CancelOtherReason"; Text[150])
        {
            Caption = 'EFRIS Cancel Other Reason';
            DataClassification = ToBeClassified;
        }
        field(70615593; "ASL.EFRIS.UploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Upload Status';
            Editable = false;
        }
        field(70615594; "ASL.EFRIS.UploadErrorCode"; Code[10])
        {
            Caption = 'EFRIS Upload Error Code';
            Editable = false;
        }
        field(70615595; "ASL.EFRIS.UploadErrorMessage"; Text[255])
        {
            Caption = 'EFRIS Upload Error Message';
            Editable = false;
        }
        field(70615596; "ASL.EFRIS.UploadErrorAction"; Enum "ASL.EFRIS.UploadErrorAction")
        {
            Caption = 'EFRIS Upload Error Action';
        }
        field(70615597; "ASL.EFRIS.ReferenceNo"; Code[20])
        {
            Caption = 'EFRIS Reference No.';
            Editable = false;
        }
        field(70615598; "ASL.EFRIS.ApprovalStatus"; Enum "ASL.EFRIS.CrNtApplApprovStatus")
        {
            Caption = 'EFRIS Approval Status';
            Editable = false;
        }
        field(70615599; "ASL.EFRIS.InvoiceId"; Code[20])
        {
            Caption = 'EFRIS Invoice Id';
            Editable = false;
        }
        field(70615600; "ASL.EFRIS.InvoiceNo"; Code[20])
        {
            Caption = 'EFRIS Invoice No.';
            Editable = false;
        }
        field(70615601; "ASL.EFRIS.Antifakecode"; Code[25])
        {
            Caption = 'EFRIS Antifake code';
            Editable = false;
        }
        field(70615602; "ASL.EFRIS.QRCode"; Text[255])
        {
            Caption = 'EFRIS QR Code';
            Editable = false;
        }
    }
}
