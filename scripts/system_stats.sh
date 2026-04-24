#!/bin/bash

# static icon
cpu_icon=""
memory_icon=""

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if [ -z "$cpu_usage" ]; then
    cpu_usage=$(top -bn1 | grep "%Cpu" | awk '{print $2}')
fi

# Get memory usage percentage
memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

# Format to one decimal place
cpu_usage=$(printf "%.1f" "$cpu_usage")
memory_usage=$(printf "%.1f" "$memory_usage")

# cpu/memory usage mapped to state
cpu_state=$(echo "$cpu_usage" | awk '{
  t = $1 + 0
  if (t < 30)      print "cpu-idle"
  else if (t < 50) print "cpu-low"
  else if (t < 70) print "cpu-moderate"
  else if (t < 90) print "cpu-high"
  else             print "cpu-critical"
}')

memory_state=$(echo "$memory_usage" | awk '{
  t = $1 + 0
  if (t < 40)      print "mem-normal"
  else if (t < 60) print "mem-moderate"
  else if (t < 80) print "mem-high"
  else             print "mem-critical"
}')



# Gets cpu temp
temp_lvl=$(sensors coretemp-isa-0000 | grep "Package id 0" | awk '{print $4}' | tr -d '+°C')
temp_icon=$(echo "$temp_lvl" | awk '{
  t = $1 + 0
  if (t < 40)      print ""
  else if (t < 50) print ""
  else if (t < 60) print ""
  else if (t < 70) print ""
  else             print ""
}')

# Temp mapped to state 
temp_state=$(echo "$temp_lvl" | awk '{
  t = $1 + 0
  if (t < 40)      print "temp-cool"
  else if (t < 50) print "temp-normal"
  else if (t < 60) print "temp-warm"
  else if (t < 70) print "temp-hot"
  else             print "temp-crit"
}')


# Output valid JSON (dont question the arrangement, it MCSS, m for manual, trust me on this it look good in terminal ;)
echo "{ \"cpu_icon\"    :\"$cpu_icon\",     \"cpu_usage\"   :\"$cpu_usage\",    \"cpu_state\"   :\"$cpu_state\",
  \"memory_icon\" :\"$memory_icon\",     \"memory_usage\":\"$memory_usage\",   \"memory_state\":\"$memory_state\",
  \"temp_icon\"   :\"$temp_icon\",     \"temp_lvl\"    :\"$temp_lvl\",   \"temp_state\"  :\"$temp_state\"}"
