/// <summary>
/// TableExtension ASL.EFRIS.SalesLine (ID 70615600) extends Record Sales Line.
/// </summary>
tableextension 50078 "ASL.EFRIS.SalesLine" extends "Sales Line"
{
    fields
    {
        field(70615581; ExiseDuty; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70615582; "ASL.EFRIS.ExciseDutyRate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70615583; "ASL.EFRIS.LineAmtExcl.Excise"; Decimal)
        {
            Caption = 'Line Amount Excl. Excise';
        }
        field(70615584; "ASL.EFRIS.DisctAmt.Excl.Excise"; Decimal)
        {
            Caption = 'Discount Amount Excl. Excise';
        }
        field(70615585; "ASL.EFRIS.DisctPer.Excl.Excise"; Decimal)
        {
            Caption = 'Discount Excise Percentage';
        }
        field(70615586; "ASL.EFRIS.UnitPrice.ExclExcise"; Decimal)
        {
            Caption = 'Unit Price Excl. Excise';
            DecimalPlaces = 2 : 6;

            trigger OnValidate()
            var
                UnitPriceCal: Decimal;
            begin
                // if Rec."VAT %" <> 0 then begin
                //     UnitPriceCal := 0;
                //     Rec.TestField(Quantity);
                //     IF Rec."Currency Code" <> '' then begin

                //         IF Rec."Currency Code" = 'USD' then
                //             CurreExcrate := 1
                //         else begin
                //             CurrencyExchangeRate.RESET;
                //             CurrencyExchangeRate.SETFILTER("Currency Code", Rec."Currency Code");
                //             CurrencyExchangeRate.SETFILTER("Starting Date", '<%1', Today);
                //             IF CurrencyExchangeRate.FINDLAST THEN
                //                 CurreExcrate := CurrencyExchangeRate."ASL.EFRIS.ExciseDutyRate";
                //         end;
                //         IF Item.Get(Rec."No.") then begin
                //             if (Item."Gen. Prod. Posting Group" = 'FG PIPE') Or (Item."Gen. Prod. Posting Group" = 'FG PP BAGS') then begin

                //                 Rec."Percentage Excise Value" := (Rec."ASL.EFRIS.UnitPrice.ExclExcise" * Rec.Quantity * (2.5 / 100));

                //                 Rec."Per Ton" := ((Rec.Weight) / 1000) * Rec.Quantity * 70 * CurreExcrate;

                //                 if Rec."Per Ton" > Rec."Percentage Excise Value" then
                //                     Rec.VALIDATE("Excise Amount", Rec."Per Ton")
                //                 else
                //                     Rec.Validate("Excise Amount", Rec."Percentage Excise Value");
                //             end;
                //         end;
                //     end
                //     else begin
                //         CurrencyExchangeRate.RESET;
                //         CurrencyExchangeRate.SETFILTER("Currency Code", 'USD');
                //         CurrencyExchangeRate.SETFILTER("Starting Date", '<%1', Today);
                //         IF CurrencyExchangeRate.FINDLAST THEN
                //             CurreExcrate := CurrencyExchangeRate."ASL.EFRIS.ExciseDutyRate";
                //         IF Item.Get(Rec."No.") then begin
                //             IF (Item."Gen. Prod. Posting Group" = 'FG PIPE') Or (Item."Gen. Prod. Posting Group" = 'FG PP BAGS') then begin
                //                 Rec."Percentage Excise Value" := (Rec."ASL.EFRIS.UnitPrice.ExclExcise" * Rec.Quantity * (2.5 / 100));
                //                 Rec."Per Ton" := ((Rec.Weight) / 1000) * Rec.Quantity * 70 * CurreExcrate;
                //                 // Message(Format(CurreExcrate));
                //                 if Rec."Per Ton" > Rec."Percentage Excise Value" then
                //                     Rec.VALIDATE("Excise Amount", Rec."Per Ton")
                //                 else
                //                     Rec.Validate("Excise Amount", Rec."Percentage Excise Value");
                //             End;
                //         end;
                //     end;
                // end else begin
                //     Rec."Percentage Excise Value" := 0;
                //     Rec."Per Ton" := 0;
                //     Rec.Validate("Excise Amount", 0);
                // end;

                // if Rec."ASL.EFRIS.UnitPrice.ExclExcise" <> 0 then begin
                //     if Rec."Excise Amount" <> 0 then begin
                //         Rec.Validate("Unit Price", (Rec."ASL.EFRIS.UnitPrice.ExclExcise" + (Rec."Excise Amount" / Rec.Quantity)));
                //     end else begin
                //         Rec.Validate("Unit Price", Rec."ASL.EFRIS.UnitPrice.ExclExcise")
                //     end;
                // end;
            end;

        }
        field(70615590; Deemed; Boolean)
        {
            Caption = 'Deemed';
            Editable = false;
        }
        field(70615591; ProjectID; Text[100])
        {
            Caption = 'VAT Project ID';
            Editable = true;
            TableRelation = "ASL.EFRIS.VatProjects".projectId where(customerNo = field("Sell-to Customer No."));

            trigger OnValidate()
            var
                Vatproject: Record "ASL.EFRIS.VatProjects";
            begin
                if Rec.ProjectID <> '' then begin
                    Vatproject.Reset();
                    Vatproject.SetRange(projectId, Rec.ProjectID);
                    if Vatproject.FindFirst() then begin
                        Rec.ProjectName := Vatproject.projectName;
                        Rec.ProjectUnit := Vatproject.unit;
                        Rec.deemedExemptCode := Vatproject.deemedExemptCode;
                        Rec.Deemed := true;
                        Rec.Modify();
                    end;
                end;
            end;
        }
        field(70615592; ProjectName; Text[250])
        {
            Caption = 'VAT Project Name';
            Editable = false;
        }
        field(70615593; ProjectUnit; Text[250])
        {
            Caption = 'Project Unit';
            Editable = false;
        }
        field(70615594; deemedExemptCode; Text[150])
        {
            Caption = 'Project Unit';
            Editable = false;
        }
        field(50012; "Order Number"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50013; Mapped; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50014; "Total Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50215; "Piece Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                // if Item.Get("No.") then begin
                //     if (Item."Excise Prod. Posting Group" <> '') then begin
                //         "ASL.EFRIS.UnitPrice.ExclExcise" := Item."Unit Price";
                //     end;
                // end;

            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                // if Rec."VAT %" <> 0 then begin
                //     IF Rec."Currency Code" <> '' then begin

                //         IF Rec."Currency Code" = 'USD' then
                //             CurreExcrate := 1
                //         else begin
                //             CurrencyExchangeRate.RESET;
                //             CurrencyExchangeRate.SETFILTER("Currency Code", Rec."Currency Code");
                //             CurrencyExchangeRate.SETFILTER("Starting Date", '<%1', Today);
                //             IF CurrencyExchangeRate.FINDLAST THEN
                //                 CurreExcrate := CurrencyExchangeRate."ASL.EFRIS.ExciseDutyRate";
                //         end;
                //         IF Item.Get(Rec."No.") then begin
                //             if (Item."Gen. Prod. Posting Group" = 'FG PIPE') Or (Item."Gen. Prod. Posting Group" = 'FG PP BAGS') then begin
                //                 Rec."Percentage Excise Value" := (Rec."ASL.EFRIS.UnitPrice.ExclExcise" * Rec.Quantity * (2.5 / 100));
                //                 Rec."Per Ton" := (Rec.Weight / 1000) * Rec.Quantity * 70 * CurreExcrate;

                //                 if Rec."Per Ton" > Rec."Percentage Excise Value" then
                //                     Rec.VALIDATE("Excise Amount", Rec."Per Ton")
                //                 else
                //                     Rec.Validate("Excise Amount", Rec."Percentage Excise Value");
                //             end;
                //         end;
                //     end
                //     else begin
                //         CurrencyExchangeRate.RESET;
                //         CurrencyExchangeRate.SETFILTER("Currency Code", 'USD');
                //         CurrencyExchangeRate.SETFILTER("Starting Date", '<%1', Today);
                //         IF CurrencyExchangeRate.FINDLAST THEN
                //             CurreExcrate := CurrencyExchangeRate."ASL.EFRIS.ExciseDutyRate";
                //         IF Item.Get(Rec."No.") then begin
                //             IF (Item."Gen. Prod. Posting Group" = 'FG PIPE') Or (Item."Gen. Prod. Posting Group" = 'FG PP BAGS') then begin
                //                 Rec."Percentage Excise Value" := (Rec."ASL.EFRIS.UnitPrice.ExclExcise" * Rec.Quantity * (2.5 / 100));
                //                 Rec."Per Ton" := ((Rec.Weight) / 1000) * Rec.Quantity * 70 * CurreExcrate;
                //                 if Rec."Per Ton" > Rec."Percentage Excise Value" then
                //                     Rec.VALIDATE("Excise Amount", Rec."Per Ton")
                //                 else
                //                     Rec.Validate("Excise Amount", Rec."Percentage Excise Value");
                //             End;
                //         end;
                //     end;
                // end else begin
                //     Rec."Percentage Excise Value" := 0;
                //     Rec."Per Ton" := 0;
                //     Rec.Validate("Excise Amount", 0);
                // end;

                // IF xRec.Quantity <> Rec.Quantity then begin
                //     if Rec."ASL.EFRIS.UnitPrice.ExclExcise" <> 0 then begin
                //         if Rec."Excise Amount" <> 0 then begin
                //             Rec.Validate("Unit Price", (Rec."ASL.EFRIS.UnitPrice.ExclExcise" + Round((Rec."Excise Amount" / Rec.Quantity), 0.001, '<')));
                //         end else begin
                //             Rec.Validate("Unit Price", Rec."ASL.EFRIS.UnitPrice.ExclExcise")
                //         end;
                //     end;
                // end;
            end;
        }

        modify("VAT Prod. Posting Group")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                // Rec.Validate(Quantity);
                // if Rec.Quantity <> 0 then begin
                //     if Rec."Excise Amount" <> 0 then
                //         Rec.Validate("Unit Price", ((Rec."Excise Amount" / Rec.Quantity) + "ASL.EFRIS.UnitPrice.ExclExcise"))
                //     else
                //         Rec.Validate("Unit Price", ((Rec."Excise Amount") + "ASL.EFRIS.UnitPrice.ExclExcise"));
                // end;
            end;
        }
    }

    var
        CurrencyExchangeRate: Record 330;
        CurreExcrate: Decimal;
        Item: Record 27;
}
