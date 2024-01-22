<?xml version = '1.0' encoding = 'UTF-8'?>
<xsl:stylesheet version="1.0" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:ns2="http://schemas.microsoft.com/2003/10/Serialization/" xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20" xmlns:bpws="http://schemas.xmlsoap.org/ws/2003/03/business-process/" xmlns:bpel="http://docs.oasis-open.org/wsbpel/2.0/process/executable" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:wsa10="http://www.w3.org/2005/08/addressing" xmlns:bpm="http://xmlns.oracle.com/bpmn20/extensions" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:plnk="http://schemas.xmlsoap.org/ws/2003/05/partner-link/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:ora="http://schemas.oracle.com/xpath/extension" xmlns:wsx="http://schemas.xmlsoap.org/ws/2004/09/mex" xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator" xmlns:wsap="http://schemas.xmlsoap.org/ws/2004/08/addressing/policy" xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl" xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction" xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc" xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue" xmlns:ipms-qplan="http://xmlns.bayer.com/ipms/qplan" xmlns:qplan="https://quickplan-p.bayer-ag.com/services" xmlns:ipms-soa="http://xmlns.bayer.com/ipms/soa" xmlns:hwf="http://xmlns.oracle.com/bpel/workflow/xpath" xmlns:med="http://schemas.oracle.com/mediator/xpath" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ids="http://xmlns.oracle.com/bpel/services/IdentityService/xpath" xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy" xmlns:xdk="http://schemas.oracle.com/bpel/extension/xpath/function/xdk" xmlns:i0="https://by-quickplan-p.bayer-ag.com/services" xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions" xmlns:msc="http://schemas.microsoft.com/ws/2005/12/wsdl/contract" xmlns:ns0="http://xmlns.bayer.com/ipms" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://schemas.oracle.com/bpel/extension" xmlns:bpmn="http://schemas.oracle.com/bpm/xpath" xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata" xmlns:ldap="http://schemas.oracle.com/xpath/extension/ldap" exclude-result-prefixes="xsi xsl plnk wsdl ipms-qplan ipms-soa ns0 xsd ns1 wsa ns2 wsa10 soap12 soapenc soap wsx wsap wsaw qplan wsp i0 msc wsu wsam xp20 bpws bpel bpm ora socket mhdr oraext dvm hwf med ids xdk xref bpmn ldap" xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas">
	
	<oracle-xsl-mapper:schema>
      <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
      <oracle-xsl-mapper:mapSources>
         <oracle-xsl-mapper:source type="WSDL">
            <oracle-xsl-mapper:schema location="../UpdateProject.wsdl"/>
            <oracle-xsl-mapper:rootElement name="callQPlan" namespace="http://xmlns.bayer.com/ipms/qplan"/>
         </oracle-xsl-mapper:source>
      </oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:mapTargets>
         <oracle-xsl-mapper:target type="WSDL">
            <oracle-xsl-mapper:schema location="../Interface.svc.wsdl"/>
            <oracle-xsl-mapper:rootElement name="UpdatePtrValues" namespace="https://quickplan-p.bayer-ag.com/services"/>
         </oracle-xsl-mapper:target>
      </oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:mapShowPrefixes type="true"/>
      <oracle-xsl-mapper:named-template-schema>
         <oracle-xsl-mapper:template name="ptrValue">
            <oracle-xsl-mapper:mapSources/>
         </oracle-xsl-mapper:template>
      </oracle-xsl-mapper:named-template-schema>
      <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [MON JUN 01 10:43:30 CEST 2015].-->
   </oracle-xsl-mapper:schema>
   <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
   <xsl:template match="/">
		<qplan:UpdatePtrValues>
			<qplan:updatePTRValuesRequest>
				<qplan:cwid>
					<xsl:value-of select="/ipms-qplan:callQPlan/ipms-qplan:updateProject/@cwid"/>
				</qplan:cwid>
				<qplan:projectId>
					<xsl:value-of select="/ipms-qplan:callQPlan/ipms-qplan:updateProject/@projectCode"/>
				</qplan:projectId>
					<xsl:apply-templates select="/ipms-qplan:callQPlan/ipms-qplan:updateProject/ipms-qplan:ptrValues"/>
			</qplan:updatePTRValuesRequest>
		</qplan:UpdatePtrValues>
	</xsl:template>
	
	<xsl:template match="ipms-qplan:ptrValues">
		<qplan:ptrValueData>
			<xsl:call-template name="ptrValue">
				<xsl:with-param name="phase">preclinical</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="ptrValue">
				<xsl:with-param name="phase">phase1</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="ptrValue">
				<xsl:with-param name="phase">phase2</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="ptrValue">
				<xsl:with-param name="phase">phase3</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="ptrValue">
				<xsl:with-param name="phase">submission</xsl:with-param>
			</xsl:call-template>
		</qplan:ptrValueData>
	</xsl:template>
	
	<xsl:template name="ptrValue">
		<xsl:param name="phase"/>
		<xsl:variable name="ptrValue" select="ipms-qplan:ptr[lower-case(ipms-qplan:phase)=$phase][1]"/>

		<xsl:element name="qplan:{$phase}">
		<xsl:choose>
			<xsl:when test="$ptrValue">
				<xsl:if test="$ptrValue/ipms-qplan:defaultProbability">
					<qplan:percentageGeneric>
						<xsl:value-of select="$ptrValue/ipms-qplan:defaultProbability"/>
					</qplan:percentageGeneric>
				</xsl:if>
				<xsl:if test="$ptrValue/ipms-qplan:projectProbability">
					<qplan:percentageProject>
						<xsl:value-of select="$ptrValue/ipms-qplan:projectProbability"/>
					</qplan:percentageProject>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="xsi:nil">true</xsl:attribute> 
			</xsl:otherwise>
		</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>