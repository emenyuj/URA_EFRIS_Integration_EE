pageextension 50119 "ASL.EFRIS.GLAccountCard" extends "G/L Account Card"
{
    layout
    {
        addafter(General)
        {
            group("ASL.EFRIS.Fields")
            {
                Caption = 'EFRIS';

                field("ASL.EFRIS.CmdtCategoryCode"; Rec."ASL.EFRIS.CmdtCategoryCode")
                {
                    Caption = 'Commodity Category Code';
                }
                field("ASL.EFRIS.CmdtCategoryName"; Rec."ASL.EFRIS.CmdtCategoryName")
                {
                    Caption = 'Commodity Category Name';
                }
                field("ASL.EFRIS.UnitOfMeasure"; Rec."ASL.EFRIS.UnitOfMeasure")
                {
                    ToolTip = 'Specifies the value of the Unit Of Measure field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UnitPrice"; Rec."ASL.EFRIS.UnitPrice")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.';
                    ApplicationArea = All;
                }
                field("ASL.EFRIS.UploadStatus"; Rec."ASL.EFRIS.UploadStatus")
                {
                    Caption = 'Upload Status';
                }
                field("ASL.EFRIS.ItemId"; Rec."ASL.EFRIS.ProductId")
                {
                    Caption = 'Product Id';
                }
                field("ASL.EFRIS.UploadErrorCode"; Rec."ASL.EFRIS.UploadErrorCode")
                {
                    Caption = 'Upload Error Code';
                }
                field("ASL.EFRIS.UploadErrorMessage"; Rec."ASL.EFRIS.UploadErrorMessage")
                {
                    Caption = 'Upload Error Message';
                }
            }
        }
    }
    actions
    {
        addafter("A&ccount")
        {
            group("ASL.EFRIS.Actions")
            {
                Caption = 'EFRIS';
                Image = "TaxSetup";

                action("ASL.EFRIS.UploadItem")
                {
                    Caption = 'Upload As Product';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Product: Record "G/L Account";
                    begin
                        if Rec."ASL.EFRIS.ProductId" <> '' then begin
                            Message('G/L Account already uploaded to EFRIS');
                            exit;
                        end;
                        Product.Reset();
                        Product.SetRange(Product."No.", Rec."No.");
                        if Product.FindFirst() then begin
                            if EFRISInterface.UploadProduct(Product, false) then
                                Message('Product successuly uploaded to EFRIS')
                            else
                                Message('EFRIS Product upload failed. ' + EFRISInterface.GetLastErrorMessage());
                        end;
                    end;
                }
                action("ASL.EFRIS.GetItemDetails")
                {
                    Caption = 'Get Product Details';
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                    begin
                        if EFRISInterface.GetEFRISProductDetails(Rec) then begin
                            Rec.Modify();
                            Message('EFRIS Product details fetched')
                        end
                        else
                            Message('Failed to get Product details from EFRIS. ' + EFRISInterface.GetLastErrorMessage());
                    end;
                }
                action("ASL.EFRIS.UpdateItem")
                {
                    Caption = 'Update EFRIS Product';
                    ApplicationArea = All;
                    Image = PostDocument;

                    trigger OnAction()
                    var
                        EFRISInterface: Codeunit "ASL.EFRIS.EFRISInterface";
                        Product: Record "G/L Account";
                    begin
                        if Rec."ASL.EFRIS.ProductId" = '' then begin
                            Error('G/L Account not yet uploaded as EFRIS Product');
                            exit;
                        end;
                        Product.Reset();
                        Product.SetRange(Product."No.", Rec."No.");
                        if Product.FindFirst() then begin
                            if EFRISInterface.UploadProduct(Product, true) then
                                Message('EFRIS Product successuly updated')
                            else
                                Message('EFRIS Product update failed. ' + EFRISInterface.GetLastErrorMessage());
                        end;
                    end;
                }
            }
        }
    }
}
