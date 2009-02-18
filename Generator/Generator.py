#! /usr/bin/env python
#
#  Generator.py
#  This file is part of Ceres.
#
#  Ceres is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Ceres is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Ceres.  If not, see <http://www.gnu.org/licenses/>.
#
#  Created by Fernando Alexandre on 1/30/09.
#  Used part of http://snippets.dzone.com/posts/show/2887 by Andrew Pennebaker (andrew.pennebaker@gmail.com)
#

import urllib
import sys
import os
import bz2
import sqlite3

from xml.dom.minidom import Document, Element, Node

def fixedxml(self, writer, indent="", addindent="", newl=""):
    # indent = current indentation
    # addindent = indentation to add to higher levels
    # newl = newline string
    writer.write(indent+"<" + self.tagName)
    
    attrs = self._get_attributes()
    a_names = attrs.keys()
    a_names.sort()
    
    for a_name in a_names:
      writer.write(" %s=\"" % a_name)
      _write_data(writer, attrs[a_name].value)
      writer.write("\"")
    
    if self.childNodes:
        if len(self.childNodes) == 1 and self.childNodes[0].nodeType == Node.TEXT_NODE:
            writer.write(">")
            self.childNodes[0].writexml(writer, "", "", "")
            writer.write("</%s>%s" % (self.tagName, newl))
        else:
            writer.write(">%s"%(newl))
            for node in self.childNodes:
                node.writexml(writer,indent+addindent,addindent,newl)
            writer.write("%s</%s>%s" % (indent,self.tagName,newl))
    else:
        writer.write("/>%s"%(newl))


Element.writexml = fixedxml

def fileExists(f):
  try:
    file = open(f)
  except IOError:
    return False
  else:
    return True

def getURLName(url):
  return "%s%s%s%s%s" % (
    os.curdir,
    os.sep,
    "Data",
    os.sep,
    url.split("/")[-1]
  )

def createDownload(url):
  instream=urllib.urlopen(url)
  
  filelenght=instream.info().getheader("Content-Length")
  if filelenght==None:
    filelenght="temp"
  
  return (instream, filelenght)

def downloadDump(dumpName):
  if fileExists(getURLName(dumpName)):
    return
  
  try:
    outfile=open(getURLName(dumpName), "wb")
    fileName=outfile.name.split(os.sep)[-1]
    
    dumpName, length=createDownload(dumpName)
    if not length:
      length="?"
    
    print "Downloading %s (%s bytes) ..." % (dumpName, length)
    if length!="?":
      length=float(length)
    bytesRead=0.0
    
    for line in dumpName:
      bytesRead+=len(line)
      
      if length!="?":
        print "%s: %.02f/%.02f kb (%d%%)" % (
          fileName,
          bytesRead/1024.0,
          length/1024.0,
          100*bytesRead/length
        )
      
      outfile.write(line)
    
    dumpName.close()
    outfile.close()
    print "Finished Downloading."
  
  except Exception, e:
    print "Error downloading %s: %s" % (dumpName, e)

def decompressbz2(filePath):
  fileName = sys.argv[1].split("/")[-1]
  print "Extracting %s..." % (fileName)
  decompressedFileName = getURLName(fileName.split(".")[0] + ".db")
  
  if fileExists(decompressedFileName):
    return decompressedFileName
  
  compressedDump = open(getURLName(sys.argv[1]), "rb")
  decompressedDump = bz2.decompress(compressedDump.read())
  try:
    open(decompressedFileName, "wb").write(decompressedDump)
  except Exception, e:
    print "Error decompressing %s" % (decompressedFileName)
  
  return decompressedFileName

def writeXML(name, doc):
  #stream = StringIO()
  #PrettyPrint(node, stream=stream, encoding='utf-8')
  open(getURLName(name), "w").write(doc.toprettyxml(indent="  "))

def addChild(doc, parent, name, text):
  element = doc.createElement(name)
  element.appendChild(doc.createTextNode(text))
  parent.appendChild(element)

def processDB(dbPath):
  print dbPath
  conn = sqlite3.connect(dbPath)
  
  c = conn.cursor()
  
  #categories
  print "Processing Categories..."
  c.execute("""SELECT categoryID AS identifier, categoryName AS name, published, description FROM invCategories;""")
  doc = Document()
  categories = doc.createElement("categories")
  doc.appendChild(categories)
  for row in c:
    category = doc.createElement("category")
    
    addChild(doc, category, "identifier", str(row[0]))
    addChild(doc, category, "name", str(row[1]))
    addChild(doc, category, "published", str(row[2]))
    addChild(doc, category, "description", str(row[3]))
    
    categories.appendChild(category)
  
  writeXML("Categories.xml", doc)
  
  #clones
  print "Processing Clones..."
  c.execute("""SELECT invTypes.typeID AS identifier, typeName AS name, basePrice AS price, valueInt AS skillpoints, description
               FROM invTypes INNER JOIN dgmTypeAttributes ON invTypes.typeID = dgmTypeAttributes.typeID
               WHERE groupId = 23 AND attributeID = 419;""")
  doc = Document()
  clones = doc.createElement("clones")
  doc.appendChild(clones)
  for row in c:
    clone = doc.createElement("clone")
    
    addChild(doc, clone, "identifier", str(row[0]))
    addChild(doc, clone, "name", str(row[1]))
    addChild(doc, clone, "price", str(row[2]))
    addChild(doc, clone, "skillpoints", str(row[3]))
    addChild(doc, clone, "description", str(row[4]))
    
    clones.appendChild(clone)
  
  writeXML("Clones.xml", doc)
  
  #groups
  print "Processing Groups..."
  c.execute("""SELECT groupID AS identifier, categoryID as categoryIdentifier, groupName AS name, published, description
               FROM invGroups;""")
  doc = Document()
  groups = doc.createElement("groups")
  doc.appendChild(groups)
  for row in c:
    group = doc.createElement("group")
    
    addChild(doc, group, "identifier", str(row[0]))
    addChild(doc, group, "categoryIdentifier", str(row[1]))
    addChild(doc, group, "name", str(row[2]))
    addChild(doc, group, "published", str(row[3]))
    addChild(doc, group, "description", str(row[4]))
    
    groups.appendChild(group)
  
  writeXML("Groups.xml", doc)
  
  #MarketGroups
  print "Processing MarketGroups..."
  c.execute("""SELECT marketGroupID AS identifier, parentGroupID AS parentIdentifier, marketGroupName AS name, hasTypes, description
               FROM invMarketGroups;""")
  doc = Document()
  marketgroups = doc.createElement("marketgroups")
  doc.appendChild(marketgroups)
  for row in c:
    marketgroup = doc.createElement("marketgroup")
    
    addChild(doc, marketgroup, "identifier", str(row[0]))
    addChild(doc, marketgroup, "parentIdentifier", str(row[1]))
    addChild(doc, marketgroup, "name", str(row[2]))
    addChild(doc, marketgroup, "hasTypes", str(row[3]))
    addChild(doc, marketgroup, "description", str(row[4]))
    
    marketgroups.appendChild(marketgroup)
  
  writeXML("MarketGroups.xml", doc)
  
  #Skills
  print "Processing Skills..."
  # c.execute("""SELECT typeID AS identifier, typeName AS name, invGroups.groupID AS groupIdentifier, marketGroupID AS marketGroupIdentifier, basePrice, invTypes.published
  #              FROM invTypes INNER JOIN invGroups ON invTypes.groupID = invGroups.groupID
  #              WHERE categoryID = 16;""")
  c.execute("""SELECT
                 inv.typeID AS identifier,
                 inv.typeName AS name,
                 inv.groupID AS groupIdentifier,
                 inv.marketGroupID as marketGroupIdentifier,
                 inv.basePrice as basePrice,
                 inv.published AS published,
                 rank.valueFloat AS rank,
                 (primaryAttribute.valueInt - 164) AS primaryAttribute,
                 (secondaryAttribute.valueInt - 164) AS secondaryAttribute,
                 inv.description AS description
               FROM invTypes inv
               INNER JOIN invGroups ON (inv.groupID = invGroups.groupID)
               INNER JOIN dgmTypeAttributes primaryAttribute ON (inv.typeID = primaryAttribute.typeID)
               INNER JOIN dgmTypeAttributes secondaryAttribute ON (inv.typeID = secondaryAttribute.typeID)
               INNER JOIN dgmTypeAttributes rank ON (inv.typeID = rank.typeID)
               WHERE invGroups.categoryID = 16
                 AND rank.attributeID = 275
                 AND primaryAttribute.attributeID = 180
                 AND secondaryAttribute.attributeID = 181
               ORDER BY identifier;""")
  doc = Document()
  skills = doc.createElement("skills")
  doc.appendChild(skills)
  for row in c:
    skill = doc.createElement("skill")
    
    addChild(doc, skill, "identifier", str(row[0]))
    addChild(doc, skill, "name", str(row[1]))
    addChild(doc, skill, "groupIdentifier", str(row[2]))
    addChild(doc, skill, "marketGroupIdentifier", str(row[3]))
    addChild(doc, skill, "price", str(row[4]))
    addChild(doc, skill, "published", str(row[5]))
    addChild(doc, skill, "rank", str(row[6]))
    
    primary = attribute = {
      0 : "Charisma",
      1 : "Intelligence",
      2 : "Memory",
      3 : "Perception",
      4 : "Willpower"
    }.get(int(row[7]))
    
    secondary = attribute = {
      0 : "Charisma",
      1 : "Intelligence",
      2 : "Memory",
      3 : "Perception",
      4 : "Willpower"
    }.get(int(row[8]))
    
    addChild(doc, skill, "primaryAttribute", primary)
    addChild(doc, skill, "secondaryAttribute", secondary)
    addChild(doc, skill, "description", str(row[9]))
    
    skills.appendChild(skill)
  
  writeXML("Skills.xml", doc)
  
  #implants
  print "Processing Implants..."
  c.execute("""SELECT invTypes.typeID as Identifier, invTypes.groupID as groupIdentifier, invTypes.typeName as Name, invTypes.basePrice, invTypes.marketGroupID as marketGroupIdentifier, invTypes.published, (invTypes.marketGroupID - 617) AS slot, (attributeID - 175) AS attribute, valueInt AS attributeBonus, description
               FROM dgmTypeAttributes INNER JOIN invTypes ON invTypes.typeID = dgmTypeAttributes.typeID
               WHERE invTypes.marketGroupID >= 618 AND invTypes.marketGroupID <= 627 AND dgmTypeAttributes.attributeID >= 175 AND dgmTypeAttributes.attributeID <= 179 AND dgmTypeAttributes.valueInt != 0""")
  doc = Document()
  implants = doc.createElement("implants")
  doc.appendChild(implants)
  for row in c:
    implant = doc.createElement("implant")
    
    addChild(doc, implant, "identifier", str(row[0]))
    addChild(doc, implant, "groupIdentifier", str(row[1]))
    addChild(doc, implant, "name", str(row[2]))
    addChild(doc, implant, "price", str(row[3]))
    addChild(doc, implant, "marketGroupIdentifier", str(row[4]))
    addChild(doc, implant, "published", str(row[5]))
    addChild(doc, implant, "slot", str(row[6]))
    
    attribute = {
      0 : "Charisma",
      1 : "Intelligence",
      2 : "Memory",
      3 : "Perception",
      4 : "Willpower"
    }.get(int(row[7]))
    
    addChild(doc, implant, "attribute", attribute)
    addChild(doc, implant, "attributeBonus", str(row[8]))
    addChild(doc, implant, "description", str(row[9]))
    
    implants.appendChild(implant)
  
  writeXML("Implants.xml", doc)

def main():
  
  try:
    downloadDump(sys.argv[1])
  except Exception, e:
    print "Link to database needed as argument! (%s)" % (e)
    sys.exit(0)
  
  dbPath = decompressbz2(getURLName(sys.argv[1]))
  
  processDB(getURLName(dbPath))
  
  print "All Done!"

if __name__=="__main__":
  main()