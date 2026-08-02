codeunit 50006 "ASL.EFRIS.EventHandlers"
{
    Permissions = tabledata "Purch. Inv. Header" = rm,
                tabledata "Purch. Inv. Line" = rm,
                tabledata "Sales Invoice Header" = rm,
                tabledata "Sales Invoice Line" = rm,
                tabledata "Sales Cr.Memo Header" = rm,
                tabledata "Item Journal Batch" = rm,
                tabledata "ASL.EFRIS.CommodityCategory" = rimd,
                tabledata "ASL.EFRIS.Log" = rim,
                tabledata "ASL.EFRIS.ComdtCatTaxPayerType" = rim,
                tabledata "ASL.EFRIS.VatProjects" = rim;


    //

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptHeaderInsert', '', true, true)]
    local procedure OnBeforePurchRcptHeaderInsert(var PurchRcptHeader: Record "Purch. Rcpt. Header";

    var
        PurchaseHeader: Record "Purchase Header";
        CommitIsSupressed: Boolean)
    var
        EFRISSEtup: Record "Sales & Receivables Setup";
        PurchLines: Record "Purchase Line";
        HasEFRISItems: Boolean;
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        EFRISSEtup.Get();
        if not EFRISSEtup."ASL.EFRIS.UploadOnPosting" then exit;
        HasEFRISItems := false;
        PurchLines.Reset();
        PurchLines.SetRange(PurchLines."Document Type", PurchaseHeader."Document Type");
        PurchLines.SetRange(PurchLines."Document No.", PurchaseHeader."No.");
        PurchLines.SetRange(PurchLines."Type", PurchLines.Type::Item);
        if PurchLines.FindSet then begin
            repeat
                Item.Get(PurchLines."No.");
                if Item."ASL.EFRIS.ItemId" <> '' then HasEFRISItems := true;
            until (PurchLines.Next = 0) or HasEFRISItems;
        end;
        if HasEFRISItems then begin
            PurchRcptHeader."ASL.EFRIS.HasEFRISItems" := true;
            // if PurchaseHeader."Vendor Shipment No." = '' then
            //    Error(ErrMissingVendorShipmentNo, PurchaseHeader."No.");
            if PurchaseHeader."ASL.EFRIS.VendorTIN" <> '' then
                PurchRcptHeader."ASL.EFRIS.VendorTIN" := PurchaseHeader."ASL.EFRIS.VendorTIN"
            else begin
                Vendor.Get(PurchRcptHeader."Buy-from Vendor No.");
                // if Vendor."ASL.EFRIS.TIN" <> '' then
                //    Error(ErrMissingVendorTIN, PurchRcptHeader."No.", Vendor."No.");
                PurchRcptHeader."ASL.EFRIS.VendorTIN" := Vendor."ASL.EFRIS.TIN";
            end;
            PurchRcptHeader."ASL.EFRIS.Import" := PurchRcptHeader."ASL.EFRIS.Import";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', true, true)]
    procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header";
    var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    PurchRcpHdrNo: Code[20];
    RetShptHdrNo: Code[20];
    PurchInvHdrNo: Code[20];
    PurchCrMemoHdrNo: Code[20];
    CommitIsSupressed: Boolean)
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        if (PurchRcpHdrNo <> '') and PurchRcptHeader.GET(PurchRcpHdrNo) then begin
            if PurchRcptHeader."ASL.EFRIS.HasEFRISItems" then begin
                // handle EFRIS items to EFRIS
                if ((PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order) or (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice) or (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order") or (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo")) and PurchaseHeader.Invoice then begin
                    EFRISInterface.UpdateInventoryForDoc(PurchRcptHeader."No.");
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', true, true)]
    local procedure OnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header";
    SalesHeader: Record "Sales Header";
    CommitIsSuppressed: Boolean;
    var IsHandled: Boolean)
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        Customer: Record Customer;
    begin
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        if SalesHeader."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then
            SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" := SalesHeader."ASL.EFRIS.InvoiceIndustryCode"
        else begin
            Customer.Get(SalesHeader."Bill-to Customer No.");
            if Customer."ASL.EFRIS.InvoiceIndustryCode" <> Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then begin
                SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" := Customer."ASL.EFRIS.InvoiceIndustryCode"
            end
            else begin
                if EFRISSetup."ASL.EFRIS.InvoiceIndustryCode" = Enum::"ASL.EFRIS.InvoiceIndustryCode"::" " then Error(ErrMissingInvoiceIndustryCode, SalesHeader."No.");
                SalesInvHeader."ASL.EFRIS.InvoiceIndustryCode" := EFRISSetup."ASL.EFRIS.InvoiceIndustryCode";
            end;
        end;
        if SalesHeader."ASL.EFRIS.PaymentMode" <> Enum::"ASL.EFRIS.PaymentMode"::" " then
            SalesInvHeader."ASL.EFRIS.PaymentMode" := SalesHeader."ASL.EFRIS.PaymentMode"
        else begin
            Customer.Get(SalesHeader."Bill-to Customer No.");
            if Customer."ASL.EFRIS.InvoicePaymentMode" <> Enum::"ASL.EFRIS.PaymentMode"::" " then begin
                SalesInvHeader."ASL.EFRIS.PaymentMode" := Customer."ASL.EFRIS.InvoicePaymentMode"
            end
            else begin
                if EFRISSetup."ASL.EFRIS.InvoicePaymentMode" = Enum::"ASL.EFRIS.PaymentMode"::" " then Error(ErrMissingPaymentMode, SalesHeader."No.");
                SalesInvHeader."ASL.EFRIS.PaymentMode" := EFRISSetup."ASL.EFRIS.InvoicePaymentMode";
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoHeaderInsert', '', true, true)]
    local procedure OnBeforeSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    SalesHeader: Record "Sales Header";
    CommitIsSuppressed: Boolean;
    var IsHandled: Boolean)
    var
        AppliedToInvHdr: Record "Sales Invoice Header";
        EFRISSEtup: Record "Sales & Receivables Setup";
    begin
        EFRISSEtup.Get();
        if not EFRISSEtup."ASL.EFRIS.UploadOnPosting" then exit;
        if (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::" ") or (SalesHeader."Applies-to Doc. No." = '') then Error(ErrUnAppliedCreditMemo);
        if SalesHeader."ASL.EFRIS.RefundReasonCode" = SalesHeader."ASL.EFRIS.RefundReasonCode"::" " then Error(ErrMissingRefundReasonCode, SalesCrMemoHeader."No.");
        if (SalesHeader."ASL.EFRIS.RefundReasonCode" = SalesHeader."ASL.EFRIS.RefundReasonCode"::Others) and (SalesHeader."ASL.EFRIS.RefundReason" = '') then Error(ErrMissingRefundReason, SalesCrMemoHeader."No.");
        SalesCrMemoHeader."ASL.EFRIS.RefundReasonCode" := SalesHeader."ASL.EFRIS.RefundReasonCode";
        SalesCrMemoHeader."ASL.EFRIS.RefundReason" := SalesHeader."ASL.EFRIS.RefundReason";
        SalesCrMemoHeader."ASL.EFRIS.Remarks" := SalesHeader."ASL.EFRIS.Remarks";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header";
    var SalesShipmentHeader: Record "Sales Shipment Header";
    var SalesInvoiceHeader: Record "Sales Invoice Header";
    var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    var ReturnReceiptHeader: Record "Return Receipt Header";
    var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    CommitIsSuppressed: Boolean;
    PreviewMode: Boolean;
    WhseShip: Boolean;
    WhseReceive: Boolean)
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        SaleLines: Record "Sales Line";
        Item: Record Item;
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
    begin
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        if ((SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice)) and SalesHeader.Invoice then begin
            if EFRISInterface.PostSalesInvoice(SalesInvoiceHeader, PreviewMode) then begin
                if not PreviewMode then SalesInvoiceHeader.Modify()
            end
            else
                Error(EFRISInterface.GetLastErrorMessage());
        end
        else begin
            if ((SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") or (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo")) and SalesHeader.Invoice then
                if EFRISInterface.SendCreditNoteApplication(SalesCrMemoHeader, PreviewMode) then
                    SalesCrMemoHeader.Modify()
                else
                    Error(EFRISInterface.GetLastErrorMessage());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnBeforeCode', '', true, true)]
    local procedure OnItemJnlPostBatchBeforeCode(var ItemJournalLine: Record "Item Journal Line")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        EFRISSetup: Record "Sales & Receivables Setup";
    begin
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        if (ItemJournalLine."Journal Template Name" <> '') and (ItemJournalLine."Journal Batch Name" <> '') then begin
            ItemJournalBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
            if ItemJournalBatch."ASL.EFRIS.TransactionNoUsed" or (ItemJournalBatch."ASL.EFRIS.TransactionNo" = 0) then begin
                ItemJournalBatch."ASL.EFRIS.TransactionNo" := ItemJournalBatch."ASL.EFRIS.TransactionNo" + 1;
                ItemJournalBatch."ASL.EFRIS.TransactionNoUsed" := false;
                ItemJournalBatch.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', true, true)]
    local procedure OnBeforeInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry";
    ItemJournalLine: Record "Item Journal Line";
    TransferItem: Boolean;
    OldItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        EFRISSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
    begin
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        if (ItemJournalLine."Journal Template Name" <> '') and (ItemJournalLine."Journal Batch Name" <> '') then begin
            ItemJournalBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
            if Item.Get(ItemLedgerEntry."Item No.") and (Item."ASL.EFRIS.ItemId" <> '') then begin
                // only mark EFRIS Items
                ItemLedgerEntry."ASL.EFRIS.UploadStatus" := Enum::"ASL.EFRIS.UploadStatus"::Pending;
                ItemLedgerEntry."ASL.EFRIS.JournalTemplateName" := ItemJournalLine."Journal Template Name";
                ItemLedgerEntry."ASL.EFRIS.JournalBatchName" := ItemJournalLine."Journal Batch Name";
                ItemLedgerEntry."ASL.EFRIS.TransactionNo" := ItemJournalBatch."ASL.EFRIS.TransactionNo";
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnAfterPostJnlLines', '', true, true)]
    local procedure OnAfterPostItemJnlLines(var ItemJournalBatch: Record "Item Journal Batch";
    var ItemJournalLine: Record "Item Journal Line";
    ItemRegNo: Integer;
    WhseRegNo: Integer)
    var
        EFRISSetup: Record "Sales & Receivables Setup";
        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
        Item: Record "Item Ledger Entry";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PrevItemNo: Code[20];
        ItemLedgerEntryErrors: Page "ASL.EFRIS.PndngItemLedgEntries";
        ProcessInvExitStatus: Enum "ASL.EFRIS.ProcessInvExitStatus";
    begin
        ItemJnlBatch.Get(ItemJournalBatch."Journal Template Name", ItemJournalBatch."Name");
        ItemJnlBatch."ASL.EFRIS.TransactionNoUsed" := true;
        ItemJnlBatch.Modify();
        EFRISSetup.Get();
        if not EFRISSetup."ASL.EFRIS.UploadOnPosting" then exit;
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        ItemLedgerEntry.SetRange("ASL.EFRIS.JournalTemplateName", ItemJournalBatch."Journal Template Name");
        ItemLedgerEntry.SetRange("ASL.EFRIS.JournalBatchName", ItemJournalBatch."Name");
        ItemLedgerEntry.SetRange("ASL.EFRIS.TransactionNo", ItemJournalBatch."ASL.EFRIS.TransactionNo");
        if ItemLedgerEntry.FindSet() then begin
            ProcessInvExitStatus := EFRISInterface.UpdateInventoryEntries(ItemLedgerEntry);
            if ProcessInvExitStatus <> Enum::"ASL.EFRIS.ProcessInvExitStatus"::Success then begin
                if ProcessInvExitStatus = ProcessInvExitStatus::Error then
                    Message(EFRISInterface.GetLastErrorMessage())
                else begin
                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetFilter("ASL.EFRIS.UploadStatus", '%1|%2', Enum::"ASL.EFRIS.UploadStatus"::Pending, Enum::"ASL.EFRIS.UploadStatus"::Error);
                    if ItemLedgerEntry.FindSet() then begin
                        ItemLedgerEntryErrors.Run();
                        Message(MsgSomeItemLedgerEntriesNotToEFRIS);
                    end;
                end;
            end;
        end;
    end;

    /// <summary>
    /// UpdateSalesInvoiceLinesOrderNumber.
    /// </summary>
    /// <param name="salesInvoiceHeader">VAR Record "Sales Invoice Header".</param>
    procedure UpdateSalesInvoiceLinesOrderNumber(var salesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLines: Record "Sales Invoice Line";
        Counter: Integer;
    begin
        Counter := 0;
        SalesInvoiceLines.Reset();
        SalesInvoiceLines.SetRange("Document No.", salesInvoiceHeader."No.");
        SalesInvoiceLines.SetFilter(Quantity, '<>%1', 0);
        if SalesInvoiceLines.FindFirst() then
            repeat
                SalesInvoiceLines."Order Number" := Counter;
                SalesInvoiceLines.Modify();

                if SalesInvoiceLines."Line Discount %" <> 0 then
                    Counter += 2
                else
                    Counter += 1;
            until SalesInvoiceLines.Next() = 0;
        Message('Lines updated successfully');
    end;

    /// <summary>
    /// UpdateSalesCreditMemoLinesOrderNumber.
    /// </summary>
    /// <param name="salesCreditMemoHeader">VAR Record "Sales Header".</param>
    procedure UpdateSalesCreditMemoLinesOrderNumber(var salesCreditMemoHeader: Record "Sales Header")
    var
        SalesCreditMemoLines: Record "Sales Line";
        salesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLines: Record "Sales Invoice Line";
    begin
        salesCreditMemoHeader.TestField("Applies-to Doc. No.");
        salesInvoiceHeader.Reset();
        salesInvoiceHeader.SetRange("No.", salesCreditMemoHeader."Applies-to Doc. No.");
        if salesInvoiceHeader.FindFirst() then begin
            SalesInvoiceLines.Reset();
            SalesInvoiceLines.SetRange("Document No.", salesCreditMemoHeader."Applies-to Doc. No.");
            if SalesInvoiceLines.FindFirst() then
                repeat
                    SalesCreditMemoLines.Reset();
                    SalesCreditMemoLines.SetRange("Document No.", salesCreditMemoHeader."No.");
                    SalesCreditMemoLines.SetRange("No.", SalesInvoiceLines."No.");
                    SalesCreditMemoLines.SetRange(Mapped, false);
                    if SalesCreditMemoLines.FindFirst() then begin
                        SalesCreditMemoLines.Validate("Order Number", SalesInvoiceLines."Order Number");
                        SalesCreditMemoLines.Mapped := true;
                        SalesCreditMemoLines.Modify();
                    end
                until SalesInvoiceLines.Next() = 0;
            Message('Order Number update successfully');
        end;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesInvLinesToDocOnAfterCopySalesDocLine', '', false, false)]
    // local procedure OnCopySalesInvLinesToDocOnAfterCopySalesDocLine(ToSalesLine: Record "Sales Line"; FromSalesInvLine: Record "Sales Invoice Line")
    // begin
    //     ToSalesLine."Order Number" := FromSalesInvLine."Order Number";
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesInvLinesToDocOnBeforeCopySalesLine', '', false, false)]
    // local procedure OnCopySalesInvLinesToDocOnBeforeCopySalesLine(ToSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line";  var TempDocSalesLine: Record "Sales Line" temporary; var FromSalesLine1: Record "Sales Line"; ExactCostRevMandatory: Boolean)
    // begin
    //     ToSalesLine."Order Number" := FromSalesInvLine."Order Number";
    //     TempSalesLineBuf."Order Number" := FromSalesInvLine."Order Number";
    // end;

    var
        ErrMissingVendorShipmentNo: TextConst ENU = 'Vendor Shipment No. not specified for Purchase Document No. %1';
        ErrMissingVendorTIN: TextConst ENU = 'Vendor TIN not specified for Purchase Document No. %1 and TIN not specified for Vendor No. %2';
        ErrMissingInvoiceIndustryCode: TextConst ENU = 'Invoice Industry Code not specified for Invoice No. %1 and no default in EFRIS Integration Setup';
        ErrMissingPaymentMode: TextConst ENU = 'EFRIS Payment Mode not specified for Invoice No. %1 and no default in EFRIS Integration Setup';
        ErrUnAppliedCreditMemo: TextConst ENU = 'Unapplied Credit Memos Not Allowed. You must specify Applies to Doc. Type and Applies to Doc. No.';
        ErrMissingRefundReasonCode: TextConst ENU = 'EFRIS Refund Reason Code not specified for Credit Memo No. %1';
        ErrMissingRefundReason: TextConst ENU = 'EFRIS Refund Reason not specified for Credit Memo No. %1 with Refund Reason Code ''Other''';
        MsgSomeItemLedgerEntriesNotToEFRIS: TextConst ENU = 'Some Item Ledger Entries have not been posted to EFRIS';
}
