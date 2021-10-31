## Booting and exploring a Development Kernel

This section is a practical tutorial on how to setup a system for interactive kernel level debugging.

At a high level, this is our workflow:

![](KernelDebugSetup.pdf)

### Data Safety

Experimenting with kernels can be like playing with fire.  The target machine must be throwaway; it might end up no longer booting, or be stuck in a boot loop.  The data on its disk might get corrupted or lost.  It is important to set up a discipline of keeping our work machine separate from our lab machine.  Furthermore, it is good to have different login identities and credentials between these two environments.  For example we wouldn't want a quirk in a beta environment causing corruption to an iCloud\index{trademark!iCloud} resource we rely upon in our work environment.

Unfortunately good "data hygiene" is mostly learnt after a painful data loss.  To avoid this, it is best to have in place a good backup strategy before experimenting with lab environments, and potential unsafe configurations and software.  One such strategy is to have all our code in a cloud service provider, such as GitHub\index{trademark!GitHub}, have our documents and photos mirrored to iCloud\index{trademark!iCloud}, have our desktop systems backed-up to Time Machine\index{trademark!Time Machine} and the high value personal documents, license keys, etc. kept also on Write-Only DVD media.

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
Filesystem     512-blocks     Used Available Capacity iused     
 ifree %iused  Mounted on
/dev/disk1s5s1 1953595632 59785248 469854808    12%  555854
 9767422306    0%   /
```

This shows that in our case, we have APFS Container 1, Volume 5, Snapshot 1 representing the hard disk for the root file system.  So our disk (ignoring the snapshot) is `disk1s5`.

### Network information

We shall be connecting to the target via the Thunderbolt Gigabit Ethernet, so we need to know the Ethernet port name used for it.  First we connect our adapters to the machine, and then assuming there is only one Gigabit Ethernet port, we run the command:

```
target-mbp2018 # ifconfig | grep -B6 1000baseT
en9: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu
 1500
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 28:ec:95:03:b3:a6 
	inet6 fe80::18f5:dff5:a92b:d3ff%en9 prefixlen 64 secured
 scopeid 0x14 
	inet 169.254.203.131 netmask 0xffff0000 broadcast
 169.254.255.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect (1000baseT
 <full-duplex,flow-control,energy-efficient-ethernet>)
```

So our network interface is `en9` and our target machine appears on that interface as IP address `169.254.203.131`.

### Kernel Debug Flags

When we setup our target for debugging, to head off potential boot-time issues, we need to establish what custom boot flags we shall use for booting and debugging.  Technically speaking, these settings are tied to the particular kernel version we are debugging.  The settings, however, change only occasionally.

Kernel information is available from the Open Source archives published by Apple. (@appleopensource)  We find that the release of such sources is delayed after the release of a given version of macOS.  iOS kernel source is not published.  However, it is macOS that is the most instructive because all the platforms are based on the same XNU kernel with just compile flag and device support differences.  The convergence of the platforms at a low level allows the macOS platform to give good insights into all Apple platforms.  We note, however, that the user experience is differentiated between the Apple platforms since the user needs to consume and experience the platform differently based upon the form factor of the system.  These differences are mainly manifest in the library software layers on top of the XNU kernel.

At the time of writing, the latest Apple Open Source release for macOS is 11.2 despite our target machine being 20E5186d.  So we download its corresponding XNU kernel, `xnu-7195.81.3`.

The file `osfmk/kern/debug.h` describes the boot parameters that are available.

```
/* Debug boot-args */
#define DB_HALT         0x1
//#define DB_PRT          0x2 -- obsolete
#define DB_NMI          0x4
#define DB_KPRT         0x8
#define DB_KDB          0x10
#define DB_ARP          0x40
#define DB_KDP_BP_DIS   0x80
//#define DB_LOG_PI_SCRN  0x100 -- obsolete
#define DB_KDP_GETC_ENA 0x200

#define DB_KERN_DUMP_ON_PANIC           0x400 /* Trigger core
 dump on panic*/
#define DB_KERN_DUMP_ON_NMI             0x800 /* Trigger core
 dump on NMI */
#define DB_DBG_POST_CORE                0x1000 /*Wait in debugger
 after NMI core */
#define DB_PANICLOG_DUMP                0x2000 /* Send paniclog
 on panic,not core*/
#define DB_REBOOT_POST_CORE             0x4000 /* Attempt to
 reboot after
	                                        * post-panic
 crashdump/paniclog
	                                        * dump.
	                                        */
#define DB_NMI_BTN_ENA          0x8000  /* Enable button to
 directly trigger NMI */
/* 0x10000 was DB_PRT_KDEBUG (kprintf kdebug events), feature
 removed */
