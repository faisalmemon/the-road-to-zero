# iOS Defense Mechanisms

The iOS system has become more sophisticated over time as the usage pattern and commercialisation of it has evolved.  Here we survey the [history](./Bibliography.md#MT) of the defense mechanisms (mitigation techniques) that have been deployed by Apple in iOS, often supported by enhancements available in [hardware](./Bibliography.md#HW).

## History of iOS Mitigation Techniques

| iOS Version | Mechanism | Comment |
| -- | -- | -- |
| 1.x | Encrypted OS images | Everything runs as root; no code sign or sandbox |
| 2.x | Code Sign, Sandbox | The Sandbox is the most durable and important technique to date |
| 3.x | - | - |
| 4.x | ASLR/DEP (iOS 4.3) | - |
| 5.x | User mode ASLR | Harder to write shell code |
| 6.x | Kernel mode ASLR, Kernel Address Space isolation | Harder to reach kernel |

## OS Mitigation Techniques

### Code Sign mitigation technique

### Sandbox Mitigation Technique

### ASLR Mitigation Technique

### DEP Mitigation Technique

## History of Hardware Mitigation Techniques

Mitigation techniques purely in Software can have an adverse effect on performance.  When the hardware provides assistance, the software can then offer greater mitigations at no, or little, performance cost.

Not all available hardware mitigations are used in iOS (Darwin).  But the introduction of newer hardware protections can give hints as to what software mitigations could be introduced.

In the following table, we list recent iPhones (a representative example), the Apple Silicon that is provided, as the hardware architecture of the chip (from the compiler's perspective because that is what Darwin leverages).  Finally we list the software migitations that there then offered.

For details on the Chip-to-Compiler architecture mapping, see 
[AArch64TargetParser.def](./Bibliography.md#AA).


| iPhone Model | Apple Silicon | ARM Architecture (HW Migitations) | SW Mitigations |
| -- | -- | -- | -- |
| 5s | A7 | ARMv8.0 | KPP |
| 6 | A8 | ARMv8.0 | KPP |
| 6s | A9 | ARMv8.0 | KPP |
| 7 | A10 | ARMv8.1 (PAN) | KTRR |
| X | A11 | ARMv8.2 (PAN, HPD)| KTRR, APRR |
| XR | A12 | ARMv8.3 (PAN, HPD, PAC) | KTRR, APRR, PPL |
| 11 | A13 | ARMv8.4 (PAN, HPD, PAC) | KTRR, APRR, PPL |
| 12 | A14 | ARMv8.5 (PAN, HPD, PAC, MTE) | KTRR, APRR, PPL |
| 13 | A15 | ARMv8.5 (PAN, HPD, PAC, MTE) | KTRR, APRR, PPL |

## Hardware Mitigation Techniques

### PAN Mitigation Technique

### HPD Mitigation Technique

### PAC Mitigation Technique

### MTE Mitigation Technique

[Memory Tagging Extension (MTE)](./Bibliography.md#MTE) is where each memory allocation is given a tag, and then any pointer that reaches that memory is checked to see if the pointer has the correct tag.  If not, it is an invalid pointer and fails.  Therefore, pointers become more restricted to where they can point to, so arbitrary maliciously crafted memory cannot be used.

The immediate benefit of this feature is that if two separate memory allocations are done, and they are contiguous then advancing a pointer from one allocation to reach the next allocation would fail.  This therefore is a upper bound dereference guard.  Similarly if a pointer points to memory that has been deallocated and then allocated, the newly allocated memory could have a different tag to the original memory allocation.  In such cases it would defeat a Use-After-Free exploit.

The MTE feature is not that strong because the number of tags is limited to 4 bits, and thus 16 possibilities.  As of 4th December, 2021, iOS does not enable MTE.  So it is a potential mitigation not yet being utilised.

## Software Mitigation Techniques

### KPP Mitigation Technique

KPP is Kernel Patch Protection, also known as WatchTower.

In ARMv8 there is a privilege model where lower privileged subsystems cannot access the memory of higher privileged subsystems (Memory Privilege), and lower privileged subsystems cannot access the CPU resources of higher privileged subsystems (Register Access Privilege).

ARM denotes the Exception Privilege levels as EL0 (lowest privilege), through to EL1, EL2, and EL3 (highest privilege).  A given implementation does not need to use all the levels.

Privilege level changes can only occur when an Exception occurs.  Exceptions are interruptions to the flow of execution of a program.  They can either be due to the instruction of the program being executed, or unrelated to the instruction.

When an Exception occurs due to the instruction being executed, it is just known as an Exception.  When an Exception occurs unrelated to the instruction being executed, we call it an Interrupt (a special case of an Exception).

KPP is a system which checks the Kernel.  To do this is runs at a higher privilege level so cannot be tampered with by Kernel code.

To enable a separation of privileges, iOS arranges its code so:

- EL0 is where application code runs (least privilege)
- EL1 is where the kernel runs
- EL3 is where the KPP code runs

To get to EL3 from either EL0 or EL1, an Exception is needed.

The two Exceptions used are:

- Whenever a FPU (Floating Point Unit) instruction is executed
- Whenever a IRQ handler fires

In the write-up by Xerub this is called [Tick-Tock](./Bibliography.md#TT).  The tick is the FPU Exception, the tock is the IRQ Interrupt.  That is because it is a state machine whereby KPP checks a portion of the kernel in the tick, and re-enables the FPU upon success.  FPU usage in the tock routes interrupts into the KPP code.  If this mutually supporting state machine hits an error, the system panics.

### KTRR Mitigation Technique

KTRR is [Kernel Text Read-Only Region](./Bibliography.md#KTRR) Protection.  It is a replacement for KPP which had a software bypass.
