#!/bin/bash

usage()
{
    echo "Please provide valid arguments"
    echo "Usage : $0 directory_name[Optional] file_name"
    exit
}


check_directory_exist()
{
    #provide 1 argument the directory $1
    directory=$1
    while [ ! -d "$directory" ]
    do
        echo "Input valid directory name!"
        read -r directory
    done
}

check_file_exist()
{
    #provide 1 argument the file_name $1
    file_name=$1
    while [ ! -f "$file_name" ]
    do
        echo "Input valid file name!"
        read -r file_name
    done
}

#global variables
word=()
declare -A parents

get_relative_path()
{
    local now=$1
    if [[ $now == "$directory" ]]; then
        echo "$now"
        return
    fi
    echo "$(get_relative_path  "${parents[$now]}")/$now"
}


put_file_in_directory()
{
    local current_file=$1
    local path=$3
    
    local extension
    local flag=0
    for i in "${word[@]}"
    do
        while read -r line; do
            for wrd in $line; do
                for (( j=0; j<${#wrd}; j++ )); do
                    if [ "${wrd:$j:${#i}}" == "$i" ]; then
                        flag=1
                        extension=$wrd
                    fi
                done
                # if [[ $i == "$wrd" ]]; then
                #     flag=1
                #     extension=$wrd
                # fi
            done
        done <"$current_file"

        for wrd in $line; do
            for (( j=0; j<${#wrd}; j++ )); do
                if [ "${wrd:$j:${#i}}" == "$i" ]; then
                    flag=1
                    extension=$wrd
                fi
            done
            # if [[ $i == "$wrd" ]]; then
            #     flag=1
            #     extension=$wrd
            # fi
        done
    done
    if (( $flag == 0 )); then
        return
    fi

    cd "$back_to"
    cd "$path"

    local lagbe="$back_to/"
    lagbe+="output/$extension"
    cp "$current_file" "$lagbe"

}

directory_tree()
{
    cd "$1"
    for f in *
    do
        parents[$f]=$1
        if [ -d "$f" ]; then
            local x=$(($2 + 1))
            directory_tree "$f" $x
        elif [ -f "$f" ]; then
            #first check if this file extension is ok
            #put the file in its directory
            local path
            path=$(get_relative_path "${parents[$f]}")
            put_file_in_directory "$f" "$2" "$path"
            
        fi
    done
    cd ..
}

extract_from_file()
{
    local idx=0
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
}

if (( $# == 2 )); then
    directory=$1
    file_name=$2
    check_directory_exist "$directory"
    check_file_exist "$file_name"
    #extract words from the file and put them in word array
    extract_from_file
    back_to=$PWD
elif (( $# == 1 )); then
    directory=${PWD##*/}
    file_name=$1
    check_file_exist "$file_name"
    #extract words from the file and put them in word array
    extract_from_file
    cd ..
    back_to=$PWD
else
    usage
fi

echo "Directory name : $directory"
echo "File name : $file_name"

# rm -rf "output"

for i in "${word[@]}"
do
    mkdir -p output/"$i"
done


#get all the files
directory_tree "$directory" 1

