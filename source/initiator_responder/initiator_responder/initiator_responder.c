//
//  initiator_responder.c
//  initiator_responder
//
//  Created by Faisal Memon on 12/04/2021.
//

#include "initiator_responder.h"

/*
 * This program is an example of a initiator thread spawning a number of
 * concurrent responders.  The initiator thread waits until all of the responders have
 * finished to exit.  Once created a responder process doesn’t do much in this
 * simple example except loop.  A count variable is used by the initiator and
 * responder processes to keep track of the current number of responders executing.
 * A mutex is associated with this count variable, and a condition variable
 * with the mutex.  This program is a simple demonstration of the use of
 * mutex and condition variables.
 */
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>

int count;         /* number of responders active */
pthread_mutex_t lock;      /* mutual exclusion for count */
pthread_cond_t done;  /* signalled each time a responder finishes */

void init() {
    count = 0;
    pthread_mutex_init(&lock, NULL);
    pthread_cond_init(&done, NULL);
    unsigned int seed = (unsigned int)time(NULL);
    srandom(seed);  /* initialize random number generator */
}
/*
 * Each responder just counts up to its argument, yielding the processor on
 * each iteration.  When it is finished, it decrements the global count
 * and signals that it is done.
 */
responder(n)
    int n;
{
int i;
    for (i = 0; i < n; i += 1)
        cthread_yield();
    mutex_lock(lock);
    count -= 1;
    printf("responder finished %d cycles.\n", n);
    condition_signal(done);
    mutex_unlock(lock);
}

/*
 * The initiator spawns a given number of responders and then waits for them all to
 * finish.
 */
initiator(nresponders)
    int nresponders;
{
int i;
    for (i = 1; i <= nresponders; i += 1) {
        mutex_lock(lock);
        /*
         * Fork a responder and detach it,
         * since the initiator never joins it individually.
         */
        count += 1;
        cthread_detach(cthread_fork(responder, random() % 1000));
        mutex_unlock(lock);
    }
    mutex_lock(lock);
    while (count != 0)
        condition_wait(done, lock);
    mutex_unlock(lock);
    printf("All %d responders have finished.\n", nresponders);
    cthread_exit(0);
}
main() {
init();
    initiator((int) random() % 16);  /* create up to 15 responders */
}
