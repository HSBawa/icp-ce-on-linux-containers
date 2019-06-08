#!/bin/sh
#head  /dev/urandom | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 60 ; echo ' '
head  /dev/urandom | tr -dc 'A-Za-z0-9\-' | head -c 32; echo ' '
