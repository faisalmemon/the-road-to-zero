# Zero Day
\pagenumbering{arabic}

## What is a Zero Day?

A Zero Day Vulnerability is a security vulnerability which is not yet known to the vendor responsible for the platform that has the vulnerability.  Once notified, the "day" value increases each day regardless of the action the vendor does.  So a 300-Day vulnerability is one that has been reported to the vendor 300 days ago.  It might have been patched on day 30.  It might have been patched on day 90.  It might never be patched.  Even if it has been patched, a vulnerability disclosed 300 days ago is still a 300-Day vulnerability.

As soon as a piece of software (it could also be firmware, a configuration file, resource file, etc.) is written the opportunity for a vulnerability arises.  It could be that no one ever discovers the problem.  Of the set of vulnerabilities that exist, some are found by humans (or their tools).  At that point there is an asymmetry between those that know about the problem and those that do not know about the problem.  Such knowledge can be valuable.  That knowledge is sometimes traded, sold, or shared.  Other times it is kept secret.
It is only when the vendor is told about the vulnerability, that the bug is no longer a Zero Day Vulnerability.  The date of disclosure then governs the "day" of the vulnerability.

## Bug Bounty Programmes

In order to encourage disclosure of vulnerabilities, vendors sometimes have a bug bounty program.  They can reward researchers with money, or a promise to contribute to a charity, or with fame by acknowledging them as finding the vulnerability.  Since researchers sometimes hoard vulnerabilities so that can do further research unlocked by them, platform owners have responded by giving vetted researchers enhanced access.  In particular, Apple has introduced the Security Research Device programme.

## Market Dynamics

Sometimes multiple groups of engineers working separately find the same Zero Day.  Sometimes a researcher suspects a bunch of related Zero Days, but only fully documents one.  Likewise, sometimes the vendor only strictly fixes the vulnerability reported, and leaves adjacent issues as untreated.  That in turn creates a dynamic in the market where recent bug fix releases are scanned for security fixes by researchers, so that adjacent issues can be explored.

As the stock of vulnerabilities has increased over time, organisations have sought to organize and catalog such findings.  This gives insights on the kinds of things that can go wrong.  Vendors will improve their game by adding mitigations, which in turn will be researched for weaknesses.  So it is a cat-and-mouse game, getting ever more sophisticated.

If we consider "The Road to Zero" in dollar terms, where the dollar amount is the equipment cost, human time cost, etc. to achieve a 0-day, we can think of this book as a stepping stone.  Firstly there is the cost to acquiring basic skills.  Then there is the cost to acquiring similar skills but on iOS (Darwin) code bases.  This book reduces that cost.  Finally, there is the cost of finding original 0-days in iOS itself.  We effectively make that final step cheaper because our skills have improved via the earlier steps.

## Market Evolution

The market dynamics for iOS 0-day vulnerabilities has changed over time due to the changing nature of the Threat Model that Apple face, and the changing role iPhones and other devices have in our lives.  Originally the iPhone had no third party apps.  There were two main threats the system had to model.  First were the Jailbreak community who wanted to customise the iPhone experience and add their own apps.  Second were those that wanted to Carrier-unlock their phone.  The phone price would typically be subsidized by the telecommunications operator via a subscription to their network over a period of time before you were allowed to buy a subscription to another operator.  With such a threat model, a simple layer of defense was needed.  Apple introduced the iPhone App Store, together with sandboxed apps, requiring code-signing for installation for all third party apps.  In those days, a vulnerability alone was enough to defeat the security of the phone.  So finding and exploiting a 0-day was "most of the game".

Over the ensuing years, Apple would increase the depth of their defenses with new security measures, but bug hunters could keep up.  However, the nature of the market changed.  As there became more apps, and everyday work flows became connected to, and supported by, mobile phone apps, the value of the information in your phone drew the interest of government entities, criminals, and law-enforcement, as well as "friends" and family.  Now the threat model is diverse and profound.  The phone must resist attack when in physical possession of an attacker (such as a phone stolen after a crime).  It must resist attack wirelessly when in a hostile network environment, such as an international conference hosting a politicaly sensitive agenda, or an innocent trip to a coffee shop. It must resist attack from a curious partner, grandparent or child.

