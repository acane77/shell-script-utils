#!/bin/bash

. map.sh

map abbr["USA"]=the United States of America
map abbr["RUS"]=Russia Federation
map abbr["PRC"]="the People's Republic of China"

if map abbr.exists "USA"; then
    map abbr["USA"]
fi

echo "Size of map: $(map abbr.size)"

echo "Map content:"
for k in $(map abbr.keys); do
    value=$(map abbr["$k"])
    echo "  $k --> $value"
done