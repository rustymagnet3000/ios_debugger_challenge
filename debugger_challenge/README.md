#Debugger Challenge
###Goal
This app was written for **lldb** practice.   The app has a real and a fake debugger check API call.  Sysctl is the Apple recommended way to check whether a debugger is attached to the running process.    Refer to: [https://developer.apple.com/library/archive/qa/qa1361/\_index.html]  Inside of this app, the fake sysctl function is called instead of the real sysctl function.  More interestingly,  how is easy is it to perform the same attack using a jailbroken iOS device with a Release App where debug names, line numbers, file names have been stripped from the app?
###Setup lldb
#####Mac - setup port listeners
`iproxy 6666 6666`       (for lldb over USB access) `iproxy 2222 22`        (for SSH over USB access)
#####Mac - SSH onto jailbroken device
`ssh -p 2222 root@localhost` `ps -ax | grep -i my_app`  -> get your process ID `debugserver localhost:6666 -a my_app`
#####Mac - start lldb
`lldb` `process connect connect://localhost:6666` `(lldb) help methods.`  smoke test.
### Use case 1: Build app with in Debug mode
'' breakpoint set -p "return" -f hook_sysctl.c
'' breakpoint modify --auto-continue 1
'' breakpoint command add 1
> '' po fake_result
> '' script print "hello”
> '' DONE
'' continue
### LLDB References
######My inspiration for anything lldb
https://github.com/DerekSelander/LLDB
######lldb cheatsheet
https://www.nesono.com/sites/default/files/lldb%20cheat%20sheet.pdf
######some lldb commands
https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa
######great lldb overview
https://www.bignerdranch.com/blog/xcode-breakpoint-wizardry/
######more lldb info
https://www.objc.io/issues/19-debugging/lldb-debugging/
###ptrace References
There were tonnes of articles on ptrace's wide API and a surprisingly large amount on using ptrace as a defence mechanism for iOS apps.
######useful debugger blogs
https://www.unvanquished.net/\~modi/code/include/x86\_64-linux-gnu/sys/ptrace.h.html http://www.vantagepoint.sg/blog/89-more-android-anti-debugging-fun
######ptrace enum values
http://www.secretmango.com/jimb/Whitepapers/ptrace/ptrace.html
######anti-debug code samples
https://gist.github.com/joswr1ght/fb8c9f4f3f9a2feebf7f https://www.theiphonewiki.com/wiki/Bugging\_Debuggers
###Background
I started with grand goals for this app.  It evolved into learning the differences of breakpoint placement and breakpoint reactions in Debug and Release iOS builds.  
