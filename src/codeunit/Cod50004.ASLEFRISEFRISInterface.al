codeunit 50004 "ASL.EFRIS.EFRISInterface"
{
    TableNo = 18;
    Permissions = TableData Item = rm,
    TableData "Item Ledger Entry" = rm,
    TableData "Purch. Inv. Header" = rm,
    TableData "Purch. Inv. Line" = rm,
    TableData "Sales Invoice Header" = rm,
    TableData "Sales Invoice Line" = rm,
    tabledata "ASL.EFRIS.CommodityCategory" = rimd,
    tabledata "ASL.EFRIS.Log" = rim,
    tabledata "ASL.EFRIS.ComdtCatTaxPayerType" = rim,
    tabledata "ASL.EFRIS.VatProjects" = rim;

    var
        LastErrorMessage: Text;
        // TCS
        LastReturnStateCode: Text[10];
        LastReturnStateMessage: Text;
        // http
        JsonHttpHandler: Codeunit "ASL.Http.HttpHandler";
        LastHttpSuccess: Boolean;
        LastHttpStatusCode: Integer;
        LastHttpReasonPhrase: Text;
        LastHttpIsBlockedByEnvironment: Boolean;
        UnknownErrorMsg: TextConst ENU = 'An Unknown error has occured';
        ErrServerUrlNotSet: TextConst ENU = 'Server Url not set in EFRIS Integration Setup';
        ErrEFRISSetupNotFound: TextConst ENU = 'EFRIS Setup Not Found';
        ErrMissingEFRISDeviceNo: TextConst ENU = 'Device No. not set in EFRIS Integration Setup. Click on the GetTCSInfo action on the EFRIS Integration Setup page to complete setup';
        ErrMissingEFRISTIN: TextConst ENU = 'TIN not set in EFRIS Integration Setup. Click on the GetTCSInfo action on the EFRIS Integration Setup page to complete setup';
        ErrSetupMissingLegalName: TextConst ENU = 'Legal Name not set in EFRIS Integration Setup. Click on the GetTCSInfo action on the EFRIS Integration Setup page to complete setup';
        ErrSetupMissingBusinessName: TextConst ENU = 'Business Name not set in EFRIS Integration Setup. Click on the GetTCSInfo action on the EFRIS Integration Setup page to complete setup';
        ErrSetupMissingEmail: TextConst ENU = 'Email not set in EFRIS Integration Setup';
        ErrHttp: TextConst ENU = 'Http Error %1:%2'; // <StatusCode>:<ReasonPhrase>
        TCSHttp: TextConst ENU = 'EFRIS API Error %1:%2'; // <StatusCode>:<ReasonPhrase>
        ErrSetupMissingDeviceNo: TextConst ENU = 'Device No. Not set in EFRIS Integration Setup. \Invoke ''Get TCS Info'' Action on EFRIS Integration Setup Page';
        ErrGetDeviceNoFailed: TextConst ENU = 'GetDeviceNo call Failed.';
        ErrSetupMissingTIN: TextConst ENU = 'TIN not specified in EFRIS Integration Setup';
        ErrIntegrationStartDateNotSet: TextConst ENU = 'Integration Start Date not specified in EFRIS Integration Setup';
        ErrPstngDateB4IntgrStartDate: TextConst ENU = 'Posting Date must not be befor Integration Start Date';
        ErrMissingEFRISCurrencyCode: TextConst ENU = 'EFRIS Currency Code not specified for Currency %1';
        ErrMissingLCYEFRISCurrencyCode: TextConst ENU = 'EFRIS Currency Code for LCY not specified in EFRIS Integration Setup';
        ErrItemNotUploadedToEFRIS: TextConst ENU = 'Item %1 not uploaded to EFRIS';
        ErrItemsUploadFailed: TextConst ENU = 'Some Items failed to upload. Check Items upload log for details';
        ErrItemMissingBaseUOM: TextConst ENU = 'Base Unit of Measure not specified for Item %1';
        ErrItemMissingSalesUOM: TextConst ENU = 'Sales Unit of Measure not specified for Item %1';
        ErrEFRISUOMNotMapped: TextConst ENU = 'EFRIS Unit of Measure not mapped for Unit of Measure ''%1''';
        ErrMissingPieceUOM: TextConst ENU = 'EFRIS Piece Unit of Measure not specified for Item %1';
        ErrItemMissingUnitPrice: TextConst ENU = 'Unit Price not specified for Item %1';
        ErrNoMatchingItemLedgerEntries: TextConst ENU = 'No matching Unposted EFRIS item ledger entries found';
        ErrSomeInventoryUploadFailed: TextConst ENU = 'Upload of some inventory entries failed. Check inventory logs for details';
        ErrPchInvEFRISItemLinesNotFound: TextConst ENU = 'No Unposted EFRIS Item lines found in Purchase Invoice %1';
        ErrVendorMissingTIN: TextConst ENU = 'TIN not specified for Vendor No. %1';
        MsgSomePurchLinesUploadFailed: TextConst ENU = 'Upload of some lines of Purchase Invoice %1 failed. Check logs for details';
        ErrPchInvPostDateAfterIntgStartDate: TextConst ENU = 'Posting Date for Invoice No. %1 is after EFRIS Integration Start Date';
        ErrB2BGCustNoTIN: TextConst ENU = 'TIN not specified fo B2B/B2G Customer No. %1';
        ErrMissingPaymentMode: TextConst ENU = 'EFRIS Payment Mode not specified for Invoice No. %1 and no default in EFRIS Integration Setup';
        ErrMissingInvIndustryCode: TextConst ENU = 'Invoice Industry Code not specified for neither Invoice nor Customer and default not specified in EFRIS Integration Setup';
        ErrMissingCrMemoCancelReasonCode: TextConst ENU = 'Cancel Reason Code not specified for Credit Memo %1';
        ErrMissingCrMemoCancelOtherReason: TextConst ENU = 'Cancel Reason not specified for Credit Memo %1 with Cancel Reaon Code: ''Other Reasons''';
        ErrMissingCrMemoInvApplCatCode: TextConst ENU = 'Invoice Apply Category Code for Credit Memo %1';
        ErrInvNoLines: TextConst ENU = 'No Invoice Lines';
        ErrCrMemoAlreadyToEFRIS: TextConst ENU = 'Credit Memo No. %1 Already sent to EFRIS';
        ErrCrMemoNotApplied: TextConst ENU = 'Credit Memo Not Applied to Invoice';
        ErrCrMemoAppliedInvNotToEFRIS: TextConst ENU = 'Applied to Invoice %1 not posted to EFRIS';
        ErrCrMemoCurrencyNotInvCurrency: TextConst ENU = 'Credit Note Currency (%1) must be the same as the currency on applied to invoice (No. %2. Currency: %3)';
        ErrCrMemoNoLines: TextConst ENU = 'No Credit Memo Lines';
        ErrCrMemoGetInvDetailsFailed: TextConst ENU = 'Failed to Get Valid EFRIS Invoice Details for Credit Memo %1';
        ErrCrMemoItemNotInApplInvoice: TextConst ENU = 'Item Code %1 not found in applied to invoice No. %2';
        ErrCrMemoSyncNoRefNo: TextConst ENU = 'Credit Memo No. %1 does not have an EFRIS Reference No.';
        ErrCrMemoVoidProcessed: TextConst ENU = 'You can only void Credit Notes before approval/rejection';
        ErrCrMemoNotSentToEFRIS: TextConst ENU = 'Credit Memo. %1 Not yet sent to EFRIS';
        ErrUnsupportedEFRISInvoiceLineType: TextConst ENU = 'Unsupported Line Type %1 for EFRIS Sales Invoice';
        ErrLineItemNotEFRISProduct: TextConst ENU = '%1 No. %2 not yet configured as an EFRIS Product';
        ProgressDialog: Dialog;
        ProgressDialogTextLine1: Label 'Document Type  #1###############\';
        ProgressDialogTextLine2: Label 'Document No.   #2###############';
        // ---------------------------- TCS Utils -------------------------------------------------------

        EventHanler: Codeunit "ASL.EFRIS.EventHandlers";


    [TryFunction]
    procedure GetTCSInfo(var Response: JsonToken)
    var
        Request: JsonToken;
    begin
        if not SendRequest('/tcsInfo', "ASL.Http.HttpMethod"::GET, Request, Response) then Error(GetLastErrorText());
        if not LastHttpSuccess then Error(StrSubstNo(ErrHttp, LastHttpStatusCode, LastHttpReasonPhrase));
    end;

    procedure GetTaxPayerInfo(TIN: Code[20];
    var TaxPayerInfo: JsonObject)
    var
        Request: JsonObject;
        Response: JsonToken;
        SelectToken: JsonToken;
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        EFRISSetup.Get();
        Request.Add('tin', TIN);
        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T119, Request.AsToken(), Response) then Error(GetLastErrorMessage());
        Response.SelectToken('taxpayer', SelectToken);
        TaxPayerInfo := SelectToken.AsObject();
    end;

    procedure GetTaxPayerExemptInfo(TIN: Code[20];
    var TaxPayerExemptInfo: JsonObject)
    var
        Request: JsonObject;
        Response: JsonToken;
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        EFRISSetup.Get();
        Request.Add('tin', TIN);
        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T137, Request.AsToken(), Response) then Error(GetLastErrorMessage());
        TaxPayerExemptInfo := Response.AsObject();
    end;

    procedure IsTCSOnline(): Boolean
    var
        TCSInfo: JsonToken;
        OnlineStatus: JsonToken;
    begin
        if GetTCSInfo(TCSInfo) then begin
            if TCSInfo.SelectToken('onlineStatus', OnlineStatus) then exit(OnlineStatus.AsValue().AsBoolean());
        end
        else
            exit(false);
    end;

    procedure GetSysDictionaryVersion(): Text[20]
    var
        EmptyRequest: JsonObject;
        LoginResponse: JsonToken;
        Success: Boolean;
        DictionarVersion: JsonToken;
    begin
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T103, EmptyRequest.AsToken(), LoginResponse);
        if Success and (LoginResponse.SelectToken('dictionaryVersion', DictionarVersion)) then
            exit(DictionarVersion.AsValue().AsText())
        else
            Error(GetLastErrorMessage());
    end;

    procedure GetSystemDictionary(var SystemDictionary: JsonToken): Boolean
    var
        EmptyRequest: JsonObject;
    begin
        exit(SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T115, EmptyRequest.AsToken(), SystemDictionary));
    end;

    procedure GetCommodityCategoryVersion(): Text[20]
    var
        EmptyRequest: JsonObject;
        LoginResponse: JsonToken;
        Success: Boolean;
        CommodityCategoryVersion: JsonToken;
    begin
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T103, EmptyRequest.AsToken(), LoginResponse);
        if Success and (LoginResponse.SelectToken('commodityCategoryVersion', CommodityCategoryVersion)) then
            exit(CommodityCategoryVersion.AsValue().AsText())
        else
            Error(GetLastErrorMessage());
    end;

    procedure GetCommodityCategories(PageNo: Integer;
    PageSize: Integer;
    var CommodityCategoryResponse: JsonToken): Boolean
    var
        CommodityCategoryPageRequest: JsonObject;
    begin
        CommodityCategoryPageRequest.Add('pageNo', PageNo);
        CommodityCategoryPageRequest.Add('pageSize', PageSize);
        exit(SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T124, CommodityCategoryPageRequest.AsToken(), CommodityCategoryResponse));
    end;

    procedure GetCommodityCategoriesRecords(PageNo: Integer;
    PageSize: Integer;
    var CommodityCategories: JsonArray): Boolean
    var
        CommodityCategoryRespToken: JsonToken;
        SelectToken: JsonToken;
    begin
        if not GetCommodityCategories(PageNo, PageSize, CommodityCategoryRespToken) then exit(false);
        if CommodityCategoryRespToken.SelectToken('records', SelectToken) then CommodityCategories := SelectToken.AsArray();
        exit(true);
    end;

    procedure GetUpdatedCommodityCategories(CommodityCategoryVersion: Code[15];
    var CommodityCategories: JsonArray): Boolean
    var
        CommodityCategoryPageRequest: JsonObject;
        CommodityCategoryResponse: JsonToken;
    begin
        CommodityCategoryPageRequest.Add('commodityCategoryVersion', CommodityCategoryVersion);
        if not SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T134, CommodityCategoryPageRequest.AsToken(), CommodityCategoryResponse) then exit(false);
        CommodityCategories := CommodityCategoryResponse.AsArray();
        exit(true);
    end;

    procedure GetExchangeRate(EFRISCurrencyCode: Code[10];
    IssueDate: Date;
    var ExchRate: Decimal): Boolean
    var
        ExchangeRateRequest: JsonObject;
        ExchangeRateResponse: JsonToken;
        Rate: JsonToken;
    begin
        ExchangeRateRequest.Add('currency', EFRISCurrencyCode);
        ExchangeRateRequest.Add('issueDate', Format(IssueDate, 0, '<Year4>-<Month,2>-<Day,2>'));
        if not SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T121, ExchangeRateRequest.AsToken(), ExchangeRateResponse) then exit(false);
        ExchangeRateResponse.AsObject().Get('rate', Rate);
        ExchRate := Rate.AsValue().AsDecimal();
        exit(true);
    end;

    [TryFunction]
    local procedure GetLCYEFRISCurrencyCode(var CurrencyCode: Code[20])
    var
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
    begin
        // validate LCY EFRIS Currency mapping
        EFRISIntegrationSetup.Get();
        if EFRISIntegrationSetup."ASL.EFRIS.LCYEFRISCurrencyCode" = '' then begin
            Error(ErrMissingLCYEFRISCurrencyCode);
        end;
        CurrencyCode := EFRISIntegrationSetup."ASL.EFRIS.LCYEFRISCurrencyCode";
    end;

    procedure UploadItem(var UploadItem: Record Item;
    UpdateExisting: Boolean): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemsUploadRequest: JsonArray;
        EFRISCurrencyCode: Code[10];
        ItemUploadResponseToken: JsonToken;
        ItemUploadResponseArray: JsonArray;
        ItemUploadResponseItem: JsonToken;
        SelectToken: JsonToken;
        ResponseItemsCount: Integer;
        I: Integer;
        Now: DateTime;
        Success: Boolean;
        ItemUploadFailed: Boolean;
        FailedItemToken: JsonToken;
        RequestText: Text;
    begin
        LogTrace(StrSubstNo('Upload Item %1', UploadItem."No."));
        Now := CreateDateTime(Today, Time);
        // validate commodity category
        if UploadItem."ASL.EFRIS.CmdtCategoryCode" = '' then begin
            LastErrorMessage := StrSubstNo('EFRIS Commodity Category not specified for Item %1', UploadItem."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        // validate sales unit of measure        
        if UploadItem."Sales Unit of Measure" <> '' then begin
            UnitOfMeasure.Get(UploadItem."Sales Unit of Measure");
            if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then begin
                LastErrorMessage := StrSubstNo(ErrEFRISUOMNotMapped, UploadItem."Sales Unit of Measure");
                LogError(LastErrorMessage);
                exit(false);
            end;
            if UploadItem."Sales Unit of Measure" <> UploadItem."Base Unit of Measure" then begin
                // validate base unit of measure
                if UploadItem."Base Unit of Measure" <> '' then begin
                    UnitOfMeasure.Get(UploadItem."Base Unit of Measure");
                    if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then begin
                        LastErrorMessage := StrSubstNo(ErrEFRISUOMNotMapped, UploadItem."Base Unit of Measure");
                        LogError(LastErrorMessage);
                        exit(false);
                    end;
                end
                else begin
                    LastErrorMessage := StrSubstNo(ErrItemMissingBaseUOM, UploadItem."No.");
                    LogError(LastErrorMessage);
                    exit(false);
                end;
            end;
        end
        else begin
            LastErrorMessage := StrSubstNo(ErrItemMissingSalesUOM, UploadItem."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        // validate unit price
        if UploadItem."Unit Price" = 0 then begin
            // only upload items with unit price
            // TODO: Consider extended price functionality
            LastErrorMessage := StrSubstNo(ErrItemMissingUnitPrice, UploadItem."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        UnitOfMeasure.Get(UploadItem."Base Unit of Measure");
        if not AddUploadItem(UploadItem, UpdateExisting, EFRISCurrencyCode, UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ItemsUploadRequest) then exit(false);

        ItemsUploadRequest.WriteTo(RequestText);

        // Message(RequestText);
        // send request
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T130, ItemsUploadRequest.AsToken(), ItemUploadResponseToken);

        if not Success and (not LastHttpSuccess or (LastReturnStateCode <> '45')) then exit(false); // do not proceed if either http error or TCS error other than partial failure
        ItemUploadResponseArray := ItemUploadResponseToken.AsArray();
        ResponseItemsCount := ItemUploadResponseArray.Count;
        ItemUploadFailed := (ResponseItemsCount > 0) and (ItemUploadResponseArray.SelectToken('$[?(@.goodsCode == ''' + UploadItem."No." + ''')]', SelectToken));
        if ItemUploadFailed then begin
            UploadItem."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
            if SelectToken.SelectToken('returnCode', FailedItemToken) then UploadItem."ASL.EFRIS.UploadErrorCode" := FailedItemToken.AsValue().AsText();
            if SelectToken.SelectToken('returnMessage', FailedItemToken) then UploadItem."ASL.EFRIS.UploadErrorMessage" := CopyStr(FailedItemToken.AsValue().AsText(), 1, MaxStrLen(UploadItem."ASL.EFRIS.UploadErrorMessage"));
            UploadItem."ASL.EFRIS.UploadErrorAction" := "ASL.EFRIS.UploadErrorAction"::Skip;
        end
        else begin
            if not GetEFRISItemDetails(UploadItem) then UploadItem."ASL.EFRIS.UploadErrorMessage" := CopyStr(GetLastErrorText(), 1, MaxStrLen(UploadItem."ASL.EFRIS.UploadErrorMessage"));
        end;
        UploadItem.Modify();
        if ResponseItemsCount > 0 then begin // empty respons if all succeeded
            LastErrorMessage := ErrItemsUploadFailed;
            LogError(LastErrorMessage);
            exit(false);
        end
        else
            exit(true);


    end;

    [TryFunction]
    local procedure AddUploadItem(var Item: Record Item;
    UpdateExisting: Boolean;
    EFRISCurrencyCode: Code[10];
    EFRISUOMCode: Code[20];
    var ItemsUploadRequest: JsonArray)
    var
        UploadItemObject: JsonObject;
        OtherUnits: JsonArray;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        PieceUnitOfMeasure: Record "Item Unit of Measure";
        EFRISUnits: Record "ASL.EFRIS.Unit";
    begin
        if UpdateExisting then
            UploadItemObject.Add('operationType', '102') // update existing
        else
            UploadItemObject.Add('operationType', '101'); // new item
        UploadItemObject.Add('goodsCode', Item."No.");
        UploadItemObject.Add('goodsName', Item.Description);
        UploadItemObject.Add('measureUnit', EFRISUOMCode);
        if not GetLCYEFRISCurrencyCode(EFRISCurrencyCode) then Error(GetLastErrorText());
        UploadItemObject.Add('currency', EFRISCurrencyCode);
        if Item."Sales Unit of Measure" <> Item."Base Unit of Measure" then begin
            // unit price on item card is per sales unit
            // convert to base units equivalent
            ItemUnitOfMeasure.Reset();
            ItemUnitOfMeasure.SetRange(ItemUnitOfMeasure."Item No.", Item."No.");
            ItemUnitOfMeasure.SetRange(ItemUnitOfMeasure.Code, Item."Sales Unit of Measure");
            UploadItemObject.Add('unitPrice', Format(Round(Item."Unit Price" / ItemUnitOfMeasure."Qty. per Unit of Measure", 0.01, '<'), 0, 1));
        end
        else
            UploadItemObject.Add('unitPrice', Format(Item."Unit Price", 0, 1));
        UploadItemObject.Add('commodityCategoryId', Item."ASL.EFRIS.CmdtCategoryCode");
        UploadItemObject.Add('description', Item.Description);
        UploadItemObject.Add('stockPrewarning', Format(Item."Safety Stock Quantity"));
        // TODO: Look into Exise Duty
        UploadItemObject.Add('haveExciseTax', '102');
        UploadItemObject.Add('exciseDutyCode', '');
        // other units of measure
        ItemUnitOfMeasure.Reset();
        ItemUnitOfMeasure.SetRange(ItemUnitOfMeasure."Item No.", Item."No.");
        ItemUnitOfMeasure.SetFilter(ItemUnitOfMeasure.Code, '<>%1', Item."Base Unit of Measure");
        if ItemUnitOfMeasure.FindSet() then begin
            // check EFRIS Piece Unit
            if Item."ASL.EFRIS.PieceUnitOfMeasure" = '' then Error(ErrMissingPieceUOM, Item."No.");
            // validate piece unit of measure
            UnitOfMeasure.Get(Item."ASL.EFRIS.PieceUnitOfMeasure");
            if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then Error(StrSubstNo(ErrEFRISUOMNotMapped, UnitOfMeasure.Code));
            PieceUnitOfMeasure.Get(Item."No.", Item."ASL.EFRIS.PieceUnitOfMeasure");
            // TODO: What is pieceUnit for?
            UploadItemObject.Add('havePieceUnit', '101');
            UploadItemObject.Add('pieceMeasureUnit', UnitOfMeasure."ASL.EFRIS.EFRISUOMCode");
            UploadItemObject.Add('pieceUnitPrice', Format(Round(Item."Unit Price" * PieceUnitOfMeasure."Qty. per Unit of Measure", 0.01, '<'), 0, 1));
            UploadItemObject.Add('packageScaledValue', Format(PieceUnitOfMeasure."Qty. per Unit of Measure", 0, 1));
            UploadItemObject.Add('pieceScaledValue', '1');
            if ItemUnitOfMeasure.Count > 1 then
                UploadItemObject.Add('haveOtherUnit', '101')
            else
                UploadItemObject.Add('haveOtherUnit', '102');
            // add other units
            repeat // skip piece unit
                if ItemUnitOfMeasure.Code <> Item."ASL.EFRIS.PieceUnitOfMeasure" then begin
                    if not AddItemUnit(ItemUnitOfMeasure, Item."Unit Price", OtherUnits) then Error(GetLastErrorText()); // rethrow
                end;
            until ItemUnitOfMeasure.Next() = 0;
            UploadItemObject.Add('goodsOtherUnits', OtherUnits);
        end
        else begin
            // TODO: What is pieceUnit for?
            UploadItemObject.Add('havePieceUnit', '102');
            UploadItemObject.Add('pieceMeasureUnit', '');
            UploadItemObject.Add('pieceUnitPrice', '');
            UploadItemObject.Add('packageScaledValue', '');
            UploadItemObject.Add('pieceScaledValue', '');
            UploadItemObject.Add('haveOtherUnit', '102');
        end;
        ItemsUploadRequest.Add(UploadItemObject);
    end;

    [TryFunction]
    local procedure AddItemUnit(var ItemUnitOfMeasure: Record "Item Unit of Measure";
    BaseUnitPrice: Decimal;
    var OtherUnits: JsonArray)
    var
        ItemUnit: JsonObject;
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // validate unit of measure
        UnitOfMeasure.Get(ItemUnitOfMeasure.Code);
        if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then Error(StrSubstNo(ErrEFRISUOMNotMapped, ItemUnitOfMeasure.Code));
        ItemUnit.Add('otherUnit', UnitOfMeasure."ASL.EFRIS.EFRISUOMCode");
        ItemUnit.Add('otherPrice', Format(Round(BaseUnitPrice * ItemUnitOfMeasure."Qty. per Unit of Measure", 0.01, '<'), 0, 1));
        ItemUnit.Add('otherScaled', Format(ItemUnitOfMeasure."Qty. per Unit of Measure", 0, 1));
        ItemUnit.Add('packageScaled', '1');
        OtherUnits.Add(ItemUnit);
    end;

    procedure GetEFRISItemDetails(var Item: Record Item): Boolean
    var
        ResponseRecord: JsonObject;
        SelectToken: JsonToken;
    begin
        if not GetEFRISItemInfo(Item."No.", ResponseRecord) then exit(false);
        if ResponseRecord.SelectToken('id', SelectToken) then Item."ASL.EFRIS.ItemId" := SelectToken.AsValue().AsText();
        if ResponseRecord.SelectToken('commodityCategoryCode', SelectToken) then Item.Validate("ASL.EFRIS.CmdtCategoryCode", SelectToken.AsValue().AsText());
        Item."ASL.EFRIS.UploadStatus" := Item."ASL.EFRIS.UploadStatus"::Success;
        Item."ASL.EFRIS.UploadErrorCode" := '';
        Item."ASL.EFRIS.UploadErrorMessage" := '';
        Item."ASL.EFRIS.UploadErrorAction" := Item."ASL.EFRIS.UploadErrorAction"::" ";
        exit(true);
    end;

    local procedure GetEFRISItemInfo(ProductCode: Code[20];
    var ResponseRecord: JsonObject): Boolean
    var
        ItemInquiryRequest: JsonObject;
        ResponseToken: JsonToken;
        SelectToken: JsonToken;
        ResponseRecordsArray: JsonArray;
    begin
        ItemInquiryRequest.Add('goodsCode', ProductCode);
        if not SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T127, ItemInquiryRequest.AsToken(), ResponseToken) then exit(false);
        if ResponseToken.SelectToken('$.records', SelectToken) then begin
            ResponseRecordsArray := SelectToken.AsArray();
            if ResponseRecordsArray.Count <> 1 then begin
                LastErrorMessage := StrSubstNo('Product Code %1 not found on EFRIS', ProductCode);
                LogError(LastErrorMessage);
                exit(false);
            end;
            ResponseRecordsArray.Get(0, SelectToken);
            ResponseRecord := SelectToken.AsObject();
        end;
        exit(true);
    end;

    procedure PostOpeningStock(var Item: Record Item): Boolean
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        OpeningStockAsAtDate: Date;
        OpeningStockItem: Record Item;
        GoodsStockIn: JsonObject;
        StockMaintenanceRequest: JsonObject;
        StockMaintenanceLines: JsonArray;
        ResponseToken: JsonToken;
        StockMaintenanceResponse: JsonArray;
        UnitOfMeasure: Record "Unit of Measure";
        CompanyInfo: Record "Company Information";
        Success: Boolean;
        ItemUploadFailed: Boolean;
        StockUploadResponseArray: JsonArray;
        ResponseItemsCount: Integer;
        SelectToken: JsonToken;
        Now: DateTime;
        ResponseEntry: JsonObject;
    begin
        LogTrace(StrSubstNo('Post Opening Stock for Item %1', Item."No."));
        EFRISSetup.Get();
        if EFRISSetup."ASL.EFRIS.IntegrationStartDate" <> 0D then
            OpeningStockAsAtDate := CalcDate('-1D', EFRISSetup."ASL.EFRIS.IntegrationStartDate")
        else begin
            LastErrorMessage := ErrIntegrationStartDateNotSet;
            LogError(LastErrorMessage);
            exit(false);
        end;
        if not Item.FindFirst() then Error('No Items specified for opening stock posting');
        CompanyInfo.Get();
        GoodsStockIn.Add('operationType', '101'); // stock-in
        GoodsStockIn.Add('supplierName', CompanyInfo.Name);
        GoodsStockIn.Add('supplierTin', '');
        GoodsStockIn.Add('adjustType', '');
        GoodsStockIn.Add('remarks', 'Opening Stock');
        GoodsStockIn.Add('stockInDate', Format(OpeningStockAsAtDate, 0, '<Year4>-<Month,2>-<Day,2>'));
        GoodsStockIn.Add('stockInType', Format("ASL.EFRIS.StockinType"::"Opening Stock".AsInteger()));
        GoodsStockIn.Add('productionBatchNo', '');
        GoodsStockIn.Add('productionDate', '');
        GoodsStockIn.Add('branchId', '');
        GoodsStockIn.Add('invoiceNo', '');
        GoodsStockIn.Add('isCheckBatchNo', '');
        StockMaintenanceRequest.Add('goodsStockIn', GoodsStockIn);
        if Item."ASL.EFRIS.OpenInvUploadStatus" <> "ASL.EFRIS.UploadStatus"::Success then begin
            OpeningStockItem.Reset();
            OpeningStockItem.SetRange("No.", Item."No.");
            OpeningStockItem.SetFilter("Date Filter", StrSubstNo('..C%1', OpeningStockAsAtDate));
            if OpeningStockItem.FindFirst() then begin
                if OpeningStockItem."ASL.EFRIS.ItemId" = '' then begin
                    LastErrorMessage := StrSubstNo(ErrItemNotUploadedToEFRIS, UnitOfMeasure.Code);
                    LogError(LastErrorMessage);
                    exit(false);
                end;
                OpeningStockItem.CalcFields("Net Change");
                if OpeningStockItem."Net Change" > 0 then begin
                    // lines
                    UnitOfMeasure.Get(Item."Base Unit of Measure");
                    if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then begin
                        LastErrorMessage := StrSubstNo(ErrEFRISUOMNotMapped, UnitOfMeasure.Code);
                        LogError(LastErrorMessage);
                        exit(false);
                    end;
                    AddStockMaintenanceLine(StockMaintenanceLines, OpeningStockItem."No.", OpeningStockItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", OpeningStockItem."Net Change", OpeningStockItem."Unit Cost");
                end;
            end;
        end;
        if StockMaintenanceLines.Count = 0 then begin
            LastErrorMessage := 'No Inventory as of ' + Format(OpeningStockAsAtDate);
            LogError(LastErrorMessage);
            exit(false);
        end;
        StockMaintenanceRequest.Add('goodsStockInItem', StockMaintenanceLines);
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T131, StockMaintenanceRequest.AsToken(), ResponseToken);
        if not Success and (not LastHttpSuccess or (LastReturnStateCode <> '45')) then exit(false); // do not proceed if either http error or TCS error other than partial failure
        StockUploadResponseArray := ResponseToken.AsArray();
        ResponseItemsCount := StockUploadResponseArray.Count;
        Now := CreateDateTime(Today, Time());
        ItemUploadFailed := (ResponseItemsCount > 0) and (StockUploadResponseArray.SelectToken('$[?(@.goodsCode == ''' + Item."No." + ''')]', SelectToken));
        Item.Get(Item."No.");
        Item."ASL.EFRIS.OpenInvUploadTime" := Now;
        if ItemUploadFailed then begin
            ResponseEntry := SelectToken.AsObject();
            Item."ASL.EFRIS.OpenInvUploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
            if ResponseEntry.SelectToken('returnCode', SelectToken) then Item."ASL.EFRIS.OpenInvUpldErrorCode" := SelectToken.AsValue().AsText();
            if ResponseEntry.SelectToken('returnMessage', SelectToken) then Item."ASL.EFRIS.OpnInvUpldErrMessage" := SelectToken.AsValue().AsText();
            Item."ASL.EFRIS.OpenInvUpldErrAction" := "ASL.EFRIS.UploadErrorAction"::Skip;
        end
        else begin
            Item."ASL.EFRIS.OpenInvUploadStatus" := "ASL.EFRIS.UploadStatus"::Success;
            Item."ASL.EFRIS.OpenInvUpldErrorCode" := '';
            Item."ASL.EFRIS.OpnInvUpldErrMessage" := '';
            Item."ASL.EFRIS.OpenInvUpldErrAction" := "ASL.EFRIS.UploadErrorAction"::" ";
        end;
        Item.Modify();
        exit(Success);
    end;

    procedure UpdateInventoryForItem(ItemNo: Code[20]): Enum "ASL.EFRIS.ProcessInvExitStatus"
    begin
        exit(UpdateInventory(ItemNo, ''));
    end;

    procedure UpdateInventoryForDoc(DocumentNo: Code[20]): Enum "ASL.EFRIS.ProcessInvExitStatus"
    begin
        exit(UpdateInventory('', DocumentNo));
    end;

    procedure UpdateInventoryEntries(var ItemLedgerEntry: Record "Item Ledger Entry"): Enum "ASL.EFRIS.ProcessInvExitStatus"
    begin
        exit(UpdateInventory(ItemLedgerEntry));
    end;

    local procedure UpdateInventory(ItemNo: Code[20];
    DocumentNo: Code[20]): Enum "ASL.EFRIS.ProcessInvExitStatus"
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        LogTrace(StrSubstNo('Update Inventory for Item %1', ItemNo));
        EFRISSetup.Get();
        if EFRISSetup."ASL.EFRIS.IntegrationStartDate" = 0D then begin
            LastErrorMessage := ErrIntegrationStartDateNotSet;
            LogError(LastErrorMessage);
            exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::"Error");
        end;
        // post item ledger entries by document
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        // entries after integration start date
        ItemLedgerEntry.SetFilter("Posting Date", StrSubStno('%1..', EFRISSetup."ASL.EFRIS.IntegrationStartDate"));
        // filter for entries not yet posted to EFRIS
        ItemLedgerEntry.SetFilter("ASL.EFRIS.UploadStatus", StrSubstNo('<>%1', "ASL.EFRIS.UploadStatus"::Success));
        // if DocumentNo specified. filter entries for DocumentNo only
        if DocumentNo <> '' then
            ItemLedgerEntry.SetRange("Document No.", DocumentNo)
        else
            if ItemNo <> '' then begin // filter positive/negative adjustments for specified item
                ItemLedgerEntry.SetRange("Item No.", ItemNo);
                ItemLedgerEntry.SetFilter("Entry Type", StrSubstNo('%1|%2', ItemLedgerEntry."Entry Type"::"Positive Adjmt.", ItemLedgerEntry."Entry Type"::"Negative Adjmt."));
            end;
        if not ItemLedgerEntry.FindSet() then begin
            LogTrace(ErrNoMatchingItemLedgerEntries);
            exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::"No Matching entries");
        end
        else
            exit(UpdateInventory(ItemLedgerEntry));
    end;

    local procedure UpdateInventory(var ItemLedgerEntry: Record "Item Ledger Entry"): Enum "ASL.EFRIS.ProcessInvExitStatus"
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        CompanyInfo: Record "Company Information";
        Skipped: Boolean;
        HasNext: Boolean;
        LastEntryType: enum "Item Ledger Entry Type";
        LastDocType: enum "Item Ledger Document Type";
        LastDocNo: Code[20];
        LastDocDate: Date;
        LedgerEntryItem: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
        PurchInvHdr: Record "Purch. Inv. Header";
        PeturnRcptHdr: Record "Return Receipt Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        Vendor: Record Vendor;
        LineCount: Integer;
        UploadCount: Integer;
        GoodsStockIn: JsonObject;
        PurchaseLines: JsonArray;
        PurchaseReturnLines: JsonArray;
        PositiveAdjLines: JsonArray;
        NegativeAdjLines: JsonArray;
        ConsumptionLines: JsonArray;
        OutputLines: JsonArray;
        GoodsStockInResponse: JsonToken;
        Success: Boolean;
        ItemLedgerUploadResponseArray: JsonArray;
        ResponseItemsCount: Integer;
        SelectToken: JsonToken;
        ResponseEntry: JsonObject;
        Now: DateTime;
        ItemUploadFailed: Boolean;
        UploadedItemLedgEntries: Record "Item Ledger Entry" temporary;
        ItemLedgerUploadLog: Record "Item Ledger Entry";
        FieldFilter: Text[250];
        PostingDateMin: Date;
        PostingDateMax: Date;
        SomeFailed: Boolean;
    begin
        LogTrace('Update Invemtory (Item Ledger Entries)');
        SomeFailed := false;
        EFRISSetup.Get();
        CompanyInfo.Get();
        if EFRISSetup."ASL.EFRIS.IntegrationStartDate" = 0D then begin
            LastErrorMessage := ErrIntegrationStartDateNotSet;
            LogError(LastErrorMessage);
            exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::Error);
        end;
        HasNext := true;
        ProgressDialog.Open(ProgressDialogTextLine1 + ProgressDialogTextLine2);
        UploadCount := 0;
        LineCount := 0;
        repeat
            Skipped := false;
            if (ItemLedgerEntry."ASL.EFRIS.UploadStatus" = "ASL.EFRIS.UploadStatus"::Error) and (ItemLedgerEntry."ASL.EFRIS.UploadErrorAction" = "ASL.EFRIS.UploadErrorAction"::Skip) then begin // skip tried and failed entries unless marked for retry
                HasNext := ItemLedgerEntry.Next() <> 0;
                Skipped := true;
            end
            else begin
                LedgerEntryItem.Get(ItemLedgerEntry."Item No.");
                if LedgerEntryItem."ASL.EFRIS.ItemId" = '' then begin // skip non EFRIS Items
                    HasNext := ItemLedgerEntry.Next() <> 0;
                    Skipped := true;
                end;
            end;
            if not Skipped then begin
                LineCount += 1;
                UploadCount += 1;
                // get line details
                LastEntryType := ItemLedgerEntry."Entry Type";
                LastDocType := ItemLedgerEntry."Document Type";
                LastDocNo := ItemLedgerEntry."Document No.";
                LastDocDate := ItemLedgerEntry."Posting Date";
                UnitOfMeasure.Get(ItemLedgerEntry."Unit of Measure Code");
                if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then begin
                    LastErrorMessage := StrSubstNo(ErrEFRISUOMNotMapped, UnitOfMeasure.Code);
                    LogError(LastErrorMessage);
                    exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::Error);
                end;
                case ItemLedgerEntry."Entry Type" of
                    ItemLedgerEntry."Entry Type"::"Positive Adjmt.":
                        begin
                            AddStockMaintenanceLine(PositiveAdjLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                    ItemLedgerEntry."Entry Type"::"Negative Adjmt.":
                        begin
                            AddStockMaintenanceLine(NegativeAdjLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", -ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                    ItemLedgerEntry."Entry Type"::Purchase:
                        begin
                            if (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Receipt") or (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Invoice") then begin
                                AddStockMaintenanceLine(PurchaseLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                            end
                            else
                                if (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Return Shipment") or (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Purchase Credit Memo") then begin
                                    AddStockMaintenanceLine(PurchaseReturnLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", -ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                                end;
                        end;
                    ItemLedgerEntry."Entry Type"::Consumption:
                        begin
                            AddStockMaintenanceLine(ConsumptionLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", -ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                    ItemLedgerEntry."Entry Type"::"Assembly Consumption":
                        begin
                            AddStockMaintenanceLine(ConsumptionLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", -ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                    ItemLedgerEntry."Entry Type"::Output:
                        begin
                            AddStockMaintenanceLine(OutputLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                    ItemLedgerEntry."Entry Type"::"Assembly Output":
                        begin
                            AddStockMaintenanceLine(OutputLines, LedgerEntryItem."No.", LedgerEntryItem."ASL.EFRIS.ItemId", UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ItemLedgerEntry.Quantity, LedgerEntryItem."Unit Cost");
                        end;
                end;
                // cache
                UploadedItemLedgEntries.Init();
                UploadedItemLedgEntries.Copy(ItemLedgerEntry);
                UploadedItemLedgEntries.Insert();
                // move to next line
                HasNext := ItemLedgerEntry.Next() <> 0;
            end;
            // no more lines or next line is for different document/entry type
            if (LineCount > 0) and (not HasNext or (LastDocType <> ItemLedgerEntry."Document Type") or (LastDocNo <> ItemLedgerEntry."Document No.") or (LastEntryType <> ItemLedgerEntry."Entry Type")) then begin
                ProgressDialog.Update(1, LastDocType);
                ProgressDialog.Update(2, LastDocNo);
                Success := true;
                if PurchaseLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, PurchaseLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                if PurchaseReturnLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, PurchaseReturnLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                if PositiveAdjLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, PositiveAdjLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                if NegativeAdjLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, NegativeAdjLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                if ConsumptionLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, ConsumptionLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                if OutputLines.Count > 0 then begin
                    Success := PostInventory(LastDocDate, LastDocNo, LastEntryType, LastDocType, UploadedItemLedgEntries, OutputLines, GoodsStockInResponse);
                    if (not SomeFailed and not Success) then SomeFailed := true;
                end;
                LogItemLedgerEntrySuccess(UploadedItemLedgEntries);
                // reset
                Clear(GoodsStockIn);
                Clear(PositiveAdjLines);
                Clear(NegativeAdjLines);
                Clear(ConsumptionLines);
                Clear(OutputLines);
                UploadedItemLedgEntries.DeleteAll();
                LineCount := 0;
            end;
        until HasNext = false;
        if UploadCount > 0 then begin
            if SomeFailed then begin
                LastErrorMessage := ErrSomeInventoryUploadFailed;
                exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::Error);
            end
            else
                exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::Success);
        end
        else begin
            LogTrace(ErrNoMatchingItemLedgerEntries);
            exit(Enum::"ASL.EFRIS.ProcessInvExitStatus"::"No Matching entries");
        end;
    end;

    local procedure PostInventory(PostingDate: Date;
    DocNo: Code[20];
    EntryType: Enum "Item Ledger Entry Type";
    DocumentType: Enum "Item Ledger Document Type";
    var UploadedItemLedgEntries: Record "Item Ledger Entry" temporary;
    var Entries: JsonArray;
    var GoodsStockInResponse: JsonToken): Boolean
    var
        Header: JsonObject;
        GoodsStockInRequest: JsonObject;
        ItemLedgerUploadResponseArray: JsonArray;
        ResponseItemsCount: Integer;
        ItemUploadFailed: Boolean;
        ResponseEntry: JsonObject;
        SelectToken: JsonToken;
        SomeFailed: Boolean;
        CompanyInfo: Record "Company Information";
        EFRISSEtup: Record "Sales & Receivables Setup";
        PurchRcptHdr: Record "Purch. Rcpt. Header";
        PurchInvHdr: Record "Purch. Inv. Header";
        Vendor: Record Vendor;
        ItemLedgerUploadLog: Record "Item Ledger Entry";
        Success: Boolean;
    begin
        Header.Add('stockInDate', Format(PostingDate, 0, '<Year4>-<Month,2>-<Day,2>'));
        case EntryType of
            EntryType::Purchase:
                begin
                    if (DocumentType = DocumentType::"Purchase Receipt") then begin
                        PurchRcptHdr.Get(DocNo);
                        Vendor.Get(PurchRcptHdr."Buy-from Vendor No.");
                        /*
                                        if Vendor."ASL.EFRIS.TIN" = '' then begin
                                            LastErrorMessage := StrSubstNo(ErrVendorMissingTIN, Vendor."No.");
                                            LogError(LastErrorMessage);
                                            exit(false);
                                        end;
                                        */
                        Header.Add('operationType', '101'); // increase
                        if PurchRcptHdr."ASL.EFRIS.Import" then
                            Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::Import.AsInteger()))
                        else
                            Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::"Local Purchase".AsInteger()));
                        Header.Add('supplierName', Vendor.Name);
                        Header.Add('supplierTin', Vendor."ASL.EFRIS.TIN");
                        Header.Add('invoiceNo', PurchRcptHdr."Vendor Shipment No.");
                    end
                    else
                        if (DocumentType = DocumentType::"Purchase Invoice") then begin
                            PurchInvHdr.Get(DocNo);
                            Vendor.Get(PurchInvHdr."Buy-from Vendor No.");
                            /*
                                              if Vendor."ASL.EFRIS.TIN" = '' then begin
                                                  LastErrorMessage := StrSubstNo(ErrVendorMissingTIN, Vendor."No.");
                                                  LogError(LastErrorMessage);
                                                  exit(false);
                                              end;
                                              */
                            Header.Add('operationType', '101'); // increase
                            if PurchInvHdr."ASL.EFRIS.Import" then
                                Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::Import.AsInteger()))
                            else
                                Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::"Local Purchase".AsInteger()));
                            Header.Add('supplierName', Vendor.Name);
                            Header.Add('supplierTin', Vendor."ASL.EFRIS.TIN");
                            Header.Add('invoiceNo', PurchInvHdr."Vendor Invoice No.");
                        end
                        else
                            if DocumentType = DocumentType::"Purchase Return Shipment" then begin
                                Header.Add('operationType', '102'); // decrease
                                Header.Add('adjustType', Format("ASL.EFRIS.AdjustType"::Others.AsInteger()));
                            end
                            else
                                if DocumentType = DocumentType::"Purchase Credit Memo" then begin
                                    Header.Add('operationType', '102'); // decrease
                                    Header.Add('adjustType', Format("ASL.EFRIS.AdjustType"::Others.AsInteger()));
                                end;
                    Header.Add('productionBatchNo', '');
                    Header.Add('productionDate', '');
                    Header.Add('adjustType', '');
                    Header.Add('branchId', '');
                    Header.Add('isCheckBatchNo', '');
                    Header.Add('remarks', 'Purchase Reference: ' + DocNo);
                end;
            EntryType::Output, EntryType::"Assembly Output", EntryType::"Positive Adjmt.":
                begin
                    Header.Add('operationType', '101'); // increase
                    CompanyInfo.Get();
                    if (EntryType = EntryType::Output) or (EntryType = EntryType::"Assembly Output") then begin
                        Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::"Manufacture/Assembling".AsInteger()));
                        Header.Add('invoiceNo', '');
                        Header.Add('supplierName', ''); // TODO: try without this
                        Header.Add('supplierTin', ''); // TODO: try without this
                        Header.Add('productionBatchNo', DocNo);
                        Header.Add('productionDate', PostingDate);
                        Header.Add('remarks', 'Production Reference: ' + DocNo);
                    end
                    else begin // Positive Adjustment
                               // TODO: Really not a purchase. 'stockInType' required for any inventory increase
                        Header.Add('stockInType', Format("ASL.EFRIS.StockinType"::"Local Purchase".AsInteger()));
                        Header.Add('invoiceNo', '');
                        Header.Add('supplierName', CompanyInfo.Name); // TODO: try without this
                        Header.Add('supplierTin', EFRISSetup."ASL.EFRIS.TIN"); // TODO: try without this
                        Header.Add('productionBatchNo', '');
                        Header.Add('productionDate', '');
                        Header.Add('remarks', 'Postitive Adjustment Doc No.: ' + DocNo);
                    end;
                    Header.Add('adjustType', '');
                    Header.Add('branchId', '');
                    Header.Add('isCheckBatchNo', '');
                end;
            EntryType::Consumption, EntryType::"Assembly Consumption", EntryType::"Negative Adjmt.":
                begin
                    Header.Add('operationType', '102'); // decrease
                    if (EntryType = EntryType::Consumption) or (EntryType = EntryType::"Assembly Consumption") then begin
                        Header.Add('adjustType', Format("ASL.EFRIS.AdjustType"::"Raw Material(s)".AsInteger()));
                        Header.Add('remarks', 'Production Refernce ' + DocNo);
                    end
                    else begin
                        Header.Add('adjustType', Format("ASL.EFRIS.AdjustType"::Others.AsInteger()));
                        Header.Add('remarks', 'Negative Adjustment Doc No. ' + DocNo);
                    end;
                    Header.Add('supplierName', '');
                    Header.Add('supplierTin', '');
                    Header.Add('stockInType', '');
                    Header.Add('productionBatchNo', '');
                    Header.Add('productionDate', '');
                    Header.Add('branchId', '');
                    Header.Add('invoiceNo', '');
                    Header.Add('isCheckBatchNo', '');
                end;
        end;
        GoodsStockInRequest.Add('goodsStockIn', Header);
        GoodsStockInRequest.Add('goodsStockInItem', Entries);
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T131, GoodsStockInRequest.AsToken(), GoodsStockInResponse);
        if not Success then begin // all failed
            UploadedItemLedgEntries.FindFirst();
            repeat
                ItemLedgerUploadLog.Get(UploadedItemLedgEntries."Entry No.");
                ItemLedgerUploadLog."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorCode" := LastReturnStateCode;
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorMessage" := GetLastErrorMessage();
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorAction" := "ASL.EFRIS.UploadErrorAction"::Skip;
                ItemLedgerUploadLog.Modify();
            until UploadedItemLedgEntries.Next() = 0;
        end
        else
            if (LastReturnStateCode = '45') then begin // partial failure
                ItemLedgerUploadResponseArray := GoodsStockInResponse.AsArray();
                ResponseItemsCount := ItemLedgerUploadResponseArray.Count;
                UploadedItemLedgEntries.FindFirst();
                repeat
                    ItemUploadFailed := (ResponseItemsCount > 0) and (ItemLedgerUploadResponseArray.SelectToken('$[?(@.goodsCode == ''' + UploadedItemLedgEntries."Item No." + ''')]', SelectToken));
                    ItemLedgerUploadLog.Get(UploadedItemLedgEntries."Entry No.");
                    if ItemUploadFailed then begin
                        ResponseEntry := SelectToken.AsObject();
                        ItemLedgerUploadLog."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
                        if ResponseEntry.SelectToken('returnCode', SelectToken) then ItemLedgerUploadLog."ASL.EFRIS.UploadErrorCode" := SelectToken.AsValue().AsText();
                        if ResponseEntry.SelectToken('returnMessage', SelectToken) then ItemLedgerUploadLog."ASL.EFRIS.UploadErrorMessage" := CopyStr(SelectToken.AsValue().AsText(), 1, MaxStrLen(ItemLedgerUploadLog."ASL.EFRIS.UploadErrorMessage"));
                        ItemLedgerUploadLog."ASL.EFRIS.UploadErrorAction" := "ASL.EFRIS.UploadErrorAction"::Skip;
                        if not SomeFailed then SomeFailed := true;
                        ItemLedgerUploadLog.Modify();
                        // mark temp entry as failed
                        UploadedItemLedgEntries."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
                        UploadedItemLedgEntries.Modify();
                    end;
                until UploadedItemLedgEntries.Next() = 0;
            end;
        exit(Success);
    end;

    local procedure LogItemLedgerEntrySuccess(var UploadedItemLedgEntries: Record "Item Ledger Entry" temporary)
    var
        ItemLedgerUploadLog: Record "Item Ledger Entry";
    begin
        UploadedItemLedgEntries.FindFirst();
        repeat
            ItemLedgerUploadLog.Get(UploadedItemLedgEntries."Entry No.");
            if (ItemLedgerUploadLog."ASL.EFRIS.UploadStatus" <> Enum::"ASL.EFRIS.UploadStatus"::Error) or (ItemLedgerUploadLog."ASL.EFRIS.UploadErrorAction" = Enum::"ASL.EFRIS.UploadErrorAction"::Retry) then begin
                ItemLedgerUploadLog."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Success;
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorCode" := '';
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorMessage" := '';
                ItemLedgerUploadLog."ASL.EFRIS.UploadErrorAction" := "ASL.EFRIS.UploadErrorAction"::" ";
                ItemLedgerUploadLog.Modify();
            end;
        until UploadedItemLedgEntries.Next() = 0;
    end;

    local procedure AddStockMaintenanceLine(var StockMaintenanceLines: JsonArray;
    ItemNo: Code[20];
    EFRISItemId: Code[20];
    EFRISUOMCode: Code[10];
    Qty: Decimal;
    UnitPrice: Decimal)
    var
        StockMaintenanceLine: JsonObject;
    begin
        StockMaintenanceLine.Add('commodityGoodsId', EFRISItemId);
        StockMaintenanceLine.Add('goodsCode', ItemNo);
        StockMaintenanceLine.Add('measureUnit', EFRISUOMCode);
        StockMaintenanceLine.Add('quantity', Format(Qty, 0, 1));
        StockMaintenanceLine.Add('unitPrice', Format(UnitPrice, 0, 1));
        StockMaintenanceLines.Add(StockMaintenanceLine);
    end;

    procedure PostSalesInvoice(var SalesInvoice: Record "Sales Invoice Header";
    PreviewMode: Boolean): Boolean
    var
        SalesInvoiceLines: Record "Sales Invoice Line";
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
        CrMemo: Record "Sales Cr.Memo Header";
        Invoice: JsonObject;
        SelletDetails: JsonObject;
        BasicInfo: JsonObject;
        Customer: Record Customer;
        VatProdPostingGroup: Record "VAT Product Posting Group";
        InvoiceIndustryCode: Enum "ASL.EFRIS.InvoiceIndustryCode";
        BuyerDetails: JsonObject;
        BuyerExtendDetails: JsonObject;
        GoodsDetails: JsonArray;
        VATExempt: Boolean;
        VATZero: Boolean;
        LineGrossAmount: Decimal;
        LineTaxAmount: Decimal;
        LineDiscountGrossAmount: Decimal;
        LineDiscountTaxAmount: Decimal;
        VATTaxCategory: Enum "ASL.EFRIS.TaxCategory";
        TaxDetailsAccuml: Dictionary of [Integer, List of [Decimal]];
        TaxDetailsKeys: List of [Integer];
        TaxDetailsKey: Integer;
        GrossAndTaxAmounts: List of [Decimal];
        TaxDetails: JsonArray;
        I: Integer;
        DiscountLine: JsonObject;
        TotalGrossAmount: Decimal;
        TotalTaxAmount: Decimal;
        Summary: JsonObject;
        ItemCount: Integer;
        Payments: JsonArray;
        Payment: JsonObject;
        InvoiceUploadResponse: JsonToken;
        Success: Boolean;
        ResponseText: Text;
        DetailsText: Text;
    begin
        SalesInvoiceLines.Reset();
        SalesInvoiceLines.SetRange(SalesInvoiceLines."Document No.", SalesInvoice."No.");
        SalesInvoiceLines.SetFilter(SalesInvoiceLines.Type, '%1|%2', SalesInvoiceLines.Type::Item, SalesInvoiceLines.Type::"G/L Account");
        SalesInvoiceLines.SetFilter(SalesInvoiceLines."No.", '<>''''');
        SalesInvoiceLines.SetFilter(SalesInvoiceLines.Quantity, '>0');
        if not SalesInvoiceLines.FindSet() then begin
            LastErrorMessage := ErrInvNoLines;
            LogError(LastErrorMessage);
            exit(false);
        end;
        if not SetSalesSellerDetails(Enum::"Sales Document Type"::Invoice, SalesInvoice, CrMemo, SelletDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('sellerDetails', SelletDetails);
        Customer.Get(SalesInvoice."Bill-to Customer No.");
        if SalesInvoice."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then
            InvoiceIndustryCode := SalesInvoice."ASL.EFRIS.InvoiceIndustryCode"
        else
            if Customer."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then
                InvoiceIndustryCode := Customer."ASL.EFRIS.InvoiceIndustryCode"
            else begin
                if EFRISIntegrationSetup."ASL.EFRIS.InvoiceIndustryCode" = Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then begin
                    LastErrorMessage := ErrMissingInvIndustryCode;
                    LogError(LastErrorMessage);
                    exit(false);
                end;
                InvoiceIndustryCode := EFRISIntegrationSetup."ASL.EFRIS.InvoiceIndustryCode";
            end;
        if not SetInvoiceBasicInfo(SalesInvoice."Currency Code", SalesInvoice."Posting Date", Enum::"ASL.EFRIS.InvoiceType"::"Invoice/Receipt", InvoiceIndustryCode, '', false, BasicInfo, SalesInvoice."ASL.EFRIS.DeliveryTerms") then exit(false);
        Invoice.Add('basicInformation', BasicInfo);
        if not SetSalesBuyerDetails(SalesInvoice, Customer, BuyerDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('buyerDetails', BuyerDetails);
        if not SetInvoiceEmptyBuyerExtendDetails(BuyerExtendDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('buyerExtend', BuyerExtendDetails);
        VATExempt := SalesInvoice."ASL.EFRIS.VATExempt";
        // check for VAT Zero based on Invoice Industry Code
        if InvoiceIndustryCode = Enum::"ASL.EFRIS.InvoiceIndustryCode"::Export then VATZero := true;
        I := 0;
        ItemCount := 0;
        repeat
            LineGrossAmount := 0;
            LineTaxAmount := 0;
            if not AddInvoiceLineDetails(I, SalesInvoiceLines, SalesInvoice."Prices Including VAT", SalesInvoice."ASL.EFRIS.VATDeemed", VATExempt, VATZero, LineGrossAmount, LineTaxAmount, GoodsDetails, SalesInvoice) then begin
                LastErrorMessage := GetLastErrorText();
                LogError(LastErrorMessage);
                exit(false);
            end;

            SalesInvoiceLines."Order Number" := I;
            SalesInvoiceLines.Modify();

            if (SalesInvoiceLines."Line Discount Amount" > 0) or (SalesInvoiceLines."Inv. Discount Amount" > 0) then begin
                I += 1;
                AddInvoiceDiscountLine(I, SalesInvoiceLines, SalesInvoice."Prices Including VAT", SalesInvoice."ASL.EFRIS.VATDeemed", VATExempt, VATZero, LineDiscountGrossAmount, LineDiscountTaxAmount, GoodsDetails);
                LineGrossAmount -= LineDiscountGrossAmount;
                LineTaxAmount -= LineDiscountTaxAmount;
            end;

            //-UPDATE EJ
            if VATZero then
                VATTaxCategory :=
                    Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else begin
                VatProdPostingGroup.Get(
                    SalesInvoiceLines."VAT Prod. Posting Group");
                VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");

                if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                   Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                then
                    VATTaxCategory :=
                        Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                else
                    if SalesInvoice."ASL.EFRIS.VATDeemed" then
                        VATTaxCategory :=
                            Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                    else
                        if SalesInvoice."ASL.EFRIS.VATExempt" then
                            VATTaxCategory :=
                                Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                        else
                            VATTaxCategory :=
                                VatProdPostingGroup."ASL.EFRIS.TaxCategory";
            end;
            //New Adj
            /* if VATZero then
                VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else
                if SalesInvoice."ASL.EFRIS.VATDeemed" then
                    VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                else
                    if SalesInvoice."ASL.EFRIS.VATExempt" then
                        VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                    else begin
                        VatProdPostingGroup.Get(SalesInvoiceLines."VAT Prod. Posting Group");
                        VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");
                        VATTaxCategory := VatProdPostingGroup."ASL.EFRIS.TaxCategory";
                    end; */
            AddSalesTaxDetails(VATTaxCategory, LineGrossAmount, SalesInvoiceLines."VAT %", LineTaxAmount, TaxDetailsAccuml);
            TotalGrossAmount += LineGrossAmount;
            TotalTaxAmount += LineTaxAmount;
            I += 1;
            ItemCount += 1;
        until SalesInvoiceLines.Next() = 0;
        Invoice.Add('goodsDetails', GoodsDetails);
        GoodsDetails.WriteTo(DetailsText);
        //ej debugging

        //Message(DetailsText);

        // tax details
        if TaxDetailsAccuml.Count > 0 then begin
            TaxDetailsKeys := TaxDetailsAccuml.Keys();
            I := 1;
            repeat
                if TaxDetailsKeys.Get(I, TaxDetailsKey) then begin
                    if TaxDetailsAccuml.Get(TaxDetailsKey, GrossAndTaxAmounts) then begin
                        SetTaxDetailFieldValues(Enum::"ASL.EFRIS.TaxCategory".FromInteger(TaxDetailsKey), GrossAndTaxAmounts.Get(1), GrossAndTaxAmounts.Get(2), GrossAndTaxAmounts.Get(3), TaxDetails);
                    end;
                end;
                I += 1;
            until I > TaxDetailsKeys.Count;
            Invoice.Add('taxDetails', TaxDetails);
        end;
        // Error('Error is Error');
        Summary.Add('netAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        if SalesInvoice."ASL.EFRIS.VATDeemed" or SalesInvoice."ASL.EFRIS.VATExempt" then begin
            Summary.Add('taxAmount', Format(0, 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        end
        else begin
            Summary.Add('taxAmount', Format(Round(TotalTaxAmount, 0.01, '='), 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount, 0.01, '='), 0, 1));
        end;
        Summary.Add('itemCount', Format(ItemCount, 0, 1));
        Summary.Add('modeCode', '1'); // 1 - online, 0 - offline
        Summary.Add('remarks', SalesInvoice."ASL.EFRIS.Remarks");
        Summary.Add('qrCode', '');
        Invoice.Add('summary', Summary);
        EFRISIntegrationSetup.Get();
        if SalesInvoice."ASL.EFRIS.PaymentMode" <> Enum::"ASL.EFRIS.PaymentMode"::" " then
            Payment.Add('paymentMode', Format(SalesInvoice."ASL.EFRIS.PaymentMode".AsInteger(), 0, 1))
        else begin
            if EFRISIntegrationSetup."ASL.EFRIS.InvoicePaymentMode" = Enum::"ASL.EFRIS.PaymentMode"::" " then begin
                LastErrorMessage := StrSubstNo(ErrMissingPaymentMode, SalesInvoice."No.");
                LogError(LastErrorMessage);
                exit(false);
            end;
            Payment.Add('paymentMode', Format(EFRISIntegrationSetup."ASL.EFRIS.InvoicePaymentMode".AsInteger(), 0, 1));
        end;
        if SalesInvoice."ASL.EFRIS.VATDeemed" or SalesInvoice."ASL.EFRIS.VATExempt" then
            Payment.Add('paymentAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '<'), 0, 1))
        else
            Payment.Add('paymentAmount', Format(Round(TotalGrossAmount, 0.01, '<'), 0, 1));
        Payment.Add('orderNumber', 'a');
        Payments.Add(Payment);
        Invoice.Add('payWay', Payments);
        // if preview mode, then getting here means all preconditions are met. return success
        // only errors thrown by EFRIS API are outstanding
        if PreviewMode then exit(true);

        Invoice.WriteTo(ResponseText);
        // Message(ResponseText);
        // Error('Here is the error');
        // Error('Not Allowed');
        // not PreviewMode proceed to send request
        Success := SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T109, Invoice.AsToken(), InvoiceUploadResponse);
        InvoiceUploadResponse.WriteTo(ResponseText);
        // Message(ResponseText);
        SalesInvoice."ASL.EFRIS.UploadTime" := CreateDateTime(Today, Time);
        if Success then begin
            if not GetEFRISInvoiceDetails(SalesInvoice) then exit(false);
        end
        else begin
            // check if already posted 
            // return code '2253' => The seller's reference number already exists!
            if LastHttpSuccess and (LastReturnStateCode = '2253') then begin
                if GetEFRISInvoiceDetails(SalesInvoice) then begin
                    SalesInvoice.Modify(); // fetch existing EFRIS invoice details
                    exit(true);
                end
                else
                    exit(false);
            end
            else begin
                SalesInvoice."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Error;
                SalesInvoice."ASL.EFRIS.UploadErrorCode" := LastReturnStateCode;
                SalesInvoice."ASL.EFRIS.UploadErrorMessage" := CopyStr(GetLastErrorMessage(), 1, MaxStrLen(SalesInvoice."ASL.EFRIS.UploadErrorMessage"));
                SalesInvoice."ASL.EFRIS.UploadErrorAction" := Enum::"ASL.EFRIS.UploadErrorAction"::Skip;
            end;
        end;
        exit(Success);
    end;

    procedure GetEFRISInvoiceDetails(var SalesInvoice: Record "Sales Invoice Header"): Boolean
    var
        InvoiceQuery: JsonObject;
        InvoiceQueryResult: JsonToken;
        SelectToken: JsonToken;
        EFRISSellerRefNo: Code[20];
        invoiceText: Text;
    begin
        LogTrace(StrSubstNo('Get EFRIS Invoice Details for Invoice %1', SalesInvoice."No."));
        // get invoice id by ref number
        OnBeforeGetEFRISInvoiceDetails(SalesInvoice, EFRISSellerRefNo);
        // Message(EFRISSellerRefNo);
        if EFRISSellerRefNo <> '' then
            InvoiceQuery.Add('referenceNo', EFRISSellerRefNo)
        else
            InvoiceQuery.Add('referenceNo', SalesInvoice."No.");

        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T106, InvoiceQuery.AsToken(), InvoiceQueryResult) then exit(false);
        InvoiceQueryResult.WriteTo(invoiceText);
        // Message(invoiceText);
        SalesInvoice."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Success;
        if InvoiceQueryResult.SelectToken('$.records[0].invoiceNo', SelectToken) then SalesInvoice."ASL.EFRIS.InvoiceNo" := SelectToken.AsValue().AsText();
        if InvoiceQueryResult.SelectToken('$.records[0].id', SelectToken) then SalesInvoice."ASL.EFRIS.InvoiceId" := SelectToken.AsValue().AsText();
        // get invoice details by EFRIS invoice number
        Clear(InvoiceQuery);
        Clear(InvoiceQueryResult);
        InvoiceQuery.Add('invoiceNo', SalesInvoice."ASL.EFRIS.InvoiceNo");
        if SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T108, InvoiceQuery.AsToken(), InvoiceQueryResult) then begin
            if InvoiceQueryResult.SelectToken('$.basicInformation.antifakeCode', SelectToken) then SalesInvoice."ASL.EFRIS.Antifakecode" := SelectToken.AsValue().AsText();
            if InvoiceQueryResult.SelectToken('$.summary.qrCode', SelectToken) then SalesInvoice."ASL.EFRIS.QRCode" := SelectToken.AsValue().AsText();
        end;
        exit(true);
    end;

    procedure GetEFRISInvoiceDetailsMod(var SalesInvoice: Record "Sales Invoice Header"): Boolean
    var
        InvoiceQuery: JsonObject;
        InvoiceQueryResult: JsonToken;
        SelectToken: JsonToken;
        EFRISSellerRefNo: Code[20];
        invoiceText: Text;
    begin
        LogTrace(StrSubstNo('Get EFRIS Invoice Details for Invoice %1', SalesInvoice."No."));
        // get invoice id by ref number
        OnBeforeGetEFRISInvoiceDetails(SalesInvoice, EFRISSellerRefNo);
        // Message(EFRISSellerRefNo);
        if EFRISSellerRefNo <> '' then
            InvoiceQuery.Add('referenceNo', EFRISSellerRefNo)
        else
            InvoiceQuery.Add('referenceNo', SalesInvoice."No.");

        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T106, InvoiceQuery.AsToken(), InvoiceQueryResult) then exit(false);
        InvoiceQueryResult.WriteTo(invoiceText);
        // Message(invoiceText);
        SalesInvoice."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Success;
        if InvoiceQueryResult.SelectToken('$.records[0].invoiceNo', SelectToken) then SalesInvoice."ASL.EFRIS.InvoiceNo" := SelectToken.AsValue().AsText();
        if InvoiceQueryResult.SelectToken('$.records[0].id', SelectToken) then SalesInvoice."ASL.EFRIS.InvoiceId" := SelectToken.AsValue().AsText();
        // get invoice details by EFRIS invoice number
        Clear(InvoiceQuery);
        Clear(InvoiceQueryResult);
        InvoiceQuery.Add('invoiceNo', SalesInvoice."ASL.EFRIS.InvoiceNo");
        if SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T108, InvoiceQuery.AsToken(), InvoiceQueryResult) then begin
            if InvoiceQueryResult.SelectToken('$.basicInformation.antifakeCode', SelectToken) then SalesInvoice."ASL.EFRIS.Antifakecode" := SelectToken.AsValue().AsText();
            if InvoiceQueryResult.SelectToken('$.summary.qrCode', SelectToken) then SalesInvoice."ASL.EFRIS.QRCode" := SelectToken.AsValue().AsText();
        end;
        exit(true);
    end;

    procedure FetchEFRISInvoiceDetails(var SalesInvoice: Record "Sales Invoice Header"): Boolean
    begin
        if GetEFRISInvoiceDetailsMod(SalesInvoice) then SalesInvoice.Modify();
    end;

    [TryFunction]
    local procedure SetSalesSellerDetails(DocumentType: Enum "Sales Document Type";
    var SalesInvoiceHeader: Record "Sales Invoice Header";
    var SalesCrMEmoHeader: Record "Sales Cr.Memo Header";
    var SelletDetails: JsonObject)
    var
        CompanyInfo: Record "Company Information";
        EFRISSetup: Record "Sales & Receivables Setup";
        ReferenceNo: Text;
    begin
        CompanyInfo.Get();
        EFRISSetup.Get();


        if EFRISSetup."ASL.EFRIS.TIN" = '' then Error(ErrSetupMissingTIN);
        if EFRISSetup."ASL.EFRIS.LegalName" = '' then Error(ErrSetupMissingLegalName);
        if EFRISSetup."ASL.EFRIS.BusinessName" = '' then Error(ErrSetupMissingBusinessName);
        if EFRISSetup."ASL.EFRIS.E-Mail" = '' then Error(ErrSetupMissingEmail);

        if DocumentType = Enum::"Sales Document Type"::Invoice then
            ReferenceNo := SalesInvoiceHeader."No."
        else
            ReferenceNo := SalesCrMemoHeader."No.";

        OnBeforeSetSellerReferenceNo(
                        DocumentType,
                        SalesInvoiceHeader,
                        SalesCrMEmoHeader,
                        ReferenceNo);

        SelletDetails.Add('referenceNo', ReferenceNo);
        SelletDetails.Add('tin', EFRISSetup."ASL.EFRIS.TIN");
        SelletDetails.Add('ninBrn', EFRISSetup."ASL.EFRIS.BRN");
        SelletDetails.Add('legalName', EFRISSetup."ASL.EFRIS.LegalName");
        SelletDetails.Add('businessName', EFRISSetup."ASL.EFRIS.BusinessName");
        SelletDetails.Add('address', CopyStr(CompanyInfo.Address + CompanyInfo."Address 2", 1, 500));
        SelletDetails.Add('mobilePhone', CompanyInfo."Phone No. 2");
        SelletDetails.Add('linePhone', CompanyInfo."Phone No.");
        SelletDetails.Add('emailAddress', EFRISSetup."ASL.EFRIS.E-Mail");
        SelletDetails.Add('placeOfBusiness', CopyStr(CompanyInfo."Ship-to Address" + CompanyInfo."Ship-to Address 2", 1, 500));
        /* if DocumentType = Enum::"Sales Document Type"::Invoice then
            SelletDetails.Add('referenceNo', SalesInvoiceHeader."No.")
        else
            SelletDetails.Add('referenceNo', SalesCrMemoHeader."No."); */

        SelletDetails.Add('isCheckReferenceNo', '1');
        SelletDetails.Add('branchCode', '');
        SelletDetails.Add('branchName', '');
        OnAfterSetSellerDetails(SalesInvoiceHeader, SelletDetails);
    end;

    local procedure SetInvoiceBasicInfo(CurrencyCode: Code[20];
    PostingDate: Date;
    InvoiceType: enum "ASL.EFRIS.InvoiceType";
    InvoiceIndustryCode: enum "ASL.EFRIS.InvoiceIndustryCode";
    OriInvoiceId: Code[20];
    IsBatch: Boolean;
    var BasicInfo: JsonObject; DeliveryTerms: Enum "ASL.EFRIS.DeliveryTermsCodeDes"): Boolean
    var
        Currency: Record Currency;
        ExchangeRate: Record "Currency Exchange Rate";
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        EFRISSetup: Record "Sales & Receivables Setup";
        EFRISCurrency: Record "ASL.EFRIS.Currency";
        NonLCY: Boolean;
        ExchRate: Decimal;
        DeliveryTermsCode: Enum "ASL.EFRIS.DeliveryTermsCode";
    begin
        CompanyInfo.Get();
        EFRISSetup.Get();
        GLSetup.Get();
        if CurrencyCode <> '' then begin
            Currency.Get(CurrencyCode);
            if Currency."ASL.EFRIS.EFRISCurrencyCode" = '' then begin
                LastErrorMessage := StrSubstNo(ErrMissingEFRISCurrencyCode, Currency.Code);
                LogError(LastErrorMessage);
                exit(false);
            end;
            EFRISCurrency.Get(Currency."ASL.EFRIS.EFRISCurrencyCode");
            NonLCY := true;
        end
        else begin
            if EFRISSetup."ASL.EFRIS.LCYEFRISCurrencyCode" = '' then begin
                LastErrorMessage := ErrMissingLCYEFRISCurrencyCode;
                LogError(LastErrorMessage);
                exit(false);
            end;
            EFRISCurrency.Get(EFRISSetup."ASL.EFRIS.LCYEFRISCurrencyCode");
            NonLCY := false;
        end;
        BasicInfo.Add('invoiceId', '');
        BasicInfo.Add('invoiceNo', '');
        BasicInfo.Add('antifakeCode', '');
        if EFRISSetup."ASL.EFRIS.DeviceNo" = '' then begin
            LastErrorMessage := StrSubstNo(ErrSetupMissingDeviceNo);
            LogError(LastErrorMessage);
            exit(false);
        end;
        BasicInfo.Add('deviceNo', EFRISSetup."ASL.EFRIS.DeviceNo");
        BasicInfo.Add('issuedDate', Format(CreateDateTime(PostingDate, 0T), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
        BasicInfo.Add('operator', CompanyInfo.Name);
        BasicInfo.Add('currency', EFRISCurrency.Name);
        BasicInfo.Add('oriInvoiceId', OriInvoiceId);
        BasicInfo.Add('invoiceType', Format(InvoiceType.AsInteger(), 0, 1));
        BasicInfo.Add('invoiceKind', Format(Enum::"ASL.EFRIS.InvoiceKind"::Invoice.AsInteger(), 0, 1));
        BasicInfo.Add('dataSource', Format(Enum::"ASL.EFRIS.DataSource"::Mis.AsInteger(), 0, 1));
        BasicInfo.Add('invoiceIndustryCode', Format(InvoiceIndustryCode.AsInteger(), 0, 1));
        if IsBatch then
            BasicInfo.Add('isBatch', '1')
        else
            BasicInfo.Add('isBatch', '0');
        if NonLCY then begin
            ExchRate := ExchangeRate.ExchangeRate(PostingDate, CurrencyCode);
            /*
                  if not GetExchangeRate(EFRISCurrency.Code, PostingDate, ExchRate) then
                      exit(false);
                  */
            BasicInfo.Add('currencyRate', Format(Round(ExchRate, 0.01, '<'), 0, 1));
        end
        else
            BasicInfo.Add('currencyRate', '1');
        exit(true);
    end;

    [TryFunction]
    local procedure SetSalesBuyerDetails(var SalesInvHeader: Record "Sales Invoice Header";
    var Buyer: Record Customer;
    var BuyerDetails: JsonObject)
    var
        DeliveryTerms: Enum "ASL.EFRIS.DeliveryTermsCode";
    begin
        if Buyer."ASL.EFRIS.BuyerType" = Enum::"ASL.EFRIS.BuyerType"::"B2B/B2G" then begin
            if Buyer."ASL.EFRIS.TIN" = '' then Error(ErrB2BGCustNoTIN, Buyer."No.");
            BuyerDetails.Add('buyerTin', Buyer."ASL.EFRIS.TIN");
        end
        else
            BuyerDetails.Add('buyerTin', '');
        BuyerDetails.Add('buyerNinBrn', Buyer."ASL.EFRIS.NINBRN");
        BuyerDetails.Add('buyerPassportNum', Buyer."ASL.EFRIS.PassportNo");
        if Buyer."ASL.EFRIS.LegalName" <> '' then
            BuyerDetails.Add('buyerLegalName', Buyer."ASL.EFRIS.LegalName")
        else
            BuyerDetails.Add('buyerLegalName', Buyer.Name);
        if Buyer."ASL.EFRIS.BusinessName" <> '' then
            BuyerDetails.Add('buyerBusinessName', Buyer."ASL.EFRIS.BusinessName")
        else
            BuyerDetails.Add('buyerBusinessName', Buyer.Name);
        BuyerDetails.Add('buyerAddress', CopyStr(Buyer.Address + Buyer."Address 2", 1, 499));
        BuyerDetails.Add('buyerEmail', Buyer."E-Mail");
        BuyerDetails.Add('buyerMobilePhone', Buyer."Mobile Phone No.");
        BuyerDetails.Add('buyerLinePhone', Buyer."Phone No.");
        BuyerDetails.Add('buyerPlaceOfBusi', CopyStr(Buyer.Address + Buyer."Address 2", 1, 499));
        BuyerDetails.Add('buyerType', Format(Buyer."ASL.EFRIS.BuyerType".AsInteger(), 0, 1));
        BuyerDetails.Add('buyerCitizenship', Buyer."ASL.EFRIS.Citizenship");
        BuyerDetails.Add('buyerSector', Buyer."ASL.EFRIS.Sector");
        BuyerDetails.Add('buyerReferenceNo', Buyer."No.");
        if SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" = SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode"::Export then begin
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Cost and Freight" then begin
                BuyerDetails.Add('deliveryTermsCode', 'CFR');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Cost Insurance and Freight" then begin
                BuyerDetails.Add('deliveryTermsCode', 'CIF');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Carriage and Insurance Paid To" then begin
                BuyerDetails.Add('deliveryTermsCode', 'CIP');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Carriage Paid To" then begin
                BuyerDetails.Add('deliveryTermsCode', 'CPT');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Delivered at Place" then begin
                BuyerDetails.Add('deliveryTermsCode', 'DAP');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Delivered Duty Paid" then begin
                BuyerDetails.Add('deliveryTermsCode', 'DDP');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Delivered at Place Unloaded" then begin
                BuyerDetails.Add('deliveryTermsCode', 'DPU');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Ex Works" then begin
                BuyerDetails.Add('deliveryTermsCode', 'EXW');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Free Alongside Ship" then begin
                BuyerDetails.Add('deliveryTermsCode', 'FAS');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Free Carrier" then begin
                BuyerDetails.Add('deliveryTermsCode', 'FCA');
            end;
            if SalesInvHeader."ASL.EFRIS.DeliveryTerms" = SalesInvHeader."ASL.EFRIS.DeliveryTerms"::"Free On Board" then begin
                BuyerDetails.Add('deliveryTermsCode', 'FOB');
            end;
        end;
        OnAfterSetBuyerDetails(SalesInvHeader, Buyer, BuyerDetails);
    end;

    [TryFunction]
    local procedure SetInvoiceEmptyBuyerExtendDetails(var BuyerExtendDetails: JsonObject)
    var
    begin
        BuyerExtendDetails.Add('propertyType', '');
        BuyerExtendDetails.Add('district', '');
        BuyerExtendDetails.Add('municipalityCounty', '');
        BuyerExtendDetails.Add('divisionSubcounty', '');
        BuyerExtendDetails.Add('town', '');
        BuyerExtendDetails.Add('cellVillage', '');
        BuyerExtendDetails.Add('effectiveRegistrationDate', '');
        BuyerExtendDetails.Add('meterStatus', '');
    end;

    [TryFunction]
    local procedure AddInvoiceLineDetails(OrderNo: Integer;
    Var Line: Record "Sales Invoice Line";
    PricesIncludeVAT: Boolean;
    Deemed: Boolean;
    Exempt: Boolean;
    Zero: Boolean;
    var LineGrossAmount: Decimal;
    var LineTaxAmount: Decimal;
    var InvoiceLines: JsonArray;
    var SalesInvoice: Record "Sales Invoice Header")
    var
        UnitOfMeasure: Record "Unit Of Measure";
        EFRISUnitOfMeasure: Record "ASL.EFRIS.Unit";
        UnitOfMeasure1: Record "Unit Of Measure";
        EFRISUnitOfMeasure1: Record "ASL.EFRIS.Unit";
        Item: Record "Item";
        GLAccount: Record "G/L Account";
        CommodityCategory: Record "ASL.EFRIS.CommodityCategory";
        VatProdPostingGroup: Record "VAT Product Posting Group";
        InvoiceLineDetails: JsonObject;
        UnitPriceIncVAT: Decimal;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (Line.Type <> Line.Type::Item) and (Line.Type <> Line.Type::"G/L Account") then Error(ErrUnsupportedEFRISInvoiceLineType, Line.Type);
        if Line.Type = Line.Type::Item then begin
            Item.Get(Line."No.");
            if Item."ASL.EFRIS.ItemId" = '' then Error(ErrLineItemNotEFRISProduct, Line.Type, Line."No.");
        end
        else begin
            GLAccount.Get(Line."No.");
            if GLAccount."ASL.EFRIS.ProductId" = '' then Error(ErrLineItemNotEFRISProduct, Line.Type, Line."No.");
        end;
        InvoiceLineDetails.Add('orderNumber', Format(OrderNo, 0, 1));
        InvoiceLineDetails.Add('itemCode', Line."No.");
        if Deemed then
            InvoiceLineDetails.Add('item', Line.Description + ' (Deemed)')
        else
            InvoiceLineDetails.Add('item', Line.Description);
        if Line.Type = Line.Type::Item then
            CommodityCategory.Get(Item."ASL.EFRIS.CmdtCategoryCode")
        else
            CommodityCategory.Get(GLAccount."ASL.EFRIS.CmdtCategoryCode");
        InvoiceLineDetails.Add('goodsCategoryId', CommodityCategory.Code);
        InvoiceLineDetails.Add('goodsCategoryName', CommodityCategory.Name);
        InvoiceLineDetails.Add('qty', Line.Quantity);
        UnitOfMeasure.Get(Line."Unit of Measure Code");
        if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then Error(ErrEFRISUOMNotMapped, UnitOfMeasure.Code);
        EFRISUnitOfMeasure.Get(UnitOfMeasure."ASL.EFRIS.EFRISUOMCode");
        InvoiceLineDetails.Add('unitOfMeasure', EFRISUnitOfMeasure.Code);
        if PricesIncludeVAT then
            UnitPriceIncVAT := Round(Line."Unit Price", 0.00000001, '=')
        else // set price inc. vat
            UnitPriceIncVAT := Round((100 + Line."VAT %") * Line."Unit Price" * 0.01, 0.00000001, '=');
        InvoiceLineDetails.Add('unitPrice', Format(UnitPriceIncVAT, 0, 1));
        LineGrossAmount := Round(UnitPriceIncVAT * Line.Quantity, 0.01, '<');
        LineTaxAmount := Round((Line."VAT %" * LineGrossAmount) / (100 + Line."VAT %"), 0.01, '<');
        if (Line."Line Discount Amount" = 0) and (Line."Inv. Discount Amount" = 0) then begin
            InvoiceLineDetails.Add('discountFlag', Format(Enum::"ASL.EFRIS.Discount"::"Non-Discount Item".AsInteger(), 0, 1));
        end
        else begin
            // NAV VAT calculation excludes discount
            // EFRIS requires tax calculation amount on undiscounted amount and 
            // a separate line for the discount            
            InvoiceLineDetails.Add('discountFlag', Format(Enum::"ASL.EFRIS.Discount"::"On Entire Item".AsInteger(), 0, 1));
            if PricesIncludeVAT then
                InvoiceLineDetails.Add('discountTotal', Format(-Round(Line."Line Discount Amount" + Line."Inv. Discount Amount", 0.00000001, '<'), 0, 1))
            else // set discount inc. vat
                InvoiceLineDetails.Add('discountTotal', Format(-Round((100 + Line."VAT %") * (Line."Line Discount Amount" + Line."Inv. Discount Amount") * 0.01, 0.00000001, '='), 0, 1));
        end;
        //
        VatProdPostingGroup.Get(Line."VAT Prod. Posting Group");

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            InvoiceLineDetails.Add('taxRate', '0')
        else
            if Zero or
               (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)")
            then
                InvoiceLineDetails.Add('taxRate', '0')
            else
                if Exempt or
                   (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                    Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)")
                then
                    InvoiceLineDetails.Add('taxRate', '-')
                else
                    InvoiceLineDetails.Add(
                        'taxRate',
                        Format(Line."VAT %" * 0.01, 0, 1));

        InvoiceLineDetails.Add('tax', Format(LineTaxAmount, 0, 1));
        InvoiceLineDetails.Add('total', Format(LineGrossAmount, 0, 1));

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            InvoiceLineDetails.Add('vatApplicableFlag', '0')
        else
            InvoiceLineDetails.Add('vatApplicableFlag', '1');
        //
        if Deemed then begin
            InvoiceLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Deemed".AsInteger(), 0, 1));
            InvoiceLineDetails.Add('deemedExemptCode', '101');
            InvoiceLineDetails.Add('vatProjectId', Line.ProjectID);
            InvoiceLineDetails.Add('vatProjectName', Line.ProjectName);
        end else
            InvoiceLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Not Deemed".AsInteger(), 0, 1));
        InvoiceLineDetails.Add('exciseFlag', Format(Enum::"ASL.EFRIS.Excise"::"Not Excise".AsInteger(), 0, 1));
        /* TODO: look into excise tax support        
            InvoiceLineDetails.Add('categoryId', 'Test');
            InvoiceLineDetails.Add('categoryName', 'Test');
            InvoiceLineDetails.Add('exciseRate', '0.12');
            InvoiceLineDetails.Add('exciseRule', '1');
            InvoiceLineDetails.Add('exciseTax', '20.22');
            InvoiceLineDetails.Add('pack', '1');
            InvoiceLineDetails.Add('stick', '20');
            InvoiceLineDetails.Add('exciseUnit', '101');
            InvoiceLineDetails.Add('exciseCurrency', 'UGX');
            InvoiceLineDetails.Add('exciseRateName', '123');*/

        if SalesInvoice."ASL.EFRIS.InvoiceIndustryCode" = SalesInvoice."ASL.EFRIS.InvoiceIndustryCode"::Export then begin
            Line.TestField("Total Weight");
            InvoiceLineDetails.Add('totalWeight', Format(Line."Total Weight"));

            if Line.Type = Line.Type::Item then begin
                Item.Reset();
                Item.SetRange("No.", Line."No.");
                if Item.FindFirst() then begin
                    Item.TestField("ASL.EFRIS.PieceUnitOfMeasure");

                    ItemUnitOfMeasure.Reset();
                    ItemUnitOfMeasure.SetRange("Item No.", Line."No.");
                    ItemUnitOfMeasure.SetRange(Code, Item."ASL.EFRIS.PieceUnitOfMeasure");
                    if ItemUnitOfMeasure.FindFirst() then begin
                        InvoiceLineDetails.Add('pieceQty', Format(Line.Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure"))
                    end;

                    if UnitOfMeasure1.Get(Item."ASL.EFRIS.PieceUnitOfMeasure") then begin
                        if UnitOfMeasure1."ASL.EFRIS.EFRISUOMCode" = '' then Error(ErrEFRISUOMNotMapped, UnitOfMeasure1.Code);
                        EFRISUnitOfMeasure1.Get(UnitOfMeasure1."ASL.EFRIS.EFRISUOMCode");
                        InvoiceLineDetails.Add('pieceMeasureUnit', EFRISUnitOfMeasure1.Code);
                    end;
                end;
            end;
        end;

        InvoiceLines.Add(InvoiceLineDetails);
    end;

    [TryFunction]
    local procedure AddInvoiceDiscountLine(OrderNo: Integer;
    Var Line: Record "Sales Invoice Line";
    PricesIncludeVAT: Boolean;
    Deemed: Boolean;
    Exempt: Boolean;
    Zero: Boolean;
    var GrossAmount: Decimal;
    var TaxAmount: Decimal;
    var InvoiceLines: JsonArray)
    var
        UnitOfMeasure: Record "Unit Of Measure";
        EFRISUnitOfMeasure: Record "ASL.EFRIS.Unit";
        Item: Record "Item";
        CommodityCategory: Record "ASL.EFRIS.CommodityCategory";
        VatProdPostingGroup: Record "VAT Product Posting Group";
        InvoiceLineDetails: JsonObject;
        TaxRate: Decimal;
    begin
        if (Line."Line Discount Amount" <= 0) and (Line."Inv. Discount Amount" <= 0) then exit;
        InvoiceLineDetails.Add('orderNumber', Format(OrderNo, 0, 1));
        InvoiceLineDetails.Add('itemCode', Line."No.");
        if Deemed then
            InvoiceLineDetails.Add('item', Line.Description + ' (Deemed) (Discount)')
        else
            InvoiceLineDetails.Add('item', Line.Description + ' (Discount)');
        Item.Get(Line."No.");
        CommodityCategory.Get(Item."ASL.EFRIS.CmdtCategoryCode");
        InvoiceLineDetails.Add('goodsCategoryId', CommodityCategory.Code);
        InvoiceLineDetails.Add('goodsCategoryName', CommodityCategory.Name);
        if PricesIncludeVAT then
            GrossAmount := Round(Line."Line Discount Amount" + Line."Inv. Discount Amount", 0.00000001, '=')
        else // set price inc. vat
            GrossAmount := Round((100 + Line."VAT %") * (Line."Line Discount Amount" + Line."Inv. Discount Amount") * 0.01, 0.00000001, '=');
        InvoiceLineDetails.Add('total', Format(-GrossAmount, 0, 1));


        /* VatProdPostingGroup.Get(Line."VAT Prod. Posting Group");
        if Zero or (VatProdPostingGroup."ASL.EFRIS.TaxCategory" = Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)") then
            InvoiceLineDetails.Add('taxRate', '0')
        else
            if Exempt or (VatProdPostingGroup."ASL.EFRIS.TaxCategory" = Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)") then
                InvoiceLineDetails.Add('taxRate', '-')
            else
                InvoiceLineDetails.Add('taxRate', Format(Line."VAT %" * 0.01, 0, 1));


        TaxAmount := Round((Line."VAT %" * GrossAmount) / (100 + Line."VAT %"), 0.01, '<');
        InvoiceLineDetails.Add('tax', Format(-TaxAmount, 0, 1));
 */
        VatProdPostingGroup.Get(Line."VAT Prod. Posting Group");

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            InvoiceLineDetails.Add('taxRate', '0')
        else
            if Zero or
               (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)")
            then
                InvoiceLineDetails.Add('taxRate', '0')
            else
                if Exempt or
                   (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                    Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)")
                then
                    InvoiceLineDetails.Add('taxRate', '-')
                else
                    InvoiceLineDetails.Add(
                        'taxRate',
                        Format(Line."VAT %" * 0.01, 0, 1));

        TaxAmount := Round(
            (Line."VAT %" * GrossAmount) / (100 + Line."VAT %"),
            0.01,
            '<');

        InvoiceLineDetails.Add('tax', Format(-TaxAmount, 0, 1));

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            InvoiceLineDetails.Add('vatApplicableFlag', '0')
        else
            InvoiceLineDetails.Add('vatApplicableFlag', '1');

        InvoiceLineDetails.Add('discountFlag', Format(Enum::"ASL.EFRIS.Discount"::"On Amount".AsInteger(), 0, 1));
        if Deemed then begin
            InvoiceLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Deemed".AsInteger(), 0, 1));
            InvoiceLineDetails.Add('deemedExemptCode', '101');
            InvoiceLineDetails.Add('vatProjectId', Line.ProjectID);
            InvoiceLineDetails.Add('vatProjectName', Line.ProjectName);
        end
        else
            InvoiceLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Not Deemed".AsInteger(), 0, 1));
        InvoiceLineDetails.Add('exciseFlag', Format(Enum::"ASL.EFRIS.Excise"::"Not Excise".AsInteger(), 0, 1));
        InvoiceLines.Add(InvoiceLineDetails);
    end;

    local procedure AddSalesTaxDetails(TaxCategory: Enum "ASL.EFRIS.TaxCategory";
    GrossAmount: Decimal;
    TaxRate: Decimal;
    TaxAmount: Decimal;
    var TaxDetails: Dictionary of [Integer, List of [Decimal]])
    var
        TaxDetailsKeys: List of [Integer];
        TaxDetailsKey: Integer;
        TaxCategoryCode: Integer;
        I: Integer;
        TaxAndGrossAmounts: List of [Decimal];
        Found: Boolean;
    begin
        TaxCategoryCode := TaxCategory.AsInteger();
        if TaxDetails.Count > 0 then begin
            TaxDetailsKeys := TaxDetails.Keys();
            I := 1;
            repeat
                if TaxDetailsKeys.Get(I, TaxDetailsKey) then begin
                    if TaxDetailsKey = TaxCategoryCode then begin
                        if TaxDetails.Get(TaxDetailsKey, TaxAndGrossAmounts) then begin
                            TaxAndGrossAmounts.Set(1, (TaxAndGrossAmounts.Get(1) + GrossAmount));
                            TaxAndGrossAmounts.Set(3, (TaxAndGrossAmounts.Get(3) + TaxAmount));
                            TaxDetails.Set(TaxDetailsKey, TaxAndGrossAmounts);
                            Found := true;
                        end;
                    end;
                end;
                I += 1;
            until Found or (I > TaxDetailsKeys.Count);
        end;
        if not Found then begin
            TaxAndGrossAmounts.Add(GrossAmount);
            TaxAndGrossAmounts.Add(TaxRate);
            TaxAndGrossAmounts.Add(TaxAmount);
            TaxDetails.Add(TaxCategoryCode, TaxAndGrossAmounts);
        end;
    end;
    //

    local procedure SetTaxDetailFieldValues(
        TaxCategory: Enum "ASL.EFRIS.TaxCategory";
        GrossAmount: Decimal;
        TaxRate: Decimal;
        TaxAmount: Decimal;
        var TaxDetails: JsonArray)
    var
        TaxCategoryCode: Text[2];
        TaxDetailLine: JsonObject;
    begin
        TaxCategoryCode := Format(TaxCategory.AsInteger(), 0, 1);
        if StrLen(TaxCategoryCode) = 1 then
            TaxCategoryCode := '0' + TaxCategoryCode;

        TaxDetailLine.Add('taxCategory', Format(TaxCategory));
        TaxDetailLine.Add('taxCategoryCode', TaxCategoryCode);
        TaxDetailLine.Add(
            'netAmount',
            Format(
                Round(GrossAmount - TaxAmount, 0.00000001, '='),
                0,
                1));

        if TaxCategory =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then begin
            TaxDetailLine.Add('taxRate', '0');
            TaxDetailLine.Add('taxRateName', '0%');
        end else
            if (TaxCategory =
                Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)") or
               (TaxCategory =
                Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)")
            then
                TaxDetailLine.Add('taxRate', '-')
            else
                TaxDetailLine.Add(
                    'taxRate',
                    Format(Round(TaxRate * 0.01, 0.01, '<'), 0, 1));

        TaxDetailLine.Add('taxAmount', Format(TaxAmount, 0, 1));
        TaxDetailLine.Add('grossAmount', Format(GrossAmount, 0, 1));

        TaxDetails.Add(TaxDetailLine);
    end;

    //

    /* local procedure SetTaxDetailFieldValues(TaxCategory: Enum "ASL.EFRIS.TaxCategory";
    GrossAmount: Decimal;
    TaxRate: Decimal;
    TaxAmount: Decimal;
    var TaxDetails: JsonArray)
    var
        TaxCategoryCode: Text[2];
        TaxDetailLine: JsonObject;
    begin
        TaxCategoryCode := Format(TaxCategory.AsInteger(), 0, 1);
        if StrLen(TaxCategoryCode) = 1 then TaxCategoryCode := '0' + TaxCategoryCode;
        if TaxDetailLine.Contains('taxCategory') then TaxDetailLine.Remove('taxCategory');
        TaxDetailLine.Add('taxCategory', Format((TaxCategory)));
        if TaxDetailLine.Contains('taxCategoryCode') then TaxDetailLine.Remove('taxCategoryCode');
        TaxDetailLine.Add('taxCategoryCode', TaxCategoryCode);
        if TaxDetailLine.Contains('netAmount') then TaxDetailLine.Remove('netAmount');
        TaxDetailLine.Add('netAmount', Format(Round(GrossAmount - TaxAmount, 0.00000001, '='), 0, 1));
        if TaxDetailLine.Contains('taxRate') then TaxDetailLine.Remove('taxRate');
        IF TaxCategory = Enum::"ASL.EFRIS.TaxCategory"::"F: VAT Not Applicable" THEN begin
            TaxDetailLine.Add('taxRate', '0.18')
        end;
        if TaxDetailLine.Contains('taxRate') then TaxDetailLine.Remove('taxRate');
        if (TaxCategory = Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)") or (TaxCategory = Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)") then
            TaxDetailLine.Add('taxRate', '-')
        else
            TaxDetailLine.Add('taxRate', Format(Round(TaxRate * 0.01, 0.01, '<'), 0, 1));
        if TaxDetailLine.Contains('taxAmount') then TaxDetailLine.Remove('taxAmount');
        TaxDetailLine.Add('taxAmount', Format(TaxAmount, 0, 1));
        if TaxDetailLine.Contains('grossAmount') then TaxDetailLine.Remove('grossAmount');
        TaxDetailLine.Add('grossAmount', Format(GrossAmount, 0, 1));
        TaxDetails.Add(TaxDetailLine);
    end; */

    procedure SendCreditNoteApplication(var SalesCrMemo: Record "Sales Cr.Memo Header";
    PreviewMode: Boolean): Boolean
    var
        CrNoteApplnRequest: JsonObject;
        GoodsDetails: JsonArray;
        InvoiceDetailsQuery: JsonObject;
        InvoiceDetailsQueryResult: JsonToken;
        InvoiceGoodsDetails: JsonArray;
        InvoiceGoodsDetailsLine: JsonObject;
        VATTaxCategory: Enum "ASL.EFRIS.TaxCategory";
        TaxDetails: JsonArray;
        Summary: JsonObject;
        Payments: JsonArray;
        Payment: JsonObject;
        BasicInfo: JsonObject;
        SelletDetails: JsonObject;
        BuyerDetails: JsonObject;
        BuyerExtendDetails: JsonObject;
        CrNoteApplnResponse: JsonToken;
        SalesInvHeader: Record "Sales Invoice Header";
        Currency: Record Currency;
        EFRISCurrency: Record "ASL.EFRIS.Currency";
        EFRISSetup: Record "Sales & Receivables Setup";
        NonLCY: Boolean;
        CrMemoLines: Record "Sales Cr.Memo Line";
        TaxDetailsAccuml: Dictionary of [Integer, List of [Decimal]];
        TaxDetailsKeys: List of [Integer];
        TaxDetailsKey: Integer;
        GrossAndTaxAmounts: List of [Decimal];
        Customer: Record Customer;
        CrMemoGetInvDetailsFailed: Boolean;
        VatProdPostingGroup: Record "VAT Product Posting Group";
        I: Integer;
        J: Integer;
        T: Integer;
        FoundOrderNo: Integer;
        LineGrossAmount: Decimal;
        LineTaxAmount: Decimal;
        TotalGrossAmount: Decimal;
        TotalTaxAmount: Decimal;
        Success: Boolean;
        SelectToken: JsonToken;
    begin
        LogTrace(StrSubstNo('Send Credit Note Application for Credit Memo %1', SalesCrMemo."No."));
        if SalesCrMemo."ASL.EFRIS.ReferenceNo" <> '' then begin
            LastErrorMessage := StrSubstNo(ErrCrMemoAlreadyToEFRIS, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        EFRISSetup.Get();
        if SalesCrMemo."Applies-to Doc. Type" <> Enum::"Gen. Journal Document Type"::Invoice then begin
            LastErrorMessage := ErrCrMemoNotApplied;
            LogError(LastErrorMessage);
            exit(false);
        end;
        SalesInvHeader.Get(SalesCrMemo."Applies-to Doc. No.");
        if SalesInvHeader."ASL.EFRIS.InvoiceId" = '' then begin
            LastErrorMessage := StrSubstNo(ErrCrMemoAppliedInvNotToEFRIS, SalesCrMemo."Applies-to Doc. No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        CrNoteApplnRequest.Add('oriInvoiceId', SalesInvHeader."ASL.EFRIS.InvoiceId");
        CrNoteApplnRequest.Add('oriInvoiceNo', SalesInvHeader."ASL.EFRIS.InvoiceNo");
        CrNoteApplnRequest.Add('reasonCode', Format(SalesCrMemo."ASL.EFRIS.RefundReasonCode".AsInteger(), 0, 1));
        CrNoteApplnRequest.Add('reason', SalesCrMemo."ASL.EFRIS.RefundReason");
        CrNoteApplnRequest.Add('applicationTime', Format(CreateDateTime(Today, Time), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
        CrNoteApplnRequest.Add('invoiceApplyCategoryCode', '101'); // 101 - Credit Note"
        if SalesCrMemo."Currency Code" <> '' then begin
            IF SalesCrMemo."Currency Code" <> SalesInvHeader."Currency Code" then begin
                LastErrorMessage := StrSubstNo(ErrCrMemoCurrencyNotInvCurrency, SalesCrMemo."No.", SalesInvHeader."No.", SalesInvHeader."Currency Code");
                exit(false);
            end;
            Currency.Get(SalesCrMemo."Currency Code");
            if Currency."ASL.EFRIS.EFRISCurrencyCode" = '' then begin
                LastErrorMessage := StrSubstNo(ErrMissingEFRISCurrencyCode, Currency.Code);
                LogError(LastErrorMessage);
                exit(false);
            end;
            EFRISCurrency.Get(Currency."ASL.EFRIS.EFRISCurrencyCode");
            NonLCY := true;
        end
        else begin
            if EFRISSetup."ASL.EFRIS.LCYEFRISCurrencyCode" = '' then begin
                LastErrorMessage := StrSubstNo(ErrMissingLCYEFRISCurrencyCode);
                LogError(LastErrorMessage);
                exit(false);
            end;
            EFRISCurrency.Get(EFRISSetup."ASL.EFRIS.LCYEFRISCurrencyCode");
            NonLCY := false;
        end;
        CrNoteApplnRequest.Add('currency', EFRISCurrency.Name);
        CrNoteApplnRequest.Add('contactName', EFRISSetup."ASL.EFRIS.CrNotesContactName");
        CrNoteApplnRequest.Add('contactMobileNum', EFRISSetup."ASL.EFRIS.CrNotesContactMobile");
        CrNoteApplnRequest.Add('contactEmail', EFRISSetup."ASL.EFRIS.CrNotesContactEmail");
        CrNoteApplnRequest.Add('source', Format(Enum::"ASL.EFRIS.DataSource"::Mis.AsInteger(), 0, 1));
        CrNoteApplnRequest.Add('remarks', SalesCrMemo."ASL.EFRIS.Remarks");
        CrNoteApplnRequest.Add('sellersReferenceNo', SalesCrMemo."No.");
        // lines
        // CrMemoLines.Reset();
        CrMemoLines.SetCurrentKey("Order Number");
        CrMemoLines.SetAscending("Order Number", true);
        CrMemoLines.SetRange(CrMemoLines."Document No.", SalesCrMemo."No.");
        CrMemoLines.SetRange(CrMemoLines.Type, CrMemoLines.Type::Item);
        CrMemoLines.SetFilter(CrMemoLines."No.", '<>''''');
        if not CrMemoLines.FindSet() then begin
            LastErrorMessage := ErrCrMemoNoLines;
            LogError(LastErrorMessage);
            exit(false);
        end;
        // get original invoice details to match line order nos.
        // get invoice id by ref number
        InvoiceDetailsQuery.Add('invoiceNo', SalesInvHeader."ASL.EFRIS.InvoiceNo");
        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T108, InvoiceDetailsQuery.AsToken(), InvoiceDetailsQueryResult) then exit(false);
        CrMemoGetInvDetailsFailed := false;
        CrMemoGetInvDetailsFailed := not InvoiceDetailsQueryResult.IsObject();
        if not CrMemoGetInvDetailsFailed then begin
            if not InvoiceDetailsQueryResult.SelectToken('$.goodsDetails', SelectToken) then CrMemoGetInvDetailsFailed := true;
            if not CrMemoGetInvDetailsFailed then CrMemoGetInvDetailsFailed := not SelectToken.IsArray();
            if not CrMemoGetInvDetailsFailed then CrMemoGetInvDetailsFailed := SelectToken.AsArray().Count = 0;
        end;
        if CrMemoGetInvDetailsFailed then begin
            LastErrorMessage := StrSubstNo(ErrCrMemoGetInvDetailsFailed, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        InvoiceGoodsDetails := SelectToken.AsArray();
        I := 0;
        repeat // find invoice order number for item
            J := 0;
            FoundOrderNo := -1;
            repeat
                InvoiceGoodsDetails.Get(J, SelectToken);
                InvoiceGoodsDetailsLine := SelectToken.AsObject();
                InvoiceGoodsDetailsLine.SelectToken('itemCode', SelectToken);
                if SelectToken.AsValue().AsText() = CrMemoLines."No." then begin
                    InvoiceGoodsDetailsLine.SelectToken('orderNumber', SelectToken);
                    FoundOrderNo := SelectToken.AsValue().AsInteger();
                end;
                J += 1;
            until (FoundOrderNo >= 0) or (J = InvoiceGoodsDetails.Count);
            if FoundOrderNo < 0 then begin
                LastErrorMessage := StrSubstNo(ErrCrMemoItemNotInApplInvoice, CrMemoLines."No.", SalesInvHeader."No.");
                LogError(LastErrorMessage);
                exit(false);
            end;
            LineGrossAmount := 0;
            LineTaxAmount := 0;
            FoundOrderNo := CrMemoLines."Order Number";
            if not AddCrNoteLineDetails(FoundOrderNo, CrMemoLines, SalesInvHeader."Prices Including VAT", SalesInvHeader."ASL.EFRIS.VATDeemed", SalesInvHeader."ASL.EFRIS.VATExempt", SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" = Enum::"ASL.EFRIS.InvoiceIndustryCode"::Export, LineGrossAmount, LineTaxAmount, GoodsDetails) then begin
                LastErrorMessage := GetLastErrorText();
                LogError(LastErrorMessage);
                exit(false);
            end;


            /* if SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" = Enum::"ASL.EFRIS.InvoiceIndustryCode"::Export then
                VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else
                if SalesInvHeader."ASL.EFRIS.VATDeemed" then
                    VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                else
                    if SalesInvHeader."ASL.EFRIS.VATExempt" then
                        VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                    else begin
                        VatProdPostingGroup.Get(CrMemoLines."VAT Prod. Posting Group");
                        VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");
                        VATTaxCategory := VatProdPostingGroup."ASL.EFRIS.TaxCategory";
                    end; */
            if SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" =
               Enum::"ASL.EFRIS.InvoiceIndustryCode"::Export
            then
                VATTaxCategory :=
                    Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else begin
                VatProdPostingGroup.Get(
                    CrMemoLines."VAT Prod. Posting Group");
                VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");

                if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                   Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                then
                    VATTaxCategory :=
                        Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                else
                    if SalesInvHeader."ASL.EFRIS.VATDeemed" then
                        VATTaxCategory :=
                            Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                    else
                        if SalesInvHeader."ASL.EFRIS.VATExempt" then
                            VATTaxCategory :=
                                Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                        else
                            VATTaxCategory :=
                                VatProdPostingGroup."ASL.EFRIS.TaxCategory";
            end;

            //


            AddSalesTaxDetails(VATTaxCategory, LineGrossAmount, CrMemoLines."VAT %", LineTaxAmount, TaxDetailsAccuml);
            TotalGrossAmount += LineGrossAmount;
            TotalTaxAmount += LineTaxAmount;
            I += 1;
        until CrMemoLines.Next() = 0;
        CrNoteApplnRequest.Add('goodsDetails', GoodsDetails);
        // tax details
        if TaxDetailsAccuml.Count > 0 then begin
            TaxDetailsKeys := TaxDetailsAccuml.Keys();
            T := 1;
            repeat
                if TaxDetailsKeys.Get(T, TaxDetailsKey) then begin
                    if TaxDetailsAccuml.Get(TaxDetailsKey, GrossAndTaxAmounts) then begin
                        SetTaxDetailFieldValues(Enum::"ASL.EFRIS.TaxCategory".FromInteger(TaxDetailsKey), GrossAndTaxAmounts.Get(1), GrossAndTaxAmounts.Get(2), GrossAndTaxAmounts.Get(3), TaxDetails);
                    end;
                end;
                T += 1;
            until T > TaxDetailsKeys.Count;
            CrNoteApplnRequest.Add('taxDetails', TaxDetails);
        end;
        // Error('Nope');
        // summary
        Summary.Add('netAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        if SalesInvHeader."ASL.EFRIS.VATDeemed" or SalesInvHeader."ASL.EFRIS.VATExempt" then begin
            Summary.Add('taxAmount', Format(0, 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        end
        else begin
            Summary.Add('taxAmount', Format(Round(TotalTaxAmount, 0.01, '<'), 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount, 0.01, '<'), 0, 1));
        end;
        Summary.Add('itemCount', Format(I, 0, 1));
        Summary.Add('modeCode', '1'); // 1 - online, 0 - offline
        Summary.Add('remarks', '');
        Summary.Add('qrCode', '');
        CrNoteApplnRequest.Add('summary', Summary);
        // payway
        EFRISSetup.Get();
        if SalesInvHeader."ASL.EFRIS.PaymentMode" <> Enum::"ASL.EFRIS.PaymentMode"::" " then
            Payment.Add('paymentMode', Format(SalesInvHeader."ASL.EFRIS.PaymentMode".AsInteger(), 0, 1))
        else begin
            if EFRISSetup."ASL.EFRIS.InvoicePaymentMode" = Enum::"ASL.EFRIS.PaymentMode"::" " then Error(ErrMissingPaymentMode, SalesInvHeader."No.");
            Payment.Add('paymentMode', Format(EFRISSetup."ASL.EFRIS.InvoicePaymentMode".AsInteger(), 0, 1));
        end;
        Payment.Add('paymentAmount', Format(TotalGrossAmount, 0, 1));
        Payment.Add('orderNumber', 'a');
        Payments.Add(Payment);
        CrNoteApplnRequest.Add('payWay', Payments);
        // seller info
        if not SetSalesSellerDetails(Enum::"Sales Document Type"::"Credit Memo", SalesInvHeader, SalesCrMemo, SelletDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        CrNoteApplnRequest.Add('sellerDetails', SelletDetails);
        // basic info
        if not SetInvoiceBasicInfo(SalesCrMemo."Currency Code", SalesCrMemo."Posting Date", Enum::"ASL.EFRIS.InvoiceType"::"Invoice/Receipt", SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode", SalesInvHeader."ASL.EFRIS.InvoiceId", false, BasicInfo, SalesCrMemo."ASL.EFRIS.DeliveryTerms"::" ") then exit(false);
        CrNoteApplnRequest.Add('basicInformation', BasicInfo);
        // buyer info
        Customer.Get(SalesCrMemo."Bill-to Customer No.");
        if not SetSalesBuyerDetails(SalesInvHeader, Customer, BuyerDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        CrNoteApplnRequest.Add('buyerDetails', BuyerDetails);
        if not SetInvoiceEmptyBuyerExtendDetails(BuyerExtendDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        CrNoteApplnRequest.Add('buyerExtend', BuyerExtendDetails);
        // if Preview Mode then exit with success        
        if PreviewMode then exit(true);
        // if not Preview Mode then proceed with sending request
        Success := SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T110, CrNoteApplnRequest.AsToken(), CrNoteApplnResponse);
        if Success then begin
            SalesCrMemo."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Success;
            SalesCrMemo."ASL.EFRIS.UploadErrorCode" := '';
            SalesCrMemo."ASL.EFRIS.UploadErrorMessage" := '';
            SalesCrMemo."ASL.EFRIS.UploadErrorAction" := Enum::"ASL.EFRIS.UploadErrorAction"::" ";
            SalesCrMemo."ASL.EFRIS.ApprovalStatus" := SalesCrMemo."ASL.EFRIS.ApprovalStatus"::Submitted;
            if CrNoteApplnResponse.SelectToken('$.referenceNo', SelectToken) then begin
                SalesCrMemo."ASL.EFRIS.ReferenceNo" := SelectToken.AsValue().AsText();
            end;
        end
        else begin
            SalesCrMemo."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Error;
            SalesCrMemo."ASL.EFRIS.UploadErrorCode" := LastReturnStateCode;
            SalesCrMemo."ASL.EFRIS.UploadErrorMessage" := CopyStr(GetLastErrorMessage(), 1, MaxStrLen(SalesCrMemo."ASL.EFRIS.UploadErrorMessage"));
            SalesCrMemo."ASL.EFRIS.UploadErrorAction" := Enum::"ASL.EFRIS.UploadErrorAction"::Skip;
        end;
        exit(Success);
    end;

    [TryFunction]
    local procedure AddCrNoteLineDetails(OrderNo: Integer;
    Var Line: Record "Sales Cr.Memo Line";
    PricesIncludeVAT: Boolean;
    Deemed: Boolean;
    Exempt: Boolean;
    Zero: Boolean;
    var LineGrossAmount: Decimal;
    var LineTaxAmount: Decimal;
    var CrNoteLines: JsonArray)
    var
        UnitOfMeasure: Record "Unit Of Measure";
        EFRISUnitOfMeasure: Record "ASL.EFRIS.Unit";
        Item: Record "Item";
        CommodityCategory: Record "ASL.EFRIS.CommodityCategory";
        VatProdPostingGroup: Record "VAT Product Posting Group";
        CrNoteLineDetails: JsonObject;
        UnitPriceIncVAT: Decimal;
        GLAccount: record "G/L Account";
    begin
        if (Line.Type <> Line.Type::Item) and (Line.Type <> Line.Type::"G/L Account") then exit;
        // Item.Get(Line."No.");
        // if Item."ASL.EFRIS.ItemId" = '' then exit;

        if Line.Type = Line.Type::Item then begin
            Item.Get(Line."No.");
            if Item."ASL.EFRIS.ItemId" = '' then
                exit;
        end;

        if Line.Type = Line.Type::"G/L Account" then begin
            GLAccount.Get(Line."No.");
            if GLAccount."ASL.EFRIS.ProductId" = '' then
                exit;
        end;

        CrNoteLineDetails.Add('orderNumber', Format(OrderNo, 0, 1));
        CrNoteLineDetails.Add('itemCode', Line."No.");
        if Deemed then
            CrNoteLineDetails.Add('item', Line.Description + ' (Deemed)')
        else
            CrNoteLineDetails.Add('item', Line.Description);

        if Line.Type = Line.Type::Item then begin
            Item.Get(Line."No.");
            CommodityCategory.Get(Item."ASL.EFRIS.CmdtCategoryCode");
            CrNoteLineDetails.Add('goodsCategoryId', CommodityCategory.Code);
            CrNoteLineDetails.Add('goodsCategoryName', CommodityCategory.Name);
        end;

        if Line.Type = Line.Type::"G/L Account" then begin
            GLAccount.Get(Line."No.");
            CommodityCategory.Get(GLAccount."ASL.EFRIS.CmdtCategoryCode");
            CrNoteLineDetails.Add('goodsCategoryId', CommodityCategory.Code);
            CrNoteLineDetails.Add('goodsCategoryName', CommodityCategory.Name);
        end;

        CrNoteLineDetails.Add('qty', Format(-Line.Quantity, 0, 1));
        UnitOfMeasure.Get(Line."Unit of Measure Code");
        if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then Error(ErrEFRISUOMNotMapped, UnitOfMeasure.Code);
        EFRISUnitOfMeasure.Get(UnitOfMeasure."ASL.EFRIS.EFRISUOMCode");
        CrNoteLineDetails.Add('unitOfMeasure', EFRISUnitOfMeasure.Code);
        if PricesIncludeVAT then
            UnitPriceIncVAT := Round(Line."Unit Price", 0.00000001, '=')
        else // set price inc. vat
            UnitPriceIncVAT := Round((100 + Line."VAT %") * Line."Unit Price" * 0.01, 0.00000001, '=');
        CrNoteLineDetails.Add('unitPrice', Format(UnitPriceIncVAT, 0, 1));
        LineGrossAmount := -Round(UnitPriceIncVAT * Line.Quantity, 0.01, '<');
        if (Line."Line Discount Amount" > 0) or (Line."Inv. Discount Amount" > 0) then LineGrossAmount += (Line."Line Discount Amount" + Line."Inv. Discount Amount");
        LineTaxAmount := Round((Line."VAT %" * LineGrossAmount) / (100 + Line."VAT %"), 0.01, '<');
        CrNoteLineDetails.Add('total', Format(LineGrossAmount, 0, 1));


        /* VatProdPostingGroup.Get(Line."VAT Prod. Posting Group");
        if Zero or (VatProdPostingGroup."ASL.EFRIS.TaxCategory" = Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)") then
            CrNoteLineDetails.Add('taxRate', '0')
        else
            if Exempt or (VatProdPostingGroup."ASL.EFRIS.TaxCategory" = Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)") then
                CrNoteLineDetails.Add('taxRate', '-')
            else
                CrNoteLineDetails.Add('taxRate', Format(Line."VAT %" * 0.01, 0, 1));
        CrNoteLineDetails.Add('tax', Format(LineTaxAmount, 0, 1)); */

        VatProdPostingGroup.Get(Line."VAT Prod. Posting Group");

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            CrNoteLineDetails.Add('taxRate', '0')
        else
            if Zero or
               (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)")
            then
                CrNoteLineDetails.Add('taxRate', '0')
            else
                if Exempt or
                   (VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                    Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)")
                then
                    CrNoteLineDetails.Add('taxRate', '-')
                else
                    CrNoteLineDetails.Add(
                        'taxRate',
                        Format(Line."VAT %" * 0.01, 0, 1));

        CrNoteLineDetails.Add('tax', Format(LineTaxAmount, 0, 1));

        if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
           Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
        then
            CrNoteLineDetails.Add('vatApplicableFlag', '0')
        else
            CrNoteLineDetails.Add('vatApplicableFlag', '1');

        if Deemed then begin
            CrNoteLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Deemed".AsInteger(), 0, 1));
            CrNoteLineDetails.Add('vatProjectId', Line.ProjectID);
            CrNoteLineDetails.Add('vatProjectName', Line.ProjectName);
        end else
            CrNoteLineDetails.Add('deemedFlag', Format(Enum::"ASL.EFRIS.Deemed"::"Not Deemed".AsInteger(), 0, 1));
        CrNoteLineDetails.Add('exciseFlag', Format(Enum::"ASL.EFRIS.Excise"::"Not Excise".AsInteger(), 0, 1));
        /*   CrNoteLineDetails.Add('pack', '1');
          CrNoteLineDetails.Add('stick', '20'); */
        /* TODO: look into excise tax support        
            InvoiceLineDetails.Add('categoryId', 'Test');
            InvoiceLineDetails.Add('categoryName', 'Test');
            InvoiceLineDetails.Add('exciseRate', '0.12');
            InvoiceLineDetails.Add('exciseRule', '1');
            InvoiceLineDetails.Add('exciseTax', '20.22');
            InvoiceLineDetails.Add('pack', '1');
            InvoiceLineDetails.Add('stick', '20');
            InvoiceLineDetails.Add('exciseUnit', '101');
            InvoiceLineDetails.Add('exciseCurrency', 'UGX');
            InvoiceLineDetails.Add('exciseRateName', '123');*/
        CrNoteLines.Add(CrNoteLineDetails);
    end;

    procedure SyncCrNoteApprovalStatus(var SalesCrMemo: Record "Sales Cr.Memo Header"): Boolean
    var
        CrNoteApplnQuery: JsonObject;
        CrNoteApplnQueryResponse: JsonToken;
        Success: Boolean;
        SelectToken: JsonToken;
        ResponseArray: JsonArray;
        ResponseCreditNoteDetails: JsonObject;
        ResponseApprovalStatus: Enum "ASL.EFRIS.CrNtApplApprovStatus";
        Approved: Boolean;
    begin
        LogTrace(StrSubstNo('Sync. Credit Note Approval Status for Credit Memo %1', SalesCrMemo."No."));
        if SalesCrMemo."ASL.EFRIS.ReferenceNo" = '' then begin
            LastErrorMessage := (StrSubstNo(ErrCrMemoSyncNoRefNo, SalesCrMemo."No."));
            LogError(LastErrorMessage);
            exit(false);
        end;
        CrNoteApplnQuery.Add('referenceNo', SalesCrMemo."ASL.EFRIS.ReferenceNo");
        CrNoteApplnQuery.Add('queryType', '1');
        Success := SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T111, CrNoteApplnQuery.AsToken(), CrNoteApplnQueryResponse);
        if Success then begin
            if CrNoteApplnQueryResponse.SelectToken('records', SelectToken) then ResponseArray := SelectToken.AsArray();
            if ResponseArray.Count = 1 then begin
                ResponseArray.Get(0, SelectToken);
                ResponseCreditNoteDetails := SelectToken.AsObject();
                ResponseCreditNoteDetails.SelectToken('approveStatus', SelectToken);
                ResponseApprovalStatus := Enum::"ASL.EFRIS.CrNtApplApprovStatus".FromInteger(SelectToken.AsValue().AsInteger());
                SalesCrMemo."ASL.EFRIS.ApprovalStatus" := ResponseApprovalStatus;
                if ResponseCreditNoteDetails.SelectToken('id', SelectToken) then SalesCrMemo."ASL.EFRIS.InvoiceId" := SelectToken.AsValue().AsText();
                if ResponseApprovalStatus = Enum::"ASL.EFRIS.CrNtApplApprovStatus"::Approved then begin
                    if ResponseCreditNoteDetails.SelectToken('invoiceNo', SelectToken) then SalesCrMemo."ASL.EFRIS.InvoiceNo" := SelectToken.AsValue().AsText();
                    Approved := true;
                end;
                if Approved then begin
                    if not GetEFRISCrNoteDetails(SalesCrMemo) then exit(false);
                end;
                SalesCrMemo.Modify();
            end;
        end;
        exit(Success);
    end;

    procedure VoidCreditNote(var SalesCrMemo: Record "Sales Cr.Memo Header"): Boolean
    var
        VoidCrNoteRequest: JsonObject;
        VoidCrNoteResponse: JsonToken;
        Success: Boolean;
    begin
        if SalesCrMemo."ASL.EFRIS.ReferenceNo" = '' then begin
            LastErrorMessage := StrSubstNo(ErrCrMemoNotSentToEFRIS, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        if (SalesCrMemo."ASL.EFRIS.ApprovalStatus" <> SalesCrMemo."ASL.EFRIS.ApprovalStatus"::" ") and (SalesCrMemo."ASL.EFRIS.ApprovalStatus" <> SalesCrMemo."ASL.EFRIS.ApprovalStatus"::Submitted) then begin
            LastErrorMessage := ErrCrMemoVoidProcessed;
            LogError(LastErrorMessage);
            exit(false);
        end;
        VoidCrNoteRequest.Add('businessKey', SalesCrMemo."ASL.EFRIS.InvoiceId");
        VoidCrNoteRequest.Add('referenceNo', SalesCrMemo."ASL.EFRIS.ReferenceNo");
        Success := SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T120, VoidCrNoteRequest.AsToken(), VoidCrNoteResponse);
        if Success then begin
            SyncCrNoteApprovalStatus(SalesCrMemo);
        end;
        exit(Success);
    end;

    procedure CancelApprovedCreditNote(var SalesCrMemo: Record "Sales Cr.Memo Header"): Boolean
    var
        OriInvoiceHdr: Record "Sales Invoice Header";
        CancelCrNoteRequest: JsonObject;
        CancelCrNoteResponse: JsonToken;
        Success: Boolean;
    begin
        LogTrace(StrSubstNo('Cancel Credit Note - Credit Memo No. %1', SalesCrMemo."No."));
        if SalesCrMemo."ASL.EFRIS.ReferenceNo" = '' then begin
            LastErrorMessage := StrSubstNo(ErrCrMemoNotSentToEFRIS, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        /*
            if (SalesCrMemo."ASL.EFRIS.ApprovalStatus" <> SalesCrMemo."ASL.EFRIS.ApprovalStatus"::Approved) then begin
                LastErrorMessage := 'You can only Cancel Approved Credit Notes';
                exit(false);
            end;*/
        OriInvoiceHdr.Get(SalesCrMemo."Applies-to Doc. No.");
        CancelCrNoteRequest.Add('oriInvoiceId', OriInvoiceHdr."ASL.EFRIS.InvoiceId");
        CancelCrNoteRequest.Add('invoiceNo', OriInvoiceHdr."ASL.EFRIS.InvoiceNo");
        if SalesCrMemo."ASL.EFRIS.CancelReasonCode" = SalesCrMemo."ASL.EFRIS.CancelReasonCode"::" " then begin
            LastErrorMessage := StrSubstNo(ErrMissingCrMemoCancelReasonCode, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        CancelCrNoteRequest.Add('reasonCode', Format(SalesCrMemo."ASL.EFRIS.CancelReasonCode".AsInteger(), 0, 1));
        if (SalesCrMemo."ASL.EFRIS.CancelReasonCode" = SalesCrMemo."ASL.EFRIS.CancelReasonCode"::"Other Reasons") and (SalesCrMemo."ASL.EFRIS.CancelOtherReason" = '') then begin
            LastErrorMessage := StrSubstNo(ErrMissingCrMemoCancelOtherReason, SalesCrMemo."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        CancelCrNoteRequest.Add('reason', SalesCrMemo."ASL.EFRIS.CancelOtherReason");
        CancelCrNoteRequest.Add('invoiceApplyCategoryCode', Format(Enum::"ASL.EFRIS.InvApplyCategoryCode"::"Cancel of Credit Note", 0, 1));
        Success := SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T114, CancelCrNoteRequest.AsToken(), CancelCrNoteResponse);
        if Success then begin
            SyncCrNoteApprovalStatus(SalesCrMemo);
        end;
        exit(Success);
    end;

    procedure GetEFRISCrNoteDetails(var SalesCrMemo: Record "Sales Cr.Memo Header"): Boolean
    var
        InvoiceQuery: JsonObject;
        InvoiceQueryResult: JsonToken;
        SelectToken: JsonToken;
    begin
        LogTrace(StrSubstNo('Get EFRIS Credit Note Details for Creadit Memo No. %1', SalesCrMemo."No."));
        Clear(InvoiceQuery);
        Clear(InvoiceQueryResult);
        InvoiceQuery.Add('invoiceNo', SalesCrMemo."ASL.EFRIS.InvoiceNo");
        if not SendInterfaceRequest(Enum::"ASL.EFRIS.InterfaceCode"::T108, InvoiceQuery.AsToken(), InvoiceQueryResult) then exit(false);
        if InvoiceQueryResult.SelectToken('$.basicInformation.antifakeCode', SelectToken) then SalesCrMemo."ASL.EFRIS.Antifakecode" := SelectToken.AsValue().AsText();
        if InvoiceQueryResult.SelectToken('$.summary.qrCode', SelectToken) then SalesCrMemo."ASL.EFRIS.QRCode" := SelectToken.AsValue().AsText();
        exit(true);
    end;

    procedure UploadProduct(var UploadProduct: Record "G/L Account";
    UpdateExisting: Boolean): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
        ProductsUploadRequest: JsonArray;
        EFRISCurrencyCode: Code[10];
        ProductUploadResponseToken: JsonToken;
        ProductUploadResponseArray: JsonArray;
        ProductUploadResponseItem: JsonToken;
        SelectToken: JsonToken;
        ResponseProductsCount: Integer;
        I: Integer;
        Now: DateTime;
        Success: Boolean;
        ProductUploadFailed: Boolean;
        FailedProductToken: JsonToken;
    begin
        LogTrace(StrSubstNo('Upload Item %1', UploadProduct."No."));
        Now := CreateDateTime(Today, Time);
        // validate commodity category
        if UploadProduct."ASL.EFRIS.CmdtCategoryCode" = '' then begin
            LastErrorMessage := StrSubstNo('EFRIS Commodity Category not specified for Item %1', UploadProduct."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        // validate unit of measure        
        if UploadProduct."ASL.EFRIS.UnitOfMeasure" <> '' then begin
            UnitOfMeasure.Get(UploadProduct."ASL.EFRIS.UnitOfMeasure");
            if UnitOfMeasure."ASL.EFRIS.EFRISUOMCode" = '' then begin
                LastErrorMessage := StrSubstNo(ErrEFRISUOMNotMapped, UploadProduct."ASL.EFRIS.UnitOfMeasure");
                LogError(LastErrorMessage);
                exit(false);
            end;
        end
        else begin
            LastErrorMessage := StrSubstNo(ErrItemMissingSalesUOM, UploadProduct."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        // validate unit price
        if UploadProduct."ASL.EFRIS.UnitPrice" = 0 then begin
            // only upload items with unit price
            // TODO: Consider extended price functionality
            LastErrorMessage := StrSubstNo(ErrItemMissingUnitPrice, UploadProduct."No.");
            LogError(LastErrorMessage);
            exit(false);
        end;
        UnitOfMeasure.Get(UploadProduct."ASL.EFRIS.UnitOfMeasure");
        if not AddUploadProduct(UploadProduct, UpdateExisting, EFRISCurrencyCode, UnitOfMeasure."ASL.EFRIS.EFRISUOMCode", ProductsUploadRequest) then exit(false);
        // send request
        Success := SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T130, ProductsUploadRequest.AsToken(), ProductUploadResponseToken);
        if not Success and (not LastHttpSuccess or (LastReturnStateCode <> '45')) then exit(false); // do not proceed if either http error or TCS error other than partial failure
        ProductUploadResponseArray := ProductUploadResponseToken.AsArray();
        ResponseProductsCount := ProductUploadResponseArray.Count;
        ProductUploadFailed := (ResponseProductsCount > 0) and (ProductUploadResponseArray.SelectToken('$[?(@.goodsCode == ''' + UploadProduct."No." + ''')]', SelectToken));
        if ProductUploadFailed then begin
            UploadProduct."ASL.EFRIS.UploadStatus" := "ASL.EFRIS.UploadStatus"::Error;
            if SelectToken.SelectToken('returnCode', FailedProductToken) then UploadProduct."ASL.EFRIS.UploadErrorCode" := FailedProductToken.AsValue().AsText();
            if SelectToken.SelectToken('returnMessage', FailedProductToken) then UploadProduct."ASL.EFRIS.UploadErrorMessage" := CopyStr(FailedProductToken.AsValue().AsText(), 1, MaxStrLen(UploadProduct."ASL.EFRIS.UploadErrorMessage"));
        end
        else begin
            if not GetEFRISProductDetails(UploadProduct) then UploadProduct."ASL.EFRIS.UploadErrorMessage" := CopyStr(GetLastErrorText(), 1, MaxStrLen(UploadProduct."ASL.EFRIS.UploadErrorMessage"));
        end;
        UploadProduct.Modify();
        if ResponseProductsCount > 0 then begin // empty respons if all succeeded
            LastErrorMessage := ErrItemsUploadFailed;
            LogError(LastErrorMessage);
            exit(false);
        end
        else
            exit(true);
    end;

    [TryFunction]
    local procedure AddUploadProduct(var GLAccount: Record "G/L Account";
    UpdateExisting: Boolean;
    EFRISCurrencyCode: Code[10];
    EFRISUOMCode: Code[20];
    var ProductsUploadRequest: JsonArray)
    var
        UploadProductObject: JsonObject;
    begin
        if UpdateExisting then
            UploadProductObject.Add('operationType', '102') // update existing
        else
            UploadProductObject.Add('operationType', '101'); // new item
        UploadProductObject.Add('goodsCode', GLAccount."No.");
        UploadProductObject.Add('goodsName', GLAccount.Name);
        UploadProductObject.Add('measureUnit', EFRISUOMCode);
        if not GetLCYEFRISCurrencyCode(EFRISCurrencyCode) then Error(GetLastErrorText());
        UploadProductObject.Add('currency', EFRISCurrencyCode);
        UploadProductObject.Add('unitPrice', Format(GLAccount."ASL.EFRIS.UnitPrice", 0, 1));
        UploadProductObject.Add('commodityCategoryId', GLAccount."ASL.EFRIS.CmdtCategoryCode");
        UploadProductObject.Add('description', GLAccount.Name);
        UploadProductObject.Add('stockPrewarning', Format(0, 1));
        // TODO: Look into Exise Duty
        UploadProductObject.Add('haveExciseTax', '102');
        UploadProductObject.Add('exciseDutyCode', '');
        // other units of measure
        // TODO: What is pieceUnit for?
        UploadProductObject.Add('havePieceUnit', '102');
        UploadProductObject.Add('pieceMeasureUnit', '');
        UploadProductObject.Add('pieceUnitPrice', '');
        UploadProductObject.Add('packageScaledValue', '');
        UploadProductObject.Add('pieceScaledValue', '');
        UploadProductObject.Add('haveOtherUnit', '102');
        ProductsUploadRequest.Add(UploadProductObject);
    end;

    procedure GetEFRISProductDetails(var Product: Record "G/L Account"): Boolean
    var
        ResponseRecord: JsonObject;
        SelectToken: JsonToken;
    begin
        if not GetEFRISItemInfo(Product."No.", ResponseRecord) then exit(false);
        if ResponseRecord.SelectToken('id', SelectToken) then Product."ASL.EFRIS.ProductId" := SelectToken.AsValue().AsText();
        if ResponseRecord.SelectToken('commodityCategoryCode', SelectToken) then Product.Validate("ASL.EFRIS.CmdtCategoryCode", SelectToken.AsValue().AsText());
        Product."ASL.EFRIS.UploadStatus" := Product."ASL.EFRIS.UploadStatus"::Success;
        Product."ASL.EFRIS.UploadErrorCode" := '';
        Product."ASL.EFRIS.UploadErrorMessage" := '';
        exit(true);
    end;

    procedure IsLastHttpSuccess(): Boolean
    begin
        exit(LastHttpSuccess);
    end;

    procedure IsLastHttpBlockedByEnvironment(): Boolean
    begin
        exit(LastHttpIsBlockedByEnvironment);
    end;

    procedure GetLastErrorMessage(): Text
    var
        LastTryErrorMessage: Text;
    begin
        if LastErrorMessage <> '' then exit(LastErrorMessage);
        if LastHttpSuccess then
            exit(StrSubstno(TCSHttp, LastReturnStateCode, LastReturnStateMessage))
        else
            if LastHttpStatusCode <> 0 then
                exit(StrSubstNo(ErrHttp, LastHttpStatusCode, LastHttpReasonPhrase))
            else begin
                LastTryErrorMessage := GetLastErrorText();
                if LastTryErrorMessage <> '' then
                    exit(LastTryErrorMessage)
                else
                    exit(UnknownErrorMsg);
            end;
    end;
    // ------------------------------- TCS Http ------------------------------------------------------------------------------
    procedure SendInterfaceRequest(InterfaceCode: Enum "ASL.EFRIS.InterfaceCode";
    RequestContent: JsonToken;
    var ResponseContent: JsonToken): Boolean
    var
        RequestBody: JsonObject;
        RequestBodyJsonText: Text;
        GlobalInfo: JsonObject;
        Data: JsonObject;
        RequestContentEmpty: Boolean;
        CompressedTempBlob: Codeunit "Temp Blob";
        ContentUtf8OutStr: OutStream;
        ContentUtf8InStr: InStream;
        ContentWinInStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        DataDescription: JsonObject;
        RequestReturnStateInfo: JsonObject;
        Response: JsonToken;
        HttpSuccess: Boolean;
        ResponseContentBase64: JsonToken;
        ResponseContentText: Text;
        DataCompression: Codeunit "Data Compression";
        Compressed: JsonToken;
        DecompressedTempBlob: Codeunit "Temp Blob";
        Retry: Integer;
        ReturnStateInfo: JsonToken;
        CompressedOutStream: OutStream;
        CompressedInStream: InStream;
        DecompressedOutStream: OutStream;
        DecompressedInStream: InStream;
        ResponseContentDecompressed: Text;
        ResponseError: Boolean;
        EFRISSetup: Record "Sales & Receivables Setup";
        EFRISLog: Record "ASL.EFRIS.Log";
        LogRequestContentOutStream: OutStream;
        LogResponseMsgOutStream: OutStream;
        LogResponseContentOutStream: OutStream;
        ResponseText: Text;
        ResponseText001: Text;
    begin
        // request content not empty
        RequestContentEmpty := true;
        if RequestContent.IsObject then
            RequestContentEmpty := RequestContent.AsObject().Keys.Count = 0
        else
            if RequestContent.IsArray then
                RequestContentEmpty := RequestContent.AsArray().Count = 0
            else
                if RequestContent.IsValue then RequestContentEmpty := RequestContent.AsValue().IsNull;
        if not RequestContentEmpty then begin
            RequestContent.WriteTo(RequestBodyJsonText);
            // Message(RequestBodyJsonText);
            // to utf-8 stream
            CompressedTempBlob.CreateOutStream(ContentUtf8OutStr, TextEncoding::UTF8);
            ContentUtf8OutStr.WriteText(RequestBodyJsonText);
            // utf-8 stream to Base64
            CompressedTempBlob.CreateInStream(ContentUtf8InStr, TextEncoding::UTF8);
            Data.Add('content', Base64Convert.ToBase64(ContentUtf8InStr));
        end
        else begin
            Data.Add('content', '');
        end;
        DataDescription.Add('codeType', '0');
        DataDescription.Add('encryptCode', '0');
        DataDescription.Add('zipCode', '0');
        Data.Add('dataDescription', DataDescription);
        Data.Add('signature', '');
        Data.WriteTo(ResponseText);
        // Message(ResponseText);
        RequestBody.Add('data', Data);
        // globalInfo
        InitGlobalInfo(GlobalInfo, InterfaceCode);
        RequestBody.Add('globalInfo', GlobalInfo);
        // returnStateInfo
        RequestReturnStateInfo.Add('returnCode', '');
        RequestReturnStateInfo.Add('returnMessage', '');
        RequestBody.Add('returnStateInfo', RequestReturnStateInfo);
        // reset TCS response state. will only be updated on http success
        LastReturnStateCode := '';
        LastErrorMessage := '';
        // send request
        ResponseError := false;
        if SendRequest('/getInformation', "ASL.Http.HttpMethod"::POST, RequestBody.AsToken(), Response) then begin
            // returnStateInfo
            if Response.SelectToken('$.returnStateInfo.returnCode', ReturnStateInfo) then LastReturnStateCode := ReturnStateInfo.AsValue().AsText();
            if LastReturnStateCode = '999' then begin // TCS is offline. retry a few times
                Retry := 1;
                repeat
                    Sleep(500); // wait a bit
                                // retry sending request
                    if not SendRequest('/getInformation', "ASL.Http.HttpMethod"::POST, RequestBody.AsToken(), Response) then exit(false); // http failed
                                                                                                                                          // returnStateInfo
                    if Response.SelectToken('$.returnStateInfo.returnCode', ReturnStateInfo) then LastReturnStateCode := ReturnStateInfo.AsValue().AsText();
                    Retry += 1;
                until (LastReturnStateCode <> '999') or (Retry = 5);
            end;

            // Response.WriteTo(ResponseText);
            // Message(ResponseText);

            if Response.SelectToken('$.returnStateInfo.returnMessage', ReturnStateInfo) then LastReturnStateMessage := ReturnStateInfo.AsValue().AsText();
            // Only check response content when response code is 00 (SUCCESS) or 45 (Partial failure)
            if (LastReturnStateCode = '00') or (LastReturnStateCode = '45') then begin
                // extract and decode response content
                if Response.SelectToken('$.data.content', ResponseContentBase64) then begin
                    if Response.SelectToken('$.data.dataDescription.zipCode', Compressed) and Compressed.IsValue and (Compressed.AsValue().AsInteger() = 1) then begin // gzipped content. decompress
                        CompressedTempBlob.CreateOutStream(CompressedOutStream);
                        Base64Convert.FromBase64(ResponseContentBase64.AsValue().AsText(), CompressedOutStream);
                        CompressedTempBlob.CreateInStream(CompressedInStream);
                        DecompressedTempBlob.CreateOutStream(DecompressedOutStream);
                        DataCompression.GZipDecompress(CompressedInStream, DecompressedOutStream);
                        DecompressedTempBlob.CreateInStream(DecompressedInStream);
                        DecompressedInStream.ReadText(ResponseContentText);
                        ResponseContent.ReadFrom(ResponseContentText);
                    end
                    else begin
                        if ResponseContentBase64.IsValue() and not ResponseContentBase64.AsValue().IsUndefined() and not ResponseContentBase64.AsValue().IsNull then begin
                            ResponseContentText := Base64Convert.FromBase64(ResponseContentBase64.AsValue().AsText());
                            if ResponseContentText <> '' then ResponseContent.ReadFrom(ResponseContentText);
                        end;
                    end;
                end;
            end
            else begin
                ResponseError := true;
                LogError(LastReturnStateMessage);
            end;
        end
        else begin
            ResponseError := true;
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
        end;
        // trace
        EFRISSetup.GET();
        if EFRISSetup."ASL.EFRIS.LogLevel".AsInteger() >= "ASL.EFRIS.LogLevel"::TRACE.AsInteger() then begin
            EFRISLog.Init();
            EFRISLog.Time := CreateDateTime(Today, Time);
            EFRISLog.Level := "ASL.EFRIS.LogLevel"::TRACE;
            EFRISLog.Message := 'Interface Request';
            EFRISLog.RequestInterfaceCode := InterfaceCode;
            EFRISLog.RequestContent.CreateOutStream(LogRequestContentOutStream);
            LogRequestContentOutStream.WriteText(RequestBodyJsonText);
            EFRISLog.ResponseCode := LastReturnStateCode;
            EFRISLog.ResponseMessage.CreateOutStream(LogResponseMsgOutStream);
            LogResponseMsgOutStream.WriteText(LastReturnStateMessage);
            EFRISLog.ResponseContent.CreateOutStream(LogResponseContentOutStream);
            LogResponseContentOutStream.WriteText(ResponseContentText);
            EFRISLog.Insert(true);
        end;
        exit(not ResponseError);
    end;

    [TryFunction]
    local procedure SendRequest(Path: Text[250];
    Method: enum "ASL.Http.HttpMethod";
    Request: JsonToken;
    var Response: JsonToken)
    var
        ResponseText: Text;
    begin
        if not JsonHttpHandler.RequestJson(GetServerUrl() + '/efristcs/ws/tcsapp' + Path, Method, '', '', Request, Response) then Error(GetLastErrorText());
        // Response.WriteTo(ResponseText);
        // Message(ResponseText);
        LastHttpSuccess := JsonHttpHandler.IsLastHttpSuccess();
        if not LastHttpSuccess then begin
            LastHttpStatusCode := JsonHttpHandler.GetLastHttpStatusCode();
            LastHttpReasonPhrase := JsonHttpHandler.GetLastHttpReasonPhrase();
            LastHttpIsBlockedByEnvironment := JsonHttpHandler.GetLastIsBlockedByEnvironment();
            Error(StrSubstNo('Http Error %1: %2', LastHttpStatusCode, LastHttpReasonPhrase));
        end;
    end;

    local procedure InitGlobalInfo(var GlobalInfo: JsonObject;
    InterfaceCode: Enum "ASL.EFRIS.InterfaceCode"): Boolean
    var
        TCSInfo: JsonObject;
        ExtendField: JsonObject;
        CurrentDateTime: DateTime;
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
    begin
        if not EFRISIntegrationSetup.Get() then begin
            LastErrorMessage := ErrEFRISSetupNotFound;
            exit(false);
        end;
        if EFRISIntegrationSetup."ASL.EFRIS.DeviceNo" = '' then begin
            LastErrorMessage := ErrMissingEFRISDeviceNo;
            exit(false);
        end;
        if EFRISIntegrationSetup."ASL.EFRIS.TIN" = '' then begin
            LastErrorMessage := ErrMissingEFRISTIN;
            exit(false);
        end;
        CurrentDateTime := CreateDateTime(Today, Time());
        GlobalInfo.Add('appId', 'AP04');
        GlobalInfo.Add('brn', EFRISIntegrationSetup."ASL.EFRIS.BRN");
        GlobalInfo.Add('dataExchangeId', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Second dec.,7>'));
        GlobalInfo.Add('deviceMAC', '1');
        GlobalInfo.Add('deviceNo', EFRISIntegrationSetup."ASL.EFRIS.DeviceNo");
        ExtendField.Add('referenceNo', '21PL010020807');
        ExtendField.Add('responseDateFormat', Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4>'));
        ExtendField.Add('responseTimeFormat', Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
        GlobalInfo.Add('extendField', ExtendField);
        GlobalInfo.Add('longitude', '0');
        GlobalInfo.Add('latitude', '0');
        GlobalInfo.Add('interfaceCode', StrSubstNo('T%1', InterfaceCode.AsInteger()));
        GlobalInfo.Add('requestCode', 'TP');
        GlobalInfo.Add('requestTime', Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
        GlobalInfo.Add('responseCode', 'TA');
        GlobalInfo.Add('taxpayerID', '1');
        GlobalInfo.Add('tin', EFRISIntegrationSetup."ASL.EFRIS.TIN");
        GlobalInfo.Add('userName', 'admin');
        GlobalInfo.Add('version', EFRISIntegrationSetup."ASL.EFRIS.WSVersion");
    end;

    [TryFunction]
    local procedure TCSLogin()
    var
        Request: JsonToken;
        Response: JsonToken;
    begin
        if not SendRequest('/tcsLogin', "ASL.Http.HttpMethod"::GET, Request, Response) then Error(StrSubstNo(ErrHttp, LastHttpStatusCode, LastHttpReasonPhrase));
    end;

    local procedure GetServerUrl(): Text
    var
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
    begin
        EFRISIntegrationSetup.Get();
        if EFRISIntegrationSetup."ASL.EFRIS.ServerUrl" = '' then Error(ErrServerUrlNotSet);
        exit(EFRISIntegrationSetup."ASL.EFRIS.ServerUrl");
    end;

    local procedure Log(Level: enum "ASL.EFRIS.LogLevel";
    Message: Text)
    var
        EFRISLog: Record "ASL.EFRIS.Log";
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        EFRISSetup.GET();
        if (EFRISSetup."ASL.EFRIS.LogLevel" <> EFRISSetup."ASL.EFRIS.LogLevel"::OFF) and (EFRISSetup."ASL.EFRIS.LogLevel".AsInteger() >= Level.AsInteger()) then begin
            EFRISLog.Init();
            EFRISLog."Time" := CreateDateTime(Today, Time);
            EFRISLog.Level := Level;
            EFRISLog.Message := CopyStr(Message, 1, MaxStrLen(EFRISLog.Message));
            EFRISLog.Insert();
        end;
    end;

    local procedure getVatProjectDetails(CustomerTin: Text[15]; CommodityCategoryCode: Text[50]; var ResponseRecord: JsonArray): Boolean
    var
        InquiryRequest: JsonObject;
        ResponseToken: JsonToken;
        SelectToken: JsonToken;
        ResponseRecordsArray: JsonArray;
        ResponseTokenText: Text;
        ResponseTokenText1: Text;
    begin
        InquiryRequest.Add('tin', CustomerTin);
        InquiryRequest.Add('commodityCategoryCode', CommodityCategoryCode);
        if not SendInterfaceRequest("ASL.EFRIS.InterfaceCode"::T137, InquiryRequest.AsToken(), ResponseToken) then exit(false);
        ResponseToken.WriteTo(ResponseTokenText);
        ResponseToken.SelectToken('deemedAndExemptProjectList', SelectToken);
        ResponseRecordsArray := SelectToken.AsArray();
        ResponseRecordsArray.WriteTo(ResponseTokenText);
        //ej debugging
        //Message(ResponseTokenText);
        ResponseRecord := ResponseRecordsArray;
        exit(true);
    end;

    procedure UpdateDeemedProjectDetails(var SalesHeader: Record "Sales Header")
    var
        SalesLines: Record "Sales Line";
        ResponseRecord: JsonArray;
        ResponseRecordText: Text;
        SelectToken: JsonToken;
        Customer: Record Customer;
        Item: Record Item;
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        CommodityCategoryCode: Text[50];
        VatProjects: Record "ASL.EFRIS.VatProjects";
        VatProjects1: Record "ASL.EFRIS.VatProjects";
        deemedProject: JsonToken;
        commodityCatCode: Text;
        vatProjectId: Text;
    begin
        Clear(ResponseRecordText);
        Customer.Get(SalesHeader."Sell-to Customer No.");
        Customer.TestField("VAT Registration No.");
        SalesLines.Reset();
        SalesLines.SetRange("Document Type", SalesHeader."Document Type");
        SalesLines.SetRange("Document No.", SalesHeader."No.");
        SalesLines.SetFilter(Quantity, '<>%1', 0);
        if SalesLines.FindFirst() then
            repeat
                if SalesLines.Type = SalesLines.Type::Item then begin
                    Item.Get(SalesLines."No.");
                    CommodityCategoryCode := Item."ASL.EFRIS.CmdtCategoryCode";
                end else
                    if SalesLines.Type = SalesLines.Type::"G/L Account" then begin
                        GLAccount.Get(SalesLines."No.");
                        CommodityCategoryCode := GLAccount."ASL.EFRIS.CmdtCategoryCode";
                    end;
                if getVatProjectDetails(Customer."VAT Registration No.", CommodityCategoryCode, ResponseRecord) then begin
                    ResponseRecord.WriteTo(ResponseRecordText);
                    // Message(ResponseRecordText);
                    foreach deemedProject in ResponseRecord do begin
                        VatProjects.Init();
                        VatProjects.customerNo := Customer."No.";
                        VatProjects.CustomerTIN := Customer."VAT Registration No.";
                        deemedProject.SelectToken('commodityCategoryCode', SelectToken);
                        VatProjects.commodityCategoryCode := SelectToken.AsValue().AsText();
                        commodityCatCode := SelectToken.AsValue().AsText();
                        deemedProject.SelectToken('projectId', SelectToken);
                        VatProjects.projectId := SelectToken.AsValue().AsText();
                        vatProjectId := SelectToken.AsValue().AsText();
                        // Message(SelectToken.AsValue().AsText());
                        deemedProject.SelectToken('projectName', SelectToken);
                        VatProjects.projectName := SelectToken.AsValue().AsText();
                        if deemedProject.SelectToken('unit', SelectToken) then
                            VatProjects.unit := SelectToken.AsValue().AsText();
                        if deemedProject.SelectToken('deemedExemptCode', SelectToken) then
                            VatProjects.deemedExemptCode := SelectToken.AsValue().AsText();
                        if deemedProject.SelectToken('currentQty', SelectToken) then
                            VatProjects.currentQty := SelectToken.AsValue().AsDecimal();
                        if deemedProject.SelectToken('currentAmount', SelectToken) then
                            VatProjects.currentAmount := SelectToken.AsValue().AsDecimal();
                        if deemedProject.SelectToken('serviceMark', SelectToken) then
                            VatProjects.serviceMark := SelectToken.AsValue().AsText();

                        VatProjects1.Reset();
                        VatProjects1.SetRange(customerNo, Customer."No.");
                        VatProjects.SetRange(CustomerTIN, Customer."VAT Registration No.");
                        VatProjects1.SetRange(commodityCategoryCode, commodityCatCode);
                        VatProjects1.SetRange(projectId, vatProjectId);
                        if not VatProjects1.FindFirst() then
                            VatProjects.Insert();
                    end;
                end;
            until SalesLines.Next() = 0;
    end;

    procedure UpdateSalesInvoiceOrderNumber(var SalesInvoice: Record "Sales Invoice Header";
    PreviewMode: Boolean): Boolean
    var
        SalesInvoiceLines: Record "Sales Invoice Line";
        EFRISIntegrationSetup: Record "Sales & Receivables Setup";
        CrMemo: Record "Sales Cr.Memo Header";
        Invoice: JsonObject;
        SelletDetails: JsonObject;
        BasicInfo: JsonObject;
        Customer: Record Customer;
        VatProdPostingGroup: Record "VAT Product Posting Group";
        InvoiceIndustryCode: Enum "ASL.EFRIS.InvoiceIndustryCode";
        BuyerDetails: JsonObject;
        BuyerExtendDetails: JsonObject;
        GoodsDetails: JsonArray;
        VATExempt: Boolean;
        VATZero: Boolean;
        LineGrossAmount: Decimal;
        LineTaxAmount: Decimal;
        LineDiscountGrossAmount: Decimal;
        LineDiscountTaxAmount: Decimal;
        VATTaxCategory: Enum "ASL.EFRIS.TaxCategory";
        TaxDetailsAccuml: Dictionary of [Integer, List of [Decimal]];
        TaxDetailsKeys: List of [Integer];
        TaxDetailsKey: Integer;
        GrossAndTaxAmounts: List of [Decimal];
        TaxDetails: JsonArray;
        I: Integer;
        DiscountLine: JsonObject;
        TotalGrossAmount: Decimal;
        TotalTaxAmount: Decimal;
        Summary: JsonObject;
        ItemCount: Integer;
        Payments: JsonArray;
        Payment: JsonObject;
        InvoiceUploadResponse: JsonToken;
        Success: Boolean;
        ResponseText: Text;
        DetailsText: Text;
    begin
        SalesInvoiceLines.Reset();
        SalesInvoiceLines.SetRange(SalesInvoiceLines."Document No.", SalesInvoice."No.");
        SalesInvoiceLines.SetFilter(SalesInvoiceLines.Type, '%1|%2', SalesInvoiceLines.Type::Item, SalesInvoiceLines.Type::"G/L Account");
        SalesInvoiceLines.SetFilter(SalesInvoiceLines."No.", '<>''''');
        SalesInvoiceLines.SetFilter(SalesInvoiceLines.Quantity, '>0');
        if not SalesInvoiceLines.FindSet() then begin
            LastErrorMessage := ErrInvNoLines;
            LogError(LastErrorMessage);
            exit(false);
        end;
        if not SetSalesSellerDetails(Enum::"Sales Document Type"::Invoice, SalesInvoice, CrMemo, SelletDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('sellerDetails', SelletDetails);
        Customer.Get(SalesInvoice."Bill-to Customer No.");
        if SalesInvoice."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then
            InvoiceIndustryCode := SalesInvoice."ASL.EFRIS.InvoiceIndustryCode"
        else
            if Customer."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then
                InvoiceIndustryCode := Customer."ASL.EFRIS.InvoiceIndustryCode"
            else begin
                if EFRISIntegrationSetup."ASL.EFRIS.InvoiceIndustryCode" = Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then begin
                    LastErrorMessage := ErrMissingInvIndustryCode;
                    LogError(LastErrorMessage);
                    exit(false);
                end;
                InvoiceIndustryCode := EFRISIntegrationSetup."ASL.EFRIS.InvoiceIndustryCode";
            end;
        if not SetInvoiceBasicInfo(SalesInvoice."Currency Code", SalesInvoice."Posting Date", Enum::"ASL.EFRIS.InvoiceType"::"Invoice/Receipt", InvoiceIndustryCode, '', false, BasicInfo, SalesInvoice."ASL.EFRIS.DeliveryTerms") then exit(false);
        Invoice.Add('basicInformation', BasicInfo);
        if not SetSalesBuyerDetails(SalesInvoice, Customer, BuyerDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('buyerDetails', BuyerDetails);
        if not SetInvoiceEmptyBuyerExtendDetails(BuyerExtendDetails) then begin
            LastErrorMessage := GetLastErrorText();
            LogError(LastErrorMessage);
            exit(false);
        end;
        Invoice.Add('buyerExtend', BuyerExtendDetails);
        VATExempt := SalesInvoice."ASL.EFRIS.VATExempt";
        // check for VAT Zero based on Invoice Industry Code
        if InvoiceIndustryCode = Enum::"ASL.EFRIS.InvoiceIndustryCode"::Export then VATZero := true;
        I := 0;
        ItemCount := 0;
        repeat
            LineGrossAmount := 0;
            LineTaxAmount := 0;
            if not AddInvoiceLineDetails(I, SalesInvoiceLines, SalesInvoice."Prices Including VAT", SalesInvoice."ASL.EFRIS.VATDeemed", VATExempt, VATZero, LineGrossAmount, LineTaxAmount, GoodsDetails, SalesInvoice) then begin
                LastErrorMessage := GetLastErrorText();
                LogError(LastErrorMessage);
                exit(false);
            end;

            SalesInvoiceLines."Order Number" := I;
            SalesInvoiceLines.Modify();

            if (SalesInvoiceLines."Line Discount Amount" > 0) or (SalesInvoiceLines."Inv. Discount Amount" > 0) then begin
                I += 1;
                AddInvoiceDiscountLine(I, SalesInvoiceLines, SalesInvoice."Prices Including VAT", SalesInvoice."ASL.EFRIS.VATDeemed", VATExempt, VATZero, LineDiscountGrossAmount, LineDiscountTaxAmount, GoodsDetails);
                LineGrossAmount -= LineDiscountGrossAmount;
                LineTaxAmount -= LineDiscountTaxAmount;
            end;

            /* if VATZero then
                VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else
                if SalesInvoice."ASL.EFRIS.VATDeemed" then
                    VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                else
                    if SalesInvoice."ASL.EFRIS.VATExempt" then
                        VATTaxCategory := Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                    else begin
                        VatProdPostingGroup.Get(SalesInvoiceLines."VAT Prod. Posting Group");
                        VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");
                        VATTaxCategory := VatProdPostingGroup."ASL.EFRIS.TaxCategory";
                    end; */
            if VATZero then
                VATTaxCategory :=
                    Enum::"ASL.EFRIS.TaxCategory"::"B: Zero (0%)"
            else begin
                VatProdPostingGroup.Get(
                    SalesInvoiceLines."VAT Prod. Posting Group");
                VatProdPostingGroup.TestField("ASL.EFRIS.TaxCategory");

                if VatProdPostingGroup."ASL.EFRIS.TaxCategory" =
                   Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                then
                    VATTaxCategory :=
                        Enum::"ASL.EFRIS.TaxCategory"::"F: VAT OUT OF SCOPE"
                else
                    if SalesInvoice."ASL.EFRIS.VATDeemed" then
                        VATTaxCategory :=
                            Enum::"ASL.EFRIS.TaxCategory"::"D: Deemed (18%)"
                    else
                        if SalesInvoice."ASL.EFRIS.VATExempt" then
                            VATTaxCategory :=
                                Enum::"ASL.EFRIS.TaxCategory"::"C: Exempt (-)"
                        else
                            VATTaxCategory :=
                                VatProdPostingGroup."ASL.EFRIS.TaxCategory";
            end;

            //

            AddSalesTaxDetails(VATTaxCategory, LineGrossAmount, SalesInvoiceLines."VAT %", LineTaxAmount, TaxDetailsAccuml);
            TotalGrossAmount += LineGrossAmount;
            TotalTaxAmount += LineTaxAmount;
            I += 1;
            ItemCount += 1;
        until SalesInvoiceLines.Next() = 0;
        Invoice.Add('goodsDetails', GoodsDetails);
        GoodsDetails.WriteTo(DetailsText);

        //Message(DetailsText); //F:
        // tax details
        if TaxDetailsAccuml.Count > 0 then begin
            TaxDetailsKeys := TaxDetailsAccuml.Keys();
            I := 1;
            repeat
                if TaxDetailsKeys.Get(I, TaxDetailsKey) then begin
                    if TaxDetailsAccuml.Get(TaxDetailsKey, GrossAndTaxAmounts) then begin
                        SetTaxDetailFieldValues(Enum::"ASL.EFRIS.TaxCategory".FromInteger(TaxDetailsKey), GrossAndTaxAmounts.Get(1), GrossAndTaxAmounts.Get(2), GrossAndTaxAmounts.Get(3), TaxDetails);
                    end;
                end;
                I += 1;
            until I > TaxDetailsKeys.Count;
            Invoice.Add('taxDetails', TaxDetails);
        end;

        Summary.Add('netAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        if SalesInvoice."ASL.EFRIS.VATDeemed" or SalesInvoice."ASL.EFRIS.VATExempt" then begin
            Summary.Add('taxAmount', Format(0, 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount - TotalTaxAmount, 0.01, '='), 0, 1));
        end
        else begin
            Summary.Add('taxAmount', Format(Round(TotalTaxAmount, 0.01, '='), 0, 1));
            Summary.Add('grossAmount', Format(Round(TotalGrossAmount, 0.01, '='), 0, 1));
        end;
        Summary.Add('itemCount', Format(ItemCount, 0, 1));
        Summary.Add('modeCode', '1'); // 1 - online, 0 - offline
        Summary.Add('remarks', SalesInvoice."ASL.EFRIS.Remarks");
        Summary.Add('qrCode', '');
        Invoice.Add('summary', Summary);
        Message('Order Numbers Updated Successfully.');
    end;

    local procedure LogError(Message: Text)
    begin
        Log(Enum::"ASL.EFRIS.LogLevel"::TRACE, Message);
    end;
    /*
      local procedure LogDebug(Message: Text[255])
      begin
          Log(Enum::"ASL.EFRIS.LogLevel"::DEBUG, Message);
      end;

      local procedure LogInfo(Message: Text[255])
      begin
          Log(Enum::"ASL.EFRIS.LogLevel"::INFO, Message);
      end;
      */
    local procedure LogTrace(Message: Text)
    begin
        Log(Enum::"ASL.EFRIS.LogLevel"::TRACE, Message);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetBuyerDetails(var SalesInvoiceHeader: Record "Sales Invoice Header";
    var Buyer: Record Customer;
    var BuyerDetails: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSellerDetails(var SalesInvoiceHeader: Record "Sales Invoice Header";
    var SelletDetails: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetEFRISInvoiceDetails(var SalesInvoiceHeader: Record "Sales Invoice Header";
    var EFRISSellerReferenceNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSellerReferenceNo(DocumentType: Enum "Sales Document Type"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMEmoHeader: Record "Sales Cr.Memo Header"; var ReferenceNo: Text)
    begin
    end;
}
