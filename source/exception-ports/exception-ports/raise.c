//
//  raise.c
//  exception-ports
//
//  Created by Faisal Memon on 24/04/2021.
//  Based on NEXTSTEP documentation "Mach Concepts"
//

#include "raise.h"

/**
 raise.c: This program shows how to raise user-specified exceptions. If you use GDB,
 you can't set any breakpoints or step through any code between the call to
 `task_set_exception_port` and the return from `exception_raise()`.
 (You can never use GDB to debug exception handling code, since GDB stops the
 program by generating an EXC_BREAKPOINT exception.)
 */
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <assert.h>
#import <mach/mach.h>
#include <unistd.h>

#import "kernel_private_headers.h"

typedef struct {
    mach_port_t old_exc_port;
    mach_port_t clear_port;
    mach_port_t exc_port;
} ports_t;

typedef struct reply_holder {
    /** Number of independent mask/port/behavior/flavor sets
     * (up to EXC_TYPES_COUNT). */
    mach_msg_type_number_t count;

    /** Exception masks. */
    exception_mask_t masks[EXC_TYPES_COUNT];

    /** Exception handlers.*/
    exception_handler_t handlers[EXC_TYPES_COUNT];
    
    /** Exception behaviors. */
    exception_behavior_t behaviors[EXC_TYPES_COUNT];

    /** Exception thread flavors. */
    thread_state_flavor_t flavors[EXC_TYPES_COUNT];
} reply_holder;

volatile boolean_t pass_on = FALSE;
pthread_mutex_t            printing;

/* Listen on the exception port. */
//void *_Nullable
void *_Nullable exc_thread(void *_Nullable argp)
{
    ports_t *ports = (ports_t *) argp;
    kern_return_t   r;
    char           *msg_data[2][64];
    mach_msg_header_t   *imsg = (mach_msg_header_t *)msg_data[0],
    *omsg = (mach_msg_header_t *)msg_data[1];
    
    /* Wait for exceptions. */
    while (1) {
        imsg->msgh_size = 64;
        imsg->msgh_local_port = ports->exc_port;
        r = mach_msg_receive(imsg);
        
        if (r == MACH_MSG_SUCCESS) {
            /* Give the message to the Mach exception server. */
            if (exc_server(imsg, omsg)) {
                /* Send the reply message that exc_serv gave us. */
                r = mach_msg_send(omsg);
                if (r != MACH_MSG_SUCCESS) {
                    mach_error("exc_thread msg_send", r);
                    return (void *_Nullable)1;
                }
            }
            else { /* exc_server refused to handle imsg. */
                pthread_mutex_lock(&printing);
                printf("exc_server didn't like the message\n");
                pthread_mutex_unlock(&printing);

                return (void *_Nullable)2;
            }
        }
        else { /* msg_receive() returned an error. */
            mach_error("exc_thread msg_receive", r);
            return (void *_Nullable)3;
        }
        
        /* Pass the message to old exception handler, if necessary. */
        if (pass_on == TRUE) {
            // FIXME
            //imsg->msg_remote_port = port_p->old_exc_port;
            //imsg->msg_local_port = port_p->clear_port;
            //imsg->msgh_remote_port = port_get_re
            r = mach_msg_send(imsg);
            if (r != MACH_MSG_SUCCESS) {
                mach_error("msg_send to old_exc_port", r);
                return (void *_Nullable)4;
            }
        }
    }
}

/*
 * catch_exception_raise() is called by exc_server().  The only
 * exception it can handle is EXC_SOFTWARE.
 */
kern_return_t catch_exception_raise(port_t exception_port,
                                    port_t thread, port_t task, int exception, int code, int subcode)
{
    if ((exception == EXC_SOFTWARE) && (code == 0x20000)) {
        pass_on = FALSE;
        /* Handle the exception so that the program can continue. */
        mutex_lock(printing);
        printf("Handling the exception\n");
        mutex_unlock(printing);
        return KERN_SUCCESS;
    }
    else { /* Pass the exception on to the old port. */
        pass_on = TRUE;
        mutex_lock(printing);
        mach_NeXT_exception("Forwarding exception", exception,
                            code, subcode);
        mutex_unlock(printing);
        return KERN_FAILURE;  /* Couldn't handle this exception. */
    }
}

int raise_main()
{
    int             i;
    kern_return_t   r;
    reply_holder    reply;
    mach_port_name_t exception_port_right;
    mach_port_type_t port;
    
    reply.count = EXC_TYPES_COUNT;
    
    assert(pthread_mutex_init(&printing, NULL));
    
    /* Save the old exception port for this task. */
    //kern_return_t task_get_exception_ports(task_t task, exception_mask_t exception_mask, exception_mask_array_t masks, mach_msg_type_number_t *masksCnt, exception_handler_array_t old_handlers, exception_behavior_array_t old_behaviors, exception_flavor_array_t old_flavors);

    exception_mask_t safe_mask =
        EXC_MASK_ALL & ~(EXC_MASK_GUARD|EXC_MASK_RESOURCE);
    
    exception_mask_t mask_array;

    /**
     https://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_get_exception_ports.html
     */
    r = task_get_exception_ports(mach_thread_self(),
                                 safe_mask,
                                 reply.masks,
                                 &reply.count,  // inout
                                 reply.handlers,
                                 reply.behaviors,
                                 reply.flavors);
    if (r != KERN_SUCCESS) {
        mach_error("task_get_exception_port", r);
        return 1;
    }
    
    /* Create a new exception port for this task. */
    r = mach_port_allocate(mach_task_self(),
                           MACH_PORT_RIGHT_RECEIVE,
                           &exception_port_right);
    if (r != KERN_SUCCESS) {
        mach_error("port_allocate 0", r);
        return 1;
    }
    exception_behavior_t behaviour;
    thread_state_flavor_t flavor;
    
    r = task_set_exception_ports(mach_task_self(),
                                 safe_mask,
                                 port,
                                 behaviour,
                                 flavor);
    
    if (r != KERN_SUCCESS) {
        mach_error("task_set_exception_port", r);
        return 1;
    }
    
    pthread_t thread_details;

    pthread_create(&thread_details,
                   NULL,
                   &exc_thread,
                   &reply.handlers);
    pthread_detach(thread_details);
    
    /* Raise the exception. */
    ports.clear_port = thread_reply();

    r = exception_raise(ports.exc_port, ports.clear_port,
                        thread_self(), task_self(), EXC_SOFTWARE, 0x20000, 0);
    
    if (r != KERN_SUCCESS)
        mach_error("catch_exception_raise didn't handle exception",
                   r);
    else {
        pthread_mutex_lock(&printing);
        printf("Successfully called exception_raise\n");
        pthread_mutex_unlock(&printing);
    }
    
    sleep(5);  /* Exiting too soon can disturb other exception
                * handlers. */
}
