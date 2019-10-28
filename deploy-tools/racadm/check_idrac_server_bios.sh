#!/bin/bash

get_idrac_env_vars(){
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.BiosBootSettings.BootMode
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.BiosBootSettings.BootSeqRetry 
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.IntegratedDevices.InternalUsb
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.IntegratedDevices.SriovGlobalEnable
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.SysProfileSettings.SysProfile
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.SysSecurity.AcPwrRcvry
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.SysSecurity.AcPwrRcvryDelay
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get System.Power.RedundancyPolicy
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get System.Power.Hotspare.Enable
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get iDRAC.IPMILan.Enable
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get LifeCycleController.LCAttributes.LifecycleControllerState
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get NIC.NICConfig.1.LegacyBootProto
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn get BIOS.biosbootsettings.BootSeq
}

get_disks_config(){
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn storage get pdisks
   echo "#"
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn storage get vdisks
   echo "#"
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn raid get pdisks -o
   echo "#"
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn raid get vdisks -o
}

check_bios(){
   for idrac_ip_addr in "$@"
   do
      echo "=== Bios Information for $idrac_ip_addr ==="
      get_idrac_env_vars $idrac_ip_addr
      echo "=== End ==="
   done
}

. idrac_server_cred.sh
check_bios 1.2.3.4 

