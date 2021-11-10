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

## Static Analysis

Let us first start by doing a static analysis of `MobileSafari`.  That is, analysing it without running it.

### Entitlements

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

So we now are able to start building a mental model of what Mobile Safari it, and what its attack surface is.  We see the processes, threads, memory, and Mach ports that are used.  We also see all the files that have been opened by `MobileSafari`.

### Hidden functionality

The most fruitful way to look at a piece of technology is from the angle of triggering lesser-used functionality, or undocumented functionality.  In practice a software project will grow over time, and new engineers are added to the project and often the original engineers move to other projects or roles.  This means some of the earlier functionality can be less well understood.  Particularly in the beginning of a project, a lot of functionality is offered, but only a subset of functionality becomes popular.  So less used features are often left in the product and later changes to the product can expose bugs, faults and exploitable conditions via the older less used functionality of the software.  The reason why older functionality is not pruned out is because sometimes it is not clear who is still relying on the older functionality.  So it is "safer" just to keep it in.  But this attitude allows us opportunities to find bugs and potential exploits.

#### `MobileSafari` URL Handlers

We can explore the URL handler features of MobileSafari by looking at its `Info.plist` file.

```
plutil -p /tmp/MobileSafari.app/Info.plist
```

Amongst the output we see:
```
"CFBundleURLTypes" => [
    0 => {
      "CFBundleURLIsPrivate" => 1
      "CFBundleURLName" => "Web App URL"
      "CFBundleURLSchemes" => [
        0 => "webclip"
      ]
    }
    1 => {
      "CFBundleURLName" => "Web site URL"
      "CFBundleURLSchemes" => [
        0 => "http"
        1 => "https"
      ]
    }
    2 => {
      "CFBundleURLName" => "FTP URL"
      "CFBundleURLSchemes" => [
        0 => "ftp"
      ]
    }
    3 => {
      "CFBundleURLName" => "Web Search URL"
      "CFBundleURLSchemes" => [
        0 => "x-web-search"
      ]
    }
    4 => {
      "CFBundleURLIsPrivate" => 1
      "CFBundleURLName" => "MobileSafari Tab URL"
      "CFBundleURLSchemes" => [
        0 => "com-apple-mobilesafari-tab"
      ]
    }
  ]
```

#### Handling `x-web-search`

We saw earlier that `MobileSafari` has a URL handler `x-web-search`

