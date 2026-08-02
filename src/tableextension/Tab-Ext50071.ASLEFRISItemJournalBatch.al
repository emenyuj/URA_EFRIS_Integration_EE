tableextension 50071 "ASL.EFRIS.ItemJournalBatch" extends "Item Journal Batch"
{
    fields
    {
        field(70615581; "ASL.EFRIS.TransactionNo"; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.TransactionNoUsed"; Boolean)
        {
            Caption = 'Transaction No. Used';
            DataClassification = ToBeClassified;
        }
    }
}
