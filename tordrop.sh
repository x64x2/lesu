#!/bin/bash


#………………………………………._¸„„„„_
#…………………….……………„–~*'¯…….'\
#………….…………………… („-~~–„¸_….,/ì'Ì
#…….…………………….¸„-^"¯ : : : : :¸-¯"¯/'
#……………………¸„„-^"¯ : : : : : : : '\¸„„,-"
#**¯¯¯'^^~-„„„—-~^*'"¯ : : : : : : : : : :¸-"
#.:.:.:.:.„-^" : : : : : : : : : : : : : : : : :„-"
#:.:.:.:.:.:.:.:.:.:.: : : : : : : : : : ¸„-^¯
#.::.:.:.:.:.:.:.:. : : : : : : : ¸„„-^¯
#:.' : : '\ : : : : : : : ;¸„„-~"
#:.:.:: :"-„""***/*'ì¸'¯
#:.': : : : :"-„ : : :"\
#.:.:.: : : : :" : : : : \,
#:.: : : : : : : : : : : : 'Ì
#: : : : : : :, : : : : : :/
#"-„_::::_„-*__„„~"

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Name of the program called
export SCRIPT_NAME=`basename ${0}`

# Setting up the execution date and time
export DATE=`date +%Y%m%d_%Hh%M`

# logfile
export CURRENT_PATH=`pwd`
export LOGFILE=${CURRENT_PATH}/${SCRIPT_NAME}-${DATE}.log

# log function
log () {
    # echoing log message in the console and in the logfile
    echo -e ${1} | tee -a ${LOGFILE};
}

# error function, automatically exits the program when called
error () {
    # echoing error message in the console and in the logfile
    echo -e ${1} |  tee -a ${LOGFILE};
	echo -e "\n=== ERROR - END OF EXECUTION ===\n====================\n"
    # exiting
    exit 1;
}

# loging hte beginning of the execution
log "\n\n===========================\n  ${DATE} - New execution"

# check uid - Only root is allowed to run this script
if [ ${USER} != "root" ] ;
then
    error "Execution failed : you've been identified as ${USER}.\nOnly root is allowed to run this script. Sorry."
fi

# checks if wget is present
which wget &> /dev/null
WGET=$?
if [ ${WGET} = 1 ] ;
then
	error "Execution failed : wget seem not to be present. If yes, you should check your PATH variable. If not, install it before trying to run this program again."
fi

# checks if iptables is present
which iptables &> /dev/null
IPTABLES=$?
if [ ${IPTABLES} = 1 ] ;
then
	error "Execution failed : iptables seem not to be present. If yes, you should check your PATH variable. If not, install it before trying to run this program again."
fi

# checks if ipset is present
which ipset &> /dev/null
IPSET=$?
if [ ${IPSET} = 1 ] ;
then
	error "Execution failed : ipset seem not to be present. If yes, you should check your PATH variable. If not, install it before trying to run this program again."
fi

# checks if IP and ports sets exists, and creates them otherwise
ipset -L IPset &> /dev/null
EXISTS_IPSET=$?
if [ ${EXISTS_IPSET} = 1 ] ;
then
	log "Set IPset doesn't exist."
	ipset -N IPset iphash --hashsize 2048
	log "Set IPset created."
fi

ipset -L PORTSset &> /dev/null
EXISTS_PORTSSET=$?
if [ ${EXISTS_PORTSSET} = 1 ] ;
then
	log "Set PORTSset doesn't exist."
	ipset -N PORTSset portmap --from 1 --to 1024 
	log "Set IPset created."
fi

# setting up input ports to filter
# edit if you want to filter other ports
export PORTS="80 443"

# filter incoming packets
export CHAIN_NAME="INPUT"

# set up working dir and files
export WORKING_DIR="$HOME/.tor-dropper"
# check if working dir exists. Create it if it doesn't
if [ ! -d $WORKING_DIR ] ;
then
	log "Directory ${WORKING_DIR} doesn't exist, it will be automatically created."
	mkdir -p ${WORKING_DIR}
fi

export CURRENT_TOR_LIST="${WORKING_DIR}/current_tor_list"

# Get IP adress
# Three methods, choose the appropriate one
# First method, assuming public adress is directly associated to eth0 interface
# Replace eth0 by any other interface, depending on your configuration
# Won't work if your host is not directly connected to the Internet (gateway, proxy, virtualization, etc...)
# export IP_ADDRESS =$(ifconfig eth0 | grep inet | cut -d":" -f 2 | egrep -o "([0-9]{1,3}\.?){4}")

# second method : get your public IP address from the web
export IP_ADDRESS=$(wget -q -O - http://checkmyip.com/ | grep "Your public IP address is" | egrep -o '([0-9]{1,3}\.?){4}')

# third method : set your public IP address yourself
# export IP_ADDRESS="127.0.0.1"

# download the current list from the tor project
for PORT in ${PORTS}
do
    wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=${IP_ADDRESS}&port=${PORT}" -U NoSuchBrowser/1.0 >> ${CURRENT_TOR_LIST}
    echo >> ${CURRENT_TOR_LIST}
done

# cleaning comment lines
sed -i '/^#.*$/d' ${CURRENT_TOR_LIST}

# cleaning empty lines
sed -i '/^$/d' ${CURRENT_TOR_LIST}

# flush and fill the ports set
ipset -F PORTSset
for PORT in ${PORTS}
do
	ipset -A PORTSset ${PORT}
done

# flush and fill the IP set
ipset -F IPset
for IP in `sort -u ${CURRENT_TOR_LIST}`
do
	ipset -A IPset ${IP}
done

# add iptables rule if it doesn't exists
# string to match
export STM="match-set IPset src match-set PORTSset dst"
# tests rules presence
iptables -L ${CHAIN_NAME} | grep "${STM}"
RESULT=$?
if [ $RESULT = 1 ]
then
	iptables -A ${CHAIN_NAME} -m set --set IPset src -m set --set PORTSset dst -j DROP
fi

log "goodbye world.\n\n ;)\n"

# clean exit
exit 0
