#!/usr/bin/env python3

import os, git, sys, json, re

tree=sys.argv[1]
out=sys.argv[2]

def process(nodes, dir):
    for node in nodes:
        path = out + node['path']
        print(path)
        if os.path.isdir(path):
            now = os.getcwd()
            os.chdir(path)
            os.system('git pull')
            os.chdir(now)
        else:       
            if len(node['remotes']) == 0:
                continue     
            cur = node['remotes'][0]
            url = cur['urls'][0]
            os.system('git clone ' + url + ' ' + path)

nodes=json.loads(''.join(open(tree).readlines()))
process(nodes, out)