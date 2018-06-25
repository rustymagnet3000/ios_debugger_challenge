# Debugger Challenge
  This iOS app was written to practice techniques that would allow a person to inspect an iOS without being blocked by debugger protections.  The  idea was to use only the `lldb` debugger to perform the bypasses.  

The solutions used a combination of tools: breakpoints, code injection, the symbol table and writing new register values.

- **Challenge 1: ptrace** can you bypass ptrace deny?

- **Challenge 2: sysctl** can you hook sysctl?

## Challenge 1: PTrace on iOS
The header files for ptrace was not easily available on iOS, unlike macOS.  But you could still start a *DENY_ATTACH* on iOS.  

##### Attach debugger after ptrace DENY_ATTACH set
This was a common technique to stop a debugger attaching to an iOS app.  If you tried to attach a debugger AFTER  *deny attach* you would see something like this...
```
(lldb) process attach --pid 93791
error: attach failed: lost connection
```
##### Attach debugger before ptrace DENY_ATTACH set
You would see a process crash.

##### Bypass explained
```
process attach --pid 96441                // attach to process
rb ptrace -s libsystem_kernel.dylib       // set a regex breakpoint for ptrace
continue                                  // continue after breakpoint
dis                                       // look for the syscall

NOTE - you could issue a `(lldb) process attach --name "my_app" --waitfor` instruction, if preferred
```
##### Check where your breakpoint stopped
![thread_list](/debugger_challenge/readme_images/thread_list_image_ptrace.png)
```
thread list                               // validate you are in the ptrace call
thread return 0                           // ptrace success sends a Int 0 response
```
## BYPASS 1 - DONE
![bypass](/debugger_challenge/readme_images/ptrace_bypass.png)

## Challenge 2: sysctl on iOS
Sysctl was the Apple recommended way to check whether a debugger was attached to the running process.    Refer to: https://developer.apple.com/library/archive/qa/qa1361/index.html  


**The same trick from ptrace worked with sysctl.**  But that was not the point.  I wanted to be more creative.  I was inspired by https://github.com/DerekSelander/LLDB to create a new, empty Swift framework that loaded a C function API named - you guessed it -`sysctl`.  That was injected into my app's process image list.

##### Create an empty Swift framework
I created an empty Swift project.  I added the following C code.  You don't even need a C header file.
![framework_settings](/debugger_challenge/readme_images/framework_creation.png)
##### Add your fake sysctl API
```
int sysctl(int * mib, u_int byte_size, void *info, size_t *size, void *temp, size_t(f)){

    static void *handle;
    static void *real_sysctl;
    static int fake_result = 0;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  // ensure this is only called once & not on every function call
        handle = dlopen("/usr/lib/system/libsystem_c.dylib", RTLD_NOW);
        real_sysctl = dlsym(handle, "sysctl");  // get function pointer
    });

    printf("Real sysctl function: %p\nFake sysctl: %p\n", real_sysctl, sysctl);
    printf("HOOKED SYSCTL");
    return fake_result;
}
```
##### Use LLDB to load your hooking framework
```
(lldb) image list -b rusty_bypass
error: no modules found that match 'rusty_bypass'
```
##### Load dylib from Mac into device
Now load the process...
```
(lldb) process load /Users/PATH_TO_FRAMEWORK/rusty_bypass.framework/rusty_bypass
Loading "/Users/PATH_TO_FRAMEWORK/rusty_bypass.framework/rusty_bypass"...ok
Image 0 loaded.
```
##### dlopen and dlsym
Find the load address for the `sysctl` function inside the iOS app.

##### Find the load addresses for C API sysctl() in the symbol table
```
(lldb) expression (void*)dlopen("/usr/lib/system/libsystem_c.dylib",0x2)
(void *) $2 = 0x000000010e7086e0
(lldb) expression (void*)dlsym($2,"sysctl")
(void *) $3 = 0x0000000113be7c04
```
Ok, now check my address of my bypass...
```
(lldb) expression (void*)dlopen("/Users/rusty_magneto/Desktop/rusty_bypass.framework/rusty_bypass",0x2)
(lldb) ) $4 = 0x0000604000133ec0
(lldb) expression (void*)dlsym($4,"sysctl")
(void *) $5 = 0x000000012e292dc0
```
## BYPASS 2 - FAILED....
Now the `rusty_bypass` framework was loaded, I half expected it to work.  No.  the libsystem_kernel `sysctl` was called before my own code.
##### Symbol table to the rescue
```
(lldb) image dump symtab -m libsystem_c.dylib
Now check your Load Address:  0x0000000113be7c04  for `sysctl`
```
##### Verify what you found, the easy way
```
(lldb) image dump symtab -m rusty_bypass`
Now check your Load Address.  `0x000000012e292dc0` for `sysctl`
```
##### Set a breakpoint
```
(lldb) b 0x0000000113be7c04           
(lldb) register read
```
##### Whoop whoop
This was the killer step. The fruits of labor...
```
General Purpose Registers:
       rax = 0x000000000000028e
        .....
        .....
        .....
       rip = 0x0000000113be7c04  libsystem_c.dylib\`sysctl
```
##### Change load address of API call
```
(lldb) register write rip 0x000000012e292dc0`
rip = 0x000000012e292dc0  rusty_bypass`sysctl at hook_debugger_check.c:5
(lldb) continue
```
## BYPASS 2 - DONE

##### Bonus - use lldb to print when inside your fake sysctl API
I wanted to check I was inside of my hooked-sysctl.  I could have added `syslog` statements to achieve the same.  But that missed the point of improving my lldb skills.  Here was a more fun way...
```
(lldb) breakpoint set -p "return" -f hook_debugger_check.c
(lldb) breakpoint modify --auto-continue 1
(lldb) breakpoint command add 1
  script print "hello”
  DONE
(lldb) continue
```
##### Bonus - use lldb to print when inside your fake sysctl API
```
(lldb)  script print "hello"
hello
```
