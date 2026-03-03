#!/bin/bash
# sum skus from table (CSV)
# use ./compute_stock.sh file.csv

if [ -z "${1}" ]; then
  echo "use ./compute_stock.sh file.csv"
  exit 1
fi

# remove header from CSV
data=$(cat "${1}" | awk 'NR>1{print}')

# if any lines do not start with 2, complain
badlines=$(echo "${data}" | grep -cE "^[^2]")
if [ $badlines -gt 0 ]; then
    echo "looks to me like some table cells have new lines. I can't do that."
    exit 1
fi

echo "${data}" | awk -F ',' '{
    inorout = $2;
    fromto = $4;
    sku = $5;
    quantity = $6;
    printf "%s of %s %s\n", quantity, sku, inorout > "/dev/stderr";

    if (sku == "null") {next}

    if (fromto == "alifeee") {
      if (inorout == "IN") {
        alifeeestock[sku] += quantity;
      } else if (inorout == "OUT") {
        alifeeestock[sku] -= quantity;
      } else {
        exit "wrong in/out";
      }
    } else {
      otherplaces[fromto] = 1
      if (inorout == "IN") {
        otherstock[sku] += quantity;
      } else if (inorout == "OUT") {
        otherstock[sku] -= quantity;
      } else {
        exit "wrong in/out";
      }
    }
} END {
    printf "with alifeee:\n"
    n = asorti(alifeeestock, keyssorted);
    for (s in keyssorted) {
      if (alifeeestock[keyssorted[s]] != 0) {
        printf "%s: %s\n", keyssorted[s], alifeeestock[keyssorted[s]]
      }
    }

    printf "\n\nother places (seen: "
    for (p in otherplaces) {printf "%s%s", fs, p; fs=", "}
    printf ")\n"
    n2 = asorti(otherstock, keyssorted);
    for (s in keyssorted) {
      if (otherstock[keyssorted[s]] != 0) {
        printf "%s: %s\n", keyssorted[s], otherstock[keyssorted[s]]
      }
    }
}'
