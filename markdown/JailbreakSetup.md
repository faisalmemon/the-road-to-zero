# Jailbreak Setup

In order to explore the iOS attack surface directly we need to explore the iOS system using diagnostic tools.  Such tooling is not available under normal circumstances.

Apple engineering will be able to diagnose and explore iOS using specially constructed iPhones, so-called "Dev Fused" hardware.  This provides full access to the iPhone.

External engineers on the Security Research Device programme (see @applesrd) will be able to access a similiar phone, called a "SRD Fused" hardware.  This provides ssh access to the iPhone.  You can choose your entitlements and therefore can run any software on the phone.

Approved organisations can get access to a virtualization as a service platform from Corellium which provides a diagnostic experience from kernel level to any iOS OS image that you upload to test. (See @corelliumvirtualdevices)

Ordinary customers use production iPhones, "Prod Fused" hardware.  These have the full set of security restrictions of an iPhone. (See @srdhowworks)

The workaround that most zero day researchers use is to take Prod Fused hardware, and keep the software an an old iOS revision, potentially also staying on old hardware.  Over time, Jailbreaks will become published that match your configuration.  Staying on old hardware also means the latest hardware protection schemes do not apply.

## Jailbreak shopping list

There are many jailbreak software programs, many hardware variants.  The steps to follow also vary with the jailbreak itself.  Rather than track these rapidly evolving factors, some broad guidance is given here.

1.  We take note of the local laws.  It seems that in USA, and most countries, jailbreaking for (@jailbreakingallowed)
1.  We need a Mac running macOS.  Other options are possible but there is a smaller user base for alternative configurations, so the out-of-the-box experience might not be as smooth.
1.  Beware of scams, as Jailbreak tools should be free in cost.  The best anchor point to reach download sites is to start from https://www.theiphonewiki.com  This is the primary resource site which encapsulates the latest knowledge of tools, phones, and techniques.
1.  We need a paid Apple developer account.  This allows us to re-sign the app install files, known as `.IPA` files.
1.  We need to enable an application specific password for our Paid Developer account.  (See @appspecificpassword)
1.  We need and old iDevice.  Perhaps a second hand one, or one that we had used in the past before upgrading, or a cosemetically damaged phone.  A good choice is an iPod Touch, 7th generation.  This is not too old, quite cheap, but has many options for jailbreaking.  Such devices will likely have a long life because they are often embedded to other hardware such as point of sale terminals.

## Example Jailbreak steps

Whilst the specific details will depend on our software and hardware versions, a typical jailbreak involves steps similar to the following:

1. Confirm our Mac is running with Xcode, and can deploy a trivial app to your phone.
1. Update the Apple ID to have a application specific password.
1. Download the Unc0ver jailbreak.
1. Download the Cydia Impactor Tool and install it.
1. Drag the Unc0ver IPA file onto Cydia Impactor.
1. Supply the Apple ID, and the application specific password.
1. Follow the On-Device prompts in the Unc0ver app, and then let it reboot.
1. Enable ssh on the iDevice and change the `root/alpine` credentials to something unique.
