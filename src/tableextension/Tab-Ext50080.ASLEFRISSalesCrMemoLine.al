tableextension 50080 "ASL.EFRIS.SalesCrMemoLine" extends "Sales Cr.Memo Line"
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
            Caption = 'Project ID';
            Editable = false;
        }
        field(70615592; ProjectName; Text[150])
        {
            Caption = 'Project Name';
            Editable = false;
        }
        field(70615593; ProjectUnit; Text[150])
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
