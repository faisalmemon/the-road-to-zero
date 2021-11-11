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

The full search results are [here](./tcc_manager_daemons.txt).



