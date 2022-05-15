set_svf STOTO.svf

#################################################
# Read, link and check the design called STOTO  #
#################################################

read_verilog STOTO.v

# The RTL design includes a "trap" to make sure you remeber to set the correct top-level 
# design, STOTO, as the current_design. If you forget to do so, the current_design will
# be an "empty" design called "WRONG_DESIGN".
#
current_design STOTO

link
check_design

#################################################
# Apply and check the timing constraints        #
#################################################

source STOTO.con
check_timing

#################################################
# Apply the final physical constraints          #
#################################################

source STOTO.pcon

###########################################
# Address Design Specification #1 and #2  #
###########################################

# Determine clock name and period to apply 10% critical range to clock group
report_clock

# Apply compile focus on the reg-to-reg paths while ensuring 
# that the I/O paths are also compiled, but with less emphasis
group_path -name clk -critical 0.21 -weight 5
group_path -name INPUTS -from [all_inputs] 
group_path -name OUTPUTS -to [all_outputs]
group_path -name COMBO -from [all_inputs] -to [all_outputs]

###########################################
# Address Design Specification #3 - #7    #
###########################################

# Maintain the INPUT block hierarchy for verification purpose.
set_ungroup [get_designs "INPUT"] false

# Retime the PIPELINE block 
set_optimize_registers true -design PIPELINE

# While retiming the PIPELINE block, make sure its output registers are 
# not moved
set_dont_retime [get_cells I_MIDDLE/I_PIPELINE/z2_reg*] true

# Do NOT retime the DONT_PIPELINE block as per spec
set_dont_retime [get_cells I_MIDDLE/I_DONT_PIPELINE] true

# Prioritize fixing of setup timing (delay) violations over DRC violations
set_cost_priority -delay

############################################################
# Verify that the floorplan constraints have been applied, #
# and Design Specs #1-7 have been properly addressed       #
############################################################

# Verify that the floorplan's physical constraints were applied:
report_physical_constraints

# Verify that the corect path groups were defined. If you have incorrectly specifed 
# a path or group name, redirect the path to the "default" group
# using "-default" instead of "-name XYZ", then re-apply the correct group_path command,
#
report_path_group

# Verify that the "ungroup" attribute was correctly applied to the design.
# Expect this command to return "false".
# If you get message "Attribute 'ungroup' does not exist on design .." then apply the
# set_ungroup command. If applied to the wrong design, remove with 
# remove_attribute [get_designs "ABC"] ungroup. 
# Note: Do not use "set_ungroup .. true" as this will force the designs to be ungrouped 
# during compile, no matter what, instead of allowing auto-ungroup to make a possibly 
# smarter decision.
#
get_attribute [get_designs "INPUT"] ungroup

# Verify that the "optimize_registers" attribute was correctly applied to the design.
# Expect this command to return "true".
# If you get a message that this attribute does not exist on PIPELINE, 
# then apply the appropriate "set_optimize_registers" command:
#
get_attribute [get_designs "PIPELINE"] optimize_registers

# Check that the dont_retime attribute is correctly applied
get_attribute [get_cells I_MIDDLE/I_PIPELINE/z2_reg*] dont_retime
get_attribute [get_cells I_MIDDLE/I_DONT_PIPELINE] dont_retime

# Verify that the default cost priority was changed to prioritize 
# setup timing over DRCs. 
# Expect the command to return "max_delay".
# If you get a message that this attribute does not exist on STOTO, 
# then apply the appropriate "set_cost_priority" command:
#
get_attribute [get_designs "STOTO"] cost_priority  

###########################################
# Continue following the lab instructions #
###########################################

# Save the un-compiled design
#
write_file -f ddc -hier -out unmapped/STOTO.ddc

# Based on the available resources (Number of CPU cores and licenses)
# specify and report multi core optimization setting
#
set_host_options -max_cores 4

report_host_options

###########################################
# Address Design Specification #8 - #9    #
###########################################

# Compile the design. 
# Since the logic position of registers may be modified to improve timing, 
# enable adaptive retiming (-retime) to retime the non-pipelined parts of the design;
# Since the design is expected to have scan-chains inserted, enable test-ready synthesis (-scan).
#
compile_ultra -retime -scan 

###########################################
# Continue following the lab instructions #
###########################################

# Examine the number and names of License Features used
list_licenses

# Find out what blocks have been auto-ungrouped: MIDDLE, OUTPUT, DONT_PIPELINE, 
# GLUE, ARITH and RANDOM; The only remaining designs in the hierarchy should be STOTO, PIPELINE, 
# and INPUT. If you get different results, verify that you correctly
# specified the "set_ungroup" attribute.
#
report_hierarchy -noleaf

# Generate a constraints report (remember to include "-all").
# Expect to see max-delay violations in the INPUTS group.
# There is also a DRC violation in the I_IN instance,
# which is the INPUTS sub-design.
#
# We should not be too concerned about these max-dealy violations because
# the Design Specification warned us that the I/O constraints are "estimates and have 
# been conservatively constrained".
#
# You SHOULD NOT see any max-delay violations in the "clk" group!
#
redirect -tee -file rc_compile_ultra.rpt {report_constraint -all}

# Generate a timing report:
# Notice that cell names, by default, retain their hierarchical name even though 
# their parent block(s) may have been ungrouped (e.g. I_MIDDLE/I_DONT_PIPELINE/I_RANDOM/int1_reg*).
#
redirect -tee -file rt_compile_ultra.rpt {report_timing}


# Save the design
#
write_file -f ddc -hier -out mapped/STOTO.ddc


#  Stop recording SVF changes
#
set_svf -off

# Verify that register retiming moved registers in the PIPELINE design:
# Since this command returns specific cell names this proves that registers retiming did
# in fact move some registers. Since every single cell name starts with "I_MIDDLE/I_PIPELINE"
# you can conclude that only PIPELINE registers were moved. Lastly, since all the register 
# cells end with "S1" we can conclude that only z1_reg*, the first stage registers, were moved.
# The latter can be explicitly confirmed with an additional check (below). 
#
get_cells -hier *r_REG*_S*

# Verify that the cell name I_MIDDLE/I_PIPELINE corresponds to the 
# design or "reference" name PIPELINE:
#
report_cell -nosplit I_MIDDLE/I_PIPELINE

# Confirm that the second stage "z2_reg" registers have not been moved,
# since their cell names have not been changed:
#
get_cells -hier *z2_reg*

# Verify that registers in INPUTS were moved by adaptive retiming:
get_cells -hier R_*

# Verify that the instance name I_IN corresponds to the 
# design or "reference" name INPUT:
#
report_cell -nosplit I_IN

# Verify that not ALL the registers in INPUT were affected or moved by adaptive retiming:
#
get_cells  I_IN/*_reg* 

# Report the "physical constraints", which were applied from ./scripts/STOTO.pcon:
report_physical_constraints

exit
