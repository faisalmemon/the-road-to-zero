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
# searchsploit -m 45649
  Exploit: Apple iOS - Kernel Stack Memory Disclosure due to
 Failure to Check copyin Return Value
      URL: https://www.exploit-db.com/exploits/45649
     Path:
 /Users/faisalm/dev/exploitdb/exploits/ios/dos/45649.txt
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

## `copyin_leak` write-up

Here is the verbatim text for the write-up of this leak.  The purpose for including it is to show the "level" at which exploit research is aimed at.  The main aim of this book is to bring ourselves up to the same level so we can appreciate this piece of research, and then move forwards onto exploring and finding our own vulnerabilities.

> Here's a code snippet from sleh.c with the second level exception handler for undefined instruction exceptions:

```
 static void
 handle_uncategorized(arm_saved_state_t *state, boolean_t
 instrLen2)
 {
   exception_type_t       exception = EXC_BAD_INSTRUCTION;
   mach_exception_data_type_t   codes[2] = {EXC_ARM_UNDEFINED};
   mach_msg_type_number_t     numcodes = 2;
   uint32_t          instr;   <------ (a)

   if (instrLen2) {
     uint16_t  instr16;
     COPYIN(get_saved_state_pc(state), (char *)&instr16,
 sizeof(instr16));

     instr = instr16;
   } else {
     COPYIN(get_saved_state_pc(state), (char *)&instr,
 sizeof(instr));  <------- (b)
   }

 ....

  else {
   codes[1] = instr;   <------ (c)
  }
 }

 exception_triage(exception, codes, numcodes);  <-------- (d)
 ```

 > At (a) the uint32_t instr is declared uninitialized on the
 stack.
 At (b) the code tries to copyin the bytes of the
 exception-causing instruction from userspace
   note that the COPYIN macro doesn't itself check the return
 value of copyin, it just calls it.
 At (c) instr is assigned to codes[1], which at (d) is passed to
 exception_triage.

 > that codes array will eventually end up being sent in an
 exception mach message.

 > The bug is that we can force copyin to fail by unmapping the
 page containing the undefined instruction
 while it's being handled. (I tried to do this with XO memory but
 the kernel seems to be able to copyin that just fine.)

 > This PoC has an undefined instruction (0xdeadbeef) on its own
 page and spins up a thread to keep
 switching the protection of that page between VM_PROT_NONE and
 VM_PROT_READ|VM_PROT_EXECUTE.

 > We then keep spinning up threads which try to execute that
 undefined instruction.

 > If the race windows align the thread executes the undefined
 instruction but when the sleh code tries to copyin
 the page is unmapped, the copying fails and the exception
 message we get has stale stack memory.

 > This PoC just demonstrates that you do get values which aren't
 0xdeadbeef in there for the EXC_ARM_UNDEFINED type.
 You'd have to do a bit more fiddling to work out how to get
 something specific there.

 > Note that there are lots of other unchecked COPYIN's in sleh.c
 (eg when userspace tries to access a system register not allowed
 for EL0) and these seem to have the same issue.

 > tested on iPod Touch 6g running 11.3.1, but looking at the
 kernelcache it seems to still be there in iOS 12.


> Proof of Concept:
https://github.com/offensive-security/exploitdb-bin-sploits/raw/m
aster/bin-sploits/45649.zip

That's the end of the write-up.  It covers a lot of ground.  In
 terms of technologies and techniques we have in the solution:

- Mach
  - Mach Messages
  - Mach Exceptions
- OS
  - userspace and kernelspace
  - copyin
  - virtual memory
  - exception handling
  - Open Source XNU kernel
- Programming
  - C and Assembly languages
  - threads
  - stacks
  - race conditions and brute forcing
  - error handling or its absence

Now we just need to make sense of it all.

## The road ahead

Having learnt where we can find Exploits, looking at our first
 exploit, and then seeing what technologies it relies upon, we
 can now chart out the road ahead.

