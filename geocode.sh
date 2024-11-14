#!/bin/bash
# add lat/long to a CSV of addresses
# by geocoding
# uses Google's Geocoding API, so requires a key set in .env file

if [ -z "${3}" ]; then
  echo "usage: ./geocode.sh <file.csv> <address cols format string> <postcode col>"
  echo '  address col is format string of CSV cols e..g., "%2, %3 %1"'
  echo '  for help on format strings, run: csvtool --help'
  exit 1
fi

file="${1}"
addr_cols="${2}"
postcode_col="${3}"
output_file="hmos.csv"
time_fmt="+%H:%M:%S"

cat "${file}" | head -n1 | tr -d '\n' > "${output_file}"
printf ',latitude,longitude,geocoded_address\n' >> "${output_file}"

start_unix=$(date +%s)
start_time=$(date --date="@${start_unix}" "${time_fmt}")
tot=$(cat "${file}" | wc -l)
i=1

while read row; do
  addr=$(echo "${row}" | csvtool format "${addr_cols}" -)

  postcode=$(echo "${row}" | csvtool col "${postcode_col}" -)
  
  now_unix=$(date +%s)
  est_unix=$(awk 'BEGIN {printf "%i", '$start_unix' + ( ('$tot' / '$i') * ('$now_unix' - '$start_unix') )}')
  est_time=$(date --date="@${est_unix}" "${time_fmt}")
  
  search="${addr}, Sheffield ${postcode}, UK"
  printf "\r\033[K" # clear line
  #printf "\n" # new line
  printf "${start_time} - ${est_time} geocoding ${i}/${tot} ${search}"
  i=$(( $i + 1))
  
  result=$(./geocode_google.sh "${search}")
  printf "%s,%s\n" "${row}" "${result}" >> "${output_file}"
done <<< $(cat "${file}" | awk 'NR>1')

printf "\n"
echo "done!"

