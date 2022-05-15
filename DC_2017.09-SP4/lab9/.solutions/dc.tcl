## Run Script


read_verilog MY_DESIGN.v
link

source scripts/MY_DESIGN.con

# If errors/warnings are reported, re-run with -echo option to identify problem command(s):
# source -echo scripts/MY_DESIGN.con

# If needed, source the solution's constraints file instead:
#source .solutions/MY_DESIGN.con 

check_timing
report_clock
report_clock -skew
report_port -verbose


write_script -out scripts/MY_DESIGN.wscr

compile_ultra -scan -retime

report_constraint -all_violators
report_timing -trans -input -sig 6 -nets -to [get_ports out1] 
report_timing -trans -input -sig 6 -from [get_ports sel] -to [get_ports Cout]
report_timing -from [get_ports Cin*] -to [get_ports Cout]


write_file -format ddc -hier -out mapped/MY_DESIGN.ddc

exit
