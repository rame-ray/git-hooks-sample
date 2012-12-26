package com.awanitech.utils;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.xpath.*;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import java.util.Iterator;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class ChangeXml {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		transform_config("gudville-ng") ;
		transform_config("en-csr") ;
		//transform_config("gudvile-stage") ;
	}
	
	public static void transform_config(String configUration) {
		// TODO Auto-generated method stub 

		try {
			// Load Configuration 
			JSONParser parser = new JSONParser(); 
			Object obj = parser.parse(new FileReader("configs.json"));
			JSONObject configObject = (JSONObject) obj;
			JSONObject currConfig =  (JSONObject) configObject.get(configUration);	
			
			String base_url = (String) currConfig.get("base-url"); 
			String linkedin_api_key = (String) currConfig.get("linkedin-api_key"); 
			String linkedin_api_secret = (String) currConfig.get("linkedin-api_secret");
			String facebook_api_key = (String) currConfig.get("facebook-api_key"); 
			String facebook_api_secret = (String) currConfig.get("facebook-api_secret");
			String app_config_file_name = (String) currConfig.get("app-config-file-name");
			
			//  Transform en_app_config.xml
			
			String filepath = ("en_app_config.xml");
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
			Document doc = docBuilder.parse(filepath);
			XPath xpath = XPathFactory.newInstance().newXPath();
			
			//-- Base URL Part 
			Object baseUrlSet = xpath.evaluate("*/context/*", doc, XPathConstants.NODESET);
			NodeList list_context_level_1 = (NodeList)baseUrlSet ;
			for (int idxBaseUrlNodes = 0; idxBaseUrlNodes < list_context_level_1.getLength(); idxBaseUrlNodes++ ) {
				Node currbaseUrlNode = list_context_level_1.item(idxBaseUrlNodes) ;
				if (currbaseUrlNode.getNodeType() == Node.ELEMENT_NODE) {
					NamedNodeMap currbaseUrlNodeAttrs = currbaseUrlNode.getAttributes();
					for (int idxCurrBaseNodeAttr = 0; 
							idxCurrBaseNodeAttr < currbaseUrlNodeAttrs.getLength(); idxCurrBaseNodeAttr++ ) {
						
						if (currbaseUrlNodeAttrs.getNamedItem("name").toString().
								equals("name=\"Application installation information for white labeling\"")) {
							       //Find elements with name name="base_app_url"
							NodeList currbaseUrlParamNodeList = currbaseUrlNode.getChildNodes() ;
							for (int idxcurrbaseUrlParam = 0; idxcurrbaseUrlParam < currbaseUrlParamNodeList.getLength(); 
									idxcurrbaseUrlParam++) {
								
								Node currbaseUrlParamNode = currbaseUrlParamNodeList.item(idxcurrbaseUrlParam);
								if (currbaseUrlParamNode.getNodeType() == Node.ELEMENT_NODE) {
									NamedNodeMap currbaseUrlParamAttrs = currbaseUrlParamNode.getAttributes();
								
								if (currbaseUrlParamAttrs.getNamedItem("name").toString().equals("name=\"base_app_url\"")){
									Node currbaseUrlParamValueNode = currbaseUrlParamAttrs.getNamedItem("value") ;
									currbaseUrlParamValueNode.setTextContent(base_url);
								}
								
								}
							}
							
						}
					}
				}
				
			}
			
			
			//-- Social Fix part 
			Object set = xpath.evaluate("*/context/context/context", doc, XPathConstants.NODESET);
			NodeList list = (NodeList) set;
			int count = list.getLength();
			for (int i = 0; i < count; i++) {
			    Node node = list.item(i);
			    
			    NamedNodeMap attrmap = node.getAttributes();
			    	Node currNode = attrmap.getNamedItem("name") ;
			    	
			    	
			    	if (currNode.toString().equals("name=\"Facebook implementation\"")) {

			    		NodeList socNodes = node.getChildNodes();
			    		for (int idxsocNodes = 0; idxsocNodes < socNodes.getLength(); idxsocNodes++  ) {
			    			Node aSocNode = socNodes.item(idxsocNodes) ;
			    			if (aSocNode.getNodeType() == Node.ELEMENT_NODE ) {
			    				NamedNodeMap socAttrs = aSocNode.getAttributes();
			    				if (socAttrs.getNamedItem("name").toString().equals("name=\"api_key\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent(facebook_api_key);
			    					
			    				}else if (socAttrs.getNamedItem("name").toString().equals("name=\"api_secret\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent(facebook_api_secret);
			    					
			    				}
			    				
			    			}
			    		}
			    		
			    	} else if(currNode.toString().equals("name=\"LinkedIn implementation\"")) {
			    		NodeList socNodes = node.getChildNodes();
			    		for (int idxsocNodes = 0; idxsocNodes < socNodes.getLength(); idxsocNodes++  ) {
			    			Node aSocNode = socNodes.item(idxsocNodes) ;
			    			if (aSocNode.getNodeType() == Node.ELEMENT_NODE ) {
			    				NamedNodeMap socAttrs = aSocNode.getAttributes();
			    				if (socAttrs.getNamedItem("name").toString().equals("name=\"api_key\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent(linkedin_api_key);
			    					
			    				}else if (socAttrs.getNamedItem("name").toString().equals("name=\"api_secret\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent(linkedin_api_secret);
			    					
			    				}
			    				
			    			}
			    		}
			    	}  
			    	
					TransformerFactory transformerFactory = TransformerFactory.newInstance();
					Transformer transformer = transformerFactory.newTransformer();
					DOMSource source = new DOMSource(doc);
					StreamResult result = new StreamResult(new File(app_config_file_name));
					transformer.transform(source, result);
			}	
			
		} catch (Exception e){
			e.printStackTrace();
		}
		System.out.println("function transform_config ended well for " + configUration);
	}

}
