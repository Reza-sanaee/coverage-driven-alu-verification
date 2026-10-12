radix -hexadecimal -showbase

add wave -hex -group  	"in bus"	sim:/top/in_bus/*
add wave -hex -group  	"out bus"	sim:/top/out_bus/*
add wave -hex -group  	"dut signals"	sim:/top/dut/*


#############################################

configure wave -signalnamewidth 1

configure wave -griddelta 40
configure wave -gridoffset 0
configure wave -gridperiod 10

configure wave -timelineunits us
configure wave -namecolwidth 200
configure wave -valuecolwidth 50
configure wave -justifyvalue right
