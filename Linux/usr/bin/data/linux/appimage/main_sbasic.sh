#!/bin/bash
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${APPDIR}/usr/lib"
cd $APPDIR/usr/bin
./sbasic -m ./ main.bas
