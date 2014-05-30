#!/bin/bash

sed -i .bkup '402s/-rpath/-Wc,-stdlib=libstdc\+\+ -rpath/g' $1/IlmImf/Makefile
rm $1/IlmImf/Makefile.bkup
