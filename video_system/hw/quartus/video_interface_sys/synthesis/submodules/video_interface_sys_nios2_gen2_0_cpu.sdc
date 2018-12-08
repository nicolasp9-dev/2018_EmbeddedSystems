# Legal Notice: (C)2018 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	video_interface_sys_nios2_gen2_0_cpu 	video_interface_sys_nios2_gen2_0_cpu:*
set 	video_interface_sys_nios2_gen2_0_cpu_oci 	video_interface_sys_nios2_gen2_0_cpu_nios2_oci:the_video_interface_sys_nios2_gen2_0_cpu_nios2_oci
set 	video_interface_sys_nios2_gen2_0_cpu_oci_break 	video_interface_sys_nios2_gen2_0_cpu_nios2_oci_break:the_video_interface_sys_nios2_gen2_0_cpu_nios2_oci_break
set 	video_interface_sys_nios2_gen2_0_cpu_ocimem 	video_interface_sys_nios2_gen2_0_cpu_nios2_ocimem:the_video_interface_sys_nios2_gen2_0_cpu_nios2_ocimem
set 	video_interface_sys_nios2_gen2_0_cpu_oci_debug 	video_interface_sys_nios2_gen2_0_cpu_nios2_oci_debug:the_video_interface_sys_nios2_gen2_0_cpu_nios2_oci_debug
set 	video_interface_sys_nios2_gen2_0_cpu_wrapper 	video_interface_sys_nios2_gen2_0_cpu_debug_slave_wrapper:the_video_interface_sys_nios2_gen2_0_cpu_debug_slave_wrapper
set 	video_interface_sys_nios2_gen2_0_cpu_jtag_tck 	video_interface_sys_nios2_gen2_0_cpu_debug_slave_tck:the_video_interface_sys_nios2_gen2_0_cpu_debug_slave_tck
set 	video_interface_sys_nios2_gen2_0_cpu_jtag_sysclk 	video_interface_sys_nios2_gen2_0_cpu_debug_slave_sysclk:the_video_interface_sys_nios2_gen2_0_cpu_debug_slave_sysclk
set 	video_interface_sys_nios2_gen2_0_cpu_oci_path 	 [format "%s|%s" $video_interface_sys_nios2_gen2_0_cpu $video_interface_sys_nios2_gen2_0_cpu_oci]
set 	video_interface_sys_nios2_gen2_0_cpu_oci_break_path 	 [format "%s|%s" $video_interface_sys_nios2_gen2_0_cpu_oci_path $video_interface_sys_nios2_gen2_0_cpu_oci_break]
set 	video_interface_sys_nios2_gen2_0_cpu_ocimem_path 	 [format "%s|%s" $video_interface_sys_nios2_gen2_0_cpu_oci_path $video_interface_sys_nios2_gen2_0_cpu_ocimem]
set 	video_interface_sys_nios2_gen2_0_cpu_oci_debug_path 	 [format "%s|%s" $video_interface_sys_nios2_gen2_0_cpu_oci_path $video_interface_sys_nios2_gen2_0_cpu_oci_debug]
set 	video_interface_sys_nios2_gen2_0_cpu_jtag_tck_path 	 [format "%s|%s|%s" $video_interface_sys_nios2_gen2_0_cpu_oci_path $video_interface_sys_nios2_gen2_0_cpu_wrapper $video_interface_sys_nios2_gen2_0_cpu_jtag_tck]
set 	video_interface_sys_nios2_gen2_0_cpu_jtag_sysclk_path 	 [format "%s|%s|%s" $video_interface_sys_nios2_gen2_0_cpu_oci_path $video_interface_sys_nios2_gen2_0_cpu_wrapper $video_interface_sys_nios2_gen2_0_cpu_jtag_sysclk]
set 	video_interface_sys_nios2_gen2_0_cpu_jtag_sr 	 [format "%s|*sr" $video_interface_sys_nios2_gen2_0_cpu_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_oci_break_path|break_readreg*] -to [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr*]
set_false_path -from [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_oci_debug_path|*resetlatch]     -to [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr[33]]
set_false_path -from [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_oci_debug_path|monitor_ready]  -to [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr[0]]
set_false_path -from [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_oci_debug_path|monitor_error]  -to [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr[34]]
set_false_path -from [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_ocimem_path|*MonDReg*] -to [get_keepers *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr*]
set_false_path -from *$video_interface_sys_nios2_gen2_0_cpu_jtag_sr*    -to *$video_interface_sys_nios2_gen2_0_cpu_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$video_interface_sys_nios2_gen2_0_cpu_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$video_interface_sys_nios2_gen2_0_cpu_oci_debug_path|monitor_go