Since iDevices now have many layers of security, it is not one 0-day alone that unlock deeper access to the system.  There are chains of vulnerabilities that need to be exploited to fully attack the system.  Each subsystem has become a complex entity.  So the market is now one of specialization.  One person might be expert in WebKit vulnerabilities.  One person might be expert in PDF file format weaknesses.  One person might now how to construct "gadgets" to achieve a desired control flow path.  There are companies that buy up individual vulnerabilities and assemble them.  They might leverage toolkits from others for post-exploitation, etc.

No one person is an industry.  We are small players in a complex dynamic market.  So it is important to understand what our goals are, what skills we have or desire, and how we see ourselves in this bigger picture.

## Monetary Rewards

As the skill requirements have increased, together with increased specialization, the monetary cost of "doing business" has increased.  This places security researchers in a novel "taxation" dynamic [@offensiveworklovehate].  Apple will improve their security.  Offensive security companies will need more money to crack into the iDevices as their exploit chains will become longer and more esoteric.  They will need to buy in exploits, research material, and hire from a small pool of talent to do the equivalent in-house.  Such companies will demand higher fees for their tools, and their solutions will have shorter lifetimes.  Law enforcement, military and government entities will need to pay more for such tools.  The pressure release value is at the political level.  Either politicians agree to allowing strong protections in consumer devices, iPhone chiefly among them.  This means taxation on the population (or a re-allocation of funds) to pay the offensive companies more money, and more often, for valuable access to mobile phone information.  Or on the other hand, politicians can espouse back-doors into consumer devices.  This lowers the "taxation" but increases malicious activity from adversaries.

This explains our current surreal state of affairs.  A vulnerabilty can be worth millions, because it is a tax on millions on users that require confidentiality, security and privacy.

## Ethics

There are a lot of ethical consideration surrounding Zero Day Vulnerabilities (hereafter we shall say 0-day).  The consensus is that you should not openly discuss or explain vulnerabilities until the bug is 90 days since disclosure (i.e. a 90-day).  So we don't place 0-days in this text.  But we create software modules of our own, reachable from a non-compromised device.  These modules emulate closely the properties of an exposed subsystem so we can discuss, explore and compromise "our own code".  We also discuss past vulnerabilities that have been patched by Apple.

Will this book lead to a proliferation of 0-days?  My opinion is that the malicious actors already have the tools and knowledge they need.  It is the wider engineering community that need to up-skill in this area.  Most of these people will not be malicious.  They will enhance and improve the security of systems.

In truth, we often tell ourselves stories that make us comfortable with what we are doing, particularly if our pay-cheque aligns with that.  The best of intentions can result in adverse outcomes, as well as the converse.  For example, a researcher working on their PhD might see a bug class, but just have time to explore one fully, writing up a Proof of Concept (POC), which is duly responsibly disclosed, and patched, before being published as a finding by the researcher.  Another engineer might read the write-up, look at the binary diff related to the fix, notice associated vulnerabilities, and produce a variant POC and sell that to a market place for significant money.  At that point, the vulnerability could be combined with others and militarized.  The question is then who made that weapon, and would it have come to existence anyway?  Such a weapon could be used to save lives, lose lives, start conflict or avoid conflict depending on the circumstances politically.

## Aren't security bugs just bugs?

To take the opposite tack, we can ask ourselves, "Aren't security bugs just bugs?"  In other words, why dwell on 0-days as something special.  They are just bugs that can turn out to affect users when exploitable.  But lots of things can affect users.

To move forwards with the debate we need to be honest with ourselves.  We need to understand our own perspective and agenda.  If your goal is to learn how to find and discover 0-days, the process of discovery itself is the joy we seek.  If that bug gets an associated vulnerability number, known as a CVE number, then it is a recognition of achievement, much the same as any other professional recognition.

