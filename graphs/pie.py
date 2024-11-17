"""make pie chart of occupancies of properties
make frequency list with
csvtool namedcol "Permitted Occupants" hmos.csv | awk 'NR>1' | sort -n | uniq -c | sort -k2 -n | sed -E 's/([^ ]) ([^ ])/\1,\2/g' | sed 's/^ *//' | sed '1s/^/occurance,occupants\n/'
or using the Python below
run from folder containing hmos.csv
$ python pie.py
"""

import matplotlib.pyplot as plt
import csv
import sys

with open("hmos.csv", "r", encoding="utf-8") as file:
    reader = csv.DictReader(file)
    csvdata = list(reader)

data = {}  # occupants: frequency
for row in csvdata:
    occup = row["Permitted Occupants"]
    if row["Permitted Occupants"] not in data:
        data[occup] = 1
    else:
        data[occup] += 1

occupants = data.keys()
frequency = [data[k] for k in occupants]

tot = sum([int(f) for f in frequency])

other = 0
freqs = []
occups = []

for f, o in zip(frequency, occupants):
    if f < (tot / 100):
        other += f
    else:
        freqs.append(f)
        occups.append(o)

freqs, occups = zip(*sorted(zip(freqs, occups)))

plt.pie([other, *freqs], labels=[r"other (<1% each)", *occups])
plt.title("HMO Licenced Properties' Permitted Occupancies in Sheffield")

fig = plt.gcf()

plt.show()

fig.savefig("graphs/pie.svg")
