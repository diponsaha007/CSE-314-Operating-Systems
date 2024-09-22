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
declare -A ext_count
declare -A same_name
ignored=0

check_file_extension()
{
    #checks if file extension is in the given input file
    local current_file=$1
    local position=-1
    for (( i=0; i<${#current_file}; i++ )); do
        if [ "${current_file:$i:1}" == "." ]; then
            position=$((i+1))
        fi
    done
    if (( position == -1 )); then
        return 0
    fi
    local len=$((${#current_file}-position+1))
    local extension=${current_file:$position:$len}
    for i in "${word[@]}"
    do
        if [[ $i == "$extension" ]];then
            return 1
        fi
    done
    return 0
}

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
    if [ "${same_name[$current_file]}" ]; then
        return
    fi
    same_name[$current_file]=1
    local level=$2
    local path=$3
    
    local position=-1
    for (( i=0; i<${#current_file}; i++ )); do
        if [[ ${current_file:$i:1} == "." ]]; then
            position=$((i+1))
        fi
    done
    local extension="others"
    if (( position != -1 )); then
        local len=$((${#current_file}-position+1))
        extension=${current_file:$position:$len}
    fi
    cd "$back_to"
    mkdir -p output_dir/"$extension"
    touch "output_dir/$extension/desc_$extension.txt"
    echo "$path/$current_file" >> "output_dir/$extension/desc_$extension.txt"
    cd "$path"

    local lagbe="$back_to/"
    lagbe+="output_dir/$extension"
    cp "$current_file" "$lagbe"

    #increment count of this extension
    local cnt=1
    if [ "${ext_count[$extension]}" ]; then
        cnt=$((${ext_count[$extension]}+1))
    fi
    ext_count[$extension]=$cnt
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
            if ( check_file_extension "$f" ); then
                local path
                path=$(get_relative_path "${parents[$f]}")
                put_file_in_directory "$f" "$2" "$path"
            else
                ignored=$((ignored+1))
            fi
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


#get all the files
directory_tree "$directory" 1

#print count in csv file 
cd "$back_to"
touch "output.csv"
echo "file_type,no_of_files" > "output.csv"

for i in "${!ext_count[@]}"
do
  echo "$i,${ext_count[$i]}" >> "output.csv"
done

echo "ignored,$ignored" >> "output.csv"
