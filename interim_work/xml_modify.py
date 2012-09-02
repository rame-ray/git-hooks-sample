#!/usr/bin/env python 
import pdb
import re
import sys
import json 
import xml.etree
from xml.etree.ElementTree  import ElementTree
xml.etree.ElementTree.register_namespace('','http://appengine.google.com/ns/1.0')

configuration = sys.argv[1] 

tree=ElementTree() 

json_file = 'data.json' 
json_hash =  {} 
xmlpath = './'
xmlnamespace = '{http://appengine.google.com/ns/1.0}'

try :
	json_data = open(json_file) 
        json_hash = json.load(json_data) 

except  IOError :
	print "Failed to open ", json_file 
except ValueError:
	print "Failed to parse ", json_file 

#---------- appengine-web.xml ####################
       
fullpath =  xmlpath+'appengine-web.xml'

appengine_web_xml = tree.parse(fullpath) 

version =  appengine_web_xml.find(xmlnamespace+'version')
version.text =  json_hash[configuration]['version'] 

application =  appengine_web_xml.find(xmlnamespace+'application')
application.text =  configuration
tree.write(fullpath + '.'+ configuration) 

#---------- END appengine-web.xml ####################

##--en_app_config.xml ################################

fullpath =  xmlpath+'en_app_config.xml'

facebook_elem = None 
linkedin_elem = None 

en_app_config = tree.parse(fullpath) 

for context in en_app_config.findall('*/context') :
	curr_ctx =context.attrib['name']
	match_str = 'Application installation information for white labeling'
        if re.match(curr_ctx, match_str):
		whitelist = context 
	for whitelist_param in whitelist.findall('param') :
        	if re.match(whitelist_param.attrib['name'], 'base_app_url'):
			whitelist_param.attrib['value'] = 'http://' + json_hash[configuration]['base-url']


for context in en_app_config.findall('*/*/context') :
	what_path = context.attrib['path'] 
        if re.match(what_path, 'facebook'):
		facebook_elem = context 
        if re.match(what_path, 'linkedin'):
		linkedin_elem = context 



for fbparam in facebook_elem.findall('param') :
        if re.match(fbparam.attrib['name'], 'api_key'):
		fbparam.attrib['value'] = json_hash[configuration]['facebook-api_key']
        if re.match(fbparam.attrib['name'], 'api_secret'):
		fbparam.attrib['value'] = json_hash[configuration]['facebook-api_secret']


## End facebook 

for lnparam in linkedin_elem.findall('param') :
        if re.match(lnparam.attrib['name'], 'api_key'):
		lnparam.attrib['value'] = json_hash[configuration]['linkedin-api_key']
        if re.match(lnparam.attrib['name'], 'api_secret'):
		lnparam.attrib['value'] = json_hash[configuration]['linkedin-api_secret']

tree.write(fullpath + '.'+ configuration) 

#----------  en_app_config.xml ##########################
