#! /bin/bash

# A stupid script to set the cpu governor


for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor ; do
	echo performance | sudo tee $CPU;
done
