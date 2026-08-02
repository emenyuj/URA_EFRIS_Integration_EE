report 50071 "ASL.EFRIS.DeleteLogEntries"
{
    Caption = 'Delete Log Entries';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field("Delete Earlier Than"; DeleteEarlierThan)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    var
        DeleteEarlierThan: Date;
        EFRISLog: Record "ASL.EFRIS.Log";
        ErrEarlierThanDateNotSet: TextConst ENU = 'You must specify the Delete Earlier Than Date.';
        CnfProceedWithDelete: TextConst ENU = 'Are you sure you want to delete all log entries earlier than %1';

    trigger OnPostReport()
    var
    begin
        if DeleteEarlierThan = 0D then Error(ErrEarlierThanDateNotSet);
        if not Confirm(CnfProceedWithDelete, false, DeleteEarlierThan) then exit;
        EFRISLog.Reset();
        EFRISLog.SetFilter(Time, StrSubstNo('<%1', DeleteEarlierThan));
        if EFRISLog.FindSet() then EFRISLog.DeleteAll();
    end;
}
