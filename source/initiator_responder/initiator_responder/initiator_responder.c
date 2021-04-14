//
//  initiator_responder.c
//  initiator_responder
//
//  Created by Faisal Memon on 12/04/2021.
//  Based upon A Programmer’s Guide to the Mach User Environment
//  by Linda R. Walmer and Mary R. Thompson
//

#include "initiator_responder.h"

/*
 * This program is an example of a initiator thread spawning a number of
 * concurrent responders.  The initiator thread waits until all of the responders have
 * finished to exit.  Once created a responder process doesn’t do much in this
 * simple example except loop.  A n_responders_active variable is used by the initiator and
 * responder processes to keep track of the current number of responders executing.
 * A mutex is associated with this n_responders_active variable, and a condition variable
 * with the mutex.  This program is a simple demonstration of the use of
 * mutex and condition variables.
 */
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <assert.h>

int n_responders_active;    /* number of responders active */
pthread_mutex_t lock;       /* mutual exclusion for n_responders_active */
pthread_cond_t done;        /* signalled each time a responder finishes */

void init_initiator()
{
    n_responders_active = 0;
    assert(pthread_mutex_init(&lock, NULL) == 0);
    assert(pthread_cond_init(&done, NULL) == 0);
    unsigned int seed = (unsigned int)time(NULL);
    srandom(seed);  /* initialize random number generator */
}

/*
 * Each responder just n_responders_actives up to its argument, yielding the processor on
 * each iteration.  When it is finished, it decrements the global n_responders_active
 * and signals that it is done.
 */
void *_Nullable responder(void *_Nullable param)
{
    if (!param) {
        goto responder_exit;
    }
    int n = *((int *)param);
    for (int i = 0; i < n; i += 1) {
        pthread_yield_np();
    }
    assert(pthread_mutex_lock(&lock) == 0);
    n_responders_active -= 1;
    printf("responder finished %d cycles.\n", n);
    assert(pthread_cond_signal(&done) == 0);
    assert(pthread_mutex_unlock(&lock) == 0);
responder_exit:
    return NULL;
}

/*
 * The initiator spawns a given number of responders and then waits for them all to
 * finish.
 */
void initiator(int nresponders)
{
    for (int i = 1; i <= nresponders; ++i) {
        pthread_mutex_lock(&lock);
        n_responders_active += 1;
        pthread_t thread_details;
        int iterations = random() % 1000;
        pthread_create(&thread_details,
                       NULL,
                       &responder,
                       &iterations);
        pthread_detach(thread_details);
        pthread_mutex_unlock(&lock);
    }
    pthread_mutex_lock(&lock);
    while (n_responders_active != 0) {
        pthread_cond_wait(&done, &lock);
    }
    pthread_mutex_unlock(&lock);
    printf("All %d responders have finished.\n", nresponders);
    pthread_exit(NULL);
}

int initiator_responder_main()
{
    init_initiator();
    // <30 responders or experiment with larger values
    // such as <2560000
    int n_responders = random() % 30;
    initiator(n_responders);
    exit(EXIT_SUCCESS);
}
