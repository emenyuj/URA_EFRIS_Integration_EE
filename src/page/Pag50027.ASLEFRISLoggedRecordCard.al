page 50027 "ASL.EFRIS.LoggedRecordCard"
{
    Caption = 'Log Record Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(RequestContent)
            {
                Caption = 'Request Content';

                usercontrol(UserCtrlRequestContent;
                "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FillRequestContent();
                    end;

                    trigger Callback(data: Text)
                    begin
                        ResponseContent := data;
                    end;
                }
            }
            group(ResponseMessage)
            {
                Caption = 'Response Message';

                usercontrol(UserCtrlResponseMessage;
                "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FillResponseMessage();
                    end;

                    trigger Callback(data: Text)
                    begin
                        ResponseMessage := data;
                    end;
                }
            }
            group(ResponseContent)
            {
                Caption = 'Response Content';

                usercontrol(UserCtrlResponseContent;
                "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FillResponseContent();
                    end;

                    trigger Callback(data: Text)
                    begin
                        ResponseContent := data;
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                end;
            }
        }
    }
    var
        RequestContent: Text;
        ResponseMessage: Text;
        ResponseContent: Text;

    local procedure FillRequestContent()
    begin
        CurrPage.UserCtrlRequestContent.SetContent(StrSubstNo('<textarea Id="TxtResponseContent" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TxtResponseContent'').value)">%1</textarea>', RequestContent, MaxStrLen(RequestContent)));
    end;

    local procedure FillResponseMessage()
    begin
        CurrPage.UserCtrlResponseMessage.SetContent(StrSubstNo('<textarea Id="ResponseMessage" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TxtResponseMessage'').value)">%1</textarea>', ResponseMessage, MaxStrLen(ResponseMessage)));
    end;

    local procedure FillResponseContent()
    begin
        CurrPage.UserCtrlResponseContent.SetContent(StrSubstNo('<textarea Id="TxtResponseContent" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TxtResponseContent'').value)">%1</textarea>', ResponseContent, MaxStrLen(ResponseContent)));
    end;

    procedure SetLogged(HasRequestContent: Boolean;
    var RequestContentInStream: InStream;
    HasMessage: Boolean;
    var MessageInStream: Instream;
    HasResponseContent: Boolean;
    var ResponseContentInStream: Instream)
    var
        Buffer: Text[1048];
        N: Integer;
    begin
        RequestContent := '';
        if HasRequestContent then begin
            while not RequestContentInStream.EOS() do begin
                N := RequestContentInStream.ReadText(Buffer);
                RequestContent += CopyStr(Buffer, 1, N);
            end;
        end;
        ResponseMessage := '';
        if HasMessage then begin
            while not MessageInStream.EOS() do begin
                N := MessageInStream.ReadText(Buffer);
                ResponseMessage += CopyStr(Buffer, 1, N);
            end;
        end;
        ResponseContent := '';
        if HasResponseContent then begin
            while not ResponseContentInStream.EOS() do begin
                N := ResponseContentInStream.ReadText(Buffer);
                ResponseContent += CopyStr(Buffer, 1, N);
            end;
        end;
    end;
}
