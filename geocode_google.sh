#!/bin/bash

if [ -z "${1}" ]; then
  echo "usage: ./geocode.sh location"
  exit 1
fi

loc="${1}"
source .env # for GOOGLE_API_KEY

loc_urlencoded=$(echo "${loc}" | sed 's/ /+/g')
gmaps=$(curl -s "https://maps.googleapis.com/maps/api/geocode/json?key=${GOOGLE_API_KEY}&address=${loc_urlencoded}")

status=$(echo "${gmaps}" | jq -r '.status')

if [[ "${status}" -ne "OK" ]]; then
  echo "status not ok! status=${status}"
  exit 1
fi

latlong=$(echo "${gmaps}" | jq -r '
  .results[0]?.geometry.location
    | (.lat|tostring) + "," + (.lng|tostring)
'
)
formatted_address=$(echo "${gmaps}" | jq -r '.results[0]?.formatted_address?')

# OSM map for debugging
# echo "${latlong}" | awk -F, '{printf "https://www.openstreetmap.org/?mlat=%s&mlon=%s#map=17/%s/%s\n", $1, $2, $1, $2 }'

printf '%s,"%s"' "${latlong}" "${formatted_address}"
