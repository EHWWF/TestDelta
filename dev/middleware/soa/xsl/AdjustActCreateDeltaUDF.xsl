<?xml version = '1.0' encoding = 'UTF-8'?>
<xsl:stylesheet version="1.0"
                xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20"
                xmlns:bpws="http://schemas.xmlsoap.org/ws/2003/03/business-process/"
                xmlns:bpel="http://docs.oasis-open.org/wsbpel/2.0/process/executable"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:bpm="http://xmlns.oracle.com/bpmn20/extensions"
                xmlns:plnk="http://schemas.xmlsoap.org/ws/2003/05/partner-link/"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
                xmlns:ora="http://schemas.oracle.com/xpath/extension"
                xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:ns0="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:tns="http://xmlns.oracle.com/Primavera/P6/WS/Activity/V1"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:client="http://xmlns.bayer.com/ipms/soa" xmlns:hwf="http://xmlns.oracle.com/bpel/workflow/xpath"
                xmlns:ns2="http://docs.oasis-open.org/wsbpel/2.0/plnktype"
                xmlns:med="http://schemas.oracle.com/mediator/xpath" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ids="http://xmlns.oracle.com/bpel/services/IdentityService/xpath"
                xmlns:xdk="http://schemas.oracle.com/bpel/extension/xpath/function/xdk"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:ns1="http://xmlns.bayer.com/ipms" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:bpmn="http://schemas.oracle.com/bpm/xpath"
                xmlns:ldap="http://schemas.oracle.com/xpath/extension/ldap"
                exclude-result-prefixes="xsi xsl plnk soap wsdl intgfault ns0 tns client ns2 ns1 xsd xp20 bpws bpel bpm ora socket mhdr oraext dvm hwf med ids xdk xref bpmn ldap"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:ns4="http://xmlns.bayer.com/ipms/cache" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:ns3="http://xmlns.bayer.com/ipms/qplan">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../wsdl/ActivityService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadAllActivitiesByWBSResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/Activity/V1"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadConfiguration.wsdl"/>
        <oracle-xsl-mapper:rootElement name="config" namespace="http://xmlns.bayer.com/ipms/soa"/>
        <oracle-xsl-mapper:param name="ReadCfgOut.payload"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/UDFValue/V1/UDFValueService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="ReadUDFValuesResponse"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"/>
        <oracle-xsl-mapper:param name="ReadUDFValuesOut.result"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../AdjustActivities.wsdl"/>
        <oracle-xsl-mapper:rootElement name="empty" namespace="http://xmlns.bayer.com/ipms"/>
        <oracle-xsl-mapper:param name="PlanVersionId"/>
      </oracle-xsl-mapper:source>
    </oracle-xsl-mapper:mapSources>
    <oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:target type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/oracle/xmlns/Primavera/P6/WS/UDFValue/V1/UDFValueService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="CreateUDFValues"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"/>
      </oracle-xsl-mapper:target>
    </oracle-xsl-mapper:mapTargets>
    <oracle-xsl-mapper:mapShowPrefixes type="true"/>
    <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [MON JUN 01 10:43:33 CEST 2015].-->
  </oracle-xsl-mapper:schema>
  <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
  <xsl:param name="ReadCfgOut.payload"/>
  <xsl:param name="ReadUDFValuesOut.result"/>
  <xsl:param name="PlanVersionId"/>
  <xsl:template match="/">
    <ns0:CreateUDFValues>
      <xsl:for-each select="/tns:ReadAllActivitiesByWBSResponse/tns:Activity">
        <xsl:variable name="v_ObjectId" select="tns:ObjectId"/>
        <xsl:if test="string-length($ReadUDFValuesOut.result/ns0:ReadUDFValuesResponse/ns0:UDFValue[ns0:ForeignObjectId=$v_ObjectId and ns0:Text=$PlanVersionId and ns0:UDFTypeObjectId=$ReadCfgOut.payload/client:config/client:activity/client:planVersionIdTypeId]/ns0:ForeignObjectId) = 0">
          <ns0:UDFValue>
            <ns0:ForeignObjectId>
              <xsl:value-of select="tns:ObjectId"/>
            </ns0:ForeignObjectId>
            <ns0:Text>
              <xsl:value-of select="$PlanVersionId"/>
            </ns0:Text>
            <ns0:UDFTypeObjectId>
              <xsl:value-of select="$ReadCfgOut.payload/client:config/client:activity/client:planVersionIdTypeId"/>
            </ns0:UDFTypeObjectId>
          </ns0:UDFValue>
        </xsl:if>
      </xsl:for-each>
    </ns0:CreateUDFValues>
  </xsl:template>
</xsl:stylesheet>