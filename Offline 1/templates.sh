#!/bin/bash

#declare map 
student_id=()
degree=()
institute=()
declare -A vis
# bubble sort
bubble_sort()
{
    local n=${#student_id[@]}
    echo "$n"
    flag=1;
    for (( i = 0; i < $n-1; i++ ))
    do
        flag=0;
        for ((j = 0; j < $n-1-$i; j++ ))
        do
            if [[ ${student_id[$j]} -gt ${student_id[$j+1]} ]]
            then
                local temp=${student_id[$j]};
                student_id[$j]=${student_id[$j+1]};
                student_id[$j+1]=$temp;
                flag=1;
            fi
        done

        if [[ $flag -eq 0 ]]; then
            break;
        fi
    done
}


# print array
echo "${student_id[@]}"


#file read
while read -r line; do
    for wrd in $line; do
        word[idx]=$wrd;
        idx=$((idx + 1))
    done
done <"$file_name"

for wrd in $line; do
    word[idx]=$wrd;
    idx=$((idx + 1))
done

#read csv file

while IFS=, read -r id deg ins ; do
    echo $id $deg $ins
done <"$file_name"
echo $id $deg $ins


#iterate map
for i in "${!mp[@]}"
do
  echo "$i,${mp[$i]}"
done

#key exists in map
if [ "${same_name[$current_file]}" ]; then
    return
fi


# To count the number of lines: -l
wc -l myfile.sh
# To count the number of words: -w
wc -w myfile.sh

#to count number of lines in pdf
PageCount=$(exiftool -T -filename -PageCount -s3 -ext pdf "x.pdf")
PageCount=$(pdftk "x.pdf" dump_data | grep NumberOfPages | awk '{print $2}')


#sort csv file based on first column
sort -k1 -n -t, filename

# -k1 sorts by column 1.

# -n sorts numerically instead of lexicographically (so "11" will not come before "2,3...").

# -t, sets the delimiter (what separates values in your file) to , since your file is comma-separated.

#take the head sort the rest
(head -n1 "output.csv" && tail -n+2 "output.csv" | sort) >> "output2.csv"


#substring extract
"${current_file:$i:$len}"



