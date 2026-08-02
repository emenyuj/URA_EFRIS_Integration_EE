enum 50028 "ASL.EFRIS.DeliveryTermsCode"
{
    Extensible = true;

    value(0; " ") { }
    value(1; CFR)
    {
        Caption = 'Cost and Freight';
    }
    value(2; CIF)
    {
        Caption = 'Cost Insurance and Freight';
    }
    value(3; CIP)
    {
        Caption = 'Carriage and Insurance Paid To';
    }
    value(4; CPT)
    {
        Caption = 'Carriage Paid to';
    }
    value(5; DAP)
    {
        Caption = 'Delivered at Place';
    }
    value(6; DDP)
    {
        Caption = 'Delivered Duty Paid';
    }
    value(7; DPU)
    {
        Caption = 'Delivered at Place Unloaded ';
    }
    value(8; EXW)
    {
        Caption = 'Ex Works';
    }
    value(9; FAS)
    {
        Caption = 'Free Alongside Ship';
    }
    value(10; FCA)
    {
        Caption = 'Free Carrier';
    }
    value(11; FOB)
    {
        Caption = 'Free On Board';
    }
}