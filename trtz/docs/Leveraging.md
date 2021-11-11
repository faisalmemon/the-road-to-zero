# Leveraging Research

## Security Bulletins

One strategy for learning and exploration is to stick on an old version of iOS for which we have a Jailbreak.  Then look at each security bulletin from Apple to see what vulnerabilities have been fixed.  Using the CVE number, it is easy to google for write-ups for these.  For example, search for "CVE-2020–9934 poc" meaning "proof of concept for CVE-2020-9934".  We should note, however, that only a minority of CVEs have an associated write-up.

A list of security bulletins can be reached from [iOS Version History](./Bibliography.md#IVH).  Apple documents them in links of the form [HT211288](./Bibliography.md#S136).  This particular example lists the vulnerability
```
CVE-2020-9934: Matt Shockley (linkedin.com/in/shocktop)
```
amongst many others for iOS 13.6 (iOS 13.6 produced an extremely long security bulletin).

If we are lucky the newer exploit is applicable to our older iOS version.

## Bug Clustering

Even if a new CVE is not applicable to our old iOS version, it can generate research ideas worth exploring.  When security bugs are found, often they are clustered, and perhaps only the instance of the bug in a Proof-of-Concept reported by the security researcher is addressed.  The adjacent bugs are sometimes ignored.

Given that security bugs can be "clustered", a confirmed fix of any security bug can offer good research opportunities in neighbouring code or functionality.

## Keeping to a promising track

No doubt, it takes a lot of perserverence to find a vulnerability.  We need to give ourselves the best chance of getting rewarded with a result because otherwise our motivation levels can wane.  If we think of bug hunting as a game, the best games are where the goal is reachable with some effort, but not beyond our abilities.

Furthermore we need to keep things in balance.  Consider the example of programming in a new domain.  Randomly diving in, making elementary errors, and then constantly hitting the Stack Overflow website for answers is not productive.  At the opposite extreme, studying all the books in the domain area means we have knowledge but little resiliance.  We only know what we are taught.  And this material is easily forgotten due to a lack of practical reinforcement.

For hacking to be a journey, we need to be willing just to try and experiment, and explore what we can.  Then back that up with formal reading, or exercises which build a specific skill, such as reverse engineering or Return-Oriented Programming.  But our experiments cannot be too random.  This is where following similar footsteps of others can help out.

## Studying from Weakness

Another way of looking at things is to study the CWE.  The [Common Weakness Enumeration](./Bibliography.md#CWE) goes through the classes of security errors that our made.  In the same way that learning design patterns gives us the mental langauge to observe and identify design issues and solutions in software, the CWE helps sharpen our eye for mistakes we want to exploit.

We don't want to study a piece of code blindly and miss vulnerabilities.  It would be like propecting for gold, but not knowing what unprocessed natural gold deposits look like.

## Case study CVE-2020-9934

The vulnerability, recorded as CVE-2020-9934, as found by Matt Shockley, and recorded in his [write-up](https://medium.com/@mattshockl/cve-2020-9934-bypassing-the-os-x-transparency-consent-and-control-tcc-framework-for-4e14806f1de8) is a good example of how we can learn from weaknesses found by others.

In brief, this vulnerability is that the Trust, Consent, and Control Framework (TCC) can be subverted through the use of maliciously supplied environmental variables.

The weakness may be classified as [CWE-20: Improper Input Validation](https://cwe.mitre.org/data/definitions/20.html).  This in turn is related to the Common Attack Pattern [CAPEC-13: Subverting Environment Variable Values](http://capec.mitre.org/data/definitions/13.html).

We assume the reader has gone through this write-up.  Here we do a meta analysis; we look at the _thinking_ that possibly went into the attack.

We see that TCC is valuable because we want to attack sensitive resources without triggering User Interface pop-up dialogs asking for permission.

TCC is controlled by entitlements.  Which entitlement?  Looking at the framework

```
codesign -d --entitlements - \
/System/Library/PrivateFrameworks/TCC.framework/Resources/tccd

Executable=/System/Library/PrivateFrameworks/TCC.framework/Versions/A/Resources/tccd
[Dict]
	[Key] com.apple.private.tcc.manager
	[Value]
		[Bool] true
	[Key] com.apple.rootless.storage.TCC
	[Value]
		[Bool] true
	[Key] com.apple.fileprovider.acl-read
	[Value]
		[Bool] true
	[Key] com.apple.private.security.storage.TCC
	[Value]
		[Bool] true
	[Key] com.apple.private.system-extensions.tcc
	[Value]
		[Bool] true
	[Key] com.apple.private.kernel.global-proc-info
	[Value]
		[Bool] true
	[Key] com.apple.private.notificationcenterui.tcc
	[Value]
		[Bool] true
	[Key] com.apple.private.responsibility.set-arbitrary
	[Value]
		[Bool] true
	[Key] com.apple.private.coreservices.canmaplsdatabase
	[Value]
		[Bool] true
	[Key] com.apple.private.tcc.allow
	[Value]
		[Array]
			[String] kTCCServiceSystemPolicyAllFiles
```

The entitlement of interest is `com.apple.private.tcc.manager`.

The attacker merely went straight for the `tccd` daemon.  This is the logical first choice.

If this vulnerability is part of a cluster of bugs, we can find other potentially vulnerable daemons via a look up against the [Entitlements Cross-Reference](./Bibliography.md#ED).  The specific query would be [http://newosxbook.com/ent.jl?ent=com.apple.private.tcc.manager&osVer=OSX](http://newosxbook.com/ent.jl?ent=com.apple.private.tcc.manager&osVer=OSX).

The full search results are [tcc_manager_daemons.txt](./tcc_manager_daemons.txt).

We can search to occurences of "HOME" using:
```
for item in $(cat tcc_manager_daemons.txt)
do
    strings $item 2>/dev/null | grep -l HOME --label $item 
done
```

to yield:
```
/System/Library/PrivateFrameworks/CloudDocsDaemon.framework/XPCServices/ContainerMetadataExtractor.xpc/Contents/MacOS/ContainerMetadataExtractor
/System/Library/PrivateFrameworks/CloudKitDaemon.framework/Support/cloudd
/System/Library/PrivateFrameworks/SyncedDefaults.framework/Support/syncdefaultsd
/System/Library/PrivateFrameworks/TCC.framework/Versions/A/Resources/tccd
/usr/bin/brctl
/usr/libexec/fmfd
/usr/libexec/pkd
```

All of these programs and daemons look interesting.  They are all privileged.  Some are obscure and lesser used functionality.  For example `brctl` appears to be a low level manipulation and diagnostics tool for iCloud.

When exploring data-sensitive commands, it is best we establish a safe lab environment.  This is because we don't want to delete or damage our own production data.

### Digression: Lab machine setup

When we do static analysis we should use an "orange" environment.  This is a separate environment where we run tools against software to inspect them.

When we do dynamic analysis we should use a "red" environment.  This is a separate environment where code is executed.

A typical way to do things is to use an Intel-based Mac.  Install it with a special Apple ID used only for security research.  Potentially this could be a paid for Apple developer account that can be used to code sign binaries.

Then create a Virtual Machine on the Mac and install it with a different Apple ID which is not connected with a paid developer account.  This whole machine should be snapshot-ed so experiments can be done and then the configuration reverted.

### Studying `brctl`

In a red environment we can play around with the `brctl` command.
If we create a file and directory structure:
```
ParentFolder/sampleText.txt
```
and this lives under the iCloud Drive of user `redtestsecure` we have
```
/Users/redtestsecure/Library/Mobile Documents/com~apple~CloudDocs/
```
as the root directory of `ParentFolder`.

To throw away the local file `sampleText.txt` so as to tell iCloud that it would need to re-download the file (in contrast to propagating the deletion of the file to the cloud) we would run the command
```
brctl evict ./sampleText.txt
```
Immediately the cloud download icon would appear on the Finder GUI for this file.

At this point we are ready to do some hacking.  We know there is at least some chance of a vulnerability through the HOME environmental variable since there was a prior bug using this approach.  We also know that this program is privileged so would definately produce valuable results if there was an exploit.  Access to sensitive data is called out for bug bounties on the Apple Bug bounty program.

The next steps would be to learn more about the utility, and then study the program's internals via reverse engineering.

Whilst we have not turned up an actual exploit so far, we have shared some insights for how a hacker would think about attacking, in this case, macOS.  Once we had an exploit then it might be possible to cross-leverage our knowledge to attack iOS.  Both systems use TCC.

Going back to a theme raised at the beginning of our book, we could profit by having two projects on-going.  One project is hacking the system.  That is something destructive.  The other project is writing some application or software.  That is something constructive.

So at this point, a good idea would be to develop an iCloud drive management program alongside our hacking research.  Apple don't provide any user interface to force synchronization of our files.  It happens "by magic" without any user side control knobs.

This means that even if `brctl` does not turn up any good hacks, we might end up with a tool we could share or sell as part of the effort.  It is easy to see that this dual-approach would help keep us motivated along this journey.  We could switch between software engineering and hacking to maintain our interest.
