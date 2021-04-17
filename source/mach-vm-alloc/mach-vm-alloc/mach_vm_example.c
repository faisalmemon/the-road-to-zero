//
//  mach_vm_example.c
//  mach-vm-alloc
//
//  Created by Faisal Memon on 16/04/2021.
//

#include "mach_vm_example.h"

#import <stdio.h>
#import <stdlib.h>

#import <mach/mach.h>

int vm_example()
{
    union data_area {
        char *indexed;
        vm_address_t handle;
    } data1, data2;
    int             i;
    uintptr_t       min;
    unsigned int    data_cnt;
    kern_return_t   rtn;
    
    mach_port_t self = mach_task_self();
    
    printf("mach_task_self is %x", self);
    
    if ((rtn = vm_allocate(self,
                           &data1.handle,
                           vm_page_size,
                           TRUE)) != KERN_SUCCESS) {
        mach_error("vm_allocate failed", rtn);
        printf("vmread: Exiting.\n");
        return -1;
    }
    
    for (i = 0; (i < vm_page_size); i++) {
        data1.indexed[i] = i;
    }
    printf("Filled space allocated with some data.\n");
    printf("Doing vm_read....\n");
    if ((rtn = vm_read(self,
                       data1.handle,
                       vm_page_size,
                       (pointer_t *)&data2,
                       &data_cnt)) != KERN_SUCCESS) {
        mach_error("vm_read failed", rtn);
        printf("vmread: Exiting.\n");
        return -1;
    }
    printf("Successful vm_read.\n");
    
    if (vm_page_size != data_cnt) {
        printf("vmread: Number of bytes read not equal to number");
        printf("available and requested.\n");
    }
    min = (vm_page_size < data_cnt) ? vm_page_size : data_cnt;
    
    for (i = 0; (i < min); i++) {
        if (data1.indexed[i] != data2.indexed[i]) {
            printf("vmread: Data not read correctly.\n");
            printf("vmread: Exiting.\n");
            return -1;
        }
    }
    printf("Checked data successfully.\n");
    
    if ((rtn = vm_deallocate(self,
                             data1.handle,
                             vm_page_size)) != KERN_SUCCESS) {
        mach_error("vm_deallocate failed", rtn);
        printf("vmread: Exiting.\n");
        return -1;
    }
    
    if ((rtn = vm_deallocate(self,
                             data2.handle,
                             data_cnt)) != KERN_SUCCESS) {
        mach_error("vm_deallocate failed", rtn);
        printf("vmread: Exiting.\n");
        return -1;
    }
    return 0;
}
