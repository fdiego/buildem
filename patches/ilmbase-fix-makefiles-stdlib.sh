#!/bin/bash

sed -i .bkup '283s/-rpath/-Wc,-stdlib=libstdc\+\+ -rpath/g' $1/Half/Makefile
sed -i .bkup '270s/-rpath/-Wc,-stdlib=libstdc\+\+ -rpath/g' $1/Iex/Makefile
sed -i .bkup '290s/-rpath/-Wc,-stdlib=libstdc\+\+ -rpath/g' $1/Imath/Makefile
sed -i .bkup '282s/-rpath/-Wc,-stdlib=libstdc\+\+ -rpath/g' $1/IlmThread/Makefile
rm $1/Half/Makefile.bkup
rm $1/Iex/Makefile.bkup
rm $1/Imath/Makefile.bkup
rm $1/IlmThread/Makefile.bkup