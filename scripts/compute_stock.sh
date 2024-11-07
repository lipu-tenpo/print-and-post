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
    sku = $5;
    quantity = $6;
    printf "%s of %s %s\n", quantity, sku, inorout > "/dev/stderr";

    if (sku == "null") {next}

    if (inorout == "IN") {
    stock[sku] += quantity;
    } else if (inorout == "OUT") {
    stock[sku] -= quantity;
    } else {
    exit "wrong in/out";
    }
} END {
    n = asorti(stock, keyssorted);
    for (s in keyssorted) {
    printf "%s: %s\n", keyssorted[s], stock[keyssorted[s]]
    }
}'
