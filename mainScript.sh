#!/bin/bash


#Author: Tziampais
#Name: fastscan 









input=./urls
echo "Init..."

if [ 1 == 1 ]; then
	echo "Help menu: \\n \\t -all (performing all tests)"
	echo "Provide full url like: https://example.com/ or IP" 
	echo "=============================================="
	echo "\n"			
fi 




ls=(nslookup curl-OPTIONS whatweb testssl nmap nikto dirb sublist3r)
#ls=( sublist3r )
isIP=0

## Resolve host
## Add 2> stderror to commands 

#echo ${ls[0]}
#echo "chekcpoint1"
for i in ${ls[@]}; do  
	#echo "chekcpoint2"
	while IFS= read -r line
	do 
		###------------------------------------------------------------
		#Check if input is URL or IP
		if [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]+$ ]]; then 
			echo "Yes is IP $line"
			isIP=1
			nameUrl=$line
			#echo $nameUrl
		else 
			#split URL on //
			nameUrl=$( echo $line | cut -d/ -f3 )
			echo "URL name: $nameUrl"
		fi
		###------------------------------------------------------------
		
		#echo "chekcpoint3"
		#all commands
		if [ "$i" == "whatweb"  ]; then									#Accepts IP
			echo "Running $i for $line"
			echo "whatweb -v $line"
			eval "whatweb -v $line" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "curl-OPTIONS" ]; then								#Accepts IP
			echo "Running $i for $line"
			eval "curl -I $line -X OPTIONS -L" >> "./$i/$nameUrl.txt" &
			eval "curl -I $line -L" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "nslookup" ] && [ "$isIP" == "0" ]; then						#No IP 
			echo "Running $i for $line"
			eval "nslookup $nameUrl" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "nmap" ]; then									#Accepts IP
			echo "Running $i for $line"
			eval "nmap $nameUrl -sV -n -Pn -v" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "nikto" ]; then									#Accepts IP
			echo "Running $i for $line"
			eval "nikto -h $line" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "dirb" ]; then									#Accepts IP with http://IP/
			if [ "$isIP" == "0" ]; then
				echo "Running $i for $line"
				eval "dirb $line -f" >> "./$i/$nameUrl.txt" &
			else
				echo "Running $i for $line (as IP) "
				eval "dirb http://$line -f" >> "./$i/$nameUrl.txt" &
			fi
		elif [ "$i" == "testssl" ]; then								#Accepts IP
			echo "Running $i for $line"								
			eval "$i $line" >> "./$i/$nameUrl.txt" &
		elif [ "$i" == "sublist3r" ] && [ "$isIP" == "0" ]; then 					#No IP
			echo "Running $i for $line"		
			eval "sublist3r -d $nameUrl" >> "./$i/$nameUrl.txt" &						
		fi
		
		isIP=0
		
	done < "$input"
	sleep 2
done


echo "=============================================="
echo "\n"	
echo " Finished "

