#!/bin/bash
find -maxdepth 2 | grep "\.build" | xargs rm -rf 
rm -fr .install