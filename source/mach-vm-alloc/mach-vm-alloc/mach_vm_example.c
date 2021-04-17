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
        char                *indexed;
        vm_address_t        handle;
    } data1, data2;
    
    vm_size_t               i;
    vm_size_t               min;
    mach_msg_type_number_t  data_cnt;
    mach_port_t             self;
    char                    *error = NULL;
    kern_return_t           rtn = KERN_SUCCESS;
    
    self = mach_task_self();
    
    printf("mach_task_self is %x", self);
    
    if ((rtn = vm_allocate(self,
                           &data1.handle,
                           vm_page_size,
                           TRUE)) != KERN_SUCCESS) {
        error = "Could not vm_allocate";
        goto vm_example_error_return;
    }
    
    for (i = 0; (i < vm_page_size); i++) {
        data1.indexed[i] = i;
    }
    printf("Filled space allocated with some data.\n");
    printf("Doing vm_read....\n");
    if ((rtn = vm_read(self,
                       data1.handle,
                       vm_page_size,
                       &data2.handle,
                       &data_cnt)) != KERN_SUCCESS) {
        error = "Could not vm_read";
        goto vm_example_error_return;
    }
    printf("Successful vm_read.\n");
    
    if (vm_page_size != data_cnt) {
        error = "vmread: Number of bytes read not equal to number available and requested.";
        goto vm_example_logic_error_return;
    }
    min = (vm_page_size < data_cnt) ? vm_page_size : data_cnt;
    
    for (i = 0; (i < min); i++) {
        if (data1.indexed[i] != data2.indexed[i]) {
            error = "Data not read correctly.";
            goto vm_example_logic_error_return;
        }
    }
    printf("Checked data successfully.\n");
    
    if ((rtn = vm_deallocate(self,
                             data1.handle,
                             vm_page_size)) != KERN_SUCCESS) {
        error = "Could not vm_deallocate";
        goto vm_example_error_return;
    }
    
    if ((rtn = vm_deallocate(self,
                             data2.handle,
                             data_cnt)) != KERN_SUCCESS) {
        error = "Could not vm_deallocate";
        goto vm_example_error_return;
    }
    return 0;
    
vm_example_error_return:
    printf("%s: %s\n", error, mach_error_string(rtn));
    return -1;

vm_example_logic_error_return:
    printf("%s\n", error);
    return -1;
}
