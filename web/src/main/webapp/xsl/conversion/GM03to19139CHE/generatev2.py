# Python 3 script

import os,sys,shutil,re

class Expr:
  def __init__(self, expr, refuse):
    self.__pattern = re.compile(expr)
    self.__refuse = re.compile( r'['+refuse+']+' )

  def replace(self,line):
    match = self.__pattern.search(line)
    index = 0

    while match != None :
      if  match.group(1) == None and self.__refuse.search(match.group(2)) == None:
        line = line[:index+match.start(2)]+'int:'+match.group(2)+line[index+match.end(2):]
      index += match.end(2)
      match = self.__pattern.search(line[index:])
    return line


dir = 'version2/'
shutil.rmtree(dir)
os.mkdir(dir)

specifics = { 'CHE03-to-19139.xsl':
                {'match="CodeISO.LanguageCodeISO_':'match="int:CodeISO.LanguageCodeISO_',
                 'Group[language':'Group[int:language',
                 'Group/language':'Group/int:language',
                 'Metadata/language':'Metadata/int:language',
                 'ge or not(language)]/plainText':'ge or not(int:language)]/int:plainText',
                 'translate(language':'translate(int:language',
                 'xmlns:comp="http://www.geocat.ch/2003/05/gateway/GM03Comprehensive"':'xmlns:comp="http://toignore"'
                 },
              'extent.xsl':
                {'string(description':'string(int:description',
                 'Core.Core.EX_Extent/description':'Core.Core.EX_Extent/int:description'},
              'content.xsl':
                {'|baseDomain':'|int:baseDomain',
                 '|processingLevelCode':'|int:processingLevelCode',
                 'GenericName_/value':'GenericName_/int:value',
                 "document('units.xml')":"document('../units.xml')",
                 'MD_Type/type':'MD_Type/int:type'
                 },
              'legislation.xsl':
                {'match="CodeISO.':'match="int:CodeISO.',
                 'CodeISO.CountryCodeISO_|CodeISO.Country_':'CodeISO.CountryCodeISO_|int:CodeISO.Country_',
                 'language/CodeISO.LanguageCodeISO_|language/CodeISO.LanguageCode_':'language/int:CodeISO.LanguageCodeISO_|int:language/int:CodeISO.LanguageCode_',
                 'codeListValue="{value}"':'codeListValue="{int:value}"',
                 },
              'metadata.xsl':
                {'codeListValue="{value}':'codeListValue="{int:value}',
                 'ortrayalCatalogueInfoMD_Metadata/portrayalCatalogueInfo"/>':'ortrayalCatalogueInfoMD_Metadata/int:portrayalCatalogueInfo"/>'
                 },
              'resp-party.xsl':
                {'codeListValue="{value}':'codeListValue="{int:value}',
                 'Contact/role':'Contact/int:role',
                 'country|address':'country|address',
                 'CI_Address/country':'CI_Address/int:country',
                 'MD_MaintenanceInformationcontact/role':'MD_MaintenanceInformationcontact/int:role',
                 'Contact/hoursOfService':'Contact/int:hoursOfService',
                 'Telephone[numberType':'Telephone[int:numberType',
                 'Address/city':'Address/int:city',
                 'Address/administrativeArea':'Address/int:administrativeArea',
                 'Address/postalCode':'Address/int:postalCode',
                 'Address/electronicMailAddress':'Address/int:electronicMailAddress',
                 'Address|electronicalMailAddress':'Address|int:electronicalMailAddress',
                 'Address/streetName':'Address/int:streetName',
                 'Address/streetNumber':'Address/int:streetNumber',
                 'Address/addressLine':'Address/int:addressLine',
                 'Address/postBox':'Address/int:postBox',
                 'URL_/value':'URL_/int:value',
                 '../../../role':'../../../int:role',
                 '|contactInfo':'|int:contactInfo',
                 'Core.Core.CI_Contact/contactInstructions':'Core.Core.CI_Contact/int:contactInstructions',
                 ' distributorContact |':' int:distributorContact |',
                 '../role |':'../int:role |'
                 },
              'citation.xsl':
                {'Code_/value':'Code_/int:value',
                 'GM03Core.Core.CI_Citation|citation':'Core.Core.CI_Citation|int:citation',
                 'Comprehensive.Comprehensive.CI_Citationidentifier/identifier':'Comprehensive.Comprehensive.CI_Citationidentifier/int:identifier',
                 'and not(alternateTitle/':'and not(int:alternateTitle/'},
              'data-quality.xsl':
                {'normalize-space(dateTime':'normalize-space(int:dateTime',
                 'normalize-space(description':'normalize-space(int:description',
                 'test=".//XMLBLBOX':'test=".//int:XMLBLBOX',
                 'elect=".//XMLBLBOX':'elect=".//int:XMLBLBOX',
                 'elect=".//value':'elect=".//int:value',
                 'attributes|features|featureInstances|attributeInstances':'attributes|int:features|int:featureInstances|int:attributeInstances'},
              'identification.xsl':
                {'Code_/value':'Code_/int:value',
                 'Comprehensive.Comprehensive.gml_CodeType/code':'Comprehensive.Comprehensive.gml_CodeType/int:code',
                 'Resolution/distance':'Resolution/int:distance',
                 'Resolution/equivalentScale':'Resolution/int:equivalentScale',
                 'Identification/revision':'Identification/revision',
                 'GM03Comprehensive.Comprehensive.formatDistributordistributorFormat[distributorFormat':'GM03Comprehensive.Comprehensive.formatDistributordistributorFormat[int:distributorFormat',
                 'Identification/revision':'Identification/int:revision',
                 'and basicGeodataID':'and int:basicGeodataID'
              }

              }

exprs = [ ]
excludes = r':\(\)\.-'
exprs.append( Expr(r'select\s*=\s*"\s*(int:)?([\w'+excludes+']+)',excludes) )
exprs.append( Expr(r'match\s*=\s*"\s*(int:)?([\w'+excludes+']+)',excludes) )
exprs.append( Expr(r'test\s*=\s*"\s*(int:)?([\w'+excludes+']+)',excludes) )


files = [fname for fname in os.listdir('.') if fname.endswith('.xsl')]
for fname in files:
  found = set()
  styleSheetTag = False
  wroteExcludes = False

  with open(dir+fname,'w') as out:
    with open(fname,'r') as f:
      for line in f.readlines():
        write = True
        if '<xsl:stylesheet' in line:
          styleSheetTag = True

        if 'exclude-result-prefixes' in line:
          parts = line.split('"',1)
          line = '{0}"int {1}'.format(parts[0],parts[1])
          wroteExcludes = True

        if styleSheetTag and '>' in line:
          styleSheetTag = False
          out.write('                xmlns:int="http://www.interlis.ch/INTERLIS2.3"\n')
          if not wroteExcludes:
            out.write('                exclude-result-prefixes="int"\n')

        if '<xsl:include href="version2' in line: write=False

        if fname in specifics:
          for toReplace in specifics[fname].keys():
            if toReplace in line:
              line = line.replace(toReplace, specifics[fname][toReplace])
              found = found | set([toReplace])

        line = line.replace('GM03','int:GM03_2')
        line = line.replace('TRANSFER', 'int:TRANSFER')
        line = line.replace('DATASECTION', 'int:DATASECTION')
        line = line.replace('comp:int', 'comp')

        for expr in exprs:
          line = expr.replace(line)

        if write: out.write(line)
  if fname in specifics and len(found) != len(specifics[fname]):
    print ("ERROR:  --- Not all replacements were matched:", "filename="+fname+" -> ", specifics[fname].keys() - found)
    exit(-1)

