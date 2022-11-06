#!/bin/bash

BASEDIR=$(dirname "$0")
#python3 ${BASEDIR}/gen_docs.py

for cl in ${BASEDIR}/../docs/codelabs/*; 
do 
    sed -i "s#https://storage.googleapis.com#../../lib#g" ${cl}/index.html
done

