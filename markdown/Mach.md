# Mach Programming

## Motivation

The reason why we want to do Mach programming is because it is an interface available from user mode (otherwise known as userland) that can reach the internals of kernel mode through the System Call Interface.  The operating system, marketed as iOS or macOS, etc., is the really the Darwin operating system.  Darwin is a UNIX operating system.  It offers two personalities to the programmer; its UNIX personality and its Mach personality.  The kernel of Darwin is XNU, and XNU natively speaks Mach because Mach Inter-Process Communication is central to the way in which it operates.

It is straightforward to learn the UNIX syscall interface, because it follows the same paradigm as Linux.  There are therefore many books and example programs written against the UNIX syscall interface.  The details will vary but the approach is the same.

The Mach programming interface is somewhat esoteric.  Apple seem to like to pretend that it does not exist.  Even experienced iOS programmers will know  little to nothing about it.  However, time and again, this interface will be used to build exploits, so it is something we shall learn.
