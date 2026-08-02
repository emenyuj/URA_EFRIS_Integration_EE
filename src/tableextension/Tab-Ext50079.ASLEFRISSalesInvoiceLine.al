/// <summary>
/// TableExtension ASL.EFRIS.SalesLine (ID 70615600) extends Record Sales Line.
/// </summary>
tableextension 50079 "ASL.EFRIS.SalesInvoiceLine" extends "Sales Invoice Line"
{
    fields
    {
        field(70615581; ExiseDuty; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.ExciseDutyRate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.LineAmtExcl.Excise"; Decimal)
        {
            Caption = 'Line Amount Excl. Excise';
        }
        field(70615584; "ASL.EFRIS.DisctAmt.Excl.Excise"; Decimal)
        {
            Caption = 'Discount Amount Excl. Excise';
        }
        field(70615585; "ASL.EFRIS.DisctPer.Excl.Excise"; Decimal)
        {
            Caption = 'Discount Excise Percentage';
        }
        field(70615586; "ASL.EFRIS.UnitPrice.ExclExcise"; Decimal)
        {
            Caption = 'Unit Price Excl. Excise';
            DecimalPlaces = 2 : 6;
        }
        field(70615590; Deemed; Boolean)
        {
            Caption = 'Deemed';
            Editable = false;
        }
        field(70615591; ProjectID; Text[100])
        {
            Caption = 'VAT Project ID';
            Editable = false;
            // TableRelation = "ASL.EFRIS.VatProjects".projectId;
        }
        field(70615592; ProjectName; Text[250])
        {
            Caption = 'VAT Project Name';
            Editable = false;
        }
        field(70615593; ProjectUnit; Text[250])
        {
            Caption = 'Project Unit';
            Editable = false;
        }
        field(70615594; deemedExemptCode; Text[150])
        {
            Caption = 'Project Unit';
            Editable = false;
        }
        field(50012; "Order Number"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50013; Mapped; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50014; "Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50215; "Piece Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
