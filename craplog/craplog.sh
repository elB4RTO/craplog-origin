#!/bin/bash

FallbackPATH="$(pwd)"
cd "$(dirname $(realpath $0))"

# REMOVE CONFLICT FILES
while [ -e ./CLEAN.txt ] || [ -e ./IPS ] || [ -e ./REQUESTS ] || [ -e ./RESULTS ] || [ -e ./USER-AGENTS ]
	do
		if [ -e ./CLEAN.txt ];		then rm ./CLEAN.txt;		fi
		if [ -e ./IPS ];			then rm ./IPS;				fi
		if [ -e ./REQUESTS ];		then rm ./REQUESTS;			fi
		if [ -e ./RESULTS ];		then rm ./RESULTS;			fi
		if [ -e ./USER-AGENTS ];	then rm ./USER-AGENTS;		fi
	done

# CLEAN LOGS
echo "CLEANING LOGS ..."
IP=FALSE
while IFS= read -r line
	do
		if [[ $line != 192.168.* ]] && [[ $line != ::1* ]]
			then
				if [[ $IP == FALSE ]]
					then
						IP="$(echo $line | cut -f1 -d' ')"
					fi
				IP_check="$(echo "$line" | cut -f1 -d' ')"
				if [[ $IP != $IP_check ]]
					then
						printf "\n" >> CLEAN.txt
						IP=$IP_check
					fi
				echo "$line" >> CLEAN.txt
				printf "\n" >> CLEAN.txt
			fi
	done < /var/log/apache2/access.log.1

# SPLITTING ITEMS
echo "SPLITTING ITEMS ..."
while IFS= read -r line
	do
		if [[ $line != 192.168.* ]] && [[ $line != ::1* ]]
			then
				IP="$(echo $line | cut -f1 -d' ')"
				echo "$IP" >> ./IPS
				if [[ $line != OPTIONS* ]]
					then
						REQ="$(echo $line | cut -f2 -d'"')"
						echo "$REQ" >> ./REQUESTS
					else
						REQ="$(echo $line | cut -f2 -d'"')"
						REQ1=${line# }
						REQ2=${line% }
						echo "$REQ1 $REQ2" >> ./REQUESTS
					fi
				RES=`echo $line | cut -f3 -d'"'`
				echo "$RES" >> ./RESULTS
				UA=`echo $line | cut -f6 -d'"'`
				echo "$UA" >> ./USER-AGENTS
			fi
	done < /var/log/apache2/access.log.1

# FINISH
cd "$FallbackPATH"
echo "DONE"
