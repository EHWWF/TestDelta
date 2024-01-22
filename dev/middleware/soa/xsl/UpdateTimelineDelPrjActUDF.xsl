<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction" xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20" xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions" xmlns:tns="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1" xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator" xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas" xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns0="http://xmlns.bayer.com/ipms/soa" exclude-result-prefixes=" xsd oracle-xsl-mapper xsi xsl ns0 tns mhdr oraext xp20 xref socket dvm oraxsl"
                xmlns:ns2="http://xmlns.bayer.com/ipms/cache"
                xmlns:plnk="http://schemas.xmlsoap.org/ws/2003/05/partner-link/" xmlns:ns1="http://xmlns.bayer.com/ipms"
                xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:ns3="http://xmlns.bayer.com/ipms/qplan"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/">
   <oracle-xsl-mapper:schema>
      <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
      <oracle-xsl-mapper:mapSources>
         <oracle-xsl-mapper:source type="WSDL">
            <oracle-xsl-mapper:schema location="../UpdateTimeline.wsdl"/>
            <oracle-xsl-mapper:rootElement name="update" namespace="http://xmlns.bayer.com/ipms/soa"/>
         </oracle-xsl-mapper:source>
         <oracle-xsl-mapper:source type="WSDL">
            <oracle-xsl-mapper:schema location="../UpdateTimeline.wsdl"/>
            <oracle-xsl-mapper:rootElement name="config" namespace="http://xmlns.bayer.com/ipms/soa"/>
            <oracle-xsl-mapper:param name="ReadConfigurationOut.payload"/>
         </oracle-xsl-mapper:source>
      </oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:mapTargets>
         <oracle-xsl-mapper:target type="WSDL">
            <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/UDFValue/V1/UDFValueService.wsdl"/>
            <oracle-xsl-mapper:rootElement name="DeleteUDFValues" namespace="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"/>
         </oracle-xsl-mapper:target>
      </oracle-xsl-mapper:mapTargets>
      <!--GENERATED BY ORACLE XSL MAPPER 12.2.1.0.0(XSLT Build 151013.0700.0085) AT [WED AUG 29 09:39:26 CEST 2018].-->
   </oracle-xsl-mapper:schema>
   <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
   <xsl:param name="ReadConfigurationOut.payload"/>
   <xsl:template match="/">
      <tns:DeleteUDFValues>
        <xsl:for-each select="/ns0:update/ns1:timeline/ns1:activities/ns1:activity">
          <xsl:choose>
          <xsl:when test="@mustBeDeleted = &quot;true&quot;"/>
          <xsl:otherwise>
          
             <tns:ObjectId>
                <tns:UDFTypeObjectId>
                   <xsl:value-of select="$ReadConfigurationOut.payload/ns0:config/ns0:activity/ns0:studyIdTypeId"/>
                </tns:UDFTypeObjectId>
                <tns:ForeignObjectId>
                   <xsl:value-of select="@id"/>
                </tns:ForeignObjectId>
             </tns:ObjectId>
         
          </xsl:otherwise>
          </xsl:choose>
      </xsl:for-each>
      </tns:DeleteUDFValues>
   </xsl:template>
</xsl:stylesheet>