From some research on Google and [Stack Overflow](https://stackoverflow.com/a/50044505) we can come up with some code to trigger such functionality.

It turns out that the best technology stack to do experimentation and exploit development is to use Objective-C because this gives us the fewest number of abstraction layers between our code and the system.  Objective-C is also more amenable to hacking because it is less type-safe than Swift.  We can craft malicious message calls and call private APIs easily.

In our case, we just make a standard API call as follows:
```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"x-web-search://?toast"]
                                       options:@{}  completionHandler:^(BOOL success) {
        NSLog(@"status %ld", (long)success);
    }];
}
```

This indeed will launch the browser and perform a search for "toast" using the default search engine.

## Dynamic Analysis

We now switch to doing a dynamic analysis of `MobileSafari`.

### Process Explorer

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

The full output file, [mobile_safari.procexp.txt](./mobile_safari.procexp.txt), is kept on our Mac.

The output file is quite large, so we'll show a truncated excerpt below:

```
-----------------
Process: 99988  Name: MobileSafari      Parent:     1   Status: runnable
Container: /private/var/mobile/Containers/Data/Application/FDFCAC6B-8E4F-4381-B354-C0DEAB28D32B
Flags:   64-bit,called exec,session leader,App

Extmods: Task shows no signs of external modification or tampering
Code signing: valid,get-task-allow,installer,require enforcement,require library validation

UID:      501   RUID:   501     SVUID:   501
GID:      501   RGID:   501     SVGID:   501

Virtual size:           4312M (4522409984)      Resident size:          31M (33226752)
Time:     00.08   =    00.08 (User)    +    00.00 (System)
Syscalls:       38961   Mach Traps:   34832
Disk I/O:      55852K Read            25532K Written
No Network I/O detected for this process

#Threads:   6     Workqueues:3 threads (3 running, 0 blocked) State: 0
Thread Info:

(0)                    0x75d0c88f 0000000100180000-0000000100380000 [   2M]r-x/r-x COW /Applications/MobileSafari.app/MobileSafari
(0)                    0x75d0c88f 0000000100380000-0000000100394000 [  80K]r--/rw- PRV /Applications/MobileSafari.app/MobileSafari
.
.
Shared PMAP            0x00000000 0000000270000000-0000000280000000 [ 256M]r--/r-- NUL

Process Hierarchy:
 99988 MobileSafari  has no children

46 File descriptors: MobileSafari     99988 FD  0r  /dev/null @0x0
MobileSafari     99988 FD  1u  /dev/null @0x0
MobileSafari     99988 FD  2u  /dev/null @0x317
MobileSafari     99988 FD  3u  /private/var/mobile/Library/Safari/Bookmarks.db @0x0
.
.
MobileSafari     99988 FD 29u  /private/var/mobile/Library/Safari/History.db @0x0
MobileSafari     99988 FD 30u  /private/var/mobile/Library/Safari/History.db-wal @0x0
MobileSafari     99988 FD 31u  /private/var/mobile/Library/Safari/History.db-shm @0x0
.
.
MobileSafari     99988 FD 45u  /private/var/mobile/Library/Safari/Bookmarks.db @0x0
Jetsam Level: 0
Thread policy version
        PID : 99988 (399071), comm: MobileSafari Flags: PID Suspended, Frozen, DarwinBG, Live Donor, WQ Flags avail
        Size: 18M Max Res: 75M
        IOStats: Disk Reads: 1688 reads (57192448 bytes), 54 writes (26144768 bytes)

                TID: 3721957 State: Waiting  PRI: 4/4 Flags: DarwinBG, Suspended 
                Continuation: 0xfffffff007118af8 (no kernel stack)
                CPU Times: User: 0.612410 secs, System: 0.000000 secs
                Backtrace:
                Frame 0: 0x1b08b3198
                Frame 1: 0x1b08b260c
                Frame 2: 0x1b0a5d468
                Frame 3: 0x1b0a5849c
                Frame 4: 0x1b0a57ce8
                Frame 5: 0x1baba238c
                Frame 6: 0x1b4b86444
                Frame 7: 0x100186770
                Frame 8: 0x1b08df8f0
                Frame 9: 0x0

                IOStats: Disk Reads: 592 reads (19787776 bytes), 2 writes (8192 bytes)
.
.
MobileSafari:99988:0x103        task, kernel 0x79c64c07
MobileSafari:99988:0x203
MobileSafari:99988:0x303        (thread) 0x79d853e7
MobileSafari:99988:0x403
MobileSafari:99988:0x507
MobileSafari:99988:0x603
MobileSafari:99988:0x707        (HSP: Coalition)->launchd:1:0x1103
MobileSafari:99988:0x803        (clock) 0x72b03a4f
MobileSafari:99988:0x903        (semaphore) 0x7a8ec76f
MobileSafari:99988:0xa03
MobileSafari:99988:0xb03        (voucher) 0x73ec9147
MobileSafari:99988:0xc03
MobileSafari:99988:0xd07        <-notifyd:58084:0xcf0b
MobileSafari:99988:0xe03        <-logd:58032:0x2bb0b
MobileSafari:99988:0xf03        ->logd:58032:0x52713
MobileSafari:99988:0x1003       <-cfprefsd:58085:0x27773
MobileSafari:99988:0x1103       ->logd:58032:0x1b803
.
.
MobileSafari:99988:0x15123      ->ContextService:58199:0x2f13
MobileSafari:99988:0x15217      "com.apple.cloudd"      ->cloudd:58141:0x2603
MobileSafari:99988:0x1530f
```

### History Exploit

There is a vulnerability which can be exploited from the output of the process explorer.  We notice that the `MobileSafari` app uses predictable paths for sensitive resources, such as the browsing history.

From
```
MobileSafari     99988 FD 29u  /private/var/mobile/Library/Safari/History.db @0x0
```

we see it opens the file (with a predictable path)
```
/private/var/mobile/Library/Safari/History.db
```

In an exploit documented at [https://blog.redteam.pl/2020/08/stealing-local-files-using-safari-web.html](./Bibliography#MSSV) by Pawel Wylecial, it was demonstrated that when performing a Share the Share URL is not constrained to the web page resources.  Private resources via the `file://` schema are supported but this means a malicious share URL can leak sensitive information.

To demonstrate the vulnerability with a free standing app, see `examples/history` from the [The Road to Zero GitHub](./Bibliography.md#TRTZ) website.  This app merely loads a malicious web page, which has a link to file:///private/var/mobile/Library/Safari/History.db, and upon loading, will also automatically click the share button, so all the user has to do is to pick the sharing target, such as Messages.

Once shared, the recipient and view the website browsing history of the victim using a simple SQL Lite command.  We see output similar to the below:

```
# sqlite3 ~/Downloads/History.db
SQLite version 3.36.0 2021-06-18 18:58:49
Enter ".help" for usage hints.
sqlite> .dump
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE history_items (id INTEGER PRIMARY KEY AUTOINCREMENT,url TEXT NOT NULL UNIQUE,domain_expansion TEXT NULL,visit_count INTEGER NOT NULL,daily_visit_counts BLOB NOT NULL,weekly_visit_counts BLOB NULL,autocomplete_triggers BLOB NULL,should_recompute_derived_visit_counts INTEGER NOT NULL,visit_count_score INTEGER NOT NULL);
INSERT INTO history_items VALUES(1206,'https://www.theiphonewiki.com/w/index.php?search=Cydia%20Impactor&title=Special%3ASearch','theiphonewiki',1,X'14000000',NULL,NULL,0,20);
INSERT INTO history_items VALUES(1207,'https://onedrive.live.com/?cid=STUFFYOUSHOULDNOTSEE&authkey=SOMETHINGELSESENSITIVE','onedrive.live',1,X'14000000',NULL,NULL,0,20);
INSERT INTO history_items VALUES(1209,'http://www.cydiaimpactor.com/','cydiaimpactor',3,X'34000000',NULL,NULL,0,52);
.
.
```
## Documenting the Journey

We have just scratched the surface of `MobileSafari`.  
In a way we have half-cheated.  We did not find a zero day from our own efforts but we did find interesting information.  When correlated to an actual exploit we can see what we have done would have taken us a step closer to the exploit.
The item we found was that the `MobileSafari` had opened a sensitive file path which we discovered.  A separate vulnerability is that it allowed sharing of items with the `file://` URL schema; it is not something we figured out.  But if we had, then we would have had a reasonable stab at a hack because we would know what URL path to supply to the `file://` URL.

When we explore a system, it is worthwhile documenting our journey as we go.  We have seen that merely by running commands in a fashion that send back the output to our Mac allows us to retain a record of what we found.  It is not much effort to wrap such analysis into a Markdown file with simple notes, and links to web resources.  These files naturally can be placed under version control.

Hacking is all about the details.  Sometimes our experiments are fruitless.  But if we have a good record of what we have done, then at a later point in time when we get another idea, we can work back through our notes and possible recommence a failed approach but with a new angle of attack.

When we are successful in creating a zero-day, often there is a write-up done after the event (for example when the bug has been fixed and customers have updated to using the fix).  Documenting the journey means we will have a valuable resource for writing a blog post, for example.
