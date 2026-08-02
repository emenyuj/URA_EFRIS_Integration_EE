pageextension 50094 "ASL.EFRIS.CustomerCard" extends "Customer Card"
{
    layout
    {
        addafter(Invoicing)
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';

                field("ASL.EFRIS.LegalName"; Rec."ASL.EFRIS.LegalName")
                {
                    Caption = 'Legal Name';
                }
                field("ASL.EFRIS.BusinessName"; Rec."ASL.EFRIS.BusinessName")
                {
                    Caption = 'Business Name';
                }
                field("ASL.EFRIS.TIN"; Rec."ASL.EFRIS.TIN")
                {
                    Caption = 'TIN';
                }
                field("ASL.EFRIS.NINBRN"; Rec."ASL.EFRIS.NINBRN")
                {
                    Caption = 'NIN/BRN';
                }
                field("ASL.EFRIS.BuyerType"; Rec."ASL.EFRIS.BuyerType")
                {
                    Caption = 'EFRIS Buyer Type';
                }
                field("ASL.EFRIS.TaxPayerKind"; Rec."ASL.EFRIS.TaxPayerKind")
                {
                    ToolTip = 'Specifies the value of the Tax Payer Kind field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.Citizenship"; Rec."ASL.EFRIS.Citizenship")
                {
                    Caption = 'Citizenship';
                }
                field("ASL.EFRIS.PassportNo"; Rec."ASL.EFRIS.PassportNo")
                {
                    Caption = 'Passport No';
                }
                field("ASL.EFRIS.Sector"; Rec."ASL.EFRIS.Sector")
                {
                    Caption = 'Sector';
                }
                field("ASL.EFRIS.InvoiceIndustryCode"; Rec."ASL.EFRIS.InvoiceIndustryCode")
                {
                    ToolTip = 'Specifies the value of the Invoice Industry Code field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.InvoicePaymentMode"; Rec."ASL.EFRIS.InvoicePaymentMode")
                {
                    ToolTip = 'Specifies the value of the Invoice Payment Mode field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addafter("Prices and Discounts")
        {
            group(EFRIS)
            {
                Image = TaxSetup;

                action("Check Tax Payer Info")
                {
                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        TaxPayerInfo: JsonObject;
                        TaxPayerExemptInfo: JsonObject;
                        SelectToken: JsonToken;
                        TaxPayerType: Enum "ASL.EFRIS.TaxPayerType";
                        TaxExemptType: Enum "ASL.EFRIS.TaxExemptType";
                    begin
                        if Rec."ASL.EFRIS.TIN" = '' then
                            Error(ErrMissingTIN, Rec."No.")
                        else begin
                            EFRISInterface.GetTaxPayerExemptInfo(rec."ASL.EFRIS.TIN", TaxPayerExemptInfo);
                            if TaxPayerExemptInfo.SelectToken('taxpayerType', SelectToken) then TaxPayerType := Enum::"ASL.EFRIS.TaxPayerType".FromInteger(SelectToken.AsValue().AsInteger());
                            if TaxPayerExemptInfo.SelectToken('exemptType', SelectToken) then
                                TaxExemptType := Enum::"ASL.EFRIS.TaxExemptType".FromInteger(SelectToken.AsValue().AsInteger())
                            else
                                TaxExemptType := Enum::"ASL.EFRIS.TaxExemptType"::None;
                            Message(MsgTaxPayerTypeInfo, TaxPayerType, TaxExemptType);
                        end;
                    end;
                }
            }
        }
    }
    var
        ErrMissingTIN: TextConst ENU = 'TIN not specified for Customer No. %1';
        MsgTaxPayerTypeInfo: TextConst ENU = 'Tax Payer Type: %1, Tax Exempt Type: %2';
}
