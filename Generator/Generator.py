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
#  Created by Ibridi on 1/30/09.
#  Used part of http://snippets.dzone.com/posts/show/2887 by Andrew Pennebaker (andrew.pennebaker@gmail.com)
#

import urllib
import sys
import os
import bz2
import sqlite3
from xml.dom.minidom import Document

def fileExists(f):
  try:
    file = open(f)
  except IOError:
    exists = 0
  else:
    exists = 1
  return exists

def getURLName(url):
  directory=os.curdir

  name="%s%s%s%s%s" % (
    directory,
    os.sep,
    "Data",
    os.sep,
    url.split("/")[-1]
  )

  return name

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
  print "Extracting %s..." % (sys.argv[1].split("/")[-1])
  compressedDump = open(getURLName(sys.argv[1]), "rb")
  decompressedDump = bz2.decompress(compressedDump.read())
  decompressedFileName = getURLName(sys.argv[1].split(".")[0] + ".db")
  try:
    open(decompressedFileName, "wb").write(decompressedDump)

  except Exception, e:
    print "Error decompressing %s" % (decompressedFileName)
  
  return decompressedFileName

def processDB(dbPath):
  print dbPath
  conn = sqlite3.connect(dbPath)
  c = conn.cursor()
  
  #categories
  print "Processing Categories..."
  c.execute("""SELECT categoryID AS identifier, categoryName AS name, published FROM invCategories;""")
  doc = Document()
  categories = doc.createElement("categories")
  doc.appendChild(categories)
  for row in c:
    category = doc.createElement("category")
    
    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    category.appendChild(identifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[1])
    name.appendChild(nameText)
    category.appendChild(name)
    
    published = doc.createElement("published")
    publishedText = doc.createTextNode(str(row[2]))
    published.appendChild(publishedText)
    category.appendChild(published)
    
    categories.appendChild(category)
    
  open(getURLName("Categories.xml"), "w").write(doc.toprettyxml(indent="  "))

  #clones
  print "Processing Clones..."
  c.execute("""SELECT invTypes.typeID AS identifier, typeName AS name, basePrice AS price, valueInt AS skillpoints
  FROM invTypes INNER JOIN dgmTypeAttributes ON invTypes.typeID = dgmTypeAttributes.typeID
  WHERE groupId = 23 AND attributeID = 419;""")
  doc = Document()
  clones = doc.createElement("clones")
  doc.appendChild(clones)
  for row in c:
    clone = doc.createElement("clone")
    
    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    clone.appendChild(identifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[1])
    name.appendChild(nameText)
    clone.appendChild(name)
    
    price = doc.createElement("price")
    priceText = doc.createTextNode(str(row[2]))
    price.appendChild(priceText)
    clone.appendChild(price)
    
    skillpoints = doc.createElement("skillpoints")
    skillpointsText = doc.createTextNode(str(row[3]))
    skillpoints.appendChild(skillpointsText)
    clone.appendChild(skillpoints)
    
    clones.appendChild(clone)
    
  open(getURLName("Clones.xml"), "w").write(doc.toprettyxml(indent="  "))

  #groups
  print "Processing Groups..."
  c.execute("""SELECT groupID AS identifier, categoryID as categoryIdentifier, groupName AS name, published FROM invGroups;""")
  doc = Document()
  groups = doc.createElement("groups")
  doc.appendChild(groups)
  for row in c:
    group = doc.createElement("group")
    
    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    group.appendChild(identifier)
    
    categoryIdentifier = doc.createElement("categoryIdentifier")
    categoryIdentifierText = doc.createTextNode(str(row[1]))
    categoryIdentifier.appendChild(categoryIdentifierText)
    group.appendChild(categoryIdentifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[2])
    name.appendChild(nameText)
    group.appendChild(name)
    
    published = doc.createElement("published")
    publishedText = doc.createTextNode(str(row[3]))
    published.appendChild(publishedText)
    group.appendChild(published)
    
    groups.appendChild(group)
    
  open(getURLName("Groups.xml"), "w").write(doc.toprettyxml(indent="  "))
  
  #MarketGroups
  print "Processing MarketGroups..."
  c.execute("""SELECT marketGroupID AS identifier, parentGroupID AS parentIdentifier, marketGroupName AS name, hasTypes FROM invMarketGroups;""")
  doc = Document()
  marketgroups = doc.createElement("marketgroups")
  doc.appendChild(marketgroups)
  for row in c:
    marketgroup = doc.createElement("marketgroup")
    
    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    marketgroup.appendChild(identifier)
    
    if row[1] is None:
      value = "NULL"
    else:
      value = str(row[1])
    
    parentIdentifier = doc.createElement("parentIdentifier")
    parentIdentifierText = doc.createTextNode(value)
    parentIdentifier.appendChild(parentIdentifierText)
    marketgroup.appendChild(parentIdentifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[2])
    name.appendChild(nameText)
    marketgroup.appendChild(name)
    
    types = doc.createElement("hasTypes")
    typesText = doc.createTextNode(str(row[3]))
    types.appendChild(typesText)
    marketgroup.appendChild(types)
    
    marketgroups.appendChild(marketgroup)
    
  open(getURLName("MarketGroups.xml"), "w").write(doc.toprettyxml(indent="  "))
  
  #Skills
  print "Processing Skills..."
  c.execute("""SELECT typeID AS identifier, typeName AS name, invGroups.groupID AS groupIdentifier, marketGroupID AS marketGroupIdentifier, basePrice, invTypes.published FROM
  invTypes INNER JOIN invGroups ON invTypes.groupID = invGroups.groupID
  WHERE categoryID = 16;""")
  doc = Document()
  skills = doc.createElement("skills")
  doc.appendChild(skills)
  for row in c:
    skill = doc.createElement("skill")
    
    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    skill.appendChild(identifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[1])
    name.appendChild(nameText)
    skill.appendChild(name)
    
    groupIdentifier = doc.createElement("groupIdentifier")
    groupIdentitierText = doc.createTextNode(str(row[2]))
    groupIdentifier.appendChild(groupIdentitierText)
    skill.appendChild(groupIdentifier)
    
    if row[3] is None:
      value = "NULL"
    else:
      value = str(row[3])
    
    marketGroupIdentifier = doc.createElement("marketGroupIdentifier")
    marketGroupIdentifierText = doc.createTextNode(value)
    marketGroupIdentifier.appendChild(marketGroupIdentifierText)
    skill.appendChild(marketGroupIdentifier)
    
    price = doc.createElement("price")
    priceText = doc.createTextNode(str(row[4]))
    price.appendChild(priceText)
    skill.appendChild(price)
    
    published = doc.createElement("published")
    publishedText = doc.createTextNode(str(row[5]))
    published.appendChild(publishedText)
    skill.appendChild(published)
    
    skills.appendChild(skill)
    
  open(getURLName("Skills.xml"), "w").write(doc.toprettyxml(indent="  "))
    
  #implants
  print "Processing Implants..."
  c.execute("""SELECT invTypes.typeID as Identifier, invTypes.groupID as groupIdentifier, invTypes.typeName as Name, invTypes.basePrice, invTypes.marketGroupID as marketGroupIdentifier, invTypes.published, (invTypes.marketGroupID - 617) AS slot, (attributeID - 175) AS attribute, valueInt AS attributeBonus
    FROM dgmTypeAttributes INNER JOIN invTypes ON invTypes.typeID = dgmTypeAttributes.typeID
    WHERE invTypes.marketGroupID >= 618 AND invTypes.marketGroupID <= 627 AND dgmTypeAttributes.attributeID >= 175 AND dgmTypeAttributes.attributeID <= 179 AND dgmTypeAttributes.valueInt != 0""")
  doc = Document()
  implants = doc.createElement("implants")
  doc.appendChild(implants)
  for row in c:
    implant = doc.createElement("implant")

    identifier = doc.createElement("identifier")
    identifierText = doc.createTextNode(str(row[0]))
    identifier.appendChild(identifierText)
    implant.appendChild(identifier)
    
    groupIdentifier = doc.createElement("groupIdentifier")
    groupIdentitierText = doc.createTextNode(str(row[1]))
    groupIdentifier.appendChild(groupIdentitierText)
    implant.appendChild(groupIdentifier)
    
    name = doc.createElement("name")
    nameText = doc.createTextNode(row[2])
    name.appendChild(nameText)
    implant.appendChild(name)

    price = doc.createElement("price")
    priceText = doc.createTextNode(str(row[3]))
    price.appendChild(priceText)
    implant.appendChild(price)
    
    if row[4] is None:
      value = "NULL"
    else:
      value = str(row[4])

    marketGroupIdentifier = doc.createElement("marketGroupIdentifier")
    marketGroupIdentifierText = doc.createTextNode(value)
    marketGroupIdentifier.appendChild(marketGroupIdentifierText)
    implant.appendChild(marketGroupIdentifier)

    published = doc.createElement("published")
    publishedText = doc.createTextNode(str(row[5]))
    published.appendChild(publishedText)
    implant.appendChild(published)

    slot = doc.createElement("slot")
    slotText = doc.createTextNode(str(row[6]))
    slot.appendChild(slotText)
    implant.appendChild(slot)
    
    result = {
      0 : "Charisma",
      1 : "Intelligence",
      2 : "Memory",
      3 : "Perception",
      4 : "Willpower"
    }.get(int(row[7]))
    
    #Falta por aqui o resto.
    attribute = doc.createElement("attribute")
    attributeText = doc.createTextNode(result)
    attribute.appendChild(attributeText)
    implant.appendChild(attribute)
    
    attributeBonus = doc.createElement("attributeBonus")
    attributeBonusText = doc.createTextNode(str(row[8]))
    attributeBonus.appendChild(attributeBonusText)
    implant.appendChild(attributeBonus)
    
    implants.appendChild(implant)

  open(getURLName("Implants.xml"), "w").write(doc.toprettyxml(indent="  "))
    
    

def main():
  
  try:
    downloadDump(sys.argv[1])
  except Exception, e:
    print "Link to database needed as argument!"
    sys.exit(0)
  
  dbPath = decompressbz2(getURLName(sys.argv[1]))
  
  processDB(getURLName(dbPath))
  
  print "All Done!"

if __name__=="__main__":
  main()