#!/bin/bash
fib(){
    if [ $1 -le 0 ]; then
        echo 0
    elif [ $1 -eq 1 ]; then
        echo 1
    else
        local ind=$1
        echo $(( $(fib $((ind - 1)) ) + $(fib $((ind - 2)) ) ))
    fi
}

fib $1

