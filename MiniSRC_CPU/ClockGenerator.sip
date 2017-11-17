set_global_assignment -entity "ClockGenerator" -library "lib_ClockGenerator" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "ClockGenerator" -library "lib_ClockGenerator" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "ClockGenerator" -library "lib_ClockGenerator" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ClockGenerator" -name SPD_FILE [file join $::quartus(sip_path) "ClockGenerator.spd"]

set_global_assignment -library "lib_ClockGenerator" -name MISC_FILE [file join $::quartus(sip_path) "ClockGenerator_sim/ClockGenerator.vho"]