#define DB_DISABLE_LOCAL_CORE   0x20000 /* ignore local kernel
 core dump support */
#define DB_DISABLE_GZIP_CORE    0x40000 /* don't gzip kernel core
 dumps */
#define DB_DISABLE_CROSS_PANIC  0x80000 /* x86 only - don't
 trigger cross panics. Only
	                                 * necessary to enable
 x86 kernel debugging on
	                                 * configs with a
 dev-fused co-processor running
	                                 * release bridgeOS.
	                                 */
#define DB_REBOOT_ALWAYS        0x100000 /* Don't wait for
 debugger connection */
#define DB_DISABLE_STACKSHOT_TO_DISK 0x200000 /* Disable writing
 stackshot to local disk */
```

We require:

- `DB_NMI`: we want to enter the debugger upon a Non-Maskable Interrupt
- `DB_ARP`: we want the debugger communication to be over Address Resolution Protocol (in fact UDP packets)
- `DB_NMI_BTN_ENA`: we want the power button being tapped to generate a Non-Maskable Interrupt

Hence we shall plan on supplying the debug boot argument `debug=0x8044`

### Assumed Configuration

For ease of explanation, we setup the following environmental variables matching our lab setup:

```
TARGET=target-mbp2018
DISK=disk1s5
KERNEL=20E5186d
KDK=KDK_11.3_20E5186d.kdk
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

### Configuring the Development Kernel

Having rebooted our target machine, with the lowered security, we can adjust our machine to use the Development Kernel.  This makes use of a kernel debugger easier since we have the kernel symbols for it that our debugger can use.

#### Mount Read Write the Root File System

```
export TARGET=target-mbp2018 DISK=disk1s5 KERNEL=20E5186d
 NETWORK_INTERFACE=en9 KDK=KDK_11.3_20E5186d.kdk
mkdir /tmp/mnt
sudo mount -o nobrowse -t apfs /dev/$DISK /tmp/mnt
```

We should now have the root disk mounted Read Only and mounted Read Write
```
target-mbp2018 # mount
/dev/disk1s5s1 on / (apfs, sealed, local, read-only, journaled)
.
.
/dev/disk1s5 on /private/tmp/mnt (apfs, sealed, local, journaled,
 nobrowse)
```

#### Install the Development Kernel

We place the development kernel on our system with:

```
sudo cp
 /Library/Developer/KDKs/$KDK/System/Library/Kernels/kernel.devel
opment /tmp/mnt/System/Library/Kernels
```

#### Bless the Root File System

We make our modified root file system bootable by the system by using the `bless` command.

```
sudo bless --folder /tmp/mnt/System/Library/CoreServices
 --bootefi --create-snapshot
```

#### Set boot parameters

We need to set the boot parameters to use the development kernel.  We also need to make it:

1.  Use the thunderbolt ethernet adapter (`kdp_match_name=en9`),
1.  Not go to sleep when debugging (`wdt=-1`),
1.  Verbose boot for debugging (`-v`)
1.  Use Power Key for entering the debugger over UDP packets (`debug=0x8044`),

In our lab configuration, this is done with:

```
export NETWORK_INTERFACE=en9
sudo nvram boot-args="debug=0x8044
 kdp_match_name=$NETWORK_INTERFACE wdt=-1 -v"
```

#### Target machine reboot

Now we have everything in place. The target machine can be rebooted.  If we watch it reboot closely, we can see that as it reboots, a lot of debug information will be printed onto the screen as part of the reboot.

### Host machine configuration

At this point we have a host machine with Xcode, and the KDK installed on it.  Only one further change is needed.

The KDK comes with helper scripts to aid kernel debugging.  These are tied to the Python 2 runtime environment, but Xcode LLDB Debugger uses Python 3 as the default.  We need to switch to Python 2 as follows:

```
defaults write com.apple.dt.lldb DefaultPythonVersion 2
```

### Interactive debugging

The host machine should be connected to the target machine.  It should have the KDK installed on it.  The Apple Spotlight feature will index it, and thus will be aware of the KDK symbols without it being explicitly told about them.

On the target machine, we need to get the most recent IP address it has allocated for the Gigabit Ethernet interface `en9` (`$NETWORK_INTERFACE`).

```
target-mbp2018 # ifconfig en9
en9: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu
 1500
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 28:ec:95:03:b3:a6 
	inet6 fe80::14c8:8222:3ad9:82af%en9 prefixlen 64 secured
 scopeid 0x8 
	inet 169.254.136.48 netmask 0xffff0000 broadcast
 169.254.255.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect (1000baseT
 <full-duplex,flow-control,energy-efficient-ethernet>)
	status: active
```

