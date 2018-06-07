#include "hook_sysctl.h"

/** my fake sysctl function. **/
/** `(lldb) image lookup -s sysctl` and you will see two entries **/
int sysctl(int * mib, u_int byte_size, void *info, size_t *size, void *temp, size_t(f)){

    static void *handle;
    static void *real_sysctl;
    static int fake_result = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  // ensure this is only called once & not on every function call
        handle = dlopen("/usr/lib/system/libsystem_c.dylib", RTLD_NOW);
        real_sysctl = dlsym(handle, "sysctl");  // get function pointer
        
        //*** why not add this line? You will get into an recursive loop and crash the loop       *** //  //real_sysctl_result = debugger_sysctl();
    });
    
    printf("Real sysctl function: %p\nFake sysctl: %p\n", real_sysctl, sysctl);
    printf("HOOKED SYSCTL");
    return fake_result;
}

void close_homebrew_sysctl(){
    static void *handle;
    handle = dlopen("/debugger_challenge", RTLD_NOW);
    void *sysctl_ptr = dlsym(handle, "sysctl");  // get function pointer
    // int x = dlclose(handle);
    printf("dlclose pointing to original sysctl %p", sysctl_ptr);
}
