pageextension 50121 "ASL.EFRIS.SalesOrderSubform" extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Shipment Date")
        {
            field(Deemed; Rec.Deemed)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field(ProjectID; Rec.ProjectID)
            {
                ApplicationArea = All;
                // Editable = false;
            }
            field(ProjectName; Rec.ProjectName)
            {
                ApplicationArea = All;
                // Editable = false;
            }
            field(ProjectUnit; Rec.ProjectUnit)
            {
                ApplicationArea = All;
                // Editable = false;
            }
            field("Total Weight"; Rec."Total Weight")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}