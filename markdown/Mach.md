# Mach Programming

## Motivation

The reason why we want to do Mach programming is because it is an interface available from user mode (otherwise known as userland) that can reach the internals of kernel mode through the System Call Interface (syscall interface).  The operating system, marketed as iOS or macOS, etc., is the really the Darwin operating system.  Darwin is a UNIX operating system.  It offers two personalities to the programmer; its UNIX personality and its Mach personality.  The kernel of Darwin is XNU, and XNU natively speaks Mach because Mach Inter-Process Communication is central to the way in which it internally operates.

It is straightforward to learn the UNIX syscall interface, because it follows the same paradigm as Linux.  There are therefore many books and example programs written against the UNIX syscall interface.  The details will vary but the approach is the same.

The Mach programming interface is somewhat esoteric.  Apple seem to like to pretend that it does not exist.  Even experienced iOS programmers will know  little to nothing about it.  However, time and again, this interface will be used to build exploits, so it is something we shall learn.

The original idea with Mach was to extend UNIX with new capabilities to tackle the emergence of multiprocessor systems and distributed computing more naturally.  The solution was to add a new set of messaging primitives.  [@machsyscalls]

When correctly coded, Mach based solutions can be elegant.  When incorrectly coded, Mach based code offers an expansive attack surface.  We shall study different techniques that abuse the Mach messaging system, such as Type Confusion.  Furthermore, Mach based attacks can be Data oriented attacks, which side-step the traditional mitigations in the Operating System (such as stack overflow protection and control flow integrity).

## Mach Fundamental Abstractions

Mach [@machconcepts] is built upon the following abstractions:

Entry|Meaning
--|--
`task` | An execution environment.
`thread` | The basic unit of execution.
`port` | A communication channel.
`message` | A typed collection of data used for communication between threads

In the original formulation, tasks could be on the same machine, on different processors in the machine, or on different machines.  Such tasks become active entities when they host one or more threads.  And threads can communicate with each other using well-defined interfaces that are invariant to whether the recipient is on the same machine or on a different machine.

In reality, due to the inescapable nature of distributed communication, latency and reliability cannot be ignored.  Therefore, the uniform communication abstraction never works out satisfactorily in real systems.  However, within a CPU with threads from the same task, or tasks in a parent-child relationship, the inherently well design message passing abstraction comes into its own.  This is where the XNU kernel does its work.

## How to learn Mach programming

Mach is not so easy to learn.  There are few modern programs on GitHub to look at.  One way into the topic is to study the NEXTSTEP\index{trademark!NEXTSTEP} documentation, [@machconcepts].  Despite its age, it is a well structured explanation of the concepts.  Another source of documentation are the header files on macOS.

We can find the header file directory with:
```
# find /Applications/Xcode.app -type d -iname mach
/Applications/Xcode.app/Contents/Developer/Platforms/AppleTVOS.pl
atform/Developer/SDKs/AppleTVOS.sdk/usr/include/mach
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.pla
tform/Developer/SDKs/iPhoneOS.sdk/usr/include/mach
.
.
.
```

Rather than duplicate or replace the NEXTSTEP documentation, we assume the reader will read that documentation, but for the practical work elements, refer to this book.  This book then acts as a modernization of the original materials.  As mentioned in the Introduction, this book is largely a tutorial guide to get us along the path to being able to find 0-day vulnerabilities.

## Memory Allocation

Here we follow along the [@machconcepts] documentation but with modernized code examples.  These are available at [@trtzgithub] in the subdirectory `source/mach-vm-alloc`

Here is code that demonstrates how to allocate memory with Mach, how to duplicate memory, and then how to free memory.

