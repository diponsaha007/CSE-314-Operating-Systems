#!/bin/bash

declare -A places

while read -r line; do
    places[$line]=0
done <"places.txt"
if (( ${#line} !=0)); then
    places[$line]=0
fi


while IFS=, read -r name all_place ; do
    IFS=,
    for word in $all_place; do
        if (( ${#word} !=0 )); then
            places[$word]=$((${places[$word]} + 1))
        fi
    done
done <"visited.csv"
IFS=,
for word in $all_place; do
    if (( ${#word} !=0 )); then
        places[$word]=$((${places[$word]} + 1))
    fi
done
touch "output.txt"
echo -n "" > "output.txt" 
for i in "${!places[@]}"
do
  echo "$i ${places[$i]}" >> "output.txt"
done

mini=1000000
min_place=""

for i in "${!places[@]}"
do
  if [[ ${places[$i]} < $mini ]];then
    mini=${places[$i]}
    mini_place=$i
  fi
done

echo "$mini_place is the most suitable place to visit" >> "output.txt"

