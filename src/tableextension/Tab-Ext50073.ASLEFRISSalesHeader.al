tableextension 50073 "ASL.EFRIS.SalesHeader" extends "Sales Header"
{
    fields
    {
        field(70615581; "ASL.EFRIS.InvoiceIndustryCode"; Enum "ASL.EFRIS.InvoiceIndustryCode")
        {
            Caption = 'Invoice Industry Code';
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.PaymentMode"; Enum "ASL.EFRIS.PaymentMode")
        {
            Caption = 'EFRIS Payment Mode';
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.RefundReasonCode"; Enum "ASL.EFRIS.RefundReasonCode")
        {
            Caption = 'EFRIS Refund Reason Code';
            DataClassification = ToBeClassified;
        }
        field(70615584; "ASL.EFRIS.RefundReason"; Text[150])
        {
            Caption = 'EFRIS Refund Reason';
            DataClassification = ToBeClassified;
        }
        field(70615585; "ASL.EFRIS.Remarks"; Text[150])
        {
            Caption = 'EFRIS Remarks';
            DataClassification = ToBeClassified;
        }
        field(70615586; "ASL.EFRIS.VATDeemed"; Boolean)
        {
            Caption = 'VAT Deemed';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ASLEFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
            begin
                if Rec."ASL.EFRIS.VATDeemed" then
                    ASLEFRISInterface.UpdateDeemedProjectDetails(Rec);
            end;
        }
        field(70615587; "ASL.EFRIS.VATExempt"; Boolean)
        {
            Caption = 'VAT Exempt';
            DataClassification = ToBeClassified;
        }
        field(70615588; "ASL.EFRIS.DeliveryTerms"; Enum "ASL.EFRIS.DeliveryTermsCodeDes")
        {
            Caption = 'Delivery Terms';
            DataClassification = ToBeClassified;
        }
    }
}