### The knowledge we require

No one book can cover all the required topics in depth.  But with
 the appropriate hacker mindset, a small subset of a large number
 of technologies can be learnt within the confines of one book.

After practice, a hacker mentality can zoom our attention to the
 most "interesting" aspects of a given technology.  We should aim
 to have a T-shaped skill profile; shallow knowledge in many
 areas, but in-depth for certain pieces of those technologies.
 This is in contrast to a standard engineering T-shaped knowledge
 base where the in-depth knowledge is confined to one or two
 technologies.

### Engineering sensibilities

If we are a professional software engineer, and look at Proof of
 Concept exploits the code structure and organisation often
 chafes at our engineering sensibilities.  Compiler warning are
 ignored, variable names are terse or badly named.  Functions are
 badly formed, with strange names, and dispersed business logic.
 Hardcoded values are rampant.  

 But the programs do "clever"
 things and use techniques often advanced programmers are unaware
 of.  This is really a reflection of the patchwork of in-depth
 skills a hacker will acquire.  Brilliance in some aspects, and
 beginner in others.  Of course, hackers can also be skilled
 software engineers, system administrators, or have another
 profession.  Such skills can be
 complementary but are not foundational.  Hacker skills are not
 built on top of a layer of great system administration skills,
 nor software engineering skills.

### The learning pathway

There is a meta skill that underpins security research.  That is,
 reading.  

We have a goal to reach but don't know half of the
 technologies needed.  So we just do an internet search, pull
 down freely available learning material, and then skim through
 the contents.  

The canonical texts are usually the best.  In the
 first iteration it is usually a matter of downloading a manual
 of hundreds of pages.  Then pressing Page-Down repeatedly and
 skimming through.  Maybe 10 seconds per page.  We are building
 up a mental model from the lowest level detail in a particular
 topic.  At that point we have awareness of what we don't know
 but enough knowledge to know a good search query to get into
 such a topic in more depth.

### Deconstructing our world

Looking at canonical materials (that is, the text that most fully
 describes the content with a minimal amount of simplification)
 allows hackers to see systems as they really are, rather than an
 abstraction of what they are.  

Software engineering is really
 the construction of layers of abstraction to get to a point of
 understanding of the task most naturally in the problem space we
 are working with.  Researchers need to think about computers in
 the way they actually work, with all the abstractions stripped
 bare.  

 For example, when programmers see a virtual function
 in C++, they know that they need to look at what class is being
 messaged to understand what function the method will invoke.
 When hackers see a virtual function, they see that there must be
 a Virtual Function Table where the control flow is switched to
 the function that is desired.  If the strategy in the mind of
 the researcher is to re-direct program control, then inspecting
 the code for virtual functions can be a goal.

Furthermore, reading a C++ manual which tells about how late
 binding works (as explained above with Virtual Function tables)
 allows those with a hacker mentality to make a mental note of
 the implied trust relationship in that code at such points.  The
 Virtual Function Table if subverted will change the operation of
 the program.

### Learning from Exploits

Looking at existing exploits teaches what are the kinds of things
 about technologies we have that need to be learnt.  That is so
 we don't waste effort on non-critical knowledge.  Granted all
 knowledge is valuable, but time is always going to be finite.
 So a trade-off is needed between learning knowledge in case it
 might be useful versus learning only what is needed for the job
 in hand.

### The hacker mindset

Our path in learning and discovery is aided by a hacker mindset.
 This is closely connected to human psychology.  What do humans
 do, and what opportunities are indirectly afforded through such
 human nature?  There are formal ways of thinking to encourage a
 hacker mindset.  We shall explore this in later chapters.

### Research goals

Looking at security exploits, we can ask what was the
 researcher aiming for which resulted in the fruits of the
 researcher.  Research is not effective unless there is a
 strategic path that is being pursued.  We shall explore this
 aspect of security research and show how this can amplify our
 efforts.
