## Run Script

read_verilog MY_DESIGN.v
link

source scripts/MY_DESIGN.con

# If errors/warnings are reported, re-run with -echo option to identify problem command(s):
# source -echo scripts/MY_DESIGN.con

# If needed, source the solution's constraints file instead:
#source .solutions/MY_DESIGN.con 

report_port -verbose

write_script -out scripts/MY_DESIGN.wscr

write_file -format ddc -hier -out unmapped/MY_DESIGN.ddc
exit
