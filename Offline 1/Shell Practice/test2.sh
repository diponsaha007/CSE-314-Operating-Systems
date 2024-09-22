#!/bin/bash

function fun1(){
    echo 23
    echo 34
}

function fun2(){
  local res=$(fun1)
  echo $res
}

fun2