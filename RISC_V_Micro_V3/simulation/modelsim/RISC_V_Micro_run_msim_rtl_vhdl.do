transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/rising_edge_detector.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Reg_File.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/PC.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/OutputLogic.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Mux_ToRegFile.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Mux.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Instruction_Mem.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Immediate_Generator.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/DataPath.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Data_Mem.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Control.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/Branch_Control.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/bcdTo7Seg.vhd}
vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/ALU_RV32.vhd}

vcom -93 -work work {D:/Development/VHDL/RISC_V_Micro/VHDL/DataPath_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  DataPath_tb

add wave *
view structure
view signals
run -all
