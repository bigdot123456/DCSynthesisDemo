# This file has been edited to keep it simple

printvar target_library
printvar link_library
alias
check_library
check_tlu_plus_files

# The following command usages are equivalents
########################################
# read_file -format verilog ./rtl/TOP.v
read_verilog ./rtl/TOP.v
########################################

current_design TOP
link
write_file -hierarchy -f ddc -out unmapped/TOP.ddc
list_designs
list_libs
source -verbose TOP.con
compile_ultra
report_constraint -all
report_timing
report_area
write_file -hierarchy -format ddc -output ./mapped/TOP.ddc
write_icc2_files -force -output ./mapped/TOP_icc2
remove_design -all
