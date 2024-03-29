<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20"
                xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:ns2="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:ns0="http://xmlns.bayer.com/ipms/soa" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator"
                xmlns:ns1="http://xmlns.oracle.com/Primavera/P6/WS/BaselineProject/V2"
                exclude-result-prefixes="xsi oracle-xsl-mapper xsl xsd ns2 ns0 ns1 xp20 oraxsl mhdr oraext dvm xref socket"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:ns3="http://xmlns.bayer.com/ipms/cache" xmlns:ns5="http://xmlns.bayer.com/ipms/qplan"
                xmlns:plnk="http://docs.oasis-open.org/wsbpel/2.0/plnktype" xmlns:ns4="http://xmlns.bayer.com/ipms"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
                xmlns:client="http://xmlns.oracle.com/ipms_mw/ipms_soa/DeleteBaselines">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../WSDLs/DeleteBaselines.wsdl"/>
        <oracle-xsl-mapper:rootElement name="delete" namespace="http://xmlns.bayer.com/ipms/soa"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../wsdl/BaselineProjectService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadBaselineProjectsResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/BaselineProject/V2"/>
        <oracle-xsl-mapper:param name="ReadAllBaselinesOut.result"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/UDFValue/V1/UDFValueService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadUDFValuesResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"/>
        <oracle-xsl-mapper:param name="ReadAllLtcIdUDFsOut.result"/>
      </oracle-xsl-mapper:source>
    </oracle-xsl-mapper:mapSources>
    <oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:target type="WSDL">
        <oracle-xsl-mapper:schema location="../WSDLs/DeleteBaselines.wsdl"/>
        <oracle-xsl-mapper:rootElement name="response" namespace="http://xmlns.bayer.com/ipms/soa"/>
      </oracle-xsl-mapper:target>
    </oracle-xsl-mapper:mapTargets>
    <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [THU MAR 03 09:02:03 CET 2016].-->
  </oracle-xsl-mapper:schema>
  <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
  <xsl:param name="ReadAllBaselinesOut.result"/>
  <xsl:param name="ReadAllLtcIdUDFsOut.result"/>
  <xsl:template match="/">
    <ns0:response id="{/ns0:delete/@id}">
      <ns0:complete id="{/ns0:delete/@id}">
        <ns4:baselines timelineId="{/ns0:delete/ns4:baselines/@timelineId}">
        <xsl:for-each select="$ReadAllBaselinesOut.result/ns1:ReadBaselineProjectsResponse/ns1:BaselineProject">
          <xsl:variable name="ObjectId" select="ns1:ObjectId"/>
          <ns4:baseline id="{ns1:ObjectId}">
            <ns4:name>
              <xsl:value-of select="ns1:Name"/>
            </ns4:name>
            <ns4:baselineTypeObjectId>
              <xsl:value-of select="ns1:BaselineTypeObjectId"/>
            </ns4:baselineTypeObjectId>
            <ns4:createDate>
              <xsl:value-of select="ns1:CreateDate"/>
            </ns4:createDate>
            <ns4:description>
              <xsl:value-of select="ns1:Description"/>
            </ns4:description>
            <ns4:ltcId>
              <xsl:value-of select="$ReadAllLtcIdUDFsOut.result/ns2:ReadUDFValuesResponse/ns2:UDFValue[ns2:ForeignObjectId=$ObjectId]/ns2:Text"/>
            </ns4:ltcId>
          </ns4:baseline>
        </xsl:for-each>
        </ns4:baselines>
      </ns0:complete>
    </ns0:response>
  </xsl:template>
</xsl:stylesheet>
