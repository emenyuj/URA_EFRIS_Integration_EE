page 50032 "ASL.EFRIS.InterfaceTest"
{
    PageType = Card;
    Caption = 'EFRIS Interface Test';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(InterfaceCode; InterfaceCode)
                {
                    Caption = 'Interface Code';

                    trigger OnValidate()
                    var
                        EFRISSetup: Record "Sales & Receivables Setup";
                        CR: Char;
                        LF: Char;
                        CRLF: Text;
                    begin
                        EFRISSetup.Get();
                        CR := 13;
                        LF := 10;
                        CRLF := Format(CR, 0) + Format(LF, 0);
                        case InterfaceCode of
                            InterfaceCode::T119:
                                begin
                                    RequestContent := '{' + CRLF + '    "tin": "' + EFRISSetup."ASL.EFRIS.TIN" + '",' + CRLF + '    "ninBrn": ""' + CRLF + '}';
                                end;
                            InterfaceCode::T124:
                                begin
                                    RequestContent := '{' + CRLF + '    "pageNo": "1",' + CRLF + '    "pageSize": "100"' + CRLF + '}';
                                end;
                            InterfaceCode::T134:
                                begin
                                    RequestContent := '{' + CRLF + '    "commodityCategoryVersion": "' + EFRISInterface.GetCommodityCategoryVersion() + '"' + CRLF + '}';
                                end;
                            else begin
                                    RequestContent := '';
                                end;
                        end;
                        FillRequestContent();
                    end;
                }
            }
            group(RequestContent)
            {
                usercontrol(UserCtrlRequestContent;
                "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FillRequestContent();
                    end;

                    trigger Callback(data: Text)
                    begin
                        RequestContent := data;
                    end;
                }
            }
            group(ResponseContent)
            {
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
            action(Send)
            {
                ApplicationArea = All;
                Promoted = true;
                Image = SendTo;

                trigger OnAction()
                var
                    Request: JsonObject;
                    Response: JsonToken;
                    Success: Boolean;
                begin
                    ResponseContent := '';
                    if RequestContent <> '' then Request.ReadFrom(RequestContent);
                    Success := EFRISInterface.SendInterfaceRequest(InterfaceCode, Request.AsToken(), Response);
                    if Success then begin
                        Response.WriteTo(ResponseContent);
                        FillResponseContent();
                    end
                    else begin
                        Error(StrSubstNo('EFRIS Interface Request Error: %1', EFRISInterface.GetLastErrorMessage()));
                    end;
                end;
            }
        }
    }
    var
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        InterfaceCode: Enum "ASL.EFRIS.InterfaceCode";
        RequestContent: Text;
        ResponseContent: Text;

    local procedure FillRequestContent()
    begin
        CurrPage.UserCtrlRequestContent.SetContent(StrSubstNo('<textarea Id="TxtRequestContent" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TxtRequestContent'').value)">%1</textarea>', RequestContent, MaxStrLen(RequestContent)));
    end;

    local procedure FillResponseContent()
    begin
        CurrPage.UserCtrlResponseContent.SetContent(StrSubstNo('<textarea Id="TxtResponseContent" maxlength="%2" style="width:100%;height:100%;resize: none; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TxtResponseContent'').value)">%1</textarea>', ResponseContent, MaxStrLen(ResponseContent)));
    end;
}
