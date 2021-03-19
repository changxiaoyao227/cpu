iverilog -o "openmips_test.vvp" openmips_min_sopc_tb.v defines.v openmips_min_sopc.v openmips.v pc_reg.v regfile.v mem.v mem_wb.v inst_rom.v if_id.v id.v id_ex.v ex.v ex_mem.v
vvp -n "openmips_test.vvp"
gtkwave "openmips_test.vcd"