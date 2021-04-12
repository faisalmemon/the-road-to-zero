# Mach Programming

## Motivation

The reason why we want to do Mach programming is because it is an interface available from user mode (otherwise known as userland) that can reach the internals of kernel mode through the System Call Interface.  The operating system, marketed as iOS or macOS, etc., is the really the Darwin operating system.  Darwin is a UNIX operating system.  It offers two personalities to the programmer; its UNIX personality and its Mach personality.  The kernel of Darwin is XNU, and XNU natively speaks Mach because Mach Inter-Process Communication is central to the way in which it internally operates.

It is straightforward to learn the UNIX syscall interface, because it follows the same paradigm as Linux.  There are therefore many books and example programs written against the UNIX syscall interface.  The details will vary but the approach is the same.

The Mach programming interface is somewhat esoteric.  Apple seem to like to pretend that it does not exist.  Even experienced iOS programmers will know  little to nothing about it.  However, time and again, this interface will be used to build exploits, so it is something we shall learn.

The original idea with Mach was to extend UNIX with new capabilities to tackle the emergence of multiprocessor systems and distributed computing more naturally.  The solution was to add a new set of messaging primitives.  (@machsyscalls)

When correctly coded, Mach based solutions can be elegant.  When incorrectly coded, Mach based code offers an expansive attack surface.  We shall study different techniques that abuse the Mach messaging system, such as Type Confusion.  Furthermore, Mach based attacks can be Data oriented attacks, which side-step the traditional mitigations in the Operating System (such as stack overflow protection and control flow integrity).

## Mach Fundamental Abstractions

Mach is built upon the following abstractions:

Entity | Purpose
--|--
`task` | An execution environment.
`thread` | The basic unit of execution.
`port` | A communication channel.
`message` | A typed collection of data used for communication between threads.

In the original formulation, tasks could be on the same machine, on different processors in the machine, or on different machines.  Such tasks become active entities when they host one or more threads.  And threads can communicate with each other using well-defined interfaces that are invariant to whether the recipient is on the same machine or on a different machine.

In reality, due to the inescapable nature of distributed communication, latency and reliability cannot be ignored.  Therefore, the uniform communication abstraction never works out satisfactorily in real systems.  However, within a CPU with threads from the same task, or tasks in a parent-child relationship, the inherently well design message passing abstraction comes into its own.  This is where the XNU kernel does its work.
