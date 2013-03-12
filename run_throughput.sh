#!/bin/bash

read -p "Enter the max number of cores: " NUM_CORES

duration=1000
buckets="512 64 32 16 8";
rw="0.1'0.9 0.2'0.8 0.3'0.7";

fill_rate=0.5;
payload_size="64 1024";
num_elements="24 96";

executables=$(ls throughput_*);
cores=$(seq 1 1 $NUM_CORES);


if [ $(uname -n) = "lpd48core" ];
then
    platform="opteron";
elif [ $(uname -n) = "diassrv8" ];
then
    platform="xeon";
elif [ $(uname -n) = "smal1.sics.se" ];
then
    platform="tilepro";
elif [ $(uname -n) = "parsasrv1.epfl.ch" ];
then
    platform="tilera"
    run=run;
elif [ $(uname -n) = "maglite" ];
then
    platform="niagara"
fi


for bu in $buckets
do
    for ne in $num_elements
    do
	num_elems=$(($ne*$bu));

	for ps in $payload_size
	do
	    for r in $rw
	    do 
		u=$(echo $r | cut -d"'" -f1);
		g=$(echo $r | cut -d"'" -f2);
		echo "#buckets: $bu / update: $u / get: $g";

		out_dat="data/throughput."$platform".b"$bu"_e"$num_elems"_ps"$ps"_u"$u"_diff_locks.dat"

		printf "#  " | tee $out_dat;
		for f in $(ls throughput_*)
		do
		    prim=$(echo $f | cut -d'_' -f2);
		    printf "%-11s" $prim | tee -a  $out_dat;
		done;
		echo "" | tee -a  $out_dat;

		for c in $cores
		do
		    printf "%-3u" $c | tee -a $out_dat;
		    for ex in $executables
		    do
			p="$bu $c $num_elems $fill_rate $ps $duration $u $g";
			./$run ./$ex $p | awk '// { printf "%-11d", $2 }' | tee -a  $out_dat;
		    done;
		    echo "" | tee -a  $out_dat;
		done;
	    done;
	done;
    done;
done;