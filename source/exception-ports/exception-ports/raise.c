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
//#import <mach/exception.h>
//#import <mach/mig_errors.h>

typedef struct {
    mach_port_t old_exc_port;
    mach_port_t clear_port;
    mach_port_t exc_port;
} ports_t;

volatile boolean_t pass_on = FALSE;
pthread_mutex_t            printing;

/* Listen on the exception port. */
int exc_thread(ports_t *port_p)
{
    kern_return_t   r;
    char           *msg_data[2][64];
    msg_header_t   *imsg = (msg_header_t *)msg_data[0],
    *omsg = (msg_header_t *)msg_data[1];
    
    /* Wait for exceptions. */
    while (1) {
        imsg->msg_size = 64;
        imsg->msg_local_port = port_p->exc_port;
        r = msg_receive(imsg, MSG_OPTION_NONE, 0);
        
        if (r==RCV_SUCCESS) {
            /* Give the message to the Mach exception server. */
            if (exc_server(imsg, omsg)) {
                /* Send the reply message that exc_serv gave us. */
                r = msg_send(omsg, MSG_OPTION_NONE, 0);
                if (r != SEND_SUCCESS) {
                    mach_error("exc_thread msg_send", r);
                    return 1;
                }
            }
            else { /* exc_server refused to handle imsg. */
                mutex_lock(printing);
                printf("exc_server didn't like the message\n");
                mutex_unlock(printing);
                return 2;
            }
        }
        else { /* msg_receive() returned an error. */
            mach_error("exc_thread msg_receive", r);
            return 3;
        }
        
        /* Pass the message to old exception handler, if necessary. */
        if (pass_on == TRUE) {
            imsg->msg_remote_port = port_p->old_exc_port;
            imsg->msg_local_port = port_p->clear_port;
            r = msg_send(imsg, MSG_OPTION_NONE, 0);
            if (r != SEND_SUCCESS) {
                mach_error("msg_send to old_exc_port", r);
                return 4;
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
    ports_t         ports;
    
    printing = mutex_alloc();
    
    /* Save the old exception port for this task. */
    r = task_get_exception_port(task_self(), &(ports.old_exc_port));
    if (r != KERN_SUCCESS) {
        mach_error("task_get_exception_port", r);
        return 1;
    }
    
    /* Create a new exception port for this task. */
    r = port_allocate(task_self(), &(ports.exc_port));
    if (r != KERN_SUCCESS) {
        mach_error("port_allocate 0", r);
        return 1;
    }
    r = task_set_exception_port(task_self(), (ports.exc_port));
    if (r != KERN_SUCCESS) {
        mach_error("task_set_exception_port", r);
        return 1;
    }
    
    /* Fork the thread that listens to the exception port. */
    cthread_detach(cthread_fork((cthread_fn_t)exc_thread,
                                (any_t)&ports));
    /* Raise the exception. */
    ports.clear_port = thread_reply();
#ifdef NOT_OUR_EXCEPTION
    /* By default, EXC_BAD_ACCESS causes a core dump. */
    r = exception_raise(ports.exc_port, ports.clear_port,
                        thread_self(), task_self(), EXC_BAD_ACCESS, 0, 0);
#else
    r = exception_raise(ports.exc_port, ports.clear_port,
                        thread_self(), task_self(), EXC_SOFTWARE, 0x20000, 0);
#endif
    
    if (r != KERN_SUCCESS)
        mach_error("catch_exception_raise didn't handle exception",
                   r);
    else {
        mutex_lock(printing);
        printf("Successfully called exception_raise\n");
        mutex_unlock(printing);
    }
    
    sleep(5);  /* Exiting too soon can disturb other exception
                * handlers. */
}
