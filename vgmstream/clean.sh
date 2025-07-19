#!/bin/bash
find -maxdepth 2 | grep "\.build" | xargs rm -r 
rm .install -r
pushd ffmpeg
make clean
popd