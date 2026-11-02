# EFRIS Direct Online Mode (no Offline Mode Enabler)

Version 1.1.0.0 connects Business Central straight to the URA EFRIS web service. The encryption and signing that the Offline Mode Enabler used to do now runs inside BC.

| | Offline Enabler (before) | Direct Online (now) |
|---|---|---|
| Endpoint | `http://<host>:9880/efristcs/ws/tcsapp/getInformation` | Test: `https://efristest.ura.go.ug/efrisws/ws/taapp/getInformation`<br>Prod: `https://efrisws.ura.go.ug/ws/taapp/getInformation` |
| Request content | Base64(JSON), no signature | Base64(AES(JSON)), `codeType 1 / encryptCode 2` |
| Signature | empty | Base64(SHA1withRSA(content)) with the taxpayer private key |
| Symmetric key | handled by enabler | T104 → `passowrdDes` RSA-decrypted with the private key, cached for 20 h (valid 24 h) in Isolated Storage, refreshed automatically |
| Device No. / TIN | read from enabler (`tcsInfo`) | entered in setup; details filled from T103 |
| `dataSource` (T109/T110) | 104 (Mis) | 103 (WebService API) |

The enabler path is still there. Set **Connection Mode = Offline Mode Enabler (legacy)** to fall back to it.

## One-time setup

1. **Keys and device on the EFRIS portal** (test portal first, then production):
   - Use the same RSA-2048 key pair (.pfx/.p12) that was configured in the enabler, or create a new one with KeyStore Explorer.
   - Under *Device Management → Thumbprint Configure List*, register the device number and the certificate thumbprint, then wait for URA's approval email.
   - Under *Device Management → Device Public Key List*, upload the public key for the device.
2. **Business Central**: in Extension Management, open the extension's settings and turn on **Allow HttpClient Requests**.
3. **EFRIS Integration Setup page**:
   1. Set **Connection Mode** to *Direct Online – URA Test*. This fills in Server URL.
   2. Enter **Device No.** (the number URA assigned to the device) and **TIN**. **WS Version** defaults to `1.1.20191201`.
   3. Run **Upload Private Key (.pfx)** and enter the key-store password.
   4. Run **Test Connection (T101)**. The server time must be within ±10 minutes of the request time shown.
   5. Run **Refresh Symmetric Key (T104)**. If this fails with a key error, the portal public key does not match the uploaded .pfx.
   6. Run **Get Taxpayer Info (T103)**. This fills in BRN, legal name and business name.
   7. Run **Update System Dictionary** (T115), then refresh commodity categories as before.
4. After URA UAT sign-off, switch to *Direct Online – URA Production*, register the device and thumbprint on the production portal, and upload the production key if it is different.

## Technical notes

- `target: OnPrem` is required because the RSA/AES operations use .NET interop (`src/dotnet/DotNet.ASLEFRIS.al`). BC17's System Application has no RSA decrypt.
- New objects: codeunit 50007 `ASL.EFRIS.Crypto`, page 50034 `ASL.EFRIS.KeyPassword`, enum 50030 `ASL.EFRIS.ConnectionMode`, setup field 70615609 `ASL.EFRIS.ConnectionMode`, and enum value `T104`.
- The .pfx and password are stored in Isolated Storage (company scope). The password is encrypted when BC data encryption is enabled.
- The signing key loads with `EphemeralKeySet` and falls back to `MachineKeySet`. If the BC service account can't load it, check its access to the machine key store.
- Requests are encrypted according to the "Request Encrypted" column of Interface Design v24.0.1. T101/T103/T104/T115/T123/T124/T125/T135/T136/T138 send plain Base64. Content is always signed when it isn't empty.
- If the server returns 02/03/15, or the response can't be decrypted, the key is refreshed through T104 and the request is retried once.
- `globalInfo` fixes: `dataExchangeId` is now a 32-character UUID, `requestTime` is UTC+3 whatever the server's time zone, `responseDateFormat`/`responseTimeFormat` now send the format patterns instead of formatted dates, `deviceMAC` is `FFFFFFFFFFFF`, `agentType` is `0`, and a failed globalInfo now stops the request instead of being ignored.
