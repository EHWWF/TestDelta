<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20"
                xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:ns0="http://xmlns.oracle.com/Primavera/P6/WS/Activity/V1"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:tns="http://xmlns.bayer.com/ipms" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator"
                exclude-result-prefixes="xsi oracle-xsl-mapper xsl xsd ns0 tns xp20 oraxsl mhdr oraext dvm xref socket"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
                xmlns:ns1="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"
                xmlns:ns2="http://xmlns.bayer.com/ipms/qplan" xmlns:client="http://xmlns.bayer.com/ipms/soa"
                xmlns:plnk="http://docs.oasis-open.org/wsbpel/2.0/plnktype">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../wsdl/ActivityService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadActivitiesResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/Activity/V1"/>
      </oracle-xsl-mapper:source>
    </oracle-xsl-mapper:mapSources>
    <oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:target type="WSDL">
        <oracle-xsl-mapper:schema location="../WSDLs/ReadLeadStudies.wsdl"/>
        <oracle-xsl-mapper:rootElement name="leadStudies" namespace="http://xmlns.bayer.com/ipms"/>
      </oracle-xsl-mapper:target>
    </oracle-xsl-mapper:mapTargets>
    <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [WED MAR 02 13:52:15 EET 2016].-->
  </oracle-xsl-mapper:schema>
  <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
  <xsl:template match="/">
    <tns:leadStudies>
      <tns:drvMilestones>
        <xsl:for-each select="/ns0:ReadActivitiesResponse/ns0:Activity">
          <tns:drvMilestone wbsId="{ns0:WBSObjectId}" activityId="{ns0:ObjectId}" type="{ns0:Type}"/>
        </xsl:for-each>
      </tns:drvMilestones>
    </tns:leadStudies>
  </xsl:template>
</xsl:stylesheet>
