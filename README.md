# HMO Licences in Sheffield

HMO licences from <https://www.sheffield.gov.uk/housing/houses-in-multiple-occupation> displayed on a map.

## Generate

the script takes around 10 minutes and should report an ETA when run

```bash
./geocode.sh <file.csv> <address cols format string> <postcode column>
# i.e., with format of hmo_licences_issued_to_9_september_2024.csv
./geocode.sh hmo_licences_issued_to_9_september_2024.csv "%2 %3 %1" 4
```

a `hmos.csv` file should now be available. there may be blank rows to be manually set, find them with:

```
while read num; do
  sed "${num}"'q;d' hmos.csv
done <<< $(cat hmos.csv | csvtool namedcol latitude - | awk '$0 ~ "null" {print NR}')
```

to turn this into a geojson file, use <a href="https://github.com/pvernier/csv2geojson">https://github.com/pvernier/csv2geojson</a> with:

```bash
git clone git@github.com:pvernier/csv2geojson.git
(cd csv2geojson/; go build main.go)
./csv2geojson/main hmos.csv
```
