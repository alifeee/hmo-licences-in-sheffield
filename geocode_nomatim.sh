#!/bin/bash
# not used

if [ -z "${2}" ]; then
  echo "requires address and postcode"
  echo "./geocode_nomatim.sh \"address\" \"postcode\""
  exit 1
fi

street="${1}"
postalcode="${2}"

# rate limit
sleep 1

curl --request GET -s "https://nominatim.openstreetmap.org/search?format=jsonv2&city=Sheffield&county=South+Yorkshire&country=UK&countrycodes=gb" --data-urlencode "street=23 Harefield Road" --data-urlencode "postalcode=S11 8NU"

# if error:
jq '.error?.code?'

sed '1s/^/latitude\tlongitude\tconfidence\taddress\tstate\tcity\tprovince\tcountry\tpost code\talt address\talt state\talt city\talt province\talt country\talt postal\n/'

