import lldb
import shlex
import optparse

def breakAfterRegex(debugger, command, result, internal_dict):
    '''Creates a regular expression breakpoint and adds it.
    Once the breakpoint is hit, control will step out of the current
    function and print the return value. Useful for stopping on
    getter/accessor/initialization methods
    '''
    print("[+] attempting to place breakpoint")
    target = debugger.GetSelectedTarget()
    breakpoint = target.BreakpointCreateByRegex(command)
    if not breakpoint.IsValid() or breakpoint.num_locations == 0:
        result.AppendWarning(
            "[+] breakpoint not valid or hasn't found any hits")
    else:
        result.AppendMessage("{}".format(breakpoint))
        breakpoint.SetScriptCallbackFunction("lldb_python.breakpointHandler")

def breakpointHandler(frame, bp_loc, dict):
    '''function called when the breakpoint gets triggered'''
    thread = frame.GetThread()
    process = thread.GetProcess()
    debugger = process.GetTarget().GetDebugger()

    function_name = frame.GetFunctionName()
    debugger.SetAsync(False)
    thread.StepOut()
    output = evaluateReturnedObject(debugger, thread, function_name)
    if output is not None:
        print(output)
    return False

def evaluateReturnedObject(debugger, thread, function_name):
    '''Grabs the reference from the return register
    and returns a string from the evaluated value. TODO ObjC only
    '''
    res = lldb.SBCommandReturnObject()
    interpreter = debugger.GetCommandInterpreter()
    target = debugger.GetSelectedTarget()
    frame = thread.GetSelectedFrame()
    parent_function_name = frame.GetFunctionName()

    expression = 'expression -lobjc -O -- {}'.format(
        getRegisterString(target))
    interpreter.HandleCommand(expression, res)

    if res.HasResult():
        output = '{}\nbreakpoint: '\
            '{}\nobject: {}\nstopped: {}'.format(
                '*' * 80,
                function_name,
                res.GetOutput().replace('\n', ''),
                parent_function_name)
        return output
    else:
        return None

def getRegisterString(target):
    '''Gets the return register as a string for lldb
    based upon the hardware
    '''
    triple_name = target.GetTriple()
    if 'x86_64' in triple_name:
        return '$rax'
    elif 'i386' in triple_name:
        return '$eax'
    elif 'arm64' in triple_name:
        return '$x0'
    elif 'arm' in triple_name:
        return '$r0'
    raise Exception('Unknown hardware. Womp womp')

def generateOptionParser():
    usage = "usage: %prog [options] breakpoint_query"
    parser = optparse.OptionParser(usage=usage, prog="bar")

    parser.add_option("-n", "--non_regex",
              action="store_true",
              default=False,
              dest="non_regex",
              help="Create a regex breakpoint based upon searching for source code")

    parser.add_option("-m", "--module",
              action="store",
              default=None,
              dest="module",
              help="Filter a breakpoint by only searching within a specified Module")

    parser.add_option("-c", "--condition",
              action="store",
              default=None,
              dest="condition",
              help="Only stop if the expression matches True. Can reference retrun value through 'obj'. Obj-C only")
    return parser

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
    debugger.HandleCommand('command script add -f lldb_python.breakAfterRegex bar')
    debugger.HandleCommand('command script add -f lldb_python.print_world hello')
    debugger.HandleCommand('command script add -f lldb_python.first_pdb_command hello_pdb')
    debugger.HandleCommand('command script add -f lldb_python.print_frame print_frame')
    debugger.HandleCommand('command script add -h "Returns the bundle ID of the app." -f lldb_python.GetBundleIdentifier bundle_id')
    print "[+] Rusty's commands successfully added"
