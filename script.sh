#!/bin/bash

hops=$1
if [ -z "$1" ]
    then
        hops=10
fi

hops_track_limit=$hops-3

echo "Enter first 3 bytes of IP adress. End line with '.'"
read parameter

check_counter=2	

echo "Testing $parameter[2-253]. Max TTL = $hops. It might take some time."
{
    ip_arr=()
    for byte4 in {2..5}
    do	
        flag=false
        echo "Testing $parameter$byte4"
        while [ "$flag" == false ]; do	
            my_output=$(traceroute -n -m "$hops" 2>&1 $parameter$byte4 | tail -n "$check_counter" | head -n 1)
            if [[ $my_output != *"* * *"* &&  $my_output != *"traceroute"* ]]; then
                ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$my_output")"
                ip_arr+=( "$ip" )
                flag=true
                check_counter=2
            elif [[ $check_counter -gt $hops_track_limit ]]; then	
                flag=true
            else 
                ((check_counter+=1))
                flag=false	
            fi
        done
            
    done
    echo "Routers:"
    echo "${ip_arr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
    echo ""
}
