# Debugger Challenge
  The app has a real and a fake debugger check API call.  Sysctl is the Apple recommended way to check whether a debugger is attached to the running process.    Refer to: https://developer.apple.com/library/archive/qa/qa1361/index.html  

Inside of this app, the fake sysctl function is called instead of the real sysctl function.

**Challenge:** with `lldb` alone, can you perform the same attack using a jailbroken iOS device with a app that was built in "Release" mode?  Release mode = no debug symbols, line numbers, file names, etc.  All have been stripped from the app.

### Setup lldb

##### Mac - setup port listeners
`iproxy 6666 6666`       (for lldb over USB access) 

`iproxy 2222 22`        (for SSH over USB access)
##### Mac - SSH onto jailbroken device
`ssh -p 2222 root@localhost` 

`ps -ax | grep -i my_app`  -> get your process ID 

`debugserver localhost:6666 -a my_app`
##### Mac - start lldb
`lldb` 

`process connect connect://localhost:6666` 

`(lldb) help methods.`  smoke test.
### DEBUG build - Add each lldb to a script
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
