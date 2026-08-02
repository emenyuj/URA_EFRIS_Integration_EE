enum 50026 "ASL.EFRIS.TaxExemptType"
{
    Extensible = true;

    value(0;
    "None")
    {
    }
    value(101;
    "VAT")
    {
        Caption = 'VAT (VAT tax exemption)';
    }
    value(102;
    "Excise Duty")
    {
        Caption = 'Excise Duty (Excise Duty tax exemption)';
    }
    value(103;
    "Both")
    {
        Caption = 'Both (Both VAT and Excise Duty tax exemption)';
    }
}
