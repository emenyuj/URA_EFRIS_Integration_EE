page 50009 "ASL.EFRIS.CommodityCategories"
{
    ApplicationArea = Basic, Suite;
    CaptionML = ENU = 'EFRIS Commodity Categories';
    PageType = List;
    SourceTable = "ASL.EFRIS.CommodityCategory";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;

                field("Code"; Rec."Code")
                {
                    Style = Strong;
                    StyleExpr = CodeEmphasize;
                    ApplicationArea = All;
                }
                field(Name; Rec."Name")
                {
                    Style = Strong;
                    StyleExpr = NameEmphasize;
                    ApplicationArea = All;
                }
                field(IsZerorated; Rec.Rate)
                {
                    ApplicationArea = All;
                }
                field("Is Exempt"; Rec.Exempt)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Update)
            {
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    UpdateCommodityCategories();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        CodeEmphasize := not Rec.Leaf;
        NameIndent := Rec.Level;
        NameEmphasize := not Rec.Leaf;
    end;

    var
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        [InDataSet]
        CodeEmphasize: Boolean;
        [InDataSet]
        NameEmphasize: Boolean;
        [InDataSet]
        NameIndent: Integer;
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Pages    #1###############\';
        ProgressDialogTextLine2: Label 'Records  #2###############';
        MsgCommodityCategoriesUptoDate: TextConst ENU = 'EFRIS Commodity categories Up to date';
        ErrCmdtCategoryUpdate: TextConst ENU = 'Commodity Category update failed. %1';

    local procedure UpdateCommodityCategories()
    var
        CommodityCategoryVersion: Code[15];
        EFRISCommodityCategoryVersion: Code[15];
        CommodityCategoryRespToken: JsonToken;
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
        PageSize: Integer;
        TotalPages: Integer;
        P: Integer;
        SelectToken: JsonToken;
        Success: Boolean;
        RecordsArray: JsonArray;
    begin
        EFRISIntegrationSetup.Get();
        CommodityCategoryVersion := EFRISIntegrationSetup."ASL.EFRIS.CmdtyCategoryVersion";
        EFRISCommodityCategoryVersion := EFRISInterface.GetCommodityCategoryVersion();
        // if commodity categories up to date, exit
        if (CommodityCategoryVersion <> '') and (CommodityCategoryVersion = EFRISCommodityCategoryVersion) then begin
            Message(MsgCommodityCategoriesUptoDate);
            exit;
        end;
        if (CommodityCategoryVersion = '') then begin
            // no local version. get all
            P := 1;
            PageSize := 500;
            Success := EFRISInterface.GetCommodityCategories(P, PageSize, CommodityCategoryRespToken);
            if Success then begin
                if CommodityCategoryRespToken.SelectToken('page.pageCount', SelectToken) then begin
                    ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
                    TotalPages := SelectToken.AsValue().AsInteger();
                    repeat
                        ProgressDialog.Update(1, StrSubstNo('%1 of %2', P, TotalPages));
                        if CommodityCategoryRespToken.SelectToken('records', SelectToken) then RecordsArray := SelectToken.AsArray();
                        UpdateCommodityCategories(RecordsArray);
                        P += 1;
                        if P <= TotalPages then begin
                            // get next page
                            Success := EFRISInterface.GetCommodityCategories(P, PageSize, CommodityCategoryRespToken);
                        end;
                    until (P > TotalPages) or (not Success);
                end;
            end;
            if Success then begin
                EFRISIntegrationSetup."ASL.EFRIS.CmdtyCategoryVersion" := EFRISCommodityCategoryVersion;
                EFRISIntegrationSetup.Modify();
            end
            else
                Error(ErrCmdtCategoryUpdate, EFRISInterface.GetLastErrorMessage());
        end
        else begin
            // get updated since local version
            if not EFRISInterface.GetUpdatedCommodityCategories(CommodityCategoryVersion, RecordsArray) then Error(ErrCmdtCategoryUpdate, EFRISInterface.GetLastErrorMessage());
            ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
            ProgressDialog.Update(1, '1 of 1');
            UpdateCommodityCategories(RecordsArray);
            EFRISIntegrationSetup."ASL.EFRIS.CmdtyCategoryVersion" := EFRISCommodityCategoryVersion;
            EFRISIntegrationSetup.Modify();
        end;
    end;

    local procedure UpdateCommodityCategories(var RecordsArray: JsonArray)
    var
        I: Integer;
        RecordCount: Integer;
        CmdtCategoryRecord: JsonObject;
        CmdtCategoryCode: Code[20];
        Exists: Boolean;
        SelectToken: JsonToken;
        CommodityCategory: Record "ASL.EFRIS.CommodityCategory";
    begin
        RecordCount := RecordsArray.Count;
        if RecordCount > 0 then begin
            I := 0;
            repeat
                ProgressDialog.Update(2, StrSubstNo('%1 of %2', I + 1, RecordCount));
                RecordsArray.Get(I, SelectToken);
                CmdtCategoryRecord := SelectToken.AsObject();
                if CmdtCategoryRecord.SelectToken('commodityCategoryCode', SelectToken) then begin
                    CmdtCategoryCode := SelectToken.AsValue().AsText();
                    Exists := CommodityCategory.Get(CmdtCategoryCode);
                    if not Exists then begin
                        CommodityCategory.Init();
                        CommodityCategory.Code := CmdtCategoryCode;
                    end;
                    if CmdtCategoryRecord.SelectToken('commodityCategoryName', SelectToken) then CommodityCategory.Name := CopyStr(SelectToken.AsValue().AsText(), 1, 100);
                    if CmdtCategoryRecord.SelectToken('parentCode', SelectToken) then CommodityCategory.Parent := SelectToken.AsValue().AsText();
                    if CmdtCategoryRecord.SelectToken('rate', SelectToken) then CommodityCategory.Rate := SelectToken.AsValue().AsDecimal();
                    if CmdtCategoryRecord.SelectToken('isZeroRate', SelectToken) then begin
                        case SelectToken.AsValue().AsInteger() of
                            101:
                                CommodityCategory.ZeroRated := true;
                            102:
                                CommodityCategory.ZeroRated := false;
                        end;
                    end;
                    if CmdtCategoryRecord.SelectToken('zeroRateStartDate', SelectToken) then CommodityCategory.ZeroRatedStartDate := SelectToken.AsValue().AsText();
                    if CmdtCategoryRecord.SelectToken('zeroRateEndDate', SelectToken) then CommodityCategory.ZeroRatedEndDate := SelectToken.AsValue().AsText();
                    if CmdtCategoryRecord.SelectToken('isExempt', SelectToken) then begin
                        case SelectToken.AsValue().AsInteger() of
                            101:
                                CommodityCategory.Exempt := true;
                            102:
                                CommodityCategory.Exempt := false;
                        end;
                    end;
                    if CmdtCategoryRecord.SelectToken('exemptRateStartDate', SelectToken) then CommodityCategory.ExemptStartDate := SelectToken.AsValue().AsText();
                    if CmdtCategoryRecord.SelectToken('exemptRateEndDate', SelectToken) then CommodityCategory.ExemptEndDate := SelectToken.AsValue().AsText();
                    if CmdtCategoryRecord.SelectToken('exclusion', SelectToken) then begin
                        case SelectToken.AsValue().AsInteger() of
                            0:
                                CommodityCategory.Exclusion := CommodityCategory.Exclusion::Zero;
                            1:
                                CommodityCategory.Exclusion := CommodityCategory.Exclusion::Exempt;
                            2:
                                CommodityCategory.Exclusion := CommodityCategory.Exclusion::"No Exclusion";
                            3:
                                CommodityCategory.Exclusion := CommodityCategory.Exclusion::Both;
                        end;
                    end;
                    if CmdtCategoryRecord.SelectToken('serviceMark', SelectToken) then begin
                        case SelectToken.AsValue().AsInteger() of
                            101:
                                CommodityCategory.Service := true;
                            102:
                                CommodityCategory.Service := false;
                        end;
                    end;
                    if CmdtCategoryRecord.SelectToken('enableStatusCode', SelectToken) then CommodityCategory.Enabled := SelectToken.AsValue().AsInteger() = 1;
                    if CmdtCategoryRecord.SelectToken('commodityCategoryLevel', SelectToken) then CommodityCategory.Level := SelectToken.AsValue().AsInteger();
                    if CmdtCategoryRecord.SelectToken('isLeafNode', SelectToken) then begin
                        case SelectToken.AsValue().AsInteger() of
                            101:
                                CommodityCategory.Leaf := true;
                            102:
                                CommodityCategory.Leaf := false;
                        end;
                    end;
                    if Exists then
                        CommodityCategory.Modify()
                    else
                        CommodityCategory.Insert();
                end;
                I += 1;
            until I = RecordCount;
        end;
    end;
}
