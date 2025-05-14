#!/bin/bash

for csv in hmos_*.csv; do
  lines=$(cat "${csv}" | tail -n+2 | wc -l)
  occ_mean=$(cat "${csv}" | csvtool namedcol "Permitted Occupants" - | awk 'NR>1{tot+=$0} END {printf "%.2f\n", tot/(NR-1)}')
  occ_median=$(cat "${csv}" | csvtool namedcol "Permitted Occupants" - | tail -n+2 | sort -n | head -n $(( $lines / 2 )) | tail -n1)
  occ_lq=$(cat "${csv}" | csvtool namedcol "Permitted Occupants" - | tail -n+2 | sort -n | head -n $(( $lines / 4 )) | tail -n1)
  occ_hq=$(cat "${csv}" | csvtool namedcol "Permitted Occupants" - | tail -n+2 | sort -n | head -n $(( ($lines / 4) * 3 )) | tail -n1)
  occ_IQR=$(( $occ_hq - $occ_lq ))
  streets=$(cat "${csv}" | csvtool namedcol "Address 3" - | sort | uniq -c | sed -e 's/^ *//;s/ /;/' | sort -n | tail -n5 | tac | awk -F';' '{printf "%s (%s), ", $2, $1}')
  postcodes=$(cat "${csv}" | csvtool namedcol "Postcode" - | awk 'NR>1{print $1}' | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | csvtool col 2,1 - | sort -V | awk -F',' '{printf "%s (%s), ", $1, $2}')
  postcodes_linesplit=$(echo "${postcodes}" | sed -E 's/(S8 \([^\)]*\))/\n    \1/')

  echo "${csv}"  
  echo "  total licences: ${lines}"
  echo "  ${occ_mean} mean occupants (IQR ${occ_IQR} [${occ_lq} - ${occ_hq}]) (median ${occ_median})"
  echo "  amount by postcode:"
  echo "    ${postcodes_linesplit}"
  echo "  streets with most licences: ${streets}"
done
