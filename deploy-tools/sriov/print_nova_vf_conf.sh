#!/bin/bash

NIC_DIR="/sys/class/net"
SRIOV_NUM=1
INTERFACES=(enp131s0f0 enp4s0f1)

declare SRIOVNET

for i in $( ls $NIC_DIR) ;
do
        if [ -d "${NIC_DIR}/$i/device" -a ! -L "${NIC_DIR}/$i/device/physfn" ]; then
                declare -a VF_PCI_BDF
                declare -a VF_INTERFACE
                k=0
                for j in $( ls "${NIC_DIR}/$i/device" ) ;
                do
                        if [[ "$j" == "virtfn"* ]]; then
                                VF_PCI=$( readlink "${NIC_DIR}/$i/device/$j" | cut -d '/' -f2 )
                                VF_PCI_BDF[$k]=$VF_PCI
                                #get the interface name for the VF at this PCI Address
                                for iface in $( ls $NIC_DIR );
                                do
                                        link_dir=$( readlink ${NIC_DIR}/$iface )
                                        if [[ "$link_dir" == *"$VF_PCI"* ]]; then
                                                VF_INTERFACE[$k]=$iface
                                        fi
                                done
                                ((k++))
                        fi
                done
                NUM_VFs=${#VF_PCI_BDF[@]}
                if [[ $NUM_VFs -gt 0 ]] && \
                   [[ $(echo ${INTERFACES[@]} | grep -o ${i} | wc -w) = 1 ]]; then

                        # Comment out if you are intending to print out the config
                        #echo $i" : sriovnet"${SRIOV_NUM}
                        SRIOVNET[$SRIOV_NUM]="sriovnet${SRIOV_NUM}:${i}"
 
                        for (( l = 0; l < $NUM_VFs; l++ )) ;
                        do
                           PCI_BDF=${VF_PCI_BDF[$l]}
                           INTERFACE=${VF_INTERFACE[$l]}

                           printf "{\"address\": \"${PCI_BDF}\", \"physical_network\": \"sriovnet${SRIOV_NUM}\", \"trusted\": \"true\"},"
                        done

                        unset VF_PCI_BDF
                        unset VF_INTERFACE
                        ((SRIOV_NUM++))
                fi
        fi
done

# Print out the interface and sriovnet mapping
echo ""
echo ""
printf "physical_device_mappings: "
for (( n = 0; n < $SRIOV_NUM; n++ )) ;
do
  printf ${SRIOVNET[$n]}"," 
done
echo ""
unset SRIOVNET
