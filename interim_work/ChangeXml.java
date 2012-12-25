package com.awanitech.utils;
import java.io.File;
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

public class ChangeXml {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub 

		try {
			String filepath = ("input-mahesh.xml");
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
			Document doc = docBuilder.parse(filepath);
			XPath xpath = XPathFactory.newInstance().newXPath();
			Object set = xpath.evaluate("*/context/context/context", doc, XPathConstants.NODESET);
			NodeList list = (NodeList) set;
			int count = list.getLength();
			for (int i = 0; i < count; i++) {
			    Node node = list.item(i);
			    
			    NamedNodeMap attrmap = node.getAttributes();
			    	Node currNode = attrmap.getNamedItem("name") ;
			    	
			    	
			    	if (currNode.toString().equals("name=\"Facebook implementation\"")) {
			    		System.out.println("Interesting Node Found ::" + currNode);
			    		NodeList socNodes = node.getChildNodes();
			    		for (int idxsocNodes = 0; idxsocNodes < socNodes.getLength(); idxsocNodes++  ) {
			    			Node aSocNode = socNodes.item(idxsocNodes) ;
			    			if (aSocNode.getNodeType() == Node.ELEMENT_NODE ) {
			    				NamedNodeMap socAttrs = aSocNode.getAttributes();
			    				System.out.println(socAttrs.getNamedItem("name") + "::" + socAttrs.getNamedItem("value")) ;
			    				if (socAttrs.getNamedItem("name").toString().equals("name=\"api_key\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent("MAHESH-soc-KEY");
			    					
			    				}else if (socAttrs.getNamedItem("name").toString().equals("name=\"api_secret\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent("MAHESH-soc-SECRET");
			    					
			    				}
			    				System.out.println("POST " + socAttrs.getNamedItem("name") + "::" + socAttrs.getNamedItem("value")) ;
			    				
			    			}
			    		}
			    		
			    	} else if(currNode.toString().equals("name=\"LinkedIn implementation\"")) {
			    		System.out.println("Interesting Node Found ::" + currNode);
			    		NodeList socNodes = node.getChildNodes();
			    		for (int idxsocNodes = 0; idxsocNodes < socNodes.getLength(); idxsocNodes++  ) {
			    			Node aSocNode = socNodes.item(idxsocNodes) ;
			    			if (aSocNode.getNodeType() == Node.ELEMENT_NODE ) {
			    				NamedNodeMap socAttrs = aSocNode.getAttributes();
			    				System.out.println(socAttrs.getNamedItem("name") + "::" + socAttrs.getNamedItem("value")) ;
			    				if (socAttrs.getNamedItem("name").toString().equals("name=\"api_key\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent("MAHESH-LI-KEY");
			    					
			    				}else if (socAttrs.getNamedItem("name").toString().equals("name=\"api_secret\"")) {
			    					Node aSocValueNode = socAttrs.getNamedItem("value") ;
			    					aSocValueNode.setTextContent("MAHESH-LI-SECRET");
			    					
			    				}
			    				System.out.println("POST " + socAttrs.getNamedItem("name") + "::" + socAttrs.getNamedItem("value")) ;
			    				
			    			}
			    		}
			    	}  
			    	
					TransformerFactory transformerFactory = TransformerFactory.newInstance();
					Transformer transformer = transformerFactory.newTransformer();
					DOMSource source = new DOMSource(doc);
					StreamResult result = new StreamResult(new File("mahesh.xml"));
					transformer.transform(source, result);
			}	
			
		} catch (Exception e){
			e.printStackTrace();
		}
		System.out.println("program ended well");
	}

}
