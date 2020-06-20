#!/bin/bash
export ANNA_HOME=$PWD
sudo apt-get -y install g++ 
haxelib setup ../../haxelib
haxelib install hxcpp
haxelib git sepia git@github.com:skylerparr/sepia.git
haxelib dev sepia ../../haxelib/sepia/git/src
haxelib git hscript-plus git@github.com:skylerparr/hscript-plus.git
haxelib git hxbert git@github.com:skylerparr/hxbert.git
haxelib dev hxbert ../../haxelib/hxbert/git/src

haxe build-static.hxml
