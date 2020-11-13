# iOS Debugger Challenge

![](https://img.shields.io/github/commit-activity/m/rustymagnet3000/debugger_challenge?style=for-the-badge)
<!-- TOC depthFrom:2 depthTo:2 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Challenge: Method Swizzling on non-jailbroken device](#challenge-method-swizzling-on-non-jailbroken-device)
- [Challenge: Bypass anti-debug (ptrace)](#challenge-bypass-anti-debug-ptrace)
- [Challenge: Bypass ptrace (asm Syscall)](#challenge-bypass-ptrace-asm-syscall)
- [Challenge: Bypass anti-debug (sysctl)](#challenge-bypass-anti-debug-sysctl)
- [Challenge: Bypass anti-debug ( sysctl, more advanced )](#challenge-bypass-anti-debug-sysctl-more-advanced-)
- [Challenge: Bypass anti-debug (Exception Ports)](#challenge-bypass-anti-debug-exception-ports)
- [Challenge: Hook Apple's Random String function](#challenge-hook-apples-random-string-function)
- [Challenge: Find Encryption key](#challenge-find-encryption-key)
- [Challenge: Dancing with Threads](#challenge-dancing-with-threads)
- [Challenge: Certificate Pinning bypass ( with Frida )](#challenge-certificate-pinning-bypass-with-frida-)
- [Challenge: Certificate Pinning bypass ( with Method Swizzle )](#challenge-certificate-pinning-bypass-with-method-swizzle-)

<!-- /TOC -->

## Challenge: Other ways to bypass Jailbreak detections
Writing a self built Jailbreak detection is tempting.  But there are elegant libraries available to detect `Elevated Privilege`.  Check out an open-source Swift version: https://github.com/securing/IOSSecuritySuite.
```
if IOSSecuritySuite.amIJailbroken() {
	print("This device is jailbroken")
} else {
	print("This device is not jailbroken")
}
```
Most of the libraries have a `true/false` response, at a high-level.  But what happens if Apple changed an API?  What happens if ARM change something?  What happens a detection failed or was forced to fail?  You hit two common problem in Security;`false positives` and a `fail close / fail open policy`.

Mature iOS libraries recognize these risk.  Code is written code underneath the `true/false` response that is building a confidence level.
```
static func amIJailbrokenWithFailedChecks() -> (jailbroken: Bool, failedChecks: [FailedCheck]) {
    let status = performChecks()
    return (!status.passed, status.failedChecks)
}
```
There are lots of articles online that focus anti-Jailbreak on `patching` out a `Boolean` response to `amIJailbroken()`.  This challenge is looking at other variables - the ones that build the confidence level - that can be targeted instead of the `Boolean`.

## Challenge: Bypass ptrace (asm)
To start with, let's start with a reminder; "how do you eat an Elephant?"  Correct, one piece at a time.  Bypassing ASM code is daunting. But how about focusing on a tiny piece of code, outside the target app.  Get the technique down and then try the bigger app?

## Challenge: Animal bytes. Find the Animal type and change it.
Let’s find the string.
```
▶ strings c_play         
<nothing of interest>
```
Ok, so we can guess the string was `obfuscated`, `encrypted` or maybe just hidden?

const int animalByteArray[7] = { 66, 97, 98, 111, 111, 110 };
```
▶ rabin2 -qz c_play         
0x100003f60 28 6 Baboon
```
r2 c_play

[0x100003ec0]> s 0x100003f60

[0x100003f60]> x 28		< Int array of seven ( 7 x sizeOfInt(4))

- offset -    0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
0x100003f60  4200 0000 6100 0000 6200 0000 6f00 0000  B...a...b...o...
0x100003f70  6f00 0000 6e00 0000 0000 0000            o...n.......


[0x100003ec0]> iS
[Sections]
00 0x00003e90   158 0x100003e90   158 -r-x 0.__TEXT.__text
01 0x00003f2e    12 0x100003f2e    12 -r-x 1.__TEXT.__stubs
02 0x00003f3c    36 0x100003f3c    36 -r-x 2.__TEXT.__stub_helper
03 0x00003f60    28 0x100003f60    28 -r-x 3.__TEXT.__const. <— IN HERE
04 0x00003f7c    52 0x100003f7c    52 -r-x 4.__TEXT.__cstring

Now you have the Section (__TEXT) for an lldb memory search.
You want to find out what Section the code is inside.


## Challenge: Method Swizzling on non-jailbroken device
Why `Swizzle`? If you understand `swizzling` you understand part of `Objective-C's` beauty. Read this from [Apple][20e2b71f]
:

  [20e2b71f]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048-CH1-SW1 "apple_article"

> The Objective-C language defers as many decisions as it can from compile time and link time to runtime. Whenever possible, it does things dynamically.

My goal was to `method swizzle`.  I wanted to swap out a real `random` value with a value that I had chosen (`42`), as the below picture describes:

![swizzle_overview](debugger_challenge/readme_images/SwizzleOverview.png)

#### Step 1: Use a debugger to find information
```
(lldb) dclass -m YDObjCFramework
Dumping classes
************************************************************
YDHelloClass

(lldb) methods YDHelloClass
<YDHelloClass: 0x10ef63128>:
in YDHelloClass:
	Class Methods:
		+ (void) sayStaticHello; (0x10ef62ec0)
	Instance Methods:
		- (long) getRandomNumber; (0x10ef62e90)
(NSObject ...)

(lldb) exp import YDObjCFramework

(lldb) exp let $a = YDHelloClass()

(lldb) exp $a.getRandomNumber()
(Int) $R4 = 7981
(lldb) exp $a.getRandomNumber()
(Int) $R6 = 1021
(lldb) exp $a.getRandomNumber()
(Int) $R8 = 1614
```

#### Step 2: Write Swizzle code
I needed to write the code that would target the following information:
```
Class = YDHelloClass
Instance Method = getRandomNumber
```
I went back to `xCode` and selected `New\Project\iOS\Framework\Objective-C`.  Using Objective-C `runtime` APIs, I wrote code that would target Alice's SDK.  

```
+ (void)load
{
    Class orignalClass = objc_getClass("YDHelloClass");

    if (orignalClass != nil) {
        NSLog(@"\n[+] 🎣 Found YDHelloClass\n[+] 🎣 Placing hook on getRandomNumber\n");
        Method original, swizzled;
        original = class_getInstanceMethod(orignalClass, @selector(getRandomNumber));
        swizzled = class_getInstanceMethod(self, @selector(fakeRandomNumber));
        if(original != nil && swizzled != nil)
            method_exchangeImplementations(original, swizzled);
    }
}

@end
```
#### Step 3: Place the Swizzle
Let's start on an iOS Simulator.  I used my trusty debugger connected to the app running on an XCode simulator:
```
lldb) process load /Users/.../swizzle_framework.framework/swizzle_framework
[+] 🎣 Found YDHelloClass

  [70b2d1d9]: https://github.com/rustymagnet3000/YDObjCFramework "YDObjCFramework"

Loading "/Users/.../swizzle_framework.framework/swizzle_framework"...ok
Image 0 loaded.
```
### COMPLETE ( IOS SIMULATOR )
After applying the `method swizzle` you would always get a `42` value...

![success_swizzle](debugger_challenge/readme_images/swizzle_success_resized.png)

### Repackage app
The way to solve this challenge on a real iOS device depended on whether you had a _jailed_ or _jailbroken_ device.  I had a clean, _jailed iOS12_ device.  I chose to **repackage** the _debuggerChallenge.ipa_ file. This involves taking it apart, adding the `dynamic framework` that contained the _Swizzle_ code and putting the app back together.  

For more info on **repackaging apps**  read [here][5e75f6f0].

  [5e75f6f0]: https://github.com/OWASP/owasp-mstg/blob/master/Document/0x06c-Reverse-Engineering-and-Tampering.md "owasp"

#### Approach
- [x] Build and run Debugger Challenge within xCode.
- [x] Copy the `Product` (which is a folder called `DebuggerChallenge.app` from Finder).
- [x] Copy Bob's framework to the _DebuggerChallenge.app/Framework_ folder.
- [x] Insert a _load command_ with _Optool_ to the app's binary.
- [x] Put the DebuggerChallenge.app directory inside a new, empty folder named `Payload`.
- [x] Compress the `Payload` folder to `unsigned.ipa`.
- [x] Use `Applesign` to re-sign everything inside the IPA.
- [x] Use `iOS-deploy` to get the freshly signed app onto the _Jailed_ device.

It all sounded simple.  But I hit roadblocks:
##### Hiccup: OpTool
`OpTool` is a small repo that allows you to insert or remove `Load Commands`.  These commands fire when your app opens and decides what dynamically linked files to load into the process.

First, you need a local copy of `OpTool`.  You also need to ensure that you added `submodules`.  This last step tripped me up.
```
git clone https://github.com/alexzielenski/optool.git
Make initialize optool’s submodules:
cd optool/
git submodule update --init --recursive   
```
You tell the main app binary to load this new framework.
```
optool install -c load -p "@executable_path/Frameworks/YDBobSwizzle.framework/YDBobSwizzle" -t Payload/debugger_challenge.app/debugger_challenge
```
If it worked you would see..
```
Found FAT Header
Found thin header...
Found thin header...
Inserting a LC_LOAD_DYLIB command for architecture: arm
Successfully inserted a LC_LOAD_DYLIB command for arm
Inserting a LC_LOAD_DYLIB command for architecture: arm64
Successfully inserted a LC_LOAD_DYLIB command for arm64
Writing executable to debugger_challenge.app/debugger_challenge...
```
Verify it..
```
jtool -arch arm64 -l Payload/debugger_challenge.app/debugger_challenge
```
##### Hiccup: Code signatures
If you forgot to `code sign` anything, you would hit obscure Apple errors when you tried to install the app on the iPhone.
```
applesign -7 -i <DEVELOPER CODE SIGNING ID> -m embedded.mobileprovision unsigned.ipa -o ready.ipa
ios-deploy -b ready.ipa
ios-deploy -b debugger_challenge.app
No code signature found. AMDeviceSecureInstallApplication(0, device, url, options, install_callback, 0)
```
##### Hiccup: Entitlements
```
ios-deploy -b debugger_challenge.app
The executable was signed with invalid entitlements.
```
What had gone wrong, when I code signed the IPA? Check the file the `provisioning file`  you passed to Applesign.

`security cms -D -i embedded.mobileprovision`

Expiry date, device ID were good. Had I chosen the wrong developer Code Signing ID?
```
<key>Entitlements</key>
<key>ExpirationDate</key>
	<date>2019-05-21T11:01:06Z</date>
<key>ProvisionedDevices</key>
	<string>0ec8227a5f623d0f4f6d257438730d79858a977f</string>
<key>TeamName</key>
	<string>Rusty Magnet</string>
<key>TeamIdentifier</key>
		<string>2N3CU4HVH8</string>
```
Let's try again with a new code signing ID!
```
security find-identity -v -p codesigning
applesign -7 -i <NEW DEVELOPER CODE SIGNING ID> -m embedded.mobileprovision debugger_chall_unsigned.ipa -o ready.ipa
```
That worked.  I could install the app on the device.
#### Hiccup 4: White screen of death
Argh.  The app won't open but it generated a crash log [] which you could get from XCode ].
```
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Description: DYLD, Library not loaded: @executable_path/YDBobSwizzle.dylib | Referenced from: /var/containers/Bundle/Application/3F9EDE3F-7BCF-4F25-B438-9145FD3A21B7/debugger_challenge.app/debugger_challenge | Reason: image not found
Triggered by Thread:  0
```
I had forgotten to copy the actual framework!  So I had the _Load Command_ but no code to load!

### COMPLETE ( real device )
Repeat all the above.  It worked! The Swizzle was placed and working on a `jailed` device.

![success_swizzle](debugger_challenge/readme_images/swizzled_jailed_device.png)

## Challenge: Bypass anti-debug (ptrace)

Using `ptrace` on `iOS` is still a common technique to stop a debugger attaching to an iOS app.  If you tried to attach a debugger after `PT_DENY_ATTACH` was issued, you would see something like this...
```
(lldb) process attach --pid 93791
error: attach failed: lost connection
```
If you attached a debugger before ptrace `PT_DENY_ATTACH` was set, you would see a process crash.

##### Use dtrace to observe the ptrace call
Unlike macOS, the header files for `ptrace` were not available on iOS.  But You could still `dynamically link` to the ptrace symbol at runtime on iOS.

To see this call on an iOS Simulator, run `DebuggerChallenge` and hit the `ptrace` button, after writing this command:
```
sudo dtrace -qn 'syscall::ptrace:entry { printf("%s(%d, %d, %d, %d) from %s\n", probefunc, arg0, arg1, arg2, arg3, execname); }'
// ptrace(31, 0, 0, 0) from debugger_challen
```
This will **crash** your app, if XCode is attached.

##### Bypass steps
Type the following into your debugger:
```
process attach --pid 96441                // attach to process
rb ptrace -s libsystem_kernel.dylib       // set a regex breakpoint for ptrace
continue                                  // continue after breakpoint
dis                                       // look for the syscall

```
Check where your breakpoint stopped:

![thread_list](debugger_challenge/readme_images/thread_list_image_ptrace.png)

Return an integer 0, to sidestep the real `ptrace` result.
```
(lldb) thread return 0
```
### COMPLETE

![bypass](debugger_challenge/readme_images/ptrace_bypass.png)

## Challenge: Bypass ptrace (asm Syscall)

If you want to make it harder to stop `ptrace` being sidestepped, you could write `inline assembly code`.  `Extended inline assembly` allows `C` language `Symbols` within the `asm` code.  

##### Bypass steps ( manual method )
```
(lldb) image lookup -r -n Ptrace
****************************************************
1 hits in: debugger_challenge
****************************************************
+[YDDebuggerPtrace setPtraceWithASM]
```
Now `disassemble` that function:
```
(lldb) disas -n "+[YDDebuggerPtrace setPtraceWithASM]"
    .....
    0x104539dac <+80>:  mov    x0, #0x1a          
    0x104539db0 <+84>:  mov    x1, #0x1f
    0x104539db4 <+88>:  mov    x2, #0x0
    0x104539db8 <+92>:  mov    x3, #0x0
    0x104539dbc <+96>:  mov    x16, #0x0
    0x104539dc0 <+100>: svc    #0x1a
    .....
    ....
    ...
    ..
    .
    0x104539e0c <+176>: ret    
```
Check the value of the registers:
```
(lldb) p/d 0x1a
(int) $5 = 26         // syscall for ptrace on arm

(lldb) p/d 0x1f
(int) $6 = 31         // PT_DENY_ATTACH == 31
```

Set breakpoint on the `svc` call: `(lldb) b *0x104539dc0`.

### COMPLETE
When the breakpoint fires, you set the `(lldb) po $x1 = 0`.  Depending on how the code is written, that may provide an effective bypass.  That set the `x1` register to the value `PTRACE_TRACEME`.


## Challenge: Bypass anti-debug (sysctl)
The C API, `Sysctl` was the [Apple][a3a00022] recommended way to check if a debugger was attached to your app.

  [a3a00022]: https://developer.apple.com/library/archive/qa/qa1361/index.html "apple_link"

> The sysctl utility retrieves kernel state and allows processes with appropriate privilege to set kernel tate.

To avoid repeating the `trace` trick, create a new, empty Swift framework that loaded a C function API named `sysctl`.  This code would be injected into my app's process at run-time.

##### Create an empty Swift framework
Create an empty Swift project. Add the following C code ( from Apple ).  You don't need a C header file.
![framework_settings](debugger_challenge/readme_images/framework_creation.png)
##### Write your fake sysctl API
```
int sysctl(int * mib, u_int byte_size, void *info, size_t *size, void *temp, size_t(f)){

    static void *handle;
    static void *real_sysctl;
    static int fake_result = 0;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{  // ensure this is only called once & not on every function call
        handle = dlopen("/usr/lib/system/libsystem_c.dylib", RTLD_NOW);
        real_sysctl = dlsym(handle, "sysctl");  // get actual pointer
    });

    printf("Real sysctl address: %p\nFake sysctl address: %p\n", real_sysctl, sysctl);
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

(lldb) image lookup -s sysctl  
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
(lldb) expression (void*)dlopen("/Users/..../rusty_bypass.framework/rusty_bypass",0x2)
(lldb) ) $4 = 0x0000604000133ec0
(lldb) expression (void*)dlsym($4,"sysctl")
(void *) $5 = 0x000000012e292dc0
```
#### Challenge - failed on first attempt....
Now the `rusty_bypass` framework was loaded, I half expected it to work.  No.  the libsystem_kernel `sysctl` was called before my own code.
##### Symbol table to the rescue
```
(lldb) image dump symtab -m libsystem_c.dylib
Now check your Load Address:  0x0000000113be7c04  for `sysctl`
```
##### Verify what you found, the easy way
```
(lldb) image lookup -a $rip
      Address: libsystem_c.dylib[0x0000000113be7c04]
      (libsystem_c.dylib.__TEXT.__text + 170512)
      Summary: libsystem_c.dylib`sysctl
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
       rip = 0x0000000113be7c04  libsystem_c.dylib sysctl
```
##### Change load address of API call
```
(lldb) register write rip 0x000000012e292dc0
rip = 0x000000012e292dc0  rusty_bypass`sysctl at hook_debugger_check.c:5
(lldb) continue
```
### COMPLETE
This was a cumbersome way to overwrite a register. There is a much simpler and reliable way to patch out anto-debug registers at run-time.

## Challenge: Bypass anti-debug ( sysctl, more advanced )
`sysctl` asks the Kernel to detect if a process is being debugged.  The result is the `P_TRACED` flag gets set. This is defined inside of `/sys/proc.h`.  How does `sysctl` tell the Kernel which process ID it wants to check ?  Let's inspect.

```
(lldb) b sysctl
Breakpoint 3: where = libsystem_c.dylib`sysctl, address = 0x00007fff5214c304
```
At this point, you can read what is inside the registers.
```
sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
```
You could read memory to understand what was passed into each register.  Is there a better simpler way ? You can use the call stack and move to frame before `sysctl`:
```
(lldb) bt
(lldb) frame select 1
```
Now you can observe the real variable settings:

```
(lldb) frame variable -A
(lldb) p mib
(int [4]) $14 = ([0] = 1, [1] = 14, [2] = 1, [3] = 23490)
```
Now - with the Apple documentation - we can see that the interesting value in `mib[3]` is the app's process ID.
```
  mib[0] = CTL_KERN;
  mib[1] = KERN_PROC;
  mib[2] = KERN_PROC_PID;		/* by process id */
  mib[3] = getpid();		/* current process ID */
```
If you did want to read memory instead of using the call stack, you could:
```
(lldb) po (int *) mib
0x00007ffee5f99610

(lldb) mem read 0x00007ffee646e610  -f d -c 4
0x7ffee5f99610: 1
0x7ffee5f99614: 14
0x7ffee5f99618: 1
0x7ffee5f9961c: 23490


```
### COMPLETE
Now we can bypass the check by patching out the value inside of `mib[3]`:
```
(lldb) p/x 0x00007ffee646e610 + 12      // mib[3]
(long) $16 = 0x00007ffee646e61c

(lldb) po getppid()
23493

(lldb) po mib[3]=23493
23493   // overwrite the getpid() with getppid()
```

## Challenge: Bypass anti-debug (Exception Ports)
Another anti-debug technique on macOS / iOS was to check if a debugger was attached by looking if any of the `Ports` used by a Debugger returned a valid response.  

This relied on the C `task_get_exception_ports` API.  You passed in the `Exception Port` you wanted  to check.  This was always argument 2 ( `arg2`) to the function.

### COMPLETE
Thanks to: https://alexomara.com/blog/defeating-anti-debug-techniques-macos-mach-exception-ports/.  Set the Exception Ports to check to a null value.  
```
(lldb) b task_get_exception_ports
Breakpoint 3: where = libsystem_kernel.dylib`task_get_exception_ports, address = 0x00007fff6a530675
(lldb) c
Process 48185 resuming
(lldb) p $arg2
(unsigned long) $0 = 66
(lldb) reg w rsi 0
(lldb) c
Process 48185 resuming
No debugger detected
```
### Useful references
```
http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_get_exception_ports.html
https://zgcoder.net/ramblings/osx-debugger-detection.html
https://github.com/apple/darwin-xnu/blob/master/osfmk/mach/exception_types.h
```

## Challenge: Hook Apple's Random String function
I started with some simple Swift code.  Could I whiten the UUID to a value I predefined?
```
@IBAction func random_string_btn(_ sender: Any) {
    let randomString = NSUUID().uuidString
    present_alert_controller(user_message: "Random string: \(randomString)")
}
```
![bypass](debugger_challenge/readme_images/random_number.png)
##### Use lldb to find the API
```
(lldb) image lookup -rn uuidString
<nothing returned >

(lldb) lookup NSUUID -m Foundation
****************************************************
14 hits in: Foundation
****************************************************
-[NSUUID init]
-[NSUUID hash]
+[NSUUID UUID]

```
Although the API was called via Swift, it was an Objective-C Class.I  attached `frida` to learn more.
```
[iPhone::Debug CrackMe]-> ObjC.classes.NSUUID.UUID().toString();
"6C402B55-6AFC-494A-B976-BCA781801A0A"
```
You could invoke the class with lldb:
```
(lldb) po [NSUUID UUID]
<__NSConcreteUUID 0x6000006374a0> 6BC8E049-2EFD-4BAA-B2AB-456E69AC74F8

(lldb) po [NSUUID UUID]
<__NSConcreteUUID 0x60400043fbc0> A41E59A5-C7C6-470F-88ED-48130BD85D1F
```
This was interesting.  Every time you called that `static method` it would add the pointer to the heap.  They were not deallocated.   Perhaps this was a way to ensure a repeated GUID was never given?

A disassemble revealed some interesting elements.
```
(lldb) disassemble -n "+[NSUUID UUID]" -c10
```
If you move to the init call - in the asm code, the 32-byte field was set to zeros.
```
(lldb) po (char*) $rax
<__NSConcreteUUID 0x6040006234a0> 00000000-0000-0000-0000-000000000000
```
##### Failed on first attempt....
It appeared you could not trust the return register.  As it did not match what Swift presented to the user.

##### failed on 2nd, 3rd, 4th, n attempts
```
frida-trace -m "*[NSUUID **]" -U -f funky-chicken.debugger-challenge

Instrumenting 27 functions.
```
The 4 I cared about were as follows:
```
+[NSUUID UUID]:
-[NSUUID init]:
-[NSUUID UUIDString]:
-[__NSConcreteUUID UUIDString]:
```
`Frida-Trace` generated a javascript file template when the above command ran.  I changed the javascript code to:
```
  onLeave: function (log, retval, state) {
     var message = ObjC.Object(retval);
     log("[+][__NSConcreteUUID UUIDString] -->\n\"" + message.toString() + "\"");
  }
```
### FAILED
Something was odd about this API.  It generated multiple UUID's every time you called the API.  But with Frida or lldb I could never find the actual return value going back to the swift code which was simply:
```
let randomString = UUID()
print(randomString.uuidString)
```

## Challenge: Find Encryption key
I added a popular `RNCryptor` wrapper around Apple's CommonCrypto library.  I statically embedded this into the Debugger Challenge instead of adding as a CocoaPod.

The CommonCrypto API `CCCryptorCreate init` was the target.  It was invoked behind this Swift code that called into the `RNCryptor.encrypt` API:

```
    // Encrypt
    let myString = "Ewoks don't wear pyjamas."
    let myData = myString.data(using: String.Encoding.utf8)! as Data  // note, not using NSData
    let password = "AAAAAAAA" // eight 0x41 values in hex
    let ciphertext = RNCryptor.encrypt(data: myData, withPassword: password)
```
##### Leveraging Frida-Trace
```
frida-trace -i "CCCryptorCreate*" -U "Debug CrackMe"
```
![bypass](/debugger_challenge/readme_images/common_crypto_trace.png)

Out of the box, this tells you interesting information.

Trace  | RNCryptor Definition  
--|--
op=0x0  |  Encrypt
alg=0x0  |  kCCAlgorithmAES128
options=0x1 |  kCCOptionPKCS7Padding
keyLength=0x20  |  kCCKeySizeAES256 = 32 (0x20 in hex)
key  |  A pointer to the Binary key (Data encoded)
iv  |  A pointer to the Binary I.V. (Data encoded)
cryptorRef  |  Opaque reference to a CCCryptor object

##### Watch the encryption key with a Frida-Script
```
/* Usage:   frida -U "Debug CrackMe" -l cc_hook.js --no-pause */

console.log("[+] script started...")
if (ObjC.available)
{
  if (Process.isDebuggerAttached() == true)
  {
    console.log("[+] Debugger attached, in addition to Frida.");
  }
  var a = Process.arch.toString()
  console.log("[+] Device chip: " + a);

  var f = Module.findExportByName("libcommonCrypto.dylib","CCCryptorCreate");

  if (f){
      console.log("[+] Found common crypto: " + f);
      Interceptor.attach(f, {
          onEnter: function (args) {
              console.log("inside init statement for CCCryptorCreate. Key, IV and algorithm available");
          }
      });
  }
}
else
{
    console.log("[+] Objective-C Runtime not available!");
}
console.log("[+] ...script completed")
```
##### Where is the plaintext about to be encrypted?
If you look at http://www.manpagez.com/man/3/CCCryptorCreate/ this API will lead to the Encryption Key.  But what if I want the actual plaintext that is being encrypted?  You can use lldb to show the lifecycle of the CommonCrypto API calls.  The flow is the same for encrypt and decrypt.  
```
(lldb) rb CCCrypt
```
- [ ] CCCryptorCreate
- [ ] CCCryptorCreateWithMode
- [ ] CCCryptorGetOutputLength
- [ ] CCCryptorUpdate
- [ ] CCCryptorGetOutputLength
- [ ] CCCryptorFinal
- [ ] CCCryptorRelease

The man page tells you the plaintext is sent into this API:
```
CCCryptorUpdate(CCCryptorRef cryptorRef, const void *dataIn,
         size_t dataInLength, void *dataOut, size_t dataOutAvailable,
         size_t *dataOutMoved);
```
Now we have our target - argument 2 - let's use lldb to reveal the plaintext.

RDI - first arg, **RSI - second arg**, RCX - fourth arg


```
lldb) rb CCCryptorUpdate
Breakpoint 1: where = libcommonCrypto.dylib`CCCryptorUpdate, address = 0x000000010b91092c
(lldb) c
Process 11315 resuming

(lldb) register read
General Purpose Registers:
       rsi = 0x000060400044a2a0

Note ->  RSI can be access via $arg2 in lldb
(lldb) po (char*) $arg2
"Ewoks don't wear pyjamas."

(lldb) memory read 0x000060400044a2a0
0x60400044a2a0: 45 77 6f 6b 73 20 64 6f 6e 27 74 20 77 65 61 72  Ewoks don't wear
0x60400044a2b0: 20 70 79 6a 61 6d 61 73 2e 00 00 00 00 00 00 00   pyjamas........
```
##### What is the decrypted plaintext?
```
(lldb) b CCCryptorFinal
(lldb) c
(lldb) po (char*) $arg2
(lldb) po (char*) $rsi
(lldb) mem read 0x00006040000106a0 -c10
```
Sometimes, the decrypted text was not together.  I had an assumption this related to the C `Malloc` API - that was used the hood by CommonCrypto.  `Malloc` was not always given sequential blocks of memory from the O/S.
#### Failed to get raw key
```
(lldb) rb CCCryptorCreateWithMode
Breakpoint 1: where = libcommonCrypto.dylib`CCCryptorCreateWithMode, address = 0x00000001826c8474
(lldb) rb CCCryptorCreateWithMode

API definition from Apple:
CCCryptorCreateWithMode(op, mode, alg, padding, iv, key, keyLength, tweak, tweakLength, numRounds, modeOptions, cryptorRef);

To get the Key Length.....
(lldb) po (size_t) $arg7
32  // 256 bit key

To get the raw key...
(lldb) memory read -s4 -fx -c32 $arg6
<< never get an understandble key, in here. >>
```

### COMPLETE
Using the CCCryptorCreate API spec, we can see which arguments to read.
```
CCCryptorCreate(CCOperation op, CCAlgorithm alg, CCOptions options,
         const void *key, size_t keyLength, const void *iv,
         CCCryptorRef *cryptorRef);
```
With a pre-defined key 16 byte key (128 bits), I can read it with the following debugger commands.
```
(lldb) b CCCryptorCreate
Breakpoint 1: where = libcommonCrypto.dylib`CCCryptorCreate, address = 0x000000010a6d51b7

(lldb) reg read $arg4
     rcx = 0x000060800003a590

(lldb) mem read 0x000060800003a590
0x60800003a590: 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41  AAAAAAAAAAAAAAAA

(lldb) memory read -s16 -fC $arg4
0x60800003a590: AAAAAAAAAAAAAAAA

(lldb) memory read -s16 -fx -c1 $arg4
0x60800003a590: 0x41414141414141414141414141414141
```
If you read the Initialization vector, lldb cannot display a lot of the characters.  That is because the code callinto into the API `SecRandomCopyBytes` which gives a lot of extended / non-Ascii characters.  You can still read it by forcing it to print in hex.
```
(lldb) mem read -s1 -fx $arg6
0x6080002668c0: 0x46 0xbc 0x72 0xc9 0x04 0xfb 0xb5 0xd6
```
### Useful references
```
https://richardwarrender.com/2016/04/encrypt-data-using-aes-and-256-bit-keys/
https://stackoverflow.com/questions/25754147/issue-using-cccrypt-commoncrypt-in-swift
```
## Challenge: Dancing with Threads
The idea of this challenge was to manipulate an iOS that used multiple background Threads to achieve a task.  For this, I wanted to re-order the Cars and Airplanes.  

![Dancing with Threads](debugger_challenge/readme_images/thread_chomper.png)


##### Attempt 1 - NSThread sleepForTimeInterval
As there were two background threads - each adding to a single array - I had to set a good breakpoint on a specific thread:
```
 (lldb) exp NSTimeInterval $blockThreadTimer = 0.5;
 (lldb) exp [NSThread sleepForTimeInterval:$blockThreadTimer];
  ```
![thread_chomper_attempt_1](debugger_challenge/readme_images/thread_chomper_attempt_1.png)

Something was wrong, with my first attempt.  What happened to the Airplanes?  Well, it was a bug in the code.  The line of code that blocked the main thread from returning from the `Thread Chomper` code only waited for a single background thread.   After adding:
```
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
```
##### Bypass steps
Breakpoints are better when set to a specific Thread.  Type the following into your debugger:
```
breakpoint set after one of the dispatch_async calls
breakpoint set  --file thread_chomper.m --line 34 thread 5
(lldb) expression
NSTimeInterval $blockThreadTimer = 2;
[NSThread sleepForTimeInterval:$blockThreadTimer];
// ENTER to finish expression
```
### COMPLETE
![thread_chomp_complete](debugger_challenge/readme_images/thread_chomper_complete.png)

##### Attempt 2 - A trick on Release apps
I was not satisfied with attempt 1.  It was only available on debug builds, where you could set simple `breakpoints`.  Attempt 2 looked to abuse Apple's `Grand Central Dispatch` _Quality of Service_ level that was set when coding " I want a background thread, please ".
```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
```
## Challenge: Certificate Pinning bypass ( with Frida )
Do I trust this server, before establishing a connection to this server?

That question is what `Certificate Pinning` adds to a mobile app.  It derives the answer by comparing Public Keys it has stored locally against Public Keys sent by the Server during a secured network setup.  

Hardened iOS app's often ignore the default `iOS Truststore` and add their own, smaller list of Root and Intermediary Certificate Authorities. This smaller list was called a `pinlist`.  

Why ignore the `iOS Truststore`?  It contains a lot of Certificate Authorities.  Refer to https://en.wikipedia.org/wiki/DigiNotar if you want details of why this is a bad thing.  More relevant for this Challenge, a user could add an all powerful `Self-Signed Certificate` via the Settings app on iOS. This would be "trusted" by iOS.

This challenge was written to show how to get around checks performed when sending a network request with Apple's `NSURLSession` class.

![secTrustHook](debugger_challenge/readme_images/defaultNSURLSession.png)

If you send traffic with `NSURLSession` and it was `https` [ the default since iOS 9 ] the `NSURLSessionDelegate` would invoke the following method:

```
func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
```

This was a great place for a developer to add `Cert Pinning` checks.  If an app is `Pinning` against the `iOS Truststore` you would see code like this:

```
guard let trust: SecTrust = challenge.protectionSpace.serverTrust else {
    return
}
var secResult = SecTrustResultType.invalid
var osStatus = SecTrustEvaluate(trust, &secResult)
```


If the app code could not verify the `Certificate Chain` the `secResult` would be set to negative value.  Afterwards, the app would probably call `completionHandler(.cancelAuthenticationChallenge, nil)` to cancel the attempted TLS connection.

##### Attempt 1 - Frida bypass for iOS Truststore pinning
Using `Frida` I used a script that would write over the `secResult` variable.  This was written to with this call `SecTrustEvaluate(trust, &secResult)`.  I would effectively be changing a `DENY` to a `PROCEED`.

```
const moduleName = 'Security';
const functionName = 'SecTrustEvaluate';
const SecTrustEvaluatePtr = Module.findExportByName(moduleName, functionName);

try {
    if (SecTrustEvaluatePtr == null) {
        throw '[*] %s not found', moduleName, functionName;
    }
    console.log('[*] Script loaded. ' + moduleName + '.' + functionName + '\tpointer: '+ SecTrustEvaluatePtr);

    Interceptor.replace(SecTrustEvaluatePtr,new NativeCallback(function(trust,result) {

        console.log('[*]SecTrustEvaluate called');
        console.log('\tDefault SecTrustResultType: ', Memory.readU32(result));
        Memory.writeU32(result,1);
        console.log('\tnew SecTrustResultType: ', Memory.readU32(result));
        return 0;   // Return errSecSuccess to OSStatus call
    } ,'int',['pointer','pointer']));
}
catch(err){
    console.log('[!] Exception: ' + err.message);
}
```

Success!
```
[*]SecTrustEvaluate called
	Default SecTrustResultType:  3
	new SecTrustResultType:  1
[*]SecTrustEvaluate called
	Default SecTrustResultType:  0
	new SecTrustResultType:  1
```
![secTrustHook](debugger_challenge/readme_images/bypassedNSURLSession.png)

## Challenge: Certificate Pinning bypass ( with Method Swizzle )
The Frida bypass worked well for trivial `iOS Truststore` pinning. But what happened if the app checked a locally held list of Public Keys ( the `pinlist` ) against the Public Keys it received during the client-server `TLS` setup Z?

I liked this guy's example code:
https://www.bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/
```
// Public key pinning
let serverPublicKey = SecCertificateCopyPublicKey(serverCertificate)
let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
let keyHash = sha256(data: serverPublicKeyData as Data)
if (keyHash == pinnedPublicKeyHash) {
    // Success! This is our server
    completionHandler(.useCredential, URLCredential(trust:serverTrust))
    return
}
```
I could use `Frida trace` to get me so far. I could also `statically patch` out the code. But the latter is hard and takes a lot of analysis.  How about I `Method Swizzle` to avoid this line of code?
```
completionHandler(.cancelAuthenticationChallenge, nil)
```

I wrote the following `Method Swizzle` to ignore all checks and proceed with the TLS setup?
```
- (void)YDHappyChallenge:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{

    NSLog(@"🍭NSURLSession on: %@", [[challenge protectionSpace] host]);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
}
```
### COMPLETE
The swizzle was a lot more effective.   The only trick was to ensure that the Swizzle inherited from `NSObject` instead of `NSURLSession`.

![secTrustHook](debugger_challenge/readme_images/secTrustEvalulateHook.png)

Not all Cert Pinning checks were bypassed using these methods.
