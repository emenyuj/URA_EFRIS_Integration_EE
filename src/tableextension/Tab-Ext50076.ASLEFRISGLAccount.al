tableextension 50076 "ASL.EFRIS.GLAccount" extends "G/L Account"
{
    fields
    {
        field(70615581; "ASL.EFRIS.CmdtCategoryCode"; Code[20])
        {
            Caption = 'EFRIS Commodity Category Code';
            DataClassification = ToBeClassified;
            TableRelation = "ASL.EFRIS.CommodityCategory".Code;

            trigger OnValidate()
            var
                EFRISCommodityCategory: Record "ASL.EFRIS.CommodityCategory";
            begin
                EFRISCommodityCategory.Get("ASL.EFRIS.CmdtCategoryCode");
                if not EFRISCommodityCategory.Leaf then Error(ErrCommodityCategoryNotLeaf, "ASL.EFRIS.CmdtCategoryCode");
                "ASL.EFRIS.CmdtCategoryName" := EFRISCommodityCategory.Name;
            end;
        }
        field(70615582; "ASL.EFRIS.CmdtCategoryName"; Text[150])
        {
            Caption = 'EFRIS Commodity Category Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.UnitOfMeasure"; Code[20])
        {
            Caption = 'Unit Of Measure';
            TableRelation = "Unit of Measure".Code;
            DataClassification = ToBeClassified;
        }
        field(70615584; "ASL.EFRIS.UnitPrice"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = ToBeClassified;
        }
        field(70615585; "ASL.EFRIS.UploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Upload Status';
            Editable = false;
        }
        field(70615586; "ASL.EFRIS.UploadErrorCode"; Code[10])
        {
            Caption = 'EFRIS Upload Error Code';
            Editable = false;
        }
        field(70615587; "ASL.EFRIS.UploadErrorMessage"; Text[255])
        {
            Caption = 'EFRIS Upload Error Message';
            Editable = false;
        }
        field(70615588; "ASL.EFRIS.ProductId"; Text[20])
        {
            Caption = 'EFRIS Product Id';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    var
        ErrCommodityCategoryNotLeaf: TextConst ENU = 'Commodity Category ''%1'' is  not a leas node';
}
