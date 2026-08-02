tableextension 50063 "ASL.EFRIS.Item" extends Item
{
    Caption = 'Item EFRIS Ext.';

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
        field(70615583; "ASL.EFRIS.PieceUnitOfMeasure"; Code[20])
        {
            Caption = 'EFRIS Piece Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                if "Base Unit of Measure" = '' then Error(ErrMissingBaseUnitOfMeasure);
                if "ASL.EFRIS.PieceUnitOfMeasure" = "Base Unit of Measure" then Error(ErrPieceUnitSameAsBaseUnit);
            end;
        }
        field(70615584; "ASL.EFRIS.UploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Upload Status';
            Editable = false;
        }
        field(70615585; "ASL.EFRIS.UploadErrorCode"; Code[10])
        {
            Caption = 'EFRIS Upload Error Code';
            Editable = false;
        }
        field(70615586; "ASL.EFRIS.UploadErrorMessage"; Text[255])
        {
            Caption = 'EFRIS Upload Error Message';
            Editable = false;
        }
        field(70615587; "ASL.EFRIS.UploadErrorAction"; Enum "ASL.EFRIS.UploadErrorAction")
        {
            Caption = 'EFRIS Upload Error Action';
            Editable = false;
        }
        field(70615588; "ASL.EFRIS.ItemId"; Text[20])
        {
            Caption = 'EFRIS Item Id';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70615589; "ASL.EFRIS.OpenInvUploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Opn. Inv. Upload Status';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615590; "ASL.EFRIS.OpenInvUploadTime"; DateTime)
        {
            Caption = 'EFRIS Opn. Inv. Upload Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70615591; "ASL.EFRIS.OpenInvUpldErrorCode"; Code[10])
        {
            Caption = 'EFRIS Opn. Inv. Upload Error Code';
            Editable = false;
        }
        field(70615592; "ASL.EFRIS.OpnInvUpldErrMessage"; Text[255])
        {
            Caption = 'EFRIS Opn. Inv. Upload Error Message';
            Editable = false;
        }
        field(70615593; "ASL.EFRIS.OpenInvUpldErrAction"; Enum "ASL.EFRIS.UploadErrorAction")
        {
            Caption = 'EFRIS Opn. Inv. Upload Error Action';
            Editable = false;
        }
    }
    var
        ErrMissingBaseUnitOfMeasure: TextConst ENU = 'Base Unit of Measure must be specified before Piece Unit of Measure';
        ErrPieceUnitSameAsBaseUnit: TextConst ENU = 'Piece Unit of Measure must not be the same as Base Unit of Measure';
        ErrCommodityCategoryNotLeaf: TextConst ENU = 'Commodity Category ''%1'' is  not a leas node';
}
