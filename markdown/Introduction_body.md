This is a book about Zero Day Vulnerabilities.

It is called "The Road to Zero" because it is primarily a tutorial guide to take you along the path needed to find your own vulnerabilities.

The focus of our book is iOS.  In fact, when we talk about iOS we often mean the family of Operating Systems from Apple that are based around the same underpinnings.  It would be more accurate to say this book focusses on Darwin, the common UNIX technology stack from which macOS, iOS, tvOS, watchOS are derived.

Likewise when we refer to a device, we say iDevice because there are lots of different Apple produced products in different device classes, such as various models of iPhone, or iPad.

A Zero Day Vulnerability is a security vulnerability which is not yet known to the vendor responsible for the platform that has the vulnerability.  Once notified, the "day" value increases each day regardless of the action the vendor does.  So a 300-Day vulnerability is one that has been reported to the vendor 300 days ago.  It might have been patched on day 30.  It might have been patched on day 90.  It might never be patched.  Even if it has been patched, a vulnerability disclosed 300 days ago is still a 300-Day vulnerability.

As soon as a piece of software (it could also be firmware, a configuration file, resource file, etc.) is written the opportunity for a vulnerability arises.  It could be that no one ever discovers the problem.  Of the set of vulnerabilities that exist, some are found by humans (or their tools).  At that point there is an asymmetry between those that know about the problem and those that do not know about the problem.  Such knowledge can be valuable.  That knowledge is sometimes traded, sold, or shared.  Other times it is kept secret.
It is only when the vendor is told about the vulnerability, that the bug is no longer a Zero Day Vulnerability.  The date of disclosure then governs the "day" of the vulnerability.

In order to encourage disclosure of vulnerabilities, vendors sometimes have a bug bounty program.  They can reward researchers with money, or a promise to contribute to a charity, or with fame by acknowledging them as finding the vulnerability.  Since researchers sometimes hoard vulnerabilities so that can do further research unlocked by them, platform owners have responded by giving vetted researchers enhanced access.  In particular, Apple has introduced the Security Research Device programme.

Sometimes multiple groups of engineers working separately find the same Zero Day.  Sometimes a researcher suspects a bunch of related Zero Days, but only fully documents one.  Likewise, sometimes the vendor only strictly fixes the vulnerability reported, and leaves adjacent issues as untreated.  That in turn creates a dynamic in the market where recent bug fix releases are scanned for security fixes by researchers, so that adjacent issues can be explored.

As the stock of vulnerabilities has increased over time, organisations have sought to organize and catalog such findings.  This gives insights on the kinds of things that can go wrong.  Vendors will improve their game by adding mitigations, which in turn will be researched for weaknesses.  So it is a cat-and-mouse game, getting ever more sophisticated.

There are a lot of ethical consideration surrounding Zero Day Vulnerabilities (hereafter we shall say 0-day).  The consensus is that you should not openly discuss or explain vulnerabilities until the bug is 90 days since disclosure (i.e. a 90-day).  So we don't place 0-days in this text.  But we create software modules of our own, reachable from a non-compromised device.  These modules emulate closely the properties of an exposed subsystem so we can discuss, explore and compromise "our own code".  We also discuss past vulnerabilities that have been patched by Apple.

If we consider "The Road to Zero" in dollar terms, where the dollar amount is the equipment cost, human time cost, etc. to achieve a 0-day, we can think of this book as a stepping stone.  Firstly there is the cost to acquiring basic skills.  Then there is the cost to acquiring similar skills but on iOS (Darwin) code bases.  This book reduces that cost.  Finally, there is the cost of finding original 0-days in iOS itself.  We effectively make that final step cheaper because our skills have improved via the earlier steps.

Will this book lead to a proliferation of 0-days?  My opinion is that the malicious actors already have the tools and knowledge they need.  It is the wider engineering community that need to up-skill in this area.  Most of these people will not be malicious.  They will enhance and improve the security of systems.

To complement the book, there is a website of resources which is intended to be used alongside the printed material so example projects can be setup and run by yourself and experimented with.  All references in this book are collected into the Bibliography Chapter at the end of the book.  There you will find URLs to resources, for example.

The GitHub website supporting the book is at @trtzgithub
