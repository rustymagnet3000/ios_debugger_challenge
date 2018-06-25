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
![thread_list](/images/2018/06/thread_list_image_ptrace.png)
```
thread list                               // validate you are in the ptrace call
thread return 0                           // ptrace success sends a Int 0 response
```
![bypass](images/2018/06/bypass.png)

## Challenge 2: sysctl on iOS
Sysctl is the Apple recommended way to check whether a debugger is attached to the running process.    Refer to: https://developer.apple.com/library/archive/qa/qa1361/index.html  







### Print out the Hooked, fake result
```
breakpoint set -p "return" -f hook_sysctl.c
breakpoint modify --auto-continue 1
breakpoint command add 1
  po fake_result
  script print "hello”
  DONE
continue
```

### Pro tips
###### text file:
`command source <file_path>/lldb_script.txt`

###### Python script:
`command script import <file_path>/lldb_python.py`

###### The Python debugger:
Avoid using xCode if you are using
- Kill xcode
- Run iOS app in the simulator
- run a `ps -ax` to find your PID
- `$ lldb -p <PID>`

### LLDB References
###### Inspiration for anything lldb
https://github.com/DerekSelander/LLDB
###### Multi-line lldb commands
https://swifting.io/blog/2016/02/19/6-basic-lldb-tips/
###### lldb cheatsheet
https://www.nesono.com/sites/default/files/lldb%20cheat%20sheet.pdf
###### some lldb commands
https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa
###### great lldb overview
https://www.bignerdranch.com/blog/xcode-breakpoint-wizardry/
###### more lldb info
https://www.objc.io/issues/19-debugging/lldb-debugging/
### lldb | python References
https://lldb.llvm.org/python-reference.html
### ptrace References
Tonnes of articles on ptrace's wide API and a surprisingly large amount on using ptrace as a defence mechanism for iOS apps.
###### useful debugger blogs
https://www.unvanquished.net/\~modi/code/include/x86\_64-linux-gnu/sys/ptrace.h.html 
http://www.vantagepoint.sg/blog/89-more-android-anti-debugging-fun
###### ptrace enum values
http://www.secretmango.com/jimb/Whitepapers/ptrace/ptrace.html
###### anti-debug code samples
https://gist.github.com/joswr1ght/fb8c9f4f3f9a2feebf7f https://www.theiphonewiki.com/wiki/Bugging\_Debuggers
