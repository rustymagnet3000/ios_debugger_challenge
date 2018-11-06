#include "debugger_exception_ports.h"

bool debugger_exception_ports(void) {

    exception_mask_t       exception_masks[EXC_TYPES_COUNT];
    mach_msg_type_number_t exception_count = 0;
    mach_port_t            exception_ports[EXC_TYPES_COUNT];
    exception_behavior_t   exception_behaviors[EXC_TYPES_COUNT];
    thread_state_flavor_t  exception_flavors[EXC_TYPES_COUNT];
    
    kern_return_t kr = task_get_exception_ports(
                                                mach_task_self(),
                                                EXC_MASK_BREAKPOINT,
                                                exception_masks,
                                                &exception_count,
                                                exception_ports,
                                                exception_behaviors,
                                                exception_flavors
                                                );
    if (kr == KERN_SUCCESS) {
        for (mach_msg_type_number_t i = 0; i < exception_count; i++) {
            if (MACH_PORT_VALID(exception_ports[i])) {
                printf("DEBUGGER DETECTED!\n");
                return 1;
            }
        }
    }
    else {
        printf("ERROR: task_get_exception_ports: %s\n", mach_error_string(kr));
        return 1;
    }
    
    printf("No debugger detected\n");
    
    return 0;
}
