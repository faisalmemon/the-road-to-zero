#!/bin/bash


for item in $(cat tcc_manager_daemons.txt)
do
    strings $item 2>/dev/null | grep -l HOME --label $item 
done
