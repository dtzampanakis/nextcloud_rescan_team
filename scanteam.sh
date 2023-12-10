#!/bin/bash


#***********************************************************************************************#
#                   		       scanteam.sh v1.1        					#
#                                written by Dimitris Tzampanakis       				#
#                		     April  15, 2020                   				#
#                                                						#
#           			Rescan all (Shared) team's members.    				#
#***********************************************************************************************#

#check if scanteam script is already running so we will not mess up with the temporary files
/opt/scripts/scan/check.sh        #call of check.sh to check if scanteam already running.
status=$?		          #if $?=20 then scanteam is already running,
if [ $status -eq 20 ]; then       #+  and we will get akiro.txt with ASCII message
cat /opt/scripts/scan/akiro.txt
exit 2				  #we will take exit 2
fi

		# share_with = '$1' or uid_owner='$1' or uid_initiator='$1'  group by share_with">/tmp/1.txt;

mysql -h IP -uusername -pRANDOMPASS nextcloud -e "select uid_initiator  from oc_share where   share_with = '$1' group by uid_initiator">/tmp/1.txt;
echo "$1">>/tmp/1.txt
cat /tmp/1.txt >/tmp/dimitris.txt # itan kathara gia to check

	# Connect to database of solcloud to get the members that
	#+ the user share files and store them to 1.txt in /tmp

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing

#----------------------------------------------------------------------------------------------#
#           LOOP for starting occ for every user that we get from query 		       #
#----------------------------------------------------------------------------------------------#

for i in $(cat < /tmp/1.txt); do
 cd /var/www/html/cloud
 sudo -u apache php occ files:scan -v user_id $i -q & #start occ for every user in 1.txt  
 FOO_PID=$!					      # +and store the process ID to FOO_PID
 echo $FOO_PID>>/tmp/2.txt			      #After that store it to another tmp file 2.txt in /tmp
 cd /tmp
done

rm -r /tmp/1.txt 				 #remove the tmp file 1.txt we do not need anymore




while true; do    	#endless loop. It will run untill all occs will finish scanning.
	#		check=0	
		for i in $(cat < /tmp/2.txt); do                       #loop all process id stored in 2.txt in /tmp
	  		ps -A -o pid |grep -w $i|wc -l >> /tmp/3.txt   # check if process ids of occ are running  from tmp file 2.txt
								       #+ if ps -A -o pid |grep -w $i|wc -l = 1 then is still running
							               #+ all that booleans 0/1 we store them to 3.txt in /tmp
								       #+ and we will check them more down so we will know when it
								       #+ will finish to break the while true loop

#			if  [ `ps -A -o pid |grep -w $i|wc -l` -eq 1 ]; then
#			check=1
#			else check=0
#			fi
		done

		sinolo=0		# sinolo variable start to 0 and will add all /tmp/3.txt 

		for i in $(cat < /tmp/3.txt); do
			sinolo=$(($sinolo+$i))
		done

	#echo sinolo $sinolo
	#echo count $count

		if [ $sinolo -ne 0 ]; then     		       # if the sinolo > 0 that means that all occ did not finished
								       #+ and we have to call spinner for graphical loading 
			clear
			/opt/scripts/scan/spinner.sh
			rm /tmp/3.txt 				       # remove the 3.txt and continue to the endless loop that 
								       #+ will check again for process in 2.txt and create a new
								       #+ 3.txt with new status of running processes
		else 
			echo finish				       # if the sinolo is 0 that means that all occ finished
                        break                			       #+ and we can break from endless loop

		fi	
	
	

done
rm /tmp/2.txt 			# Clearing tmp files 2,3 txt
rm /tmp/3.txt

cat /opt/scripts/scan/finish.txt  	# Show message of finish

	
