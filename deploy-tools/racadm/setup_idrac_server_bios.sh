#!/bin/bash

setup_idrac_env_vars(){

   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue delete --all
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.BiosBootSettings.BootMode Bios
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.BiosBootSettings.BootSeqRetry Disabled
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.IntegratedDevices.InternalUsb Off
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.IntegratedDevices.SriovGlobalEnable Enabled
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.SysProfileSettings.SysProfile PerfOptimized
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.SysSecurity.AcPwrRcvry On
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.SysSecurity.AcPwrRcvryDelay Random
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set System.Power.RedundancyPolicy 1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set System.Power.Hotspare.Enable Disabled
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set iDRAC.IPMILan.Enable Enabled
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set LifeCycleController.LCAttributes.LifecycleControllerState Enabled
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.1.LegacyBootProto PXE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.2.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.3.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.4.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.5.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.6.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.7.LegacyBootProto NONE
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set NIC.NICConfig.8.LegacyBootProto NONE

   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create BIOS.Setup.1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Integrated.1-1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Integrated.1-2-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Integrated.1-3-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Integrated.1-4-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Slot.3-1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Slot.3-2-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Slot.6-1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create NIC.Slot.6-2-1 

   # Restarting the server
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn serveraction hardreset
}

setup_bootseq(){
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue delete --all
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn set BIOS.biosbootsettings.BootSeq NIC.Integrated.1-1-1,HardDisk.List.1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn jobqueue create BIOS.Setup.1-1
   racadm -r $1 -u $iDRAC_USER -p $iDRAC_PASSWORD --nocertwarn serveraction hardreset
}

setup_bios(){
   for idrac_ip_addr in "$@"
   do
      echo "=== Setup Bios for $idrac_ip_addr ==="
      setup_idrac_env_vars $idrac_ip_addr
      echo "waiting 5 minutes before setting up boot sequence"
      sleep 300
      setup_bootseq $idrac_ip_addr
      echo "=== End ==="
   done
}

. idrac_server_cred.sh
setup_bios 1.2.3.4

