# iOS Defense Mechanisms

The iOS system has become more sophisticated over time as the usage pattern and commercialisation of it has evolved.  Here we survey the [history](./Bibliography.md#MT) of the defense mechanisms (mitigation techniques) that have been deployed by Apple in iOS.

## History of iOS Mitigation Techniques

| iOS Version | Mechanism | Comment | Attacks |
| -- | -- | -- | -- |
| 1.x | Encrypted OS images | Everything runs as root; no code sign or sandbox | Attacks were WebKit (website) originated |
| 2.x | Code Sign, Sandbox | The Sandbox is the most durable and important technique to date | Network based (proxy server, IPSec), Unicode, Webkit (CSS, Certificates, JavaScript, UTF-8, XSLT, GC), FreeType Fonts, DNS poisoning, Networking |
| 3.x | - | - | CoreGraphics, Image Processing (PNG), Unicode, Networking (IPSec, ICMP), XML (libxml), Mail (HTML), Video (MPEG-4), Safari (History, Clickjacking), WebKit (CSS, SVG, JavaScript, GC, DOM), SMS |
| 4.x | ASLR/DEP (iOS 4.3) | - | Sandbox, Network (PIM), Image Processing (TIFF, GIF), System Library, XML, Passcode, Safari (Cookies, Certificates), WebKit (CORS, Parsing, CSS, XSS, HTML, HTTP, XML, JavaScriptm, SVG, NTLM, DOM), PDF (FreeType), IOSurface, Configuration Profiles, GSM (TMSI)  |
| 5.x | user mode ASLR | Harder to write shell code |
| 6.x | kernel mode ASLR, Kernel Address Space isolation | Harder to reach kernel |
