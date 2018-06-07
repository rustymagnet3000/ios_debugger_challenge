# README Debugger Challenge
### Goal
I started with grand goals for this app.  It reduced to a simpler question:  

With Debug and Release iOS builds, write the `lldb` commands to assess whether the Breakpoints work in a similiar fashion on a jailbroken iOS device OR whether I need new symbolic breakpoints?

At the moment, this app has a real and a fake sysctl debugger check.  Both are loaded at run-time.  

My fake function is called instead of the real sysctl function.  


### With Debug Symbols enabled
`breakpoint set -p "return" -f hook_sysctl.c`
`breakpoint modify --auto-continue 1`
`breakpoint command add 1`
`> po fake_result`
`> script print "hello”`
`> DONE`

on the Mac...
`ios-deploy -b debugger_challenge.app/ -d`  Deploy with `ios-deploy` to a jailbroken device. 
`iproxy 6666 6666 `       (for lldb)
`iproxy 2222 22`        (for USB remote access)

SSH onto jailbroken device...
`ssh -p 2222 root@localhost`
`ps -ax | grep -i my_app`  -> get your process ID
`debugserver localhost:6666 -a my_app`

on the Mac...

`lldb`
`process connect connect://localhost:6666`
`(lldb) help methods. `  smoke test.


### LLDB References
https://github.com/DerekSelander/LLDB
https://www.nesono.com/sites/default/files/lldb%20cheat%20sheet.pdf
https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa
https://www.bignerdranch.com/blog/xcode-breakpoint-wizardry/
https://www.objc.io/issues/19-debugging/lldb-debugging/

### ptrace References
There were tonnes of articles on ptrace's wide API and a surprisingly large amount on using ptrace as a defence mechanism for iOS apps.
###### useful debugger blogs
https://www.unvanquished.net/~modi/code/include/x86_64-linux-gnu/sys/ptrace.h.html
http://www.vantagepoint.sg/blog/89-more-android-anti-debugging-fun
###### ptrace enum values
http://www.secretmango.com/jimb/Whitepapers/ptrace/ptrace.html
###### anti-debug code samples
https://gist.github.com/joswr1ght/fb8c9f4f3f9a2feebf7f
https://www.theiphonewiki.com/wiki/Bugging_Debuggers