```c
int vm_example()
{
    union data_area {
        char                *indexed;
        vm_address_t        handle;
    } data1, data2;

    vm_size_t               i;
    vm_size_t               min;
    mach_msg_type_number_t  data_cnt;
    mach_port_t             self;
    char                    *error = NULL;
    kern_return_t           rv = KERN_SUCCESS;

    printf("\nSTART: vm_example()\n");

    self = mach_task_self();

    printf("mach_task_self is 0x%x\n", self);

    rv = vm_allocate(self,
                     &data1.handle,
                     vm_page_size,
                     TRUE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_example_error_return;
    }

    for (i = 0; (i < vm_page_size); i++) {
        data1.indexed[i] = i;
    }
    printf("Filled space allocated with some data.\n");
    printf("Doing vm_read....\n");
    rv = vm_read(self,
                 data1.handle,
                 vm_page_size,
                 &data2.handle,
                 &data_cnt);
    if(rv != KERN_SUCCESS) {
        error = "Could not vm_read";
        goto vm_example_error_return;
    }
    printf("Successful vm_read.\n");

    if (vm_page_size != data_cnt) {
        error = "vmread: Number of bytes read not equal to number
 available and requested.";
        goto vm_example_logic_error_return;
    }
    min = (vm_page_size < data_cnt) ? vm_page_size : data_cnt;

    for (i = 0; (i < min); i++) {
        if (data1.indexed[i] != data2.indexed[i]) {
            error = "Data not read correctly";
            goto vm_example_logic_error_return;
        }
    }
    printf("Checked data successfully.\n");

    rv = vm_deallocate(self,
                       data1.handle,
                       vm_page_size);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_deallocate";
        goto vm_example_error_return;
    }

    rv = vm_deallocate(self,
                       data2.handle,
                       data_cnt);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_deallocate";
        goto vm_example_error_return;
    }

    printf("END: vm_example()\n");
    return 0;

vm_example_error_return:
    printf("%s: %s\n", error, mach_error_string(rv));
    return -1;

vm_example_logic_error_return:
    printf("%s\n", error);
    return -1;
}
```

### Memory Allocation discussion

In our code example, there are two stylistic points to note:

1. We use a union to clearly characterise that Mach calls accept a handle, which is a `vm_address_t` but is clearly also just a raw pointer, `char *`, so we create a union comprising these two types depending on whether we are issuing Mach calls or doing normal C-based pointer arithmetic.  The union avoids us having to use type casts.

