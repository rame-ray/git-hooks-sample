#!/usr/bin/python
import argparse, ConfigParser, os, sys
import logging 
logging.basicConfig(level=1)
scriptname = os.path.realpath(sys.argv[0]) 
configdir = os.path.dirname(scriptname)

print scriptname 
print configdir

build_config = ConfigParser.RawConfigParser()
build_config.read(configdir+'/build.cfg')


parser = argparse.ArgumentParser(description = "MYMY build / deploy script")
parser.add_argument('--publish', '-p', metavar='staging', 
                   help = 'Publish configuration',
	           action = 'store',) 

args = parser.parse_args() 


if args.publish != None :
        publish_list = build_config.items('publish.'+args.publish) 
	

#- Build Ant tasks
for ant_repo in build_config.get('build', 'build.repos').split(','):
	logging.info ("Building  "+ ant_repo)

for tag_repo in build_config.get('build', 'tag.repos').split(','):
	logging.info ("Applying TAG on ::  "+ tag_repo)

#- Do Staging if needed.

#- Do tagging 
