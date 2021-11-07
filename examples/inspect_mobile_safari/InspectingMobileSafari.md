# Inspecting Mobile Safari

## Why is Mobile Safari interesting?

The iPhone web browser is Safari, or rather "Mobile Safari" because of functionality differences from the desktop "Safari".  Web browsers are better thought of as Operating Systems rather than Applications.  They have powerful access into the system, and can dynamically create and run JavaScript code.  Therefore they have their own Sandbox execution environment.  They also present hardware functionality to Web Apps, such as the Microphone and Speaker.  Since users expect a great high-performance experience from the Web, the Web Browser is given the privilege to run dynamically generated code from websites.  If it did not have this privilege, websites would run significantly slower than competitor devices.  This commercial reason is why we have a foothold into the system.  If the Mobile Safari sandbox can be circumvented, an execution chain can be started.

## Lab Setup

We assume our host machine is an Apple Silicon based Mac.  It does not have to be this type of Mac or even a system running macOS; it could be a GNU/Linux system.  But for the sake of simplicity we make this assumption.

We assume our Mac has the [Brew](https://brew.sh) package manager installed.

We assume we have an iPod Touch running iOS 13.5 jailbroken, and setup with ssh trust and also an alias for convenience.

```
cat ~/.ssh/config
```

on our setup shows
```
Host ipodtouch13_5
        User root
        HostName 192.168.1.85
```

Then we can copy over the `MobileSafari` app with
```
scp -pr ipodtouch13_5:/Applications/MobileSafari.app /tmp
```

In order to understand the privileges of this important app, we need to use the `ldid` tool.  We can get the tool via

```
arch -x86_64 brew install ldid
```

The command prefix `arch -x86_64` ensures the command works from an Apple Silicon Mac.

## Taking a quick tour

It is worthwhile spending some time looking carefully at the entitlements of MobileSafari.  Every entitlement is a privilege, and therefore an opportunity to gain privilege if a vulnerability is found.

```
cd /tmp/MobileSafari.app
ldid -e MobileSafari
```

This will produce a lot of output!  One interesting thing to explore is anything Sandbox related.  We can tune our command with a regular expression match as follows:

```
ldid -e MobileSafari | grep -i -B 17 sandbox
```

which yields
```
	<key>com.apple.security.exception.mach-lookup.global-name</key>
	<array>
		<string>com.apple.DocumentManagerCore.Downloads</string>
		<string>com.apple.proactive.PersonalizationPortrait.NamedEntity.readOnly</string>
		<string>com.apple.coreservices.lsbestappsuggestionmanager.xpc</string>
		<string>com.apple.suggestd.urls</string>
		<string>com.apple.LORemoteUIPinService</string>
		<string>com.apple.remotemanagementd.management-state</string>
		<string>com.apple.SafariBookmarksSyncAgent</string>
		<string>com.apple.Safari.SafeBrowsing.Service</string>
		<string>com.apple.SafariCloudHistoryPushAgent</string>
		<string>com.apple.mobile.keybagd.xpc</string>
		<string>com.apple.parsecd</string>
		<string>com.apple.parsec-fbf</string>
		<string>com.apple.coreduetd.knowledge</string>
		<string>com.apple.internal.safaricyclerd</string>
		<string>com.apple.watchlistd.xpc</string>
		<string>com.apple.Safari.SandboxBroker</string>
```

The same information can be obtained from the [Entitlements Cross-Reference](Bibliography.md#ED) website.  It has a searchable index of entitlements for many versions of iOS and macOS.

## Live Inspection

There is a useful tool which allows us to explore a given process on the iDevice and this exposes a lot of low level detail.  It is called `procexp` by Jonathan Levin.

We install the tool by installing it onto our Mac:
```
arch -x86_64 brew install procexp
```

and then we transfer it onto our iDevice:
```
scp /usr/local/bin/procexp ipodtouch13_5:/tmp
```

We then manually launch Safari on the iDevice.  Once it has launched we can send commands to the device and locally store the results on our Mac.

```
ssh ipodtouch13_5 ps -ef | grep MobileSafari
  501 99988     1   0  4:06PM ??         0:03.45 /Applications/MobileSafari.appMobileSafari
```

Note that the `| grep MobileSafari` portion runs on our Mac, and the `ps -ef` portion runs on the iDevice.

Now from the output of `ps` we know that the second number is the process identifier (PID).  We can run procexp against this:

```
ssh ipodtouch13_5 /tmp/procexp 99988 all > mobile_safari.procexp.txt
```

Again note that the output file, [mobile_safari.procexp.txt](./mobile_safari.procexp.txt), is kept on our Mac.


