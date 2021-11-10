# Leveraging Research

## Security Bulletins

One strategy for learning and exploration is to stick on an old version of iOS for which we have a Jailbreak.  Then look at each security bulletin from Apple to see what vulnerabilities have been fixed.  Using the CVE number, it is easy to google for write-ups for these.  For example, search for "CVE-2020–9934 poc" meaning "proof of concept for CVE-2020-9934".  We should note, however, that only a minority of CVEs have an associated write-up.

A list of security bulletins can be reached from [iOS Version History](https://en.wikipedia.org/wiki/IOS_version_history).  Apple documents them in links of the form [HT211288](https://support.apple.com/en-us/HT211288).  This particular example lists the vulnerability
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

Another way of looking at things is to study the CWE.  The [Common Weakness Enumeration](https://cwe.mitre.org/data/definitions/699.html) goes through the classes of security errors that our made.  In the same way that learning design patterns gives us the mental langauge to observe and identify design issues and solutions in software, the CWE helps sharpen our eye for mistakes we want to exploit.

We don't want to study a piece of code blindly and miss vulnerabilities.  It would be like propecting for gold, but not knowing what unprocessed natural gold deposits look like.
