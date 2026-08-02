pageextension 50097 "ASL.EFRIS.PostedPurchInvoice" extends "Posted Purchase Invoice"
{
    actions
    {
        addafter(Correct)
        {
            group("ASL.EFRIS.EFRIS")
            {
                Caption = 'EFRIS';
                Image = SalesTax;

                action("ASL.EFRIS.PostToEFRIS")
                {
                    ApplicationArea = All;
                    Caption = 'Post to EFRIS';

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Vendor: Record Vendor;
                    begin
                        Vendor.Get(Rec."Buy-from Vendor No.");
                        if Vendor."ASL.EFRIS.TIN" = '' then Error(ErrVendorMissingTIN, Vendor."No.");
                        EFRISInterface.UpdateInventoryForDoc(Rec."No.");
                    end;
                }
                action("ASL.EFRIS.ViewLinesEFRISDetails")
                {
                    Caption = 'View Lines EFRIS Status';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        PurchInvLines: Record "Purch. Inv. Line";
                        PurchInvLinesPage: Page "Posted Purchase Invoice Lines";
                    begin
                        PurchInvLines.SetRange(PurchInvLines."Document No.", Rec."No.");
                        if PurchInvLines.FindSet() then begin
                            PurchInvLinesPage.SetTableView(PurchInvLines);
                            PurchInvLinesPage.SetRecord(PurchInvLines);
                            PurchInvLinesPage.RunModal();
                        end;
                    end;
                }

            }
        }
    }
    var
        ErrVendorMissingTIN: TextConst ENU = 'TIN not specified for Vendor No. %1';
}