1. We use a `goto` idiom to handle errors.  All our `goto` statements go forwards (so don't generate loops in our code) and just handle the error cases.  This makes such exception handling clean without too much code repetition.  That is useful because nearly all our function calls can return an error to be checked.

In our code we make the following observations:

1. We need to have the port of the task before any of the system calls can be made because any message port the system returns is namespaced to port of the task it relates to. `mach_task_self()` provides us this.  It is not actually a function call, it is a #define which provides us our thread-specific task value.  The value is typically a small integer.

1. `vm_allocate()` allocates memory.  It is logical to ask for a page sized amount of memory because this is the unit of memory upon which virtual protection and management is done.  This will be 16 KiB.

1. `vm_read()` actually also allocates memory as `vm_allocate()` does.  The function names do not have a nomenclature that tells us this, so it is worthwhile checking the function meaning each time until we are familiar with them.

1. `vm_deallocate()` deallocates our memory; we did a `vm_allocate()` and a `vm_read()` allocation so there are two pages of memory to free up.

1. It is a good practice to check return values against `!= KERN_SUCCESS` and let `mach_error_string` handle the different possible error return values, since there are many error values possible.

This `vm_example()` code merely needs to be hooked into our App code when it launches, in the `main()` function to operate.  It does feel heavyweight for what it does.

## Copy-on-Write Memory

The following example shows how Mach will Copy-on-Write pages of memory which are shared.

```c
enum copy_on_write_constants {
    COPY_ON_WRITE = 0,
    PARENT_CHANGED = 1,
    CHILD_CHANGED = 2,
};

enum lock_constants {
    NO_ONE_WAIT = 0,
    PARENT_WAIT = 1,
    CHILD_WAIT = 2
};

char *lock_status[] = {
    "NO_ONE_WAIT 0",
    "PARENT_WAIT 1",
    "CHILD_WAIT 2"
};

char *cow_status[] = {
    "COPY_ON_WRITE 0" ,
    "PARENT_CHANGED 1",
    "CHILD_CHANGED 2"
};

int vm_copy_on_write_example()
{
    union data_area {
        char                *indexed;
        vm_address_t        handle;
    } lock, mem;

    mach_port_t             self;
    char                    *error = NULL;
    kern_return_t           rv = KERN_SUCCESS;
    pid_t                   pid;
    const int               MAXDATA = 100;

    printf("\nSTART: vm_copy_on_write_example()\n");

    self = mach_task_self();

    rv = vm_allocate(self,
                     &lock.handle,
                     sizeof(int),
                     TRUE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_cow_error_return;
    }

    rv = vm_inherit(self,
                    lock.handle,
                    sizeof(int),
                    VM_INHERIT_SHARE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_inherit";
        goto vm_cow_error_return;
    }

    *lock.indexed = NO_ONE_WAIT;

    rv = vm_allocate(self,
                     &mem.handle,
                     sizeof(int) * MAXDATA,
                     TRUE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_cow_error_return;
    }

    mem.indexed[0] = COPY_ON_WRITE;
    printf("value of lock before fork: %s\n",
           lock_status[*lock.indexed]);
    pid = fork();

    if (pid) {
        printf("PARENT: copied memory = %s\n",
               cow_status[mem.indexed[0]]);
        printf("PARENT: changing to %s\n",
               cow_status[PARENT_CHANGED]);
        mem.indexed[0] = PARENT_CHANGED;
        printf("\n");
        printf("PARENT: lock = %s\n",
               lock_status[*lock.indexed]);
        printf("PARENT: changing lock to %s\n",
               lock_status[PARENT_WAIT]);
        printf("\n");
        *lock.indexed = PARENT_WAIT;

        while (*lock.indexed == PARENT_WAIT) {
            /* wait for child to change the value */
            ;
        }

        printf("PARENT: copied memory = %s\n",
               cow_status[mem.indexed[0]]);
        printf("PARENT: lock = %s\n",
               lock_status[*lock.indexed]);
        printf("PARENT: Finished.\n");
        *lock.indexed = PARENT_WAIT;
        exit(-1);
    }

    while (*lock.indexed != PARENT_WAIT) {
        /* wait for parent to change lock */
        ;
    }

    printf("CHILD: copied memory = %s\n",
           cow_status[mem.indexed[0]]);
    printf("CHILD: changing to %s\n",
           cow_status[CHILD_CHANGED]);
    mem.indexed[0] = CHILD_CHANGED;
    printf("\n");
    printf("CHILD: lock = %s\n",
           lock_status[*lock.indexed]);
    printf("CHILD: changing lock to %s\n",
           lock_status[CHILD_WAIT]);
    printf("\n");

    *lock.indexed = CHILD_WAIT;
    while (*lock.indexed == CHILD_WAIT) {
        /* wait for parent to change lock */
        ;
    }

    rv = vm_deallocate(mach_task_self(),
                       lock.handle,
                       sizeof(int));
    if (rv != KERN_SUCCESS) {
        error = "vm_deallocate failed";
        goto vm_cow_error_return;
    }

    rv = vm_deallocate(mach_task_self(),
                       mem.handle,
                       sizeof(int) * MAXDATA);
    if (rv != KERN_SUCCESS) {
        error = "vm_deallocate failed";
        goto vm_cow_error_return;
    }

    printf("CHILD: Finished.\n");
    printf("END: vm_copy_on_write_example()\n");

    return 0;

vm_cow_error_return:
    printf("%s: %s\n", error, mach_error_string(rv));
    return -1;
}
```

This program produces the following output:

```
START: vm_copy_on_write_example()
value of lock before fork: NO_ONE_WAIT 0
PARENT: copied memory = COPY_ON_WRITE 0
PARENT: changing to PARENT_CHANGED 1

PARENT: lock = NO_ONE_WAIT 0
PARENT: changing lock to PARENT_WAIT 1

CHILD: copied memory = COPY_ON_WRITE 0
CHILD: changing to CHILD_CHANGED 2

CHILD: lock = PARENT_WAIT 1
CHILD: changing lock to CHILD_WAIT 2

PARENT: copied memory = PARENT_CHANGED 1
PARENT: lock = CHILD_WAIT 2
PARENT: Finished.
CHILD: Finished.
END: vm_copy_on_write_example()
```

### Copy-on-Write Discussion

As we can see the `vm_inherit()` routine will provide both the child and parent access to the same memory until it is modified.  After that, the child and parent have separate memory pages representing their own copy of the data values which can now be different.

This program uses a very primitive form of task coordination: busy while loops.  A realistic example would use the `pthread` library instead for signalling and coordination.
