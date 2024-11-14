#!/bin/bash
# not used

if [ -z "${1}" ]; then
  echo "usage: ./geocode.sh location"
  exit 1
fi

loc="${1}"
throttled=1

while [ $throttled = 1 ]; do
  resp=$(curl -s -X POST -d locate="${loc}" -d geoit="json" "https://geocode.xyz")
  if [[ "${resp}" =~ Throttled ]]; then
    echo "throttled... retrying..." >> /dev/stderr
    throttled=1
  else
    throttled=0
  fi
  sleep 1
done

echo "got response: ${resp}" >> /dev/stderr

json=$(echo "${resp}" | jq | sed 's/ {}/""/g')

basic=$(echo "${json}" | jq -r '
.latt + "\t" +
.longt + "\t" +
.standard.confidence + "\t"'
)

standard=$(echo "${json}" | jq -r '
.standard.addresst? + "\t" +
.standard.statename? + "\t" +
.standard.city? + "\t" +
.standard.prov? + "\t" +
.standard.countryname? + "\t" +
.standard.postal? + "\t"
')

alt=$(echo "${json}" | jq -r '
.alt?.loc?.addresst + "\t" +
.alt?.loc?.statename + "\t" +
.alt?.loc?.city + "\t" +
.alt?.loc?.prov + "\t" +
.alt?.loc?.countryname + "\t" +
.alt?.loc?.postal + "\t"
')
echo "${basic}${standard}${alt}" | sed '1s/^/latitude\tlongitude\tconfidence\taddress\tstate\tcity\tprovince\tcountry\tpost code\talt address\talt state\talt city\talt province\talt country\talt postal\n/'

