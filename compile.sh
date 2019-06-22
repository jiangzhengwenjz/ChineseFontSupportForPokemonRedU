#!/usr/bin/env bash

gcc -m32 convert.c -o convert
gcc -m32 split.c -o split
gcc -m32 insert.c -o insert
rgbasm -o textreader.o textreader.asm
rgblink -o textreader.bin textreader.o
./insert
rgbfix -f g PokemonBrown54.gb
