## Booting a Development Kernel

This section is a practical tutorial on how to setup a system for interactive kernel level debugging.

### Data Safety

Experimenting with kernels can be like playing with fire.  The target machine must be throwaway; it might end up no longer booting, or be stuck in a boot loop.  The data on its disk might get corrupted or lost.  It is important to set up a discipline of keeping our work machine separate from our lab machine.  Furthermore, it is good to have different login identities and credentials between these two environments.  For example we wouldn't want a quirk in a beta environment causing corruption to an iCloud\index{trademark!iCloud} resource we rely upon in our work environment.

Unfortunately good "data hygiene" is mostly learnt after a painful data loss.  To avoid this, it is best to have in place a good backup strategy before experimenting with lab environments, and potential unsafe configurations and software.  One such strategy is to have all our code in a cloud service provider, such as GitHub\index{trademark!GitHub}, have our documents and photos mirrored to iCloud\index{trademark!iCloud}, and the high value personal documents, license keys, etc. kept also on Write-Only DVD media.

### Terminology

Here we adopt some standard terminology to describe our test environment.

Item | Description
--- | ---
target debugee | This system is being tested and inspected
host debugger | This system is driving the probing and analysis

### Required Hardware

It is surprisingly helpful to collect a random collection of old computers, peripherals, and connectors.  Sometimes an interesting vulnerability is seen only on old hardware, or a technique is only useable on old hardware. Variety is the key so that different types of lab setups are possible.

In this tutorial we use a MacBook\index{trademark!MacBook Pro} Pro target which has native USB-C interfaces.
We connect a Thunderbolt USB-C to Thunderbolt adapter, and then connect a Thunderbolt Gigabit Ethernet Adapter to the Thunderbolt interface.  Then we connect the ethernet cable to the host computer.  The host computer is a Mac Mini based upon Apple Silicon.

This choice of hardware comes from particular requirements.

#### Direct thunderbolt communication

When a system boots up, early on in its bring-up, it has few hardcoded facilities immediately at its disposal.  The kernel will not have brought up its networking stack fully.  This means for debug communication, it can only use a few hard coded facilities.  The Kernel Development Kit from Apple documents what hardware is supported.  It basically maps to either direct on-thunderbolt ethernet adapters or FireWire based connections.

The FireWire\index{trademark!FireWire} based communication is less flexible than Ethernet and is more of a legacy interface.  So we shall ignore that option in this tutorial.

We can use either the Gigabit Ethernet adapters or the 10 Gigabit Ethernet adapters (for Mac Pro\index{trademark!Mac Pro}) from Apple.  A USB Ethernet adapter will not work because it won't be able to route the debug communication packet onto that device.

Note that most all-in-one adapters that connect to USB-C and offer a variety of ports including Ethernet will not work because the internal archictecture of these will have a USB Bus, and then there will be an affordable but lower performance Ethernet chip, such as a RealTek\index{trademark!RealTek}.  There are two problems here.  Firstly the RealTek is not a supported chip for debug communication, and secondly the kernel cannot route the debug packet from the Thunderbolt bus onto the USB bus where the Ethernet chip resides.

Notice that in our setup we first convert USB-C to Thunderbolt, and then convert Thunderbolt to Gigabit Ethernet.  One advantage of our setup is that is it more flexible.  Not all computers have native USB-C, but having two adapters means we have the flexibility to debug older computers.

#### Using a laptop target

One convenience arising from choosing a laptop as the debug target is that we can map the power key to halt the kernel and drop into the debugger.  Also since the keyboard and trackpad are integrated, it means we have direct connectivity into the system.

### Required Software

In order to do kernel debugging conveniently, we need a kernel with its debug symbols available so we can set symbolic breakpoints.  We get the kernel version from the target machine as follows:

```
target-mbp2018 # sw_vers
ProductName:	macOS
ProductVersion:	11.3
BuildVersion:	20E5186d
```

We need to get the matching Kernel Development Kit (KDK) from the Apple developer website @devapplemore
We search for it using the build version, and it either it matches exactly, such as "Kernel Debug Kit 11.3 build 20E5186d", or it is not found.  When it is not found, we are supposed to raise a developer support ticket to ask for it to be uploaded onto the Apple Website.  An easier alternative is to just update our version of macOS to a version which is also shown on the @devapplemore website.

The KDK software is needed both on the target (we shall install the development kernel on it), and on the host (we need it available so the debugger can reference it).  An exact same KDK must be used on both target and host.

### Disable File Vault

In order to manipulate the root file system when in Recovery Mode, we need to first disable File Vault.  This is normally a background task and takes a while but is immediate on our MacBook Pro because its disk is managed by a T2 chip.  (@disablefilevault)

1. Use `System Preferences > Security & Privacy > FileVault`
1. Unlock the padlock.
1. Click `Turn off FileVault`

Allow the system to process the decryption in the background.  We must keep our system connected by AC power the whole time to achieve this.

### Disk information

We shall do low level disk operations on our target machine, so first need to record the hardware device used for the root file system:

```
target-mbp2018 # df /
Filesystem     512-blocks     Used Available Capacity iused      ifree %iused  Mounted on
/dev/disk1s5s1 1953595632 59785248 469854808    12%  555854 9767422306    0%   /
```

This shows that in our case, we have APFS Container 1, Volume 5, Snapshot 1 representing the hard disk for the root file system.

### Network information

We shall be connecting to the target via the Thunderbolt Gigabit Ethernet, so we need to know the Ethernet port name used for it.  First we connect our adapters to the machine, and then assuming there is only one Gigabit Ethernet port, we run the command:

```
target-mbp2018 # ifconfig | grep -B6 1000baseT
en9: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 28:ec:95:03:b3:a6 
	inet6 fe80::18f5:dff5:a92b:d3ff%en9 prefixlen 64 secured scopeid 0x14 
	inet 169.254.203.131 netmask 0xffff0000 broadcast 169.254.255.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect (1000baseT <full-duplex,flow-control,energy-efficient-ethernet>)
```

So our network interface is `en9`.

### Assumed Configuration

For ease of explanation, we setup the following environmental variables matching our lab setup:

```
TARGET=target-mbp2018
DISK=disk1s5s1
KERNEL=20E5186d
NETWORK_INTERFACE=en9
```

### Software Installation

We need to install our software first because later steps will utilise it from Recovery Mode.

#### Host side software

The host must install Xcode, and the specific KDK determined earlier.

#### Target side software

The target must install the KDK determined earlier.

### Lowering Security

In order to debug our target we must lower the security settings.  (@installxnu) We have three tasks to do whilst booted into Recovery Mode.

#### Disable System Integrity Protection (SIP)

We need to disable System Integrity Protection (SIP) using the Configurable Security Restrictions Utility (`csrutil`).  Apple documentation @configsip tells us to:

1. Boot into recovery mode (Command+R during boot)
1. Launch a Terminal window from `Utilities > Terminal`.
1. Run `csrutil disable`
1. Quit the Terminal.

#### Set No Boot Security

We need to set boot security to No Security. (@startupsecurity)

1. Launch `Utilities > Startup Security Utility`
1. In section Secure Boot, set "No Security"
1. Quit the Utility.

#### Disable Authenticated Root Volume Security

We need to disable authenticated Root Volume Security.  (@rootvolsecurity)

1. Launch a Terminal window from `Utilities > Terminal`.
1. Run `csrutil authenticated-root disable` (Requires FileVault to be already disabled.)
1. Quit the Terminal.
1. Restart the computer.