Here we have IP Address `169.254.136.48`.

We now press the Power button on the target.  It must be a normal press, not a tap, nor a long press.  This will trigger the Non-Maskable Interrupt and freeze the machine, and it will then hunt for a kernel debugger connection.

On the host machine, we run the following commands:

```
lldb
kdp-remote 169.254.136.48
```

At this point we will get a large information dump from the target machine, detailing the kernel extensions currently running:

```
Version: Darwin Kernel Version 20.4.0: Wed Feb 10 23:06:18 PST
 2021; root:xnu-7195.100.326.0.1~76/RELEASE_X86_64;
 UUID=04A94133-D929-3B0C-AF3D-907AF8BF4102;
 stext=0xffffff8010010000
Kernel UUID: 04A94133-D929-3B0C-AF3D-907AF8BF4102
Load Address: 0xffffff8010010000
Kernel slid 0xfe10000 in memory.
Loaded kernel file
 /System/Volumes/Data/Library/Developer/KDKs/KDK_11.3_20E5186d.kd
k/System/Library/Kernels/kernel
warning: 'kernel' contains a debug script. To run this script in
 this debug session:

    command script import
 "/System/Volumes/Data/Library/Developer/KDKs/KDK_11.3_20E5186d.k
dk/System/Library/Kernels/kernel.dSYM/Contents/Resources/Python/k
ernel.py"

To run all discovered debug scripts in this session:

    settings set target.load-script-from-symbol-file true

Loading 176 kext modules
 -----.-------.------....-------------.-----.--------------------
-----.-----.-----------------------------------warning:
 'IOGraphicsFamily' contains a debug script. To run this script
 in this debug session:

    command script import
 "/Library/Developer/KDKs/KDK_11.3_20E5186d.kdk/System/Library/Ex
tensions/IOGraphicsFamily.kext.dSYM/Contents/Resources/Python/IOG
raphicsFamily.py"

To run all discovered debug scripts in this session:

    settings set target.load-script-from-symbol-file true

.----.-------------..-------------.------------------------------
warning: 'IOGraphicsFamily' contains a debug script. To run this
 script in this debug session:

    command script import
 "/Library/Developer/KDKs/KDK_11.3_20E5186d.kdk/System/Library/Ex
tensions/IOGraphicsFamily.kext.dSYM/Contents/Resources/Python/IOG
raphicsFamily.py"

To run all discovered debug scripts in this session:

    settings set target.load-script-from-symbol-file true

 done.
Failed to load 161 of 176 kexts:
 com.apple.AGDCPluginDisplayMetrics                         
 1B6E3133-91F9-3C8D-91E0-80843926DDE2
 com.apple.AppleFSCompression.AppleFSCompressionTypeDataless
 94BB56D9-8BF2-3088-8B4F-5B57DA797346
.
.
.
 com.apple.security.AppleImage4                             
 2682857E-9FA5-3B36-A12C-104225C5EC80
 com.apple.security.quarantine                              
 FAADAF70-7DDD-38AC-962B-64776C8FA3CD
 com.apple.security.sandbox                                 
 1947D7D5-5A3E-3F7D-83C1-641F2BB56D94
 com.apple.vecLib.kext                                      
 DE60F885-126D-3319-9683-CB4F0B8288A8
kernel was compiled with optimization - stepping may behave
 oddly; variables may not be available.
Process 1 stopped
* thread #1, stop reason = signal SIGSTOP
    frame #0: 0xffffff801008b363
 kernel`DebuggerWithContext(reason=<unavailable>,
 ctx=<unavailable>, message=<unavailable>,
 debugger_options_mask=0) at debug.c:0 [opt]
Target 0: (kernel) stopped.
```

As instructed, we should run the debug scripts:
```
settings set target.load-script-from-symbol-file true
```

So long as we have already set the Python version to 2 (earlier) we should see the scripts run successfully:
```
Loading kernel debugging from
 /System/Volumes/Data/Library/Developer/KDKs/KDK_11.3_20E5186d.kd
k/System/Library/Kernels/kernel.dSYM/Contents/Resources/Python/ke
rnel.py
LLDB version lldb-1200.0.44.2
Apple Swift version 5.3.2 (swiftlang-1200.0.45
 clang-1200.0.32.28)
settings set target.process.python-os-plugin-path
 "/System/Volumes/Data/Library/Developer/KDKs/KDK_11.3_20E5186d.k
