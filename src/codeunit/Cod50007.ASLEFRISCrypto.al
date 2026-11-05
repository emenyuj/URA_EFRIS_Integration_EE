codeunit 50019 "ASL.EFRIS.Crypto"
{
    // Cryptography and key management for the direct (online) EFRIS web service,
    // replacing what the Offline Mode Enabler used to do locally:
    //   * holds the taxpayer RSA private key (.pfx/.p12, the same file that was configured in the enabler)
    //   * decrypts the AES (symmetric) key returned by T104 with the private key
    //   * AES-encrypts request content and AES-decrypts response content (AES/ECB/PKCS7)
    //   * signs the request content with the private key (SHA1withRSA, PKCS#1 v1.5)
    // Secrets are kept in Isolated Storage (company scope), never in table fields.

    var
        PfxStorageKeyTok: Label 'ASL.EFRIS.PrivateKey.Pfx', Locked = true;
        PfxPasswordStorageKeyTok: Label 'ASL.EFRIS.PrivateKey.Password', Locked = true;
        AESKeyStorageKeyTok: Label 'ASL.EFRIS.AESKey', Locked = true;
        AESKeyTimeStorageKeyTok: Label 'ASL.EFRIS.AESKey.ObtainedAt', Locked = true;
        ErrNoPrivateKey: Label 'No EFRIS private key has been uploaded. Open EFRIS Integration Setup and use the action ''Upload Private Key (.pfx)''.';
        ErrCannotLoadKey: Label 'The EFRIS private key could not be loaded. Check the file and password.\%1';
        ErrNoPrivateKeyInFile: Label 'The uploaded certificate file does not contain a private key. Export the key pair (not only the public certificate) as a .pfx/.p12 file.';
        ErrRSADecryptFailed: Label 'RSA decryption of passowrdDes failed, so EFRIS encrypted the key with a different public key than the one in the uploaded .pfx (thumbprint %1). Register this key for Device No. on the EFRIS portal (Device Management > Device Public Key List and Thumbprint Configure List) or upload the matching .pfx. .NET error: %2', Comment = '%1 = thumbprint, %2 = .NET error';
        ErrAESKeyLength: Label 'passowrdDes was decrypted but does not contain a usable AES key: %1 bytes decrypted, Base64-decoded length %2. Please report these numbers.', Comment = '%1 = decrypted length, %2 = decoded length';
        RSAKey: DotNet "ASLEFRIS.RSA";
        RSAKeyLoaded: Boolean;

    // ------------------------------------------------------------------ private key

    procedure HasPrivateKey(): Boolean
    begin
        exit(IsolatedStorage.Contains(PfxStorageKeyTok, DataScope::Company));
    end;

    procedure SavePrivateKey(var PfxInStream: InStream; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        PfxBase64: Text;
        Cert: DotNet "ASLEFRIS.X509Certificate2";
        TestRSA: DotNet "ASLEFRIS.RSA";
    begin
        PfxBase64 := Base64Convert.ToBase64(PfxInStream);
        // validate before storing
        if not LoadCertificate(PfxBase64, Password, Cert) then
            Error(ErrCannotLoadKey, GetLastErrorText());
        if not Cert.HasPrivateKey then
            Error(ErrNoPrivateKeyInFile);
        if not TryGetRSAPrivateKey(Cert, TestRSA) then
            Error(ErrCannotLoadKey, GetLastErrorText());

        IsolatedStorage.Set(PfxStorageKeyTok, PfxBase64, DataScope::Company);
        SetSecret(PfxPasswordStorageKeyTok, Password);
        // a new private key invalidates any cached symmetric key
        ClearAESKey();
        Clear(RSAKey);
        RSAKeyLoaded := false;
        exit(FormatCertificateInfo(Cert));
    end;

    procedure DeletePrivateKey()
    begin
        if IsolatedStorage.Contains(PfxStorageKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(PfxStorageKeyTok, DataScope::Company);
        if IsolatedStorage.Contains(PfxPasswordStorageKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(PfxPasswordStorageKeyTok, DataScope::Company);
        ClearAESKey();
        Clear(RSAKey);
        RSAKeyLoaded := false;
    end;

    procedure GetCertificateInfo(): Text
    var
        PfxBase64: Text;
        Password: Text;
        Cert: DotNet "ASLEFRIS.X509Certificate2";
    begin
        if not HasPrivateKey() then
            exit('');
        IsolatedStorage.Get(PfxStorageKeyTok, DataScope::Company, PfxBase64);
        Password := GetSecret(PfxPasswordStorageKeyTok);
        if not LoadCertificate(PfxBase64, Password, Cert) then
            exit(GetLastErrorText());
        exit(FormatCertificateInfo(Cert));
    end;

    local procedure FormatCertificateInfo(var Cert: DotNet "ASLEFRIS.X509Certificate2"): Text
    var
        Thumbprint: Text;
        Subject: Text;
        ValidTo: DateTime;
    begin
        Thumbprint := Cert.Thumbprint;
        Subject := Cert.Subject;
        ValidTo := Cert.NotAfter;
        exit(StrSubstNo('Thumbprint: %1 | Subject: %2 | Valid to: %3', Thumbprint, Subject, ValidTo));
    end;

    local procedure EnsureRSAKey()
    var
        PfxBase64: Text;
        Password: Text;
        Cert: DotNet "ASLEFRIS.X509Certificate2";
    begin
        if RSAKeyLoaded then
            exit;
        if not HasPrivateKey() then
            Error(ErrNoPrivateKey);
        IsolatedStorage.Get(PfxStorageKeyTok, DataScope::Company, PfxBase64);
        Password := GetSecret(PfxPasswordStorageKeyTok);
        if not LoadCertificate(PfxBase64, Password, Cert) then
            Error(ErrCannotLoadKey, GetLastErrorText());
        if not TryGetRSAPrivateKey(Cert, RSAKey) then
            Error(ErrCannotLoadKey, GetLastErrorText());
        RSAKeyLoaded := true;
    end;

    local procedure LoadCertificate(PfxBase64: Text; Password: Text; var Cert: DotNet "ASLEFRIS.X509Certificate2"): Boolean
    begin
        // EphemeralKeySet keeps the key in memory only (.NET 4.7.2+). Fall back to the machine key store.
        if TryLoadCertificate(PfxBase64, Password, true, Cert) then
            exit(true);
        exit(TryLoadCertificate(PfxBase64, Password, false, Cert));
    end;

    [TryFunction]
    local procedure TryLoadCertificate(PfxBase64: Text; Password: Text; Ephemeral: Boolean; var Cert: DotNet "ASLEFRIS.X509Certificate2")
    var
        Convert: DotNet "ASLEFRIS.Convert";
        StorageFlags: DotNet "ASLEFRIS.X509KeyStorageFlags";
        PfxBytes: DotNet "ASLEFRIS.Array";
    begin
        PfxBytes := Convert.FromBase64String(PfxBase64);
        if Ephemeral then
            Cert := Cert.X509Certificate2(PfxBytes, Password, StorageFlags.EphemeralKeySet)
        else
            Cert := Cert.X509Certificate2(PfxBytes, Password, StorageFlags.MachineKeySet);
    end;

    [TryFunction]
    local procedure TryGetRSAPrivateKey(var Cert: DotNet "ASLEFRIS.X509Certificate2"; var PrivateKey: DotNet "ASLEFRIS.RSA")
    var
        RSACertificateExtensions: DotNet "ASLEFRIS.RSACertificateExtensions";
    begin
        PrivateKey := RSACertificateExtensions.GetRSAPrivateKey(Cert);
        if IsNull(PrivateKey) then
            Error(ErrNoPrivateKeyInFile);
    end;

    // ------------------------------------------------------------------ signing / RSA

    procedure SignContent(ContentBase64: Text): Text
    var
        Convert: DotNet "ASLEFRIS.Convert";
        Encoding: DotNet "ASLEFRIS.Encoding";
        HashAlgorithmName: DotNet "ASLEFRIS.HashAlgorithmName";
        SignaturePadding: DotNet "ASLEFRIS.RSASignaturePadding";
        DataBytes: DotNet "ASLEFRIS.Array";
        SignatureBytes: DotNet "ASLEFRIS.Array";
    begin
        // Signature = Base64( SHA1withRSA( content field value ) )
        if ContentBase64 = '' then
            exit('');
        EnsureRSAKey();
        DataBytes := Encoding.UTF8.GetBytes(ContentBase64);
        SignatureBytes := RSAKey.SignData(DataBytes, HashAlgorithmName.SHA1, SignaturePadding.Pkcs1);
        exit(Convert.ToBase64String(SignatureBytes));
    end;

    procedure DecryptSymmetricKey(PassowrdDes: Text): Text
    var
        Convert: DotNet "ASLEFRIS.Convert";
        Encoding: DotNet "ASLEFRIS.Encoding";
        EncryptedBytes: DotNet "ASLEFRIS.Array";
        DecryptedBytes: DotNet "ASLEFRIS.Array";
        KeyBytes: DotNet "ASLEFRIS.Array";
        DecodedLength: Integer;
    begin
        // T104: passowrdDes = Base64( RSA_PKCS1( <AES key> ) ), encrypted with the device public key.
        // The decrypted value is normally the Base64 text of the AES key; raw key bytes are accepted too.
        EnsureRSAKey();
        EncryptedBytes := Convert.FromBase64String(PassowrdDes);
        if not TryRSADecrypt(EncryptedBytes, DecryptedBytes) then
            Error(ErrRSADecryptFailed, GetCertificateThumbprint(), GetLastErrorText());
        DecodedLength := -1;
        if TryFromBase64(Encoding.ASCII.GetString(DecryptedBytes), KeyBytes) then begin
            DecodedLength := KeyBytes.Length;
            if IsValidAESKeyLength(KeyBytes.Length) then
                exit(Convert.ToBase64String(KeyBytes));
        end;
        if IsValidAESKeyLength(DecryptedBytes.Length) then
            exit(Convert.ToBase64String(DecryptedBytes));
        Error(ErrAESKeyLength, DecryptedBytes.Length, DecodedLength);
    end;

    procedure GetCertificateThumbprint(): Text
    var
        PfxBase64: Text;
        Cert: DotNet "ASLEFRIS.X509Certificate2";
    begin
        if not HasPrivateKey() then
            exit('');
        IsolatedStorage.Get(PfxStorageKeyTok, DataScope::Company, PfxBase64);
        if not LoadCertificate(PfxBase64, GetSecret(PfxPasswordStorageKeyTok), Cert) then
            exit('');
        exit(Cert.Thumbprint);
    end;

    procedure GetPublicCertificatePem(): Text
    var
        Convert: DotNet "ASLEFRIS.Convert";
        PfxBase64: Text;
        Body: Text;
        Pem: TextBuilder;
        Cert: DotNet "ASLEFRIS.X509Certificate2";
        i: Integer;
    begin
        // Public part only (no private key) - for comparing with / uploading to the EFRIS portal
        if not HasPrivateKey() then
            Error(ErrNoPrivateKey);
        IsolatedStorage.Get(PfxStorageKeyTok, DataScope::Company, PfxBase64);
        if not LoadCertificate(PfxBase64, GetSecret(PfxPasswordStorageKeyTok), Cert) then
            Error(ErrCannotLoadKey, GetLastErrorText());
        Body := Convert.ToBase64String(Cert.GetRawCertData());
        Pem.AppendLine('-----BEGIN CERTIFICATE-----');
        for i := 0 to (StrLen(Body) - 1) div 64 do
            Pem.AppendLine(CopyStr(Body, i * 64 + 1, 64));
        Pem.Append('-----END CERTIFICATE-----');
        exit(Pem.ToText());
    end;

    [TryFunction]
    local procedure TryRSADecrypt(var EncryptedBytes: DotNet "ASLEFRIS.Array"; var DecryptedBytes: DotNet "ASLEFRIS.Array")
    var
        EncryptionPadding: DotNet "ASLEFRIS.RSAEncryptionPadding";
    begin
        DecryptedBytes := RSAKey.Decrypt(EncryptedBytes, EncryptionPadding.Pkcs1);
    end;

    local procedure IsValidAESKeyLength(KeyLength: Integer): Boolean
    begin
        exit(KeyLength in [16, 24, 32]);
    end;

    // ------------------------------------------------------------------ content encoding

    procedure EncodePlainContent(PlainText: Text): Text
    var
        Convert: DotNet "ASLEFRIS.Convert";
        Encoding: DotNet "ASLEFRIS.Encoding";
    begin
        if PlainText = '' then
            exit('');
        exit(Convert.ToBase64String(Encoding.UTF8.GetBytes(PlainText)));
    end;

    procedure EncryptContent(PlainText: Text; AESKeyBase64: Text): Text
    var
        Convert: DotNet "ASLEFRIS.Convert";
        Encoding: DotNet "ASLEFRIS.Encoding";
        Aes: DotNet "ASLEFRIS.Aes";
        Transform: DotNet "ASLEFRIS.ICryptoTransform";
        PlainBytes: DotNet "ASLEFRIS.Array";
        CipherBytes: DotNet "ASLEFRIS.Array";
    begin
        // content = Base64( AES/ECB/PKCS7( UTF8(json) ) )
        if PlainText = '' then
            exit('');
        CreateAes(AESKeyBase64, Aes);
        Transform := Aes.CreateEncryptor();
        PlainBytes := Encoding.UTF8.GetBytes(PlainText);
        CipherBytes := Transform.TransformFinalBlock(PlainBytes, 0, PlainBytes.Length);
        exit(Convert.ToBase64String(CipherBytes));
    end;

    [TryFunction]
    procedure TryDecodeResponseContent(ContentBase64: Text; Encrypted: Boolean; Zipped: Boolean; AESKeyBase64: Text; var PlainText: Text)
    var
        Convert: DotNet "ASLEFRIS.Convert";
        Encoding: DotNet "ASLEFRIS.Encoding";
        Aes: DotNet "ASLEFRIS.Aes";
        Transform: DotNet "ASLEFRIS.ICryptoTransform";
        Bytes: DotNet "ASLEFRIS.Array";
    begin
        // Tolerant decoding: handles gzip before and/or after AES, as EFRIS may apply either order.
        PlainText := '';
        if ContentBase64 = '' then
            exit;
        Bytes := Convert.FromBase64String(ContentBase64);
        // gzip is detected from the data (magic bytes); for encrypted, non-zipped content it is not checked here
        if (Zipped or not Encrypted) and IsGZip(Bytes) then
            GZipDecompress(Bytes);
        if Encrypted then begin
            // AES output is always a multiple of 16 bytes; otherwise it is still Base64 text
            if (Bytes.Length mod 16) <> 0 then
                Bytes := Convert.FromBase64String(Encoding.ASCII.GetString(Bytes));
            CreateAes(AESKeyBase64, Aes);
            Transform := Aes.CreateDecryptor();
            Bytes := Transform.TransformFinalBlock(Bytes, 0, Bytes.Length);
            if IsGZip(Bytes) then
                GZipDecompress(Bytes);
        end;
        PlainText := Encoding.UTF8.GetString(Bytes);
    end;

    local procedure CreateAes(AESKeyBase64: Text; var Aes: DotNet "ASLEFRIS.Aes")
    var
        Convert: DotNet "ASLEFRIS.Convert";
        CipherMode: DotNet "ASLEFRIS.CipherMode";
        PaddingMode: DotNet "ASLEFRIS.PaddingMode";
    begin
        Aes := Aes.Create();
        Aes.Mode := CipherMode.ECB;
        Aes.Padding := PaddingMode.PKCS7;
        Aes.Key := Convert.FromBase64String(AESKeyBase64);
    end;

    local procedure IsGZip(var Bytes: DotNet "ASLEFRIS.Array"): Boolean
    var
        Convert: DotNet "ASLEFRIS.Convert";
    begin
        if IsNull(Bytes) then
            exit(false);
        if Bytes.Length < 2 then
            exit(false);
        // gzip magic bytes 1F 8B encode to 'H4s=' in Base64
        exit(Convert.ToBase64String(Bytes, 0, 2) = 'H4s=');
    end;

    local procedure GZipDecompress(var Bytes: DotNet "ASLEFRIS.Array")
    var
        InputStream: DotNet "ASLEFRIS.MemoryStream";
        OutputStream: DotNet "ASLEFRIS.MemoryStream";
        GZipStream: DotNet "ASLEFRIS.GZipStream";
        CompressionMode: DotNet "ASLEFRIS.CompressionMode";
    begin
        InputStream := InputStream.MemoryStream(Bytes);
        GZipStream := GZipStream.GZipStream(InputStream, CompressionMode.Decompress);
        OutputStream := OutputStream.MemoryStream();
        GZipStream.CopyTo(OutputStream);
        GZipStream.Close();
        Bytes := OutputStream.ToArray();
    end;

    [TryFunction]
    local procedure TryFromBase64(Value: Text; var Bytes: DotNet "ASLEFRIS.Array")
    var
        Convert: DotNet "ASLEFRIS.Convert";
    begin
        Bytes := Convert.FromBase64String(Value);
    end;

    // ------------------------------------------------------------------ AES key cache (shared by all sessions)

    procedure GetAESKey(var AESKeyBase64: Text; var ObtainedAt: DateTime): Boolean
    var
        ObtainedAtText: Text;
    begin
        AESKeyBase64 := '';
        ObtainedAt := 0DT;
        if not IsolatedStorage.Contains(AESKeyStorageKeyTok, DataScope::Company) then
            exit(false);
        AESKeyBase64 := GetSecret(AESKeyStorageKeyTok);
        if IsolatedStorage.Get(AESKeyTimeStorageKeyTok, DataScope::Company, ObtainedAtText) then
            if not Evaluate(ObtainedAt, ObtainedAtText, 9) then
                ObtainedAt := 0DT;
        exit(AESKeyBase64 <> '');
    end;

    procedure StoreAESKey(AESKeyBase64: Text)
    begin
        SetSecret(AESKeyStorageKeyTok, AESKeyBase64);
        IsolatedStorage.Set(AESKeyTimeStorageKeyTok, Format(CurrentDateTime(), 0, 9), DataScope::Company);
    end;

    procedure ClearAESKey()
    begin
        if IsolatedStorage.Contains(AESKeyStorageKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(AESKeyStorageKeyTok, DataScope::Company);
        if IsolatedStorage.Contains(AESKeyTimeStorageKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(AESKeyTimeStorageKeyTok, DataScope::Company);
    end;

    local procedure SetSecret(StorageKey: Text; Value: Text)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        if IsolatedStorage.Contains(StorageKey, DataScope::Company) then
            IsolatedStorage.Delete(StorageKey, DataScope::Company);
        if Value = '' then
            exit;
        // SetEncrypted is limited to 215 characters
        if CryptographyManagement.IsEncryptionEnabled() and CryptographyManagement.IsEncryptionPossible() and (StrLen(Value) <= 215) then
            IsolatedStorage.SetEncrypted(StorageKey, Value, DataScope::Company)
        else
            IsolatedStorage.Set(StorageKey, Value, DataScope::Company);
    end;

    local procedure GetSecret(StorageKey: Text) Value: Text
    begin
        if not IsolatedStorage.Get(StorageKey, DataScope::Company, Value) then
            Value := '';
    end;

    // ------------------------------------------------------------------ globalInfo helpers

    procedure GetRequestTime(): Text
    var
        XmlTime: Text;
    begin
        // EFRIS expects the current time in Uganda (UTC+3), format yyyy-MM-dd HH:mm:ss.
        // Format 9 always renders in UTC, independent of the server/user time zone.
        XmlTime := Format(CurrentDateTime() + (3 * 60 * 60 * 1000), 0, 9);
        exit(CopyStr(XmlTime, 1, 10) + ' ' + CopyStr(XmlTime, 12, 8));
    end;

    procedure NewDataExchangeId(): Text
    begin
        // UUID, max 32 characters
        exit(LowerCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
}
