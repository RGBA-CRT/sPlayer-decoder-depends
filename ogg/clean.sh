#!/bin/bash
find -maxdepth 2 | grep "\.build" | xargs rm -r 
rm -r .install