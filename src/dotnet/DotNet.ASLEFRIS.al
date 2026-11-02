// .NET types used for direct (online) EFRIS integration without the Offline Mode Enabler.
// Requires app.json "target": "OnPrem" (already set). All aliases are prefixed to avoid
// clashes with DotNet aliases declared by other extensions.
dotnet
{
    assembly("mscorlib")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Convert"; "ASLEFRIS.Convert") { }
        type("System.Text.Encoding"; "ASLEFRIS.Encoding") { }
        type("System.Array"; "ASLEFRIS.Array") { }
        type("System.IO.MemoryStream"; "ASLEFRIS.MemoryStream") { }
        type("System.Security.Cryptography.Aes"; "ASLEFRIS.Aes") { }
        type("System.Security.Cryptography.CipherMode"; "ASLEFRIS.CipherMode") { }
        type("System.Security.Cryptography.PaddingMode"; "ASLEFRIS.PaddingMode") { }
        type("System.Security.Cryptography.ICryptoTransform"; "ASLEFRIS.ICryptoTransform") { }
        type("System.Security.Cryptography.RSA"; "ASLEFRIS.RSA") { }
        type("System.Security.Cryptography.RSAEncryptionPadding"; "ASLEFRIS.RSAEncryptionPadding") { }
        type("System.Security.Cryptography.RSASignaturePadding"; "ASLEFRIS.RSASignaturePadding") { }
        type("System.Security.Cryptography.HashAlgorithmName"; "ASLEFRIS.HashAlgorithmName") { }
    }

    assembly("System")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Security.Cryptography.X509Certificates.X509Certificate2"; "ASLEFRIS.X509Certificate2") { }
        type("System.Security.Cryptography.X509Certificates.X509KeyStorageFlags"; "ASLEFRIS.X509KeyStorageFlags") { }
        type("System.IO.Compression.GZipStream"; "ASLEFRIS.GZipStream") { }
        type("System.IO.Compression.CompressionMode"; "ASLEFRIS.CompressionMode") { }
    }

    assembly("System.Core")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Security.Cryptography.X509Certificates.RSACertificateExtensions"; "ASLEFRIS.RSACertificateExtensions") { }
    }
}
