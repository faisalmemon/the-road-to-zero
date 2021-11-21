# iOS Defense Mechanisms

The iOS system has become more sophisticated over time as the usage pattern and commercialisation of it has evolved.  Here we survey the [history](./Bibliography.md#MT) of the defense mechanisms (mitigation techniques) that have been deployed by Apple in iOS.

## History of iOS Mitigation Techniques

| iOS Version | Mechanism | Comment |
| -- | -- | -- |
| 1.x | Encrypted OS images | Everything runs as root; no code sign or sandbox |
| 2.x | Code Sign, Sandbox | The Sandbox is the most durable and important technique to date |
| 3.x | - | - |
| 4.x | ASLR/DEP (iOS 4.3) | - |
| 5.x | User mode ASLR | Harder to write shell code |
| 6.x | Kernel mode ASLR, Kernel Address Space isolation | Harder to reach kernel |

## History of iOS Attacks

### Increasing variety of attacks

The attacks have been cummulative across OS releases.  For example, iOS 1.x (strictly known as iPhoneOS) was vulnerable to WebKit based attacks.  Each version onwards has had a WebKit based attack also.  However, the method of attack has changed due to the mitigations employed by Apple.  Each new release sees a new type of attack, partly as a result of new functionality and technology being added to the device.

Whilst it seems that newer releases have more vulnerabilities than earlier releases, it is better to think of attacks as a cottage industry.  In this we mean that once someone has expertise in Wireless attacks, that expertise expands over time as Wireless mitigations improve, creating a cat-and-mouse game.  The same being true for WebKit, SMS, Networking, etc. we thus see a cottage industry of attacks, where each person (or "cottage") is working on their own technology area as their attack vector.

What is means for an attacker is that it is sufficient to stay within a specific technology domain and master the skills to attack that area.  The secret is depth of skills, not breadth of knowledge.  The reason for this is that attacks are possible in many areas because the distribution of zero-days is widespread.

The most fortified area of iOS is the SMS and other autonomous aspects of functionality.  These yield the most valuable attacks, so-called "0-click" attacks.

The web side of things is also fortified.  But the web is so complex and there is a need to stay on top of evolving standards to compete with other devices that provide a web experience.  Therefore the attack surface via the web continues to be significant and promising to an attacker.  Overall, the center of gravity has landed on web-based attacks.  These offer "1-click" attacks, the next best thing to "0-click" attacks.

### Web is the most fruitful area for attack

From studying the security disclosure notices from Apple, the pattern is clear.  Attacks are dominated by WebKit and Web-technologies.  This is because an attack mounted from inside an app can be ejected from the App Store to stop the malware being spread.  Furthermore, Apple can reach out to devices that have already installed an App and remotely delete it.  This facility is little-advertised because it demostrates the reach and power of Apple over the device ecosystem.  Such software would be considered "malware".

### App Review kills the malware vector

One purpose of Apple App Review is to identify malware either by static or dynamic analysis, or by human review.  So the only way such software ends up on the device would either be through Enterprise App Distribution, or by volunteering to run such software.

App Review is the most significant distinction between an iDevice and historic software distribution platforms.  Much of the computer security industry deals with Malware and its related variants.  Most security attacks are malware driven.  No human is needed so it scales.  Targeted attacks are a combination of Phishing and Malware.  It is harder to scale due to human effort to tailor the attack.  But significant financial or other rewards can offset this cost.

### Enterprise distribution of malware

Enterprise distribution certificates are hard to acquire from Apple as a result of due dilligence checks needed to acquire an Enterprise Developer Account.  These can be invalidated by Apple, and the iDevice calls home to see if a certificate is invalid.  So this attack route comes down to timely identification and disablement of such certificates.  Enterprise credentials are sometimes stolen by malicious actors, and then malware is distributed without the owner being aware of the problem.

### Web based attack

Web-based attacks avoid the App Store malware checks, and since websites are not allow-listed for access by Apple, anyone can host malicious content and trick a user to visit their site.  So this would be an attack comprising of both social engineering and technical means.  We would call these "1-click" attacks.

### Autonomous attack

The rarest type of attack are attacks on the autonomous processing of an iDevice.  For example, receipt of an SMS message is involuntary on behalf of the user.  Such messages can have rich content, and thus form an attack surface.  We would call these "0-click" attacks.

### Jailbreak attack

Jailbreak software is special because it exploits the system to remove security protections because the owner desires this circumvention.  So it is in an adjacent category to malware.  Here any attack vector is "acceptable".  For example, a jailbreak could be deployed from a website or via downloaded software, or downloaded source code.  Jailbreak software needs to deal with code signing in order to get the app to run on the iDevice.  For registered developers they have their own signing credentials so this is not a problem.

For non-developers, various tools are available that automate the signing of the app via the Free developer account method Apple setup to facilitate learning and deployment of Apps in an Educational setting.  That is, spreading and popularizing the understanding of App development.  The Free access is now broken for such automated tooling due to it being abused for Jailbreak signing.

## Attack Surface

The most important technology attack surface is the Web.
All areas of web technology have been used to create exploits.

In iOS, WebKit is used to serve web-based technologies.  It is open source.

From studying the security disclosures of each version of iOS, the following breeakdown can be seen of areas used to create exploits.

- WebKit
    - Certificates
    - Javascript
    - UTF-8
    - XSLT
    - CSS
    - SVG
    - DOM
    - CORS
    - Parsing
    - XSS
    - HTML
    - HTTP
    - NTLM

- Networking
    - Proxy Server
    - IPSec
    - DNS
    - ICMP
    - PIM
    - SSLv3/TLS 1.0
    - TCP
    - WiFi Credentials
    - VPN
    - BPF

- Graphics
    - CoreGraphics
    - Image Processing
	- PNG
	- TIFF
	- GIF
    - IOSurface
    - CoreMedia
    - GLSL

- Application Sandbox
    - System Logs

- Passcode

- Passbook

- File format processing
    - MS Office files

- Configuration Profiles

- GSM
    - TMSI

- Unicode

- Libraries
    - libxml
    - libresolv

- Mail
    - HTML
    - Exchange
	- Cookies
    - S/MIME

- Video
    - MPEG-4

- Safari
    - History
    - Clickjacking
    - Cookies
    - Certificates

- Messaging
    - SMS

- Calendar
    - CalDAV

- Settings
    - Parental Restrictions

- Alerts

- Kernel
    - Codesigning
    - Kernel address leak 

- dyld

- File System
    - HFS

- Siri
    - Email

## Types of Attackers

From looking at the security disclosures of iOS a stark pattern arises.  There are three classes of attackers:

- Accidental Finders
- Systematic Finders
- Motivated Attackers

### Accidental Finders
In this group, the author was tangentially involved with security and reported a vulnerability, usually an information disclosure, as a on-off report.  

### Systematic Finders
In this group, the author is normally in a team with a remit to find vulnerabilities and they often use systematic techniques.  For example, a fuzz testing tool, or an address sanitizer.  Often they have a focus on one particular area, for which they find multiple bugs.  These are often in the same OS release.

### Motivated Attackers
In this group the author, or team, is actually trying to get into the iDevice for a further goal.  It could be to further exploit the phone, or to fashion a Jailbreak.  These are the best bugs because they tend to be more powerful bugs.  They reveal more about the attack techniques that can be used against the system and how to understand how to handle OS mitigations.

### Interesting People

The most capable attackers are sometimes working on their own, working as part of a company to improve security, or are working as part of a hacking team.  They either are a Motivated Attacker, or simulate being a Motivated Attacker.

Here is a partial list of these interesting attackers:

- pod2g
- evad3rs
- iOS Jailbreak Dream Team
- Dan Rosenberg
- comex
- Mark Dowd
- Abhishek Arya
- Adam Barth
- Charlie Miller
