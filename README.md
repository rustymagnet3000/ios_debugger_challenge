# Debugger Challenge
  The app was written to practice bypassing anti-debugger techniques.  The idea was to use only a debugger like `lldb` - at run-time - to perform the bypasses.

- **Challenge 1: ptrace** can you bypass ptrace deny?

- **Challenge 2: sysctl** can you hook sysctl?

## Challenge 1: PTrace on iOS
The header files for ptrace are not easily available on iOS, unlike macOS.  But you can still start a *DENY_ATTACH* on iOS.  

##### Attach debugger after ptrace DENY_ATTACH set
This is a common technique to stop a debugger attaching to an iOS app.  If you try and attach a debugger AFTER  *deny attach* you will see something like this...

```
(lldb) process attach --pid 93791
error: attach failed: lost connection
```
##### Attach debugger before ptrace DENY_ATTACH set
You will see a process crash.

##### Bypass explained
Depending on how your ptrace API call is made, you can either issue a `(lldb) process attach --name "my_app" --waitfor` instruction or the following lldb commands..

```
process attach --pid 96441                // attach to process
rb ptrace -s libsystem_kernel.dylib       // set a regex breakpoint for ptrace
continue                                  // continue after breakpoint
dis                                       // look for the syscall
```
Now check what you are looking at..
![thread_list](/debugger_challenge/readme_images/thread_list_image_ptrace.png)
```
thread list                               // validate you are in the ptrace call
thread return 0                           // ptrace success sends a Int 0 response
```
![bypass](/debugger_challenge/readme_images/ptrace_bypass.png)

## Challenge 2: sysctl on iOS
Sysctl is the Apple recommended way to check whether a debugger is attached to the running process.    Refer to: https://developer.apple.com/library/archive/qa/qa1361/index.html  


**The same trick from ptrace works sysctl.**  But that is not the point of this learning exercise.  For this bypass I wanted to be more creative.  I was inspired by https://github.com/DerekSelander/LLDB to create a new, empty Swift framework that loaded a C function API named...you guessed it...`sysctl`.

#### Create an empty Swift framework
  Then add a C file.  You don't even need a C header file.
![framework_settings](/debugger_challenge/readme_images/framework_creation.png)
#### Write your fake sysctl API
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
#### Use LLDB to load your hooking framework
```
(lldb) image list -b hello_framework
error: no modules found that match 'hello_framework'
```
#### Load dylib from Mac into device
Now load the process...
```
(lldb) process load /Users/PATH_TO_FRAMEWORK/hello_framework.framework/hello_framework
Loading "/Users/PATH_TO_FRAMEWORK/hello_framework.framework/hello_framework"...ok
Image 0 loaded.
```
#### dlopen and dlsym
Start by trying to see if you can find the load address for the `sysctl` function inside the iOS app.

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
##### Run the app
Now you have loaded the rusty_bypass framework, did your bypass work?  No.  the libsystem_kernel `sysctl` was called before your own code.
##### Now for a scarier dump...
```
(lldb) image dump symtab -m libsystem_c.dylib
Now check your Load Address.  0x0000000113be7c04.
```
##### Verify what you found, the easy way
```
(lldb) image dump symtab -m rusty_bypass`
`0x000000012e292dc0` for `sysctl`.
```
##### Set a breakpoint
Whoop whoop.
```
(lldb) b 0x0000000113be7c04
(lldb) register read
```
Now we can see the fruit of our labor.
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
register write rip 0x000000012e292dc0`
rip = 0x000000012e292dc0  rusty_bypass`sysctl at hook_debugger_check.c:5
```
##### BYPASS DONE
`continue`
### Bonus - use lldb to print when inside your fake sysctl API
I wanted to check I was inside of my hooked-sysctl.  I could add some `syslog` statements to acheive this.  But that misses the point of improving my lldb skills.  Here is a more fun way...
```
breakpoint set -p "return" -f hook_debugger_check.c
breakpoint modify --auto-continue 1
breakpoint command add 1
  script print "hello”
  DONE
continue
```
### Bonus - use lldb to print when inside your fake sysctl API
```
(lldb)  script print "hello"
hello
```
