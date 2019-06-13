#!/bin/bash

STRING_PATTERN="^([a-zA-Z0-9\-])\$"
STRING_LENGTH=32

function generate_string(){
  #head  /dev/urandom | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 60 ; echo ' '
  head  /dev/urandom | tr -dc "${STRING_PATTERN}" | head -c ${STRING_LENGTH}; echo ''
}

function initalize(){
  if [[ ! -z "$1" ]]; then
    STRING_PATTERN=$1
  fi

  if [[ ! -z "$2" ]]; then
    STRING_LENGTH=$2
  fi
}

initalize $1 $2
generate_string
