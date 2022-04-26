#!/bin/bash

. map.sh

map abbr["USA"]=the United States of America
map abbr["RUS"]=Russia Federation
map abbr["PRC"]="the People's Republic of China"

if map abbr.exists "USA"; then
    map abbr["USA"]
fi

echo "Size of map: $(map abbr.size)"
echo "Map contains the following keys:"
map abbr.keys
