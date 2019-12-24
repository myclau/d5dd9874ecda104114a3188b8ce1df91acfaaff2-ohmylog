# d5dd9874ecda104114a3188b8ce1df91acfaaff2ohmylog

# Objective
1. Count the total number of HTTP requests recorded by access logfile (./access.log)
2. Find the top-10 (host) hosts makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59, inclusively
3. Find out the country with most requests originating from (according to the source IP)

# Prerequisite

1. any linux env with bash
2. able to have outbound traffic (i.e can ping 8.8.8.8)


# How to Test

1. git clone
2. cd to workdirectory
3. run below command will run a quick test (the log file is smaller) ```bash
./main.sh
```
4. run below command to run the full test with custom file "access.log" ```bash
./main.sh access.log
```

5. you can change the custom the variable in the main.sh
```bash

#custom input
file=${1-"small.access.log"}
searchtime_from_string="2019-06-10 00:00:00 +0800"
searchtime_to_string="2019-06-19 23:59:59 +0800"
topcount=10

```

# Assumption 

1. The log format with not be change and also in this way
```<ip> - - [<date time>] <any log message>``` 
2. The api service form http://ip-api.com/ are avaliable

# Logic thinking

1. To process the log file, we have no choice, we need to read all lines
2. for each lines , use regex to get the info we need which is the ip address, also need to get the time for next step to use , and the log must have HTTP as we just count the HTTP request
3. as we want to lower the processing data after read the logs, so on each line we depends on the time and the custom param searchtime_from_string & searchtime_to_string to only collect the ip within this time
4. Can print out the count of total request
5. Then will have an array only have all ip records (may be duplicate)
6. Then process this array to 2 array one store unique ip address and another one store the count in the data array and 2 array connected using corresponding index
7. Then find the Max 10 ( can be set in topcount )
8. The way to rank 10 are follow
	a. clone another array from the array which just store the counts
	b. find the current max
	c. for loop in counts array, if it equal to the max value ,set the value to 0 , save the index to the result array
	d. as the counts must greater than 0, so we can set it to 0 to find another max in the current cloned counts array
	e. do it 10 time ( if the record in counts is less than 10 will stop with the length of it)
	f. we will get the top 10 result of index (usually more than 10, if some counts are same , will also be consider in same rank)
	d. use the index to print out the value in array_of_ip[index] and the array_of_count[index]
8. before print the result use the ip to call the geolocation api to get the location info.
9. print the reuslt

# Limition
1. the giving log file size quite big, it consum quite a lot of time.
2. I think using bash to find some finding in this kind of big log is not really suitable.
3. The script do not support mutiple log files


# Expected result (output)

```bash
$ ./main.sh access.log
Reading logs...
Progress : [                                        ] 100%
Completed Reading, consume 525 seconds
Total count of HTTP request in access.log : 85404
Processing Data
Progress : [                                        ] 100%
Completed Processing, consume 185 seconds
Top 10 result for requesting:
Source: 1.222.44.52     Requests:730    From(country[countryCode],city): South Korea[KR],Gangnam-gu
Source: 118.24.71.239   Requests:730    From(country[countryCode],city): China[CN],Haidian
Source: 119.29.129.76   Requests:723    From(country[countryCode],city): China[CN],Beijing
Source: 148.251.244.137 Requests:486    From(country[countryCode],city): Germany[DE],Falkenstein
Source: 95.216.38.186   Requests:440    From(country[countryCode],city): Finland[FI],Tuusula
Source: 136.243.70.151  Requests:440    From(country[countryCode],city): Germany[DE],Falkenstein
Source: 213.239.216.194 Requests:437    From(country[countryCode],city): Germany[DE],Nuremberg
Source: 5.189.159.208   Requests:436    From(country[countryCode],city): Germany[DE],Munich
Source: 5.9.71.213      Requests:436    From(country[countryCode],city): Germany[DE],Falkenstein
Source: 5.9.108.254     Requests:406    From(country[countryCode],city): Germany[DE],Falkenstein
Source: 95.216.2.253    Requests:365    From(country[countryCode],city): Finland[FI],Tuusula
Source: 5.9.152.73      Requests:263    From(country[countryCode],city): Germany[DE],Falkenstein
Source: 95.216.11.34    Requests:224    From(country[countryCode],city): Finland[FI],Tuusula

```
