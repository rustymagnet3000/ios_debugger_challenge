#ifndef thread_setup_h
#define thread_setup_h

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>

typedef struct{
    int count;
    char *message;
}Chomper;

void start_and_stop_threads(void);

#endif /* thread_setup_h */