dk/System/Library/Kernels/kernel.dSYM/Contents/Resources/Python/l
ldbmacros/core/operating_system.py"
Target arch: x86_64
Instantiating threads completely from saved state in memory.
settings set target.trap-handler-names hndl_allintrs
 hndl_alltraps trap_from_kernel hndl_double_fault
 hndl_machine_check _fleh_prefabt _ExceptionVectorsBase
 _ExceptionVectorsTable _fleh_undef _fleh_dataabt _fleh_irq
 _fleh_decirq _fleh_fiq_generic _fleh_dec
command script import
 "/System/Volumes/Data/Library/Developer/KDKs/KDK_11.3_20E5186d.k
dk/System/Library/Kernels/kernel.dSYM/Contents/Resources/Python/l
ldbmacros/xnu.py"
xnu debug macros loaded successfully. Run showlldbtypesummaries
 to enable type summaries.
settings set target.process.optimization-warnings false
```

#### Simple register writing test

To prove to ourselves we have a live debuggable kernel we can run the following commands from llvm on the host.

First we get the backtrace from where we've interrupted the Operating System:
```
(lldb) bt
* thread #2, name = '0xffffff86a4828898', queue = '0x0', stop
 reason = signal SIGSTOP
  * frame #0: 0xffffff801008b363
 kernel`DebuggerWithContext(reason=<unavailable>,
 ctx=<unavailable>, message=<unavailable>,
 debugger_options_mask=0) at debug.c:0 [opt]
    frame #1: 0xffffff80111a68da
    frame #2: 0xffffff80107eeba1
 kernel`IOFilterInterruptEventSource::normalInterruptOccurred(thi
s=0xffffff93712ca880, (null)=<unavailable>, (null)=<unavailable>,
 (null)=<unavailable>) at IOFilterInterruptEventSource.cpp:236:15
 [opt]
    frame #3: 0xffffff8011130c51
    frame #4: 0xffffff80111505a7
    frame #5: 0xffffff801115496d
    frame #6: 0xffffff8010815feb
 kernel`IOSharedInterruptController::handleInterrupt(this=0xfffff
f937101f000, (null)=<unavailable>, nub=0xffffff937113ad80,
 (null)=<unavailable>) at IOInterruptController.cpp:830:5 [opt]
    frame #7: 0xffffff80111bfa77
    frame #8: 0xffffff8011126354
    frame #9: 0xffffff801112f2fd
    frame #10: 0xffffff80101c0ced kernel`interrupt [inlined]
 get_preemption_level at cpu_data.h:430:21 [opt]
    frame #11: 0xffffff801002fbdd kernel`hndl_allintrs + 285
    frame #12: 0xffffff80101c39ba kernel`machine_idle at
 pmCPU.c:235:1 [opt]
    frame #13: 0xffffff80100b32c9
 kernel`processor_idle(thread=0x0000000000000000,
 processor=0xffffff8010ea9a40) at sched_prim.c:5346:3 [opt]
    frame #14: 0xffffff80100b3498
 kernel`idle_thread(parameter=<unavailable>,
 result=<unavailable>) at sched_prim.c:5436:24 [opt]
    frame #15: 0xffffff801002f13e kernel`call_continuation + 46
```

Next we read the current registers:
```
(lldb) register read --all
General Purpose Registers:
       rax = 0x0000000000000000
       rbx = 0x0000000000000000
       rcx = 0x0000000000000000
       rdx = 0xffffff80111a6fb5
       rdi = 0x0000000000000000
       rsi = 0x0000000000000001
       rbp = 0xffffffa062996de0
       rsp = 0xffffffa062996db0
        r8 = 0x0000000000000000
        r9 = 0x0000000000000066
       r10 = 0xffffff8011196720
       r11 = 0xffffff8011196728
       r12 = 0x0000000000000046
       r13 = 0xffffff8010ea9a00  
       r14 = 0x0000000000000000
       r15 = 0x0000000000000001
       rip = 0xffffff801008b363  kernel`DebuggerWithContext + 275
 at debug.c
    rflags = 0x0000000000000046
        cs = 0x0000000000000008
        fs = 0x00000000ffff0000
        gs = 0x0000000062990000

Floating Point Registers:
       fcw = 0x0000
       fsw = 0x0000
.
.
.
```

Next we write AAA.. into a register:
```
(lldb) register write R8 0x4141414141414141
(lldb) register read --all
General Purpose Registers:
       rax = 0x0000000000000000
       rbx = 0x0000000000000000
       rcx = 0x0000000000000000
       rdx = 0xffffff80111a6fb5
       rdi = 0x0000000000000000
       rsi = 0x0000000000000001
       rbp = 0xffffffa062996de0
       rsp = 0xffffffa062996db0
        r8 = 0x4141414141414141
        r9 = 0x0000000000000066
.
.
```

Next we store the original values in the R8 register:
```
(lldb) register write R8 0x0
```
