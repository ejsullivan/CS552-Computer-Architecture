Skipping final_memory.syn.v, seems like a file meant for synthesis
Skipping memory2c_align.syn.v, seems like a file meant for synthesis
Skipping memory2c.syn.v, seems like a file meant for synthesis
Skipping stallmem.syn.v, seems like a file meant for synthesis
Skipping final_memory.syn.v, seems like a file meant for synthesis
Skipping memory2c_align.syn.v, seems like a file meant for synthesis
Skipping memory2c.syn.v, seems like a file meant for synthesis
Skipping stallmem.syn.v, seems like a file meant for synthesis
-------------------------------------------------
Step: 1
Compiling the following verilog files: alu.v cache.v claAdder16.v claAdder1bit.v claAdder4bit.v claUnit4bit.v clkrst.v control_unit.v decode_unit.v dff.v execute_unit.v fetch_unit.v final_memory.v forwarding_unit.v four_bank_mem.v hazard_unit.v memc.v memory2c_align.v memory2c.v memory_unit.v mem_system_hier.v mem_system_perfbench.v mem_system_ref.v mem_system.v memv.v nand2.v nor2.v not1.v proc_hier_pbench.v proc_hier.v proc.v reg_EX_MEM.v reg_ID_EX.v reg_IF_ID.v register.v reg_MEM_WB.v rf_bypass.v rf.v shifter.v stallmem.v statereg.v writeback_unit.v xor2.v -addr mem0.addr mem_system_perfbench alu.v cache.v claAdder16.v claAdder1bit.v claAdder4bit.v claUnit4bit.v clkrst.v control_unit.v decode_unit.v dff.v execute_unit.v fetch_unit.v final_memory.v forwarding_unit.v four_bank_mem.v hazard_unit.v memc.v memory2c_align.v memory2c.v memory_unit.v mem_system_hier.v mem_system_perfbench.v mem_system_ref.v mem_system.v memv.v nand2.v nor2.v not1.v proc_hier_pbench.v proc_hier.v proc.v reg_EX_MEM.v reg_ID_EX.v reg_IF_ID.v register.v reg_MEM_WB.v rf_bypass.v rf.v shifter.v stallmem.v statereg.v writeback_unit.v xor2.v 
Top module: mem_system_perfbench
Compilation log in wsrun.log
Executing rm -rf __work dump.wlf dump.vcd diff.trace diff.ptrace archsim.trace archsim.ptrace verilogsim.trace verilogsim.ptrace
Executing vlib __work
Executing vlog +define+RANDSEED=3 -work __work alu.v cache.v claAdder16.v claAdder1bit.v claAdder4bit.v claUnit4bit.v clkrst.v control_unit.v decode_unit.v dff.v execute_unit.v fetch_unit.v final_memory.v forwarding_unit.v four_bank_mem.v hazard_unit.v memc.v memory2c_align.v memory2c.v memory_unit.v mem_system_hier.v mem_system_perfbench.v mem_system_ref.v mem_system.v memv.v nand2.v nor2.v not1.v proc_hier_pbench.v proc_hier.v proc.v reg_EX_MEM.v reg_ID_EX.v reg_IF_ID.v register.v reg_MEM_WB.v rf_bypass.v rf.v shifter.v stallmem.v statereg.v writeback_unit.v xor2.v -addr mem0.addr mem_system_perfbench alu.v cache.v claAdder16.v claAdder1bit.v claAdder4bit.v claUnit4bit.v clkrst.v control_unit.v decode_unit.v dff.v execute_unit.v fetch_unit.v final_memory.v forwarding_unit.v four_bank_mem.v hazard_unit.v memc.v memory2c_align.v memory2c.v memory_unit.v mem_system_hier.v mem_system_perfbench.v mem_system_ref.v mem_system.v memv.v nand2.v nor2.v not1.v proc_hier_pbench.v proc_hier.v proc.v reg_EX_MEM.v reg_ID_EX.v reg_IF_ID.v register.v reg_MEM_WB.v rf_bypass.v rf.v shifter.v stallmem.v statereg.v writeback_unit.v xor2.v
Model Technology ModelSim SE vlog 5.8b Compiler 2004.01 Jan 26 2004
** Error: (vlog-1902) Unrecognized option or option requires an argument: -addr.
Use the -help option for complete vlog usage.
-------------------------------------------------
Step: 2
Running Verilog simulation...details in wsrun.log
Reading /afs/cs.wisc.edu/s/mentor-2004/common/modeltech-5.8b/tcl/vsim/pref.tcl 

# 5.8b

# vsim +addr_trace_file_name=mem0.adr0 -lib __work -c mem_system_perfbench 
# ** Error: (vsim-3170) Could not find '__work.mem_system_perfbench'.
# Error loading design
Did not create a dump file...something went wrong
