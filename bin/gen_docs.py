#!/usr/bin/env python3

import subprocess
import yaml
import shlex
import os


# Get the path to this repo's bin/ directory
binpath = '/'.join(os.path.abspath(__file__).split('/')[:-1])+'/'

with open(binpath+'../codelabs.yaml','r') as f:
    codelabs = yaml.safe_load(f)

# Generate the documents
os.chdir(binpath+'../docs')
for cl in codelabs['codelabs']:
    cmd = binpath+"claat export "+cl['gdoc']
    subprocess.run(shlex.split(cmd))