We do have to acknowledge the larger context.  Platform owners know that in a large system, there will be bugs, and a subset of those will affect security. The vendor will know that part of their responsibility is patching the bugs when they have been reported.  Their wider responsibility is to have processes that avoid the same issue appearing in the future, and avoid the same bug classes appearing.  They may change their audit procedure, hire staff to search for bugs, provide training on secure programming practices, perform threat modelling sessions, etc.  One fruitful area is applying mitigation layers.  The platform may have checks against stack overflows, or malicious changes to control flow integrity, etc.  These will be discussed later.  In practice, these are powerful weapons.

The ultimate perspective is that of an end-user.  Users want to go about their business with the minimal amount of cost, and inconvenience, whilst having a rich and enjoyable user experience.  A secure system which is so cumbersome that there are few users does little to help society.

Users need psychological safety, and trust in their systems.  A small drop of poison in a large reservoir wouldn't kill a person, but who would drink water from that reservoir?  Security delivers safety and trust.

So security bugs are important, but not special.  They are important because over time platform vendors will develop mitigation layers to sweep away the exploitability of 0-days.  And the platform vendors that do this in a way that minimises the cost and inconvenience to users will win over the greater number of users.  This means that end users will live in a digital world that provides security and trust.  And trust is essential to our modern day living.  

When we use public transit systems, we trust the safety of the transport system.  When we stop by a coffee shop and order a drink, we assume the water in the drink is safe.  Wealth is created by a division of labor with individuals doing specialist roles.  Such a society can only function when those services are trustworthy.  Computing services, such as mobile phone systems and apps are a key service that technologists contribute to the wider society.

Going back to the example of public transit.  When sitting on a train, we can often see a couple of people drinking coffee.  But we can see plausibly a majority looking at their mobile phone screens.  We need the train to be safe, the coffee to be safe, and the mobile computing experience to be safe!

## Burn Out

We haven't even started yet, and so why are we bringing up the topic of burn out?

When you start training your mind to think like a machine thinks, or start working through the details of a subsystem in great deal, it can be both engaging and exhausting. After a period of youthful exuberance can be a down hill descent of despair when you can nearly solve something, but cannot quite get it done.

As ever, there is a way to hack around such problems!  

### Looking after the body

First, the boring stuff.  Solid, regular and good-quality sleep.  Three good meals a day.  30 minutes exercise a day - a good walk for example.  These are the basics for maintaining your health.  At least for now, humans are not machines, and humans need this basic level of care.

### Optimizing the mind

Second, the mind hack.  That first hour of the day, maybe the first half hour is the golden time.  Save the heaviest and most difficult mental task to only that dream slot.  Leave the manual, boring and tedious investigation work to the end of your work day.  Everything else sits in-between those two things.

### Smoothing the ups and downs

Third, the multi-tasking hack.  If security research is the only thing you are doing, then yes you have focus but you are going to have ups and downs.  The way around that is to have two activities that vary in importance over a period of months but are a constant presence.  One good parallel activity is software engineering.  You could be writing a security tool, for example, or something unrelated.  Software engineering is in some ways the opposite of vulnerability research.  It is building abstractions, adding layers, and working in a problem domain instead of the machine domain.  It feels very constructive and creative.  Sometimes you make great progress on your software, and other times you make progress on your vulnerability research.  Since time away from one task does not stop your mind from advancing it in your mind in the background, the net effect is that when you're done with vulnerability research, the software engineering seems to go great due to pent up ideas you've been working on in the background.  The converse applies also, so that after a period of development on your software project, new ideas appear to help advance your security research.

### Using version control to contain complexity

The fourth hack is facilitated by the git version control system.  Everything you do must be recorded and tracked with git (or another version control system).  Because with git, you can make small incremental improvements (git commits), and then build on those.  This provides head space you need to achieve complex things.  You just keep incrementally developing your ideas, code, and experiments.  Do not try and keep complexity in your mind for a long period.  Just keep dumping them into text files, code, etc., into a git repository.  Then at the end of each day, you will feel that you made progress, even if there is no big result.  That will save your sanity.

## Resources

To complement the book, there is a website of resources which is intended to be used alongside the printed material so example projects can be setup and run by yourself and experimented with.  All references in this book are collected into the Bibliography Chapter at the end of the book.  There you will find URLs to resources, for example.

The GitHub website supporting the book is at [@trtzgithub]
