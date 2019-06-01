#include "thread_setup.h"

const unsigned int microseconds = 30;

void *hello_world(void *voidptr) {
    uint64_t tid;
    
    assert(pthread_threadid_np(NULL, &tid)== 0);
    printf("Thread ID: dec:%llu hex: %#08x\n", tid, (unsigned int) tid);
    Chomper *chomper = (Chomper *)voidptr;
    
    for (int i = 0; i < chomper->count; i++) {
        usleep(microseconds);
        printf("%s: %d\n", chomper->message, i);
    }
    return NULL;
}

void start_and_stop_threads() {
    
    pthread_t myThread1 = NULL, myThread2 = NULL;
    
    Chomper *shark = malloc(sizeof(*shark));
    shark->count = 10;
    shark->message = "shark";
    
    Chomper *jellyfish = malloc(sizeof(*jellyfish));
    jellyfish->count = 10;
    jellyfish->message = "jelly";
    
    assert(pthread_create(&myThread1, NULL, hello_world, (void *) shark) == 0);
    assert(pthread_create(&myThread2, NULL, hello_world, (void *) jellyfish) == 0);
    assert(pthread_join(myThread1, NULL) == 0);
    assert(pthread_join(myThread2, NULL) == 0);
    
    free(shark);
    free(jellyfish);
    printf("THREAD Code complete\n");
}
