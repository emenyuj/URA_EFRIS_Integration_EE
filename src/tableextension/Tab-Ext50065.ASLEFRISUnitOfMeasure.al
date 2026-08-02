tableextension 50065 "ASL.EFRIS.UnitOfMeasure" extends "Unit of Measure"
{
    Caption = 'Unit of Measure EFRIS Ext.';

    fields
    {
        field(70615571; "ASL.EFRIS.EFRISUOMCode"; Code[20])
        {
            Caption = 'EFRIS U.o.M Code';
            DataClassification = ToBeClassified;
            TableRelation = "ASL.EFRIS.Unit".Code;

            trigger OnValidate()
            var
                EFRISUnitOfMeasure: Record "ASL.EFRIS.Unit";
            begin
                if EFRISUnitOfMeasure.Get("ASL.EFRIS.EFRISUOMCode") then "ASL.EFRIS.EFRISUOMDescription" := EFRISUnitOfMeasure.Description;
            end;
        }
        field(70615572; "ASL.EFRIS.EFRISUOMDescription"; Text[150])
        {
            Caption = 'EFRIS U.o.M Description';
            DataClassification = ToBeClassified;
        }
    }
    var
}
