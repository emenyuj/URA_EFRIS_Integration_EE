page 50033 "Deemed Projects"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ASL.EFRIS.VatProjects";
    Editable = True;
    DataCaptionFields = projectId, projectName, customerNo, CustomerTIN;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(customerNo; Rec.customerNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the customerNo field.';
                }
                field(CustomerTIN; Rec.CustomerTIN)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CustomerTIN field.';
                }
                field(projectId; Rec.projectId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the projectId field.';
                }
                field(projectName; Rec.projectName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the projectName field.';
                }
                field(unit; Rec.unit)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the unit field.';
                }
                field(commodityCategoryCode; Rec.commodityCategoryCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the commodityCategoryCode field.';
                }
                field(currentQty; Rec.currentQty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the currentQty field.';
                }
                field(currentAmount; Rec.currentAmount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the currentAmount field.';
                }
                field(deemedExemptCode; Rec.deemedExemptCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the deemedExemptCode field.';
                }
                field(serviceMark; Rec.serviceMark)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the serviceMark field.';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}