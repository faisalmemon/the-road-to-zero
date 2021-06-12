#!/bin/bash

masterInput=bookbuilderlogo.png

sizes=(16 32 64 128 256 512 1024)

for size in ${sizes[@]}; do
    echo sips -o icon${size}x${size}.png -Z $size $masterInput
    sips -o icon${size}x${size}.png -Z $size $masterInput
done

