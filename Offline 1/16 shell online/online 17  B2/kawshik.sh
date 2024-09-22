#! /bin/bash
id_arr=()
deg_arr=()
inst_arr=()
 
 
filename="$1"
index=$((0))
while IFS="," read -r id deg inst
do
    if [ $index -eq 0 ]; then
        index=$(($index+1))
    else
        echo "id: $id"
        echo "deg: $deg"
        echo "inst: $inst"
        id_arr[$index]=$(($id))
        deg_arr[$index]="$deg";
        inst_arr[$index]="$inst" 
        index=$(($index+1))
    fi
done < $filename
 
n=$index
flag=1;
for (( i = 0; i < $n-1; i++ ))
do
    flag=0;
    for ((j = 0; j < $n-1-$i; j++ ))
    do
        if [[ ${id_arr[$j]} -gt ${id_arr[$j+1]} ]]
        then
            temp=${id_arr[$j]};
            id_arr[$j]=${id_arr[$j+1]};
            id_arr[$j+1]=$temp;
 
            temp=${deg_arr[$j]};
            deg_arr[$j]=${deg_arr[$j+1]};
            deg_arr[$j+1]=$temp;
 
            temp=${inst_arr[$j]};
            inst_arr[$j]=${inst_arr[$j+1]};
            inst_arr[$j+1]=$temp;
            flag=1;
        fi
    done
 
    if [[ $flag -eq 0 ]]; then
          break;
    fi
done
echo "${id_arr[@]}"
echo "${deg_arr[@]}"
echo "${inst_arr[@]}"
 
for (( i = 0; i < $n - 1; i++ ))
do
    echo "loop i=$i"
    cnt=$((0))
    echo "cnt=$cnt"
    for (( j = i + 1; j < $n; j++ ))
    do
        if [ ${id_arr[$i]} -eq ${id_arr[$j]} ]; then
            cnt=$(($cnt+1))
            echo "cnt=$cnt"
        else
            break
        fi
    done
    echo "cnt=$cnt"
    echo "${id_arr[$i]},$(($cnt+1)),${deg_arr[$i]},${inst_arr[$i]}"
    if [ $cnt -gt 0 ]; then
        for (( k = 0; k < $cnt; k++))
        do
            echo ",,${deg_arr[$i+$k+1]},${inst_arr[$i+$k+1]}"
            echo "k=$k"
        done
    fi
    i=$(($i+$cnt))
done
