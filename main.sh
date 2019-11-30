#!/bin/bash

function ProgressBar {
	# Process data
	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done
	# Build progressbar string lengths
	_fill=$(printf "%${_done}s")
	_empty=$(printf "%${_left}s")

	# 1.2 Build progressbar strings and print the ProgressBar line
	# 1.2.1 Output example:                           
	# 1.2.1.1 Progress : [########################################] 100%
	printf "\rProgress : [${_fill// \#}${_empty// /-}] ${_progress}%%"

}


function log_processing {
	array=( $1 )
	for ((i = 0; i < ${#array[@]}; ++i)); do
		recordip=${array[$i]}
		if [ "$recordip" != "" ];then
			recorddate=$(date -d  "$recordtime" '+%s')
			recorddateString=$(date -d  "$recordtime" )
			if [[ $recorddate -ge $searchtime_from && $currenttime -le $searchtime_to ]]; then
				added="false"
				for ((j = 0; j < ${#topip[@]}; j++)); do
	                        	if [ "${topip[$j]}" = "$recordip" ]; then
		                        	topipcount[$j]=$(( ${topipcount[$j]} + 1))
						added="true"
						break
					fi
				done
				if [ "$added" = "false" ]; then
					topip+=("$recordip")
					topipcount+=("1")
				fi
			fi
		fi
		 ProgressBar ${_start} ${_end}
		 _start=$(($_start + 1))
	done
}

#custom input
file=${1-"small.access.log"}
searchtime_from_string="2019-06-10 00:00:00 +0800"
searchtime_to_string="2019-06-19 23:59:59 +0800"
topcount=10


searchtime_from=$(date -d  "$searchtime_from_string" '+%s')
searchtime_to=$(date -d  "$searchtime_to_string" '+%s')
data=()
totalhttprequest=0
topip=()
topipcount=()

_start=1
_end=$(wc -l < "$file")
start=`date +%s`
echo "Reading logs..."
while IFS= read line
do
	# grep ip and time in  every lines of the log file
	sourceip=$(echo "$line" |  sed -n 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*\[\(.* +[0-9]\{4\}\)\].*HTTP.*/\1/p')
	requesttime=$(echo "$line" |  sed -n 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*\[\(.* +[0-9]\{4\}\)\].*HTTP.*/\2/p')
	requesttime=$(echo "$requesttime" | sed 's/\//-/g' )
        requesttime=$(echo "$requesttime" | sed 's/:/ /' )
	requestdatetime=$(date -d  "$requesttime" '+%s')
	if [ "$sourceip" != "" ];then
		totalhttprequest=$(($totalhttprequest + 1))
		if [[ $requestdatetime -ge $searchtime_from && $requestdatetime -le $searchtime_to ]]; then
			data+=("$sourceip")
		fi
	fi
	ProgressBar ${_start} ${_end}
	_start=$(($_start + 1))
done <"$file"
end=`date +%s`
runtime=$((end-start))

echo ""
echo "Completed Reading, consume $runtime seconds"

echo "Total count of HTTP request in $file : $totalhttprequest"
_start=1
_end=${#data[@]}
start=`date +%s`
echo "Processing Data"
log_processing "$(echo ${data[@]})"

end=`date +%s`
runtime=$((end-start))

echo ""
echo "Completed Processing, consume $runtime seconds"


#rank top N
echo "Top $topcount result for requesting:"
op_arr=("${topipcount[@]}")


topindexarr=()

for ((i = 0; i < $topcount; i++)); do
	(( i > ${#topipcount[@]}-1 )) && break
	max=${op_arr[0]}
	for n in "${op_arr[@]}" ; do
		((n > max)) && max=$n
	done
	for ((j = 0; j < ${#op_arr[@]}; j++));do
		if [ "$max" =  "${op_arr[$j]}" ]; then
			topindexarr+=( $j )
			op_arr[$j]="0"
		fi
	done
done


for ((i = 0; i < ${#topindexarr[@]}; i++));do
	index=${topindexarr[$i]}
	country=$(curl -s "http://ip-api.com/line/${topip[$index]}?fields=country")
	countryCode=$(curl -s "http://ip-api.com/line/${topip[$index]}?fields=countryCode")
	city=$(curl -s "http://ip-api.com/line/${topip[$index]}?fields=city")
	echo "Source: ${topip[$index]}	Requests:${topipcount[$index]}	From(country[countryCode],city): $country[$countryCode],$city"
	
done

