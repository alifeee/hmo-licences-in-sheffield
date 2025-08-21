#!/bin/bash

echo "this takes a while to run to parse all the dates..." >> /dev/stderr

echo "run at: $(date)"
echo ""

for csv in hmos_*.csv; do
  datestamps=""
  days=""
  years=""
  sep=""
  while read datestr; do
    d=$(date --date="${datestr}" '+%s')
    dy=$(date --date="${datestr}" '+%A')
    yr=$(date --date="${datestr}" '+%Y')
    datestamps="${datestamps}${sep}${d}"
    days="${days}${sep}${dy}"
    years="${years}${sep}${yr}"
    sep=$'\n'
  done <<< $(cat "${csv}" | csvtool namedcol "Licence Issue Date" - | tail -n+2)

	now_ts=$(date '+%s')
	  
  expirystamps=""
  expiryyears=""
  sep=""
  while read datestr; do
    d=$(date --date="${datestr}" '+%s')
    yr=$(date --date="${datestr}" '+%Y')
    expirystamps="${expirystamps}${sep}${d}"
    expiryyears="${expiryyears}${sep}${yr}"
    sep=$'\n'
  done <<< $(cat "${csv}" | csvtool namedcol "Licence Expiry Date" - | tail -n+2)
  
  lines=$(cat "${csv}" | tail -n+2 | wc -l)
  datelines=$(echo "${datestamps}" | wc -l)
  uniqissues=$(echo "${datestamps}" | sort | uniq | wc -l)
  dayresult=$(echo "${days}" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sed 's/Monday/1,Monday/;s/Tuesday/2,Tuesday/;s/Wednesday/3,Wednesday/;s/Thursday/4,Thursday/;s/Friday/5,Friday/;s/Saturday/6,Saturday/;s/Sunday/7,Sunday/;' | sort -t, -k2 | awk -F',' '{printf "%s (%i), ", $3, $1}')
  yearresult=$(echo "${years}" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sort -t, -k2 | awk -F',' '{printf "%s (%i), ", $2, $1}')
  expiryyearresult=$(echo "${expiryyears}" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sort -t, -k2 | awk -F',' '{printf "%s (%i), ", $2, $1}')
  
  expired=$(echo "${expirystamps}" | awk -v now_ts="${now_ts}" 'now_ts > $0 {e+=1} END {print e}')
  active=$(echo "${expirystamps}" | awk -v now_ts="${now_ts}" 'now_ts > $0 {e+=1} END {print NR-e}')

  earliest=$( while read stamp; do date --date="@${stamp}" '+%a %d %b %Y'; done <<< $(echo "${datestamps}" | sort -n | head -n2) | awk '{printf "%s, ", $0}')
	latest=$( while read stamp; do date --date="@${stamp}" '+%a %d %b %Y';	done <<<$(echo "${datestamps}" | sort -n | tail -n2) | awk '{printf "%s, ", $0}')
  earliest_exp=$( while read stamp; do date --date="@${stamp}" '+%a %d %b %Y'; done <<< $(echo "${expirystamps}" | sort -n | head -n2) | awk '{printf "%s, ", $0}')
	latest_exp=$( while read stamp; do date --date="@${stamp}" '+%a %d %b %Y';	done <<<$(echo "${expirystamps}" | sort -n | tail -n2) | awk '{printf "%s, ", $0}')


  echo "${csv}"
  echo "  ${datelines} dates in ${lines} lines (${uniqissues} unique issuing dates)"
  echo "    ${expired} expired"
  echo "    ${active} active"
  echo "  Licence Issue Dates:"
  echo "    ${earliest}… … … ${latest}"
  echo "    ${dayresult}"
  echo "    ${yearresult}"
  echo "  Licence Expiry Dates:"
  echo "    ${earliest_exp}… … … ${latest_exp}"
  echo "    ${expiryyearresult}"
done
