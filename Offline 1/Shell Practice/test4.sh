#!/bin/bash
print_in_level()
{
    for((i=1;i < $1;i=i+1))
    do
        echo -ne '|..'
    done
    echo '|--'$2
}

directory_tree_printing()
{
    cd $1

    for f in *
    do
        if [ -d "$f" ]; then
            local x=$(($2 + 1))
            print_in_level $2 "$f"
            directory_tree_printing "$f" $x
        elif [ -f "$f" ]; then
            print_in_level $2 "$f"
        fi
    done

    cd ..
}

declare -A myMap=(["my00"]="00" ["my01"]="01")
myMap["my02"]="02"
myMap["my03"]="03"

if [ ${myMap["my05"]} ]; then
    echo "exist"
fi


if [ ${myMap["my05"]} ]; then
    echo "exist"
fi