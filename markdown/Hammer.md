# The Hammer

When studying past exploits it can feel like your brain has been hit by a hammer.  It is because most exploit discussions work on the basis that you have had an apprenticeship on all the underlying techniques, and that only that final layer needs explanation.

This approach is understandable from the writer's perspective.  If you are a researcher you will naturally seek out underlying technologies, documentation and reading materials as part of your research journey.  The writer's audience will be such researchers.  So the writer will not dwell on the supporting techniques and technologies.

Since iOS and macOS use many niche technologies, or use standard techniques with some Apple ecosystem unique twists, it is not so easy to do your background reading.

In this chapter we shall look at an exploit write-up.  Our purpose is not to understand the exploit as such, but to survey the techniques and technologies at play.  It will provide us the motivation to explore such items in subsequent chapters knowing that this knowledge will then help us circle back and understand the originally presented exploit.

## Getting Exploits

Exploits can be downloaded from the Exploit Database (@exploitdb).
This is a valuable resource and one we shall often refer to.
The exploit database has a search tool, `searchsploit`.
If we install `searchsploit` from @exploitdb and configure our `~/.searchsploit_rc` file then we can easily look up exploits.

This is a search for items matching `ios` and `dos`:
```
searchsploit ios dos | less
------------------------------- ---------------------------------
 Exploit Title                 |  Path
------------------------------- ---------------------------------
Apple iOS - Kernel Stack Memor | ios/dos/45649.txt
Apple iOS 1.1.2 - Remote Denia | hardware/dos/4978.html
Apple iOS 1.1.4/2.0 / iPod 1.1 | hardware/dos/32341.html
Apple iOS 11.2.5 / watchOS 4.2 | multiple/dos/44215.m
Apple iOS 4.0.3 - DPAP Server  | ios/dos/5151.pl
Apple iOS 5.1.1 Safari Browser | ios/dos/18931.rb
Apple iOS < 10.3.2 - Notificat | ios/dos/42014.txt
Apple iOS Kernel - Use-After-F | ios/dos/45652.c
Apple iOS Mobile Safari - Memo | ios/dos/31057.html
Apple iOS Safari - 'decodeURI' | hardware/dos/15794.php
Apple iOS Safari - 'decodeURIC | hardware/dos/15796.php
Apple iOS Safari - 'JS .' Remo | hardware/dos/15805.php
Apple iOS Safari - Bad 'VML' R | ios/dos/11890.txt
Apple iOS Safari - body alink  | hardware/dos/15792.php
Apple iOS Safari - Remote Deni | ios/dos/11891.txt
Apple iOS/macOS - Kernel Memor | multiple/dos/45651.c
Apple iOS/macOS - Sandbox Esca | multiple/dos/45648.txt
Apple iOS/macOS - Sandbox Esca | multiple/dos/45650.txt
Apple Mac OSX - IOSCSIPeripher | osx/dos/39376.c
```

Exploits can be searched for, downloaded, and then explored.  Each exploit has a number associated with it, known as the `EDB-ID`.

## `copyin_leak` Exploit 45649

This program allows a user program to get the kernel to expose memory values it should not be able to see.  In that sense it is an information disclosure "leak".  The kernel routine used to do this is `copyin` hence it has been called a `copyin_leak`.

The following command places a local copy of the exploit write-up in our local directory, known as the mirror `(-m)` command.

```
➜  scratch searchsploit -m 45649
  Exploit: Apple iOS - Kernel Stack Memory Disclosure due to Failure to Check copyin Return Value
      URL: https://www.exploit-db.com/exploits/45649
     Path: /Users/faisalm/dev/exploitdb/exploits/ios/dos/45649.txt
File Type: ASCII text, with CRLF line terminators

Copied to: /Users/faisalm/dev/scratch/45649.txt
```

From looking at the text file, we find we can download the actual Proof of Concept (POC) from a Git Hub web address.  This provides us an app to run on simulator or on an iDevice.

This POC has been tested on
```
iPod touch (7th generation)
iOS 13.5 (17F75)
```
and
```
iPod touch (7th generation) simulator
iOS 14.4 (18D46)
```
