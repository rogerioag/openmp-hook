#!/bin/bash

hostname=`hostname`
echo "Retrieving hardware platform informations on $hostname"

mkdir ${hostname}

echo "Retrieving papi informations: " `papi_version`
papi_version > ${hostname}/papi-version-${hostname}.txt
papi_avail > ${hostname}/preset-events-${hostname}.txt
papi_native_avail > ${hostname}/native-events-${hostname}.txt
papi_native_avail --check > ${hostname}/native-events-${hostname}-02.txt
papi_native_avail --check --noqual > ${hostname}/native-events-${hostname}-03.txt
papi_component_avail > ${hostname}/components-events-${hostname}.txt

echo "Retrieving hardware informations."
sudo lshw -html > ${hostname}/hardware-info-${hostname}.html
sudo lshw -xml > ${hostname}/hardware-info-${hostname}.xml
sudo lshw -json > ${hostname}/hardware-info-${hostname}.json

cat /proc/cpuinfo > ${hostname}/cpuinfo-${hostname}.txt
cat /proc/meminfo > ${hostname}/meminfo-${hostname}.txt
#/usr/local/cuda/samples/1_Utilities/deviceQuery/deviceQuery > ${hostname}/gpuinfo-${hostname}.txt

# zip hardware_info_${hostname}.zip hardware_info_${hostname}.html cpuinfo.txt meminfo.txt gpuinfo.txt

# echo "Enviando para o dropbox."
# ~/dropbox/dropbox_uploader.sh upload hardware_info_${hostname}.zip
echo "End of $0".
