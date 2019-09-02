#!/usr/bin/env python3

import os, git, sys, json, re

BLACKS = [re.compile('_.*'), re.compile('\..*')]

base=sys.argv[1]
to=sys.argv[2]

def process(dir, relv, result):    
    for d in os.listdir(dir):
        black = False        
        for b in BLACKS:
            if b.match(d):
                black = True
                break
        if black:
            continue
        c = dir + '/' + d
        if os.path.isfile(c):
            continue        
        if os.path.isdir(c + '/.git'):    
            print(c)        
            repo = {
                'remotes': [],
                'path': relv + '/' + d
            }
            g = git.Repo(c)
            for rem in g.remotes:
                remote = {
                    'name': rem.name,
                    'urls': []
                }
                for url in rem.urls:
                    remote['urls'].append(url)
                repo['remotes'].append(remote)
            result.append(repo)
        else:       
            process(c, relv + '/' + d, result)
    return result

res = process(base, '', [])
open(to, 'w').write(json.dumps(res))