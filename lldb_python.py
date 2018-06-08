import lldb

def first_pdb_command(debugger, command, result, internal_dict):
    import pdb; pdb.set_trace()
    print("hello pdb")

def GetBundleIdentifier(debugger, command, result, internal_dict):
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    mainThread = process.GetThreadAtIndex(0)
    currentFrame = mainThread.GetSelectedFrame()

    bundleIdentifier = currentFrame.EvaluateExpression("(NSString *)[[NSBundle mainBundle] bundleIdentifier]").GetObjectDescription()

    result.AppendMessage(bundleIdentifier)

def print_world(debugger, command, result, internal_dict):
    ci = debugger.GetCommandInterpreter()
    res = lldb.SBCommandReturnObject()
    ci.HandleCommand('script print "world war 2"', res)


def print_frame(debugger, command, result, internal_dict):
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetSelectedThread()

    for frame in thread:
            print >>result, str(frame)

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f lldb_python.print_world hello')
    debugger.HandleCommand('command script add -f lldb_python.first_pdb_command hello_pdb')
    debugger.HandleCommand('command script add -f lldb_python.print_frame print_frame')
    debugger.HandleCommand('command script add -h "Returns the bundle ID of the app." -f lldb_python.GetBundleIdentifier bundle_id')
    print "[+] Rusty's commands successfully added"
