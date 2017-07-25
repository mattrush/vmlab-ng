#!/bin/bash

# hypervisor_agent.sh, bourne again shell
# written by mrush 07.16.2017
# https://github.com/mattrush
# m@root.dance

##############
# options
##############

[[ $@ =~ '-d' ]] && {
  debug='echo'
  shift
}

##############
# variables
##############

api_version='v1'
api_ip='192.168.3.88'
agent_name='vmlab hypervisor agent'
type='hypervisor_server'
hypervisor_server_id=2

##############
# functions
##############

get_available_percent () { # input $1 as capacity, $2 as available
  [[ $2 == 0 ]] && echo '100.00' && return 0
  echo $( printf "%.2f\n" "$(c=$1; a=$2; echo $a/$c*100 |bc -l)" )
}

##############
# business
##############

# hostname
hostname="$(hostname)"

# cpu_capacity and cpu_use
cpu_capacity=$(lscpu |grep 'CPU MHz' |tr -d ' ' |cut -d : -f2)
cpu_use=$( /root/cpu.bin )

# ram_capacity and ram_use
ram_capacity=$(free -m |grep 'Mem:' |awk '{print $2}')
ram_available=$(free -m |grep 'buffers/cache' |awk '{print $3}')
ram_use=$(get_available_percent $ram_capacity $ram_available)

# disk_capacity and disk_used
disk_capacity=$(df -m |tr '\t' ' ' |tr -s ' ' |grep ' /$' |awk '{print $2}')
disk_available=$(df -m |tr '\t' ' ' |tr -s ' ' |grep ' /$' |awk '{print $3}')
disk_used=$(get_available_percent $disk_capacity $disk_available)

# post data to api
$debug curl -v -A "$agent_name" "http://$api_ip/api/${api_version}/" -H "X-Unit-Name: $type" -X PUT \
  --data "id=$hypervisor_server_id" \
  --data "cpu_capacity=$cpu_capacity" \
  --data "cpu_use=$cpu_use" \
  --data "ram_capacity=$ram_capacity" \
  --data "ram_use=$ram_use" \
  --data "disk_capacity=$disk_capacity" \
  --data "disk_used=$disk_used"
