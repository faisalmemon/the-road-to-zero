//
//  mach_copy_on_write_example.c
//  mach-vm-alloc
//
//  Created by Faisal Memon on 18/04/2021.
//

#include "mach_copy_on_write_example.h"

#import <stdio.h>
#import <stdlib.h>

#import <unistd.h>
#import <mach/mach.h>

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
    
    rv = vm_allocate(self, &lock.handle, sizeof(int), TRUE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_cow_error_return;
    }
    
    rv = vm_inherit(self, lock.handle, sizeof(int), VM_INHERIT_SHARE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_inherit";
        goto vm_cow_error_return;
    }
    
    *lock.indexed = NO_ONE_WAIT;
    
    rv = vm_allocate(self, &mem.handle, sizeof(int) * MAXDATA, TRUE);
    if (rv != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_cow_error_return;
    }
    
    mem.indexed[0] = COPY_ON_WRITE;
    printf("value of lock before fork: %s\n", lock_status[*lock.indexed]);
    pid = fork();
    
    if (pid) {
        printf("PARENT: copied memory = %s\n", cow_status[mem.indexed[0]]);
        printf("PARENT: changing to %s\n", cow_status[PARENT_CHANGED]);
        mem.indexed[0] = PARENT_CHANGED;
        printf("\n");
        printf("PARENT: lock = %s\n", lock_status[*lock.indexed]);
        printf("PARENT: changing lock to %s\n", lock_status[PARENT_WAIT]);
        printf("\n");
        *lock.indexed = PARENT_WAIT;
        
        while (*lock.indexed == PARENT_WAIT) {
            /* wait for child to change the value */
            ;
        }
        
        printf("PARENT: copied memory = %s\n", cow_status[mem.indexed[0]]);
        printf("PARENT: lock = %s\n", lock_status[*lock.indexed]);
        printf("PARENT: Finished.\n");
        *lock.indexed = PARENT_WAIT;
        exit(-1);
    }
    
    while (*lock.indexed != PARENT_WAIT) {
        /* wait for parent to change lock */
        ;
    }
    
    printf("CHILD: copied memory = %s\n", cow_status[mem.indexed[0]]);
    printf("CHILD: changing to %s\n", cow_status[CHILD_CHANGED]);
    mem.indexed[0] = CHILD_CHANGED;
    printf("\n");
    printf("CHILD: lock = %s\n", lock_status[*lock.indexed]);
    printf("CHILD: changing lock to %s\n", lock_status[CHILD_WAIT]);
    printf("\n");
    
    *lock.indexed = CHILD_WAIT;
    while (*lock.indexed == CHILD_WAIT) {
        /* wait for parent to change lock */
        ;
    }
    
    rv = vm_deallocate(mach_task_self(), lock.handle, sizeof(int));
    if (rv != KERN_SUCCESS) {
        error = "vm_deallocate failed";
        goto vm_cow_error_return;
    }
    
    rv = vm_deallocate(mach_task_self(), mem.handle, sizeof(int) * MAXDATA);
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
