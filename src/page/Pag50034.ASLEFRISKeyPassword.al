page 50034 "ASL.EFRIS.KeyPassword"
{
    PageType = StandardDialog;
    Caption = 'EFRIS Private Key Password';

    layout
    {
        area(Content)
        {
            group(General)
            {
                InstructionalText = 'Enter the password of the .pfx/.p12 key store (the same password that was used when configuring the private key in the Offline Mode Enabler). Leave blank if the file has no password.';
                field(Password; KeyPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the password of the private key file.';
                }
            }
        }
    }

    var
        KeyPassword: Text;

    procedure GetPassword(): Text
    begin
        exit(KeyPassword);
    end;
}
