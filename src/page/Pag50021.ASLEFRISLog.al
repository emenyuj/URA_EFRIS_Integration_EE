page 50021 "ASL.EFRIS.Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ASL.EFRIS.Log";
    SourceTableView = sorting("Time") order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    Editable = false;
    Caption = 'EFRIS Log';
    Permissions = TableData "ASL.EFRIS.Log" = rd;

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("Time"; Rec.Time)
                {
                    ApplicationArea = All;
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field(RequestInterfaceCode; Rec.RequestInterfaceCode)
                {
                    Caption = 'Interface Code';
                    ApplicationArea = All;
                }
                field(ResponseCode; Rec.ResponseCode)
                {
                    Caption = 'Response Code';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewDetails)
            {
                Caption = 'View Details';
                ApplicationArea = All;
                Image = ViewDetails;

                trigger OnAction()
                var
                    LoggedResponse: Page "ASL.EFRIS.LoggedRecordCard";
                    HasRequestContent: Boolean;
                    RequestContentInstream: InStream;
                    HasMessage: Boolean;
                    MessageInStream: Instream;
                    HasResponseContent: Boolean;
                    ResponseContentInstream: InStream;
                begin
                    Clear(RequestContentInstream);
                    Clear(MessageInStream);
                    Clear(ResponseContentInstream);
                    Clear(LoggedResponse);
                    if Rec.RequestContent.HasValue then begin
                        HasRequestContent := true;
                        Rec.CalcFields(Rec.RequestContent);
                        Rec.RequestContent.CreateInStream(RequestContentInstream);
                    end;
                    if Rec.ResponseMessage.HasValue then begin
                        HasMessage := true;
                        Rec.CalcFields(Rec.ResponseMessage);
                        Rec.ResponseMessage.CreateInStream(MessageInStream);
                    end;
                    if Rec.ResponseContent.HasValue then begin
                        HasResponseContent := true;
                        Rec.CalcFields(Rec.ResponseContent);
                        Rec.ResponseContent.CreateInStream(ResponseContentInstream);
                    end;
                    LoggedResponse.SetLogged(HasRequestContent, RequestContentInstream, HasMessage, MessageInStream, HasResponseContent, ResponseContentInstream);
                    LoggedResponse.Editable := false;
                    LoggedResponse.RunModal();
                end;
            }
            action(DeleteLogs)
            {
                Caption = 'Delete Log Entries';
                Image = DeleteRow;
                RunObject = report "ASL.EFRIS.DeleteLogEntries";
            }
        }
    }
}
