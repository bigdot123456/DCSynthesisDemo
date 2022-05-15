#####################################################
# Determine the # cores and threads on your machine #
#####################################################

# Determine how many cores are available:

echo
echo "Number of CPU cores:"
grep -m 1 'cpu cores' /proc/cpuinfo
echo


# Deteremine how many threads are available:

echo "Can have 1 or 2 threads per core."
echo "Number of threads:"
/usr/bin/nproc --all
echo
echo "If #threads > #cores you can use #threads for 'set_host_options -max_cores'"
echo
