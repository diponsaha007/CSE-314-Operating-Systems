#!/bin/bash

subjects=()
declare -A numbers
declare -A avgg

get_numbers()
{
    local filename="$1"
    while read -r id num; do
        if [ "${numbers[$id]}" ]; then
            numbers[$id]=$((${numbers[$id]}+$num))
        else
            numbers[$id]=$num
        fi
    done <"$filename"
}

get_numbers2()
{
    local filename="$1"
    local id1="$2"
    while read -r id num; do
        if (( $id == $id1 )); then
            echo "$num"
            return
        fi
    done <"$filename"

    echo "0"
}

idx=0
while read -r line; do
    for wrd in $line; do
        subjects[$idx]=$wrd;
        idx=$((idx + 1))
    done
done <"course.txt"

for wrd in $line; do
    subjects[$idx]=$wrd;
    idx=$((idx + 1))
done


echo "${subjects[@]}"

for i in "${subjects[@]}"
do
    get_numbers "$i.txt"
done

sz="${#subjects[@]}"
echo $sz
for i in "${!numbers[@]}"
do
    avgg[$i]=$((${numbers[$i]} / $sz))
done

touch "output.csv"

echo -n "" > "output.csv"

echo -n "Student ID," >> "output.csv"
for i in "${subjects[@]}"
do
    echo -n "$i," >> "output.csv"
done
echo "Total Marks,Average Marks,Grade" >> "output.csv"


for i in "${!numbers[@]}"
do
    echo -n "$i," >>"output.csv"
    for j in "${subjects[@]}"
    do
        now=$(get_numbers2 "$j.txt" "$i")
        echo -n "$now," >> "output.csv"
    done 
    echo -n "${numbers[$i]},${avgg[$i]}," >> "output.csv"
    if (( ${avgg[$i]} >= 80 )); then
        echo  "A" >> "output.csv"
    elif (( ${avgg[$i]} >= 60 )); then
        echo "B" >> "output.csv"
    elif (( ${avgg[$i]} >= 40 )); then
        echo  "C" >> "output.csv"
    else
        echo  "F" >> "output.csv"
    fi
done

(head -n1 "output.csv" && tail -n+2 "output.csv" | sort -k5 -r -n -t, ) >> "output2.csv"

mv -f "output2.csv" "output.csv"

