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
                xmlns:ns1="http://xmlns.bayer.com/ipms"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:tns="http://xmlns.oracle.com/Primavera/P6/WS/UDFValue/V1"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:client="http://xmlns.bayer.com/ipms/soa" xmlns:hwf="http://xmlns.oracle.com/bpel/workflow/xpath"
                xmlns:med="http://schemas.oracle.com/mediator/xpath" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ids="http://xmlns.oracle.com/bpel/services/IdentityService/xpath"
                xmlns:xdk="http://schemas.oracle.com/bpel/extension/xpath/function/xdk"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:bpmn="http://schemas.oracle.com/bpm/xpath"
                xmlns:ldap="http://schemas.oracle.com/xpath/extension/ldap"
                exclude-result-prefixes="xsi xsl plnk wsdl ns1 client xsd soap intgfault tns xp20 bpws bpel bpm ora socket mhdr oraext dvm hwf med ids xdk xref bpmn ldap"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:ns2="http://xmlns.bayer.com/ipms/cache" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:ns0="http://xmlns.bayer.com/ipms/qplan">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../UpdateTimeline.wsdl"/>
        <oracle-xsl-mapper:rootElement name="update" namespace="http://xmlns.bayer.com/ipms/soa"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadConfiguration.wsdl"/>
        <oracle-xsl-mapper:rootElement name="config" namespace="http://xmlns.bayer.com/ipms/soa"/>
        <oracle-xsl-mapper:param name="ReadConfigurationOut.payload"/>
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
  <xsl:param name="ReadConfigurationOut.payload"/>
  <xsl:template match="/">
    <tns:CreateUDFValues>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:studyPhase]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:studyPhase"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:studyPhaseTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:planPatients]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:planPatients"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:planPatientsTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:actualPatients]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:actualPatients"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:actualPatientsTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:planEnteredScreen]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:planEnteredScreen"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:planEnteredScreenTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:actEnteredScreen]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:actEnteredScreen"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:actEnteredScreenTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:studyCountryCountPlan]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:studyCountryCountPlan"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:studyCountryCountPlanTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:studyCountryCount]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:studyCountryCount"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:studyCountryCountTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:studyUnitCount]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:studyUnitCount"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:studyUnitCountTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:studyUnitCountPlan]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:studyUnitCountPlan"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:studyUnitCountPlanTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      <xsl:for-each select="/client:update/ns1:timeline/ns1:wbsNodes/ns1:wbs[ns1:FTEAvg]">
        <tns:UDFValue>
          <tns:ForeignObjectId>
            <xsl:value-of select="@id"/>
          </tns:ForeignObjectId>
          <tns:Text>
            <xsl:value-of select="ns1:FTEAvg"/>
          </tns:Text>
          <tns:UDFTypeObjectId>
            <xsl:value-of select="$ReadConfigurationOut.payload/client:config/client:wbs/client:FTEAvgTypeId"/>
          </tns:UDFTypeObjectId>
        </tns:UDFValue>
      </xsl:for-each>
      
      
    </tns:CreateUDFValues>
  </xsl:template>
</xsl:stylesheet>