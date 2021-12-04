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

## History of Hardware Mitigation Techniques

Recent models of iPhone have the following hardware support for mitigations.  Here we take the compiler's perspective on the architecture of the chip [AArch64TargetParser.def](./Bibliography.md#AA) to derive the following table:

| iPhone Model | Apple Silicon | ARM Architecture (HW Migitations) | Technique |
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

## PAN Mitigation Technique

## HPD Mitigation Technique

## PAC Mitigation Technique

## MTE Mitigation Technique

[Memory Tagging Extension (MTE)](./Bibliography.md#MTE) is where each memory allocation is given a tag, and then any pointer that reaches that memory is checked to see if the pointer has the correct tag.  If not, it is an invalid pointer and fails.  Pointers become more restricted to where they can point to, so arbitrary maliciously crafted memory cannot be used.

