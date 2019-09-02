#!/usr/bin/env python3

import os, git, sys, json, re

tree=sys.argv[1]
out=sys.argv[2]

def process(node, dir):
    pass

nodes=json.loads(''.join(open('tree').readlines()))
process(nodes, out)