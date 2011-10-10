#!/bin/bash
# traffic.sh v1.2 (c) crx 2008
# requires vnstat 1.x
# -> vnstat.conf
# DayFormat    "%d/%m/%y"
# MonthFormat  "%b '%y"
# TopFormat    "%x"
# OutputStyle 3



#####
#
# works with debian 6.0.2 @ Kernel 2.6.32-5-amd64
# uses vnstat 1.11
#
#
#
#
#
#
####

## Settings
vnstat_bin=/usr/bin/vnstat	# where is your vnstat binary ?

separator="FALSE"      # when TRUE comma as separator
space="TRUE"           # when TRUE space between Value and Unit

traffic_limit="FALSE"   # Announcing traffic reached in percent
maximumweek="500"      # in GiB
maximummonth="2.30"    # in TiB


###################################################################################################################################
# DO NOT EDIT ANYTHING BELOW - UNLESS YOU WANT TO CHANGE THE OUTPUT AND KNOW WHAT YOU ARE DOING                                   #
###################################################################################################################################

if [ $# -eq "0" ]; then
echo "no arguments passed"
exit 0
fi

#####################################################################
# Evaluate a floating point number expression.

float_scale=2
function float_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}

#####################################################################
# Commas and space handling

commas() {
  if [ "$separator" = "TRUE" ] && [ "$space" = "FALSE" ]; then
   data=$(echo $1 $2 | sed 's/ //g' | sed 's/\./,/g')
   echo "$data"
  else
   if [ "$separator" = "FALSE" ] && [ "$space" = "TRUE" ]; then
    echo "$1 $2"
  else
   if [ "$separator" = "TRUE" ] && [ "$space" = "TRUE" ]; then
   data=$(echo $1 $2 | sed 's/\./,/g')
   echo "$data"
  else
   data=$(echo $1 $2 | sed 's/ //g')
   echo "$data"
  fi
 fi
fi
}


#####################################################################
# Main traffic script

if [ "$1" = "month" ]; then

month=$(date +%b)
thismonth=$(date +%B)
incoming=$(commas $(${vnstat_bin} -m | grep $month | awk '{ print $3 " " $4 }'))
outgoing=$(commas $(${vnstat_bin} -m | grep $month | awk '{ print $6 " " $7 }'))
total=$(commas $(${vnstat_bin} -m | grep $month | awk '{ print $9 " " $10 }'))
totalnumber=$(${vnstat_bin} -m | grep $month | awk '{ print $9}')
avg=$(commas $(${vnstat_bin} -m | grep $month | awk '{ print $12 " " $13 }'))
estimated=$(commas $(${vnstat_bin} -m | grep estimated | awk '{ print $8 " " $9 }'))
estimatednumber=$(${vnstat_bin} -m | grep estimated | awk '{ print $8}')

   if [ "$traffic_limit" = "TRUE" ]; then
      istib=$(${vnstat_bin} -m | grep $month | awk '{ print $10}' | grep TiB)
      if [ -z "$istib" ]; then
      maximummonth=$(float_eval "$maximummonth * 1024")
      fi
      maxpercent1=$(float_eval "$totalnumber * 100 / $maximummonth")
      if [[ $estimatedunit == *TiB* ]]; then
      maxpercent2=$(float_eval "$estimatednumber * 1024 * 100 / $maximummonth")
      else
      maxpercent2=$(float_eval "$estimatednumber * 100 / $maximummonth")
      fi
      echo -e "\002\003\064[\002\003TRAFFIC\002\003\064]\002\003 for $thismonth - RX:\002 ${incoming} \002- TX:\002 ${outgoing} \002- TOTAL:\002 ${total} [${maxpercent1}%] \002 - AVG:\002 ${avg}\002- ESTIMATED:\002 ${estimated} [${maxpercent2}%] \002"
   else
      echo -e "\002\003\064[\002\003TRAFFIC\002\003\064]\002\003 for $thismonth - RX:\002 ${incoming} \002- TX:\002 ${outgoing} \002- TOTAL:\002 ${total} \002 - AVG:\002 ${avg} \002- ESTIMATED:\002 ${estimated} \002"
   fi
fi

###########################################

if [ "$1" = "day" ]; then

day=$(date +%d/%m/%y)
thisday=$(date +%A)
incoming=$(commas $(${vnstat_bin} -d | grep $day | awk '{ print $2 " " $3 }'))
outgoing=$(commas $(${vnstat_bin} -d | grep $day | awk '{ print $5 " " $6 }'))
total=$(commas $(${vnstat_bin} -d | grep $day | awk ' {print $8 " " $9 }'))
avg=$(commas $(${vnstat_bin} -d | grep $day | awk '{ print $11 " " $12 }'))
estimated=$(commas $(${vnstat_bin} -d | grep estimated | awk '{ print $8 " " $9 }'))
echo -e "\002\003\064[\002\003TRAFFIC\002\003\064]\002\003 for $thisday - RX:\002 ${incoming} \002- TX:\002 ${outgoing} \002- TOTAL:\002 ${total} \002 - AVG:\002 ${avg} \002- ESTIMATED:\002 ${estimated}\002"
fi

###########################################

if [ "$1" = "week" ]; then

wk="current"
thiswk=$(date +%U)
thisyr=$(date +%Y)
incoming=$(commas $(${vnstat_bin} -w | grep $wk | awk '{ print $3 " " $4 }'))
outgoing=$(commas $(${vnstat_bin} -w | grep $wk | awk '{ print $6 " " $7 }'))

total=$(commas $(${vnstat_bin} -w | grep $wk | awk ' {print $9 " " $10 }'))
totalnumber=$(${vnstat_bin} -w | grep $wk | awk '{ print $9}')
avg=$(commas $(${vnstat_bin} -w | grep $wk | awk '{ print $12 " " $13 }'))
estimated=$(commas $(${vnstat_bin} -w | grep estimated | awk '{ print $8 " " $9 }'))
estimatednumber=$(${vnstat_bin} -w | grep estimated | awk '{ print $8}')
   if [ "$traffic_limit" = "TRUE" ]; then
      istib=$(${vnstat_bin} -m | grep $wk | awk '{ print $10}' | grep TiB)
      if [ -z "$istib" ]; then
      maximummonth=$(float_eval "$maximumweek * 1024")
      fi
      maxpercent1=$(float_eval "$totalnumber * 100 / $maximumweek")
      if [[ $estimatedunit == *TiB* ]]; then
      maxpercent2=$(float_eval "$estimatednumber * 1024 * 100 / $maximweek")
      else
      maxpercent2=$(float_eval "$estimatednumber * 100 / $maximumweek")
      fi
      echo -e "\002\003\064[\002\003TRAFFIC\002\003\064]\002\003 for week $thiswk of $thisyr - RX:\002 ${incoming} \002- TX:\002 ${outgoing} \002- TOTAL:\002 ${total} [${maxpercent1}%] \002 -AVG:\002 ${avg} \002- ESTIMATED:\002 ${estimated} [${maxpercent2}%] \002"
   else
      echo -e "\002\003\064[\002\003TRAFFIC\002\003\064]\002\003 for week $thiswk of $thisyr - RX:\002 ${incoming} \002- TX:\002 ${outgoing} \002- TOTAL:\002 ${total} \002 - AVG:\002 ${avg} \002- ESTIMATED:\002 ${estimated} \002"
   fi
fi


