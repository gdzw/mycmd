#!/bin/bash

###############################################################
# History: 2018/08/07 zhuwei First release
###############################################################

td_str=''
th_str=''

NAME_VAL_LEN=12
name_val () {
   printf "%+*s | %s\n" "${NAME_VAL_LEN}" "$1" "$2"
}

get_virtual () {
   local file="/var/log/dmesg"
   if grep -qi -e "vmware" -e "vmxnet" -e 'paravirtualized kernel on vmi' "${file}"; then
      echo "VMWare";
   elif grep -qi -e 'paravirtualized kernel on xen' -e 'Xen virtual console' "${file}"; then
      echo "Xen";
   elif grep -qi "qemu" "${file}"; then
      echo "QEmu";
   elif grep -qi 'paravirtualized kernel on KVM' "${file}"; then
      echo "KVM";
   elif grep -q "VBOX" "${file}"; then
      echo "VirtualBox";
   elif grep -qi 'hd.: Virtual .., ATA.*drive' "${file}"; then
      echo "Microsoft VirtualPC";
   else
      echo "Physical Machine"
   fi
}

get_physics(){

    name_val "Date" "`date -u +'%F %T UTC'` (local TZ: `date +'%Z %z'`)"
    name_val "Hostname" "`uname -n`"
    name_val "Uptime" "`uptime`"    
    name_val "System" "`dmidecode -s "system-manufacturer" "system-product-name" "system-version" "chassis-type"`"
    name_val "Service_num" "`dmidecode -s "system-serial-number"`"
    name_val "Platform" "`uname -s`"
    name_val "Release" "`cat /etc/{oracle,redhat,SuSE,centos}-release 2>/dev/null|sort -ru|head -n1`"
    name_val "Kernel" "`uname -r`"
    name_val "Architecture" "CPU=`lscpu|grep Architecture|awk -F: '{print $2}'|sed 's/^[[:space:]]*//g'`;OS=`getconf LONG_BIT`-bit"
    name_val "Threading" "`getconf GNU_LIBPTHREAD_VERSION`"
    name_val "SELinux" "`getenforce`"
    name_val "Virtualized" "`get_virtual`"
}

get_cpuinfo () {
   file="/proc/cpuinfo"
   virtual=`grep -c ^processor "${file}"`
   physical=`grep 'physical id' "${file}" | sort -u | wc -l`
   cores=`grep 'cpu cores' "${file}" | head -n 1 | cut -d: -f2`
   model=`grep "model name" "${file}"|sort -u|awk -F: '{print $2}'`
   speed=`grep -i "cpu MHz" "${file}"|sort -u|awk -F: '{print $2}'`
   cache=`grep -i "cache size" "${file}"|sort -u|awk -F: '{print $2}'`
   SysCPUIdle=`vmstat | sed -n '$ p' | awk '{print $15}'`

   [ "${physical}" = "0" ] && physical="${virtual}"
   [ -z "${cores}" ] && cores=0

   cores=$((${cores} * ${physical}));
   htt=""
   if [ ${cores} -gt 0 -a $cores -lt $virtual ]; then htt=yes; else htt=no; fi

   name_val "Processors" "physical = ${physical}, cores = ${cores}, virtual = ${virtual}, hyperthreading = ${htt}"
   name_val "Models" "${physical}*${model}"
   name_val "Speeds" "${virtual}*${speed}"
   name_val "Caches" "${virtual}*${cache}"
   name_val "CPUIdle(%)" "${SysCPUIdle}%"
}

get_meminfo(){
   echo "Locator   |Size     |Speed       |Form Factor  | Type      |    Type Detail"
   dmidecode| grep -v "Memory Device Mapped Address"|grep -A12 -w "Memory Device" \
   |egrep "Locator:|Size:|Speed:|Form Factor:|Type:|Type Detail:" \
   |awk -F: '/Size|Type|Form.Factor|Type.Detail|^[\t ]+Locator/{printf("|%s", $2)}/^[\t ]+Speed/{print "|" $2}' \
   |grep -v "No Module Installed" \
   |awk -F"|" '{print $4,"|", $2,"|", $7,"|", $3,"|", $5,"|", $6}'
   free -glht
   memtotal=`vmstat -s | head -1 | awk '{print $1}'`
   avm=`vmstat -s| sed -n '3p' | awk '{print $1}'`
   name_val "Mem_used_rate(%)" "`echo "100*${avm}/${memtotal}" | bc`%"
  
}

get_diskinfo(){
   echo "Filesystem        |Type   |Size |  Used  | Avail | Use%  | Mounted on | Opts" 
   df -ThP|grep -v tmpfs|sed '1d'|sort >/tmp/tmpdf1_`date +%y%m%d`.txt
   mount -l|awk '{print $1,$6}'|grep ^/|sort >/tmp/tmpdf2_`date +%y%m%d`.txt
   join /tmp/tmpdf1_`date +%y%m%d`.txt /tmp/tmpdf2_`date +%y%m%d`.txt\
   |awk '{print $1,"|", $2,"|", $3,"|", $4,"|", $5,"|", $6,"|", $7,"|", $8}' 
   lsblk
   for disk in `ls -l /sys/block|awk '{print $9}'|sed '/^$/d'|grep -v fd`
   do
      echo "${disk}" `cat /sys/block/${disk}/queue/scheduler` 
   done
   pvs
   echo "======================  =====  =====  =====  =====  =====  ==========  ======="
   vgs
   echo "======================  =====  =====  =====  =====  =====  ==========  =======" 
   lvs
}

get_netinfo(){
   echo "interface | status | ipadds     |      mtu    |  Speed     |     Duplex"
   for ipstr in `ifconfig -a|grep ": flags"|awk  '{print $1}'|sed 's/.$//'`
   do
      ipadds=`ifconfig ${ipstr}|grep -w inet|awk '{print $2}'`
      mtu=`ifconfig ${ipstr}|grep mtu|awk '{print $NF}'`
      speed=`ethtool ${ipstr}|grep Speed|awk -F: '{print $2}'`
      duplex=`ethtool ${ipstr}|grep Duplex|awk -F: '{print $2}'`
      echo "${ipstr}"  "up" "${ipadds}" "${mtu}" "${speed}" "${duplex}"\
      |awk '{print $1,"|", $2,"|", $3,"|", $4,"|", $5,"|", $6}'
   done
 }

# This script must be executed as root
RUID=`id|awk -F\( '{print $1}'|awk -F\= '{print $2}'`
# #OR# RUID=`id | cut -d\( -f1 | cut -d\= -f2` #OR#ROOT_UID=0
if [ ${RUID} != "0" ];then
    echo"This script must be executed as root"
    exit 1
fi
PLATFORM=`uname`
if [ ${PLATFORM} = "HP-UX" ] ; then
    echo "This script does not support HP-UX platform for the time being"
	exit 1
elif [ ${PLATFORM} = "SunOS" ] ; then
    echo "This script does not support SunOS platform for the time being"
	exit 1
elif [ ${PLATFORM} = "AIX" ] ; then
    echo "This script does not support AIX platform for the time being"
	exit 1
elif [ ${PLATFORM} = "Linux" ] ; then
   get_physics
   get_cpuinfo
   get_meminfo
   get_diskinfo
   get_netinfo
fi

