tableextension 50072 "ASL.EFRIS.ItemLdgEntry" extends "Item Ledger Entry"
{
    Caption = 'Item Ledger Entry EFRIS Ext.';

    fields
    {
        field(70615581; "ASL.EFRIS.JournalTemplateName"; Code[20])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(70615582; "ASL.EFRIS.JournalBatchName"; Code[20])
        {
            Caption = 'Journal Batch Name';
            Editable = false;
        }
        field(70615583; "ASL.EFRIS.TransactionNo"; Integer)
        {
            Caption = 'Transaction No.';
            Editable = false;
        }
        field(70615585; "ASL.EFRIS.UploadStatus"; Enum "ASL.EFRIS.UploadStatus")
        {
            Caption = 'EFRIS Upload Status';
            Editable = false;
        }
        field(70615587; "ASL.EFRIS.UploadErrorCode"; Code[10])
        {
            Caption = 'EFRIS Upload Error Code';
            Editable = false;
        }
        field(70615588; "ASL.EFRIS.UploadErrorMessage"; Text[255])
        {
            Caption = 'EFRIS Upload Error Message';
            Editable = false;
        }
        field(70615589; "ASL.EFRIS.UploadErrorAction"; Enum "ASL.EFRIS.UploadErrorAction")
        {
            Caption = 'EFRIS Upload Error Action';
        }
    }
}
