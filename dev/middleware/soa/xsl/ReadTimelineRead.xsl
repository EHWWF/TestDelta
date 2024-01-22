<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xp20="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.Xpath20"
                xmlns:bpws="http://schemas.xmlsoap.org/ws/2003/03/business-process/"
                xmlns:bpel="http://docs.oasis-open.org/wsbpel/2.0/process/executable"
                xmlns:tns="http://xmlns.oracle.com/Primavera/P6/WS/WSExport/V2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:bpm="http://xmlns.oracle.com/bpmn20/extensions"
                xmlns:plnk="http://schemas.xmlsoap.org/ws/2003/05/partner-link/"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
                xmlns:ora="http://schemas.oracle.com/xpath/extension"
                xmlns:socket="http://www.oracle.com/XSL/Transform/java/oracle.tip.adapter.socket.ProtocolTranslator"
                xmlns:xmime="http://www.w3.org/2005/05/xmlmime"
                xmlns:ns0="http://xmlns.oracle.com/Primavera/P6/V18.8.4/API/BusinessObjects"
                xmlns:intgfault="http://xmlns.oracle.com/Primavera/P6/WS/IntegrationFaultType/V1"
                xmlns:mhdr="http://www.oracle.com/XSL/Transform/java/oracle.tip.mediator.service.common.functions.MediatorExtnFunction"
                xmlns:oraext="http://www.oracle.com/XSL/Transform/java/oracle.tip.pc.services.functions.ExtFunc"
                xmlns:dvm="http://www.oracle.com/XSL/Transform/java/oracle.tip.dvm.LookupValue"
                xmlns:ns2="http://xmlns.bayer.com/ipms/soa" xmlns:hwf="http://xmlns.oracle.com/bpel/workflow/xpath"
                xmlns:med="http://schemas.oracle.com/mediator/xpath" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ids="http://xmlns.oracle.com/bpel/services/IdentityService/xpath"
                xmlns:xdk="http://schemas.oracle.com/bpel/extension/xpath/function/xdk"
                xmlns:xref="http://www.oracle.com/XSL/Transform/java/oracle.tip.xref.xpath.XRefXPathFunctions"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://xmlns.bayer.com/ipms"
                xmlns:bpmn="http://schemas.oracle.com/bpm/xpath"
                xmlns:ldap="http://schemas.oracle.com/xpath/extension/ldap"
                exclude-result-prefixes="xsi xsl plnk wsdl ns0 ns2 xsd ns1 xp20 bpws bpel bpm ora socket mhdr oraext dvm hwf med ids xdk xref bpmn ldap"
                xmlns:oracle-xsl-mapper="http://www.oracle.com/xsl/mapper/schemas"
                xmlns:ns3="http://xmlns.bayer.com/ipms/cache" xmlns:oraxsl="http://www.oracle.com/XSL/Transform/java"
                xmlns:ns4="http://xmlns.bayer.com/ipms/qplan" xmlns:ns8="http://xmlns.bayer.com/ipms/p6">
  <oracle-xsl-mapper:schema>
    <!--SPECIFICATION OF MAP SOURCES AND TARGETS, DO NOT MODIFY.-->
    <oracle-xsl-mapper:mapSources>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadTimeline.wsdl"/>
        <oracle-xsl-mapper:rootElement name="APIBusinessObjects"
                                       namespace="http://xmlns.oracle.com/Primavera/P6/V18.8.4/API/BusinessObjects"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadConfiguration.wsdl"/>
        <oracle-xsl-mapper:rootElement name="config" namespace="http://xmlns.bayer.com/ipms/soa"/>
        <oracle-xsl-mapper:param name="ReadConfigOut.payload"/>
      </oracle-xsl-mapper:source>
      <oracle-xsl-mapper:source type="WSDL">
        <oracle-xsl-mapper:schema location="oramds:/apps/com/bayer/xmlns/ipms/p6/ProjectService.wsdl"/>
        <oracle-xsl-mapper:rootElement name="WBS" namespace="http://xmlns.bayer.com/ipms/p6"/>
        <oracle-xsl-mapper:param name="P6xReadWBS_Out.payload"/>
      </oracle-xsl-mapper:source>
    </oracle-xsl-mapper:mapSources>
    <oracle-xsl-mapper:mapTargets>
      <oracle-xsl-mapper:target type="WSDL">
        <oracle-xsl-mapper:schema location="../ReadTimeline.wsdl"/>
        <oracle-xsl-mapper:rootElement name="response" namespace="http://xmlns.bayer.com/ipms/soa"/>
      </oracle-xsl-mapper:target>
    </oracle-xsl-mapper:mapTargets>
    <oracle-xsl-mapper:mapShowPrefixes type="true"/>
    <!--GENERATED BY ORACLE XSL MAPPER 12.1.3.0.0(XSLT Build 140529.0700.0211) AT [THU JUN 11 13:44:33 EEST 2015].-->
  </oracle-xsl-mapper:schema>
  <!--User Editing allowed BELOW this line - DO NOT DELETE THIS LINE-->
  <xsl:param name="ReadConfigOut.payload"/>
  <xsl:param name="P6xReadWBS_Out.payload"/>
  <xsl:template match="/">
    <ns2:response>
      <xsl:attribute name="id">
        <xsl:value-of select="/ns2:read/@id"/>
      </xsl:attribute>
      <ns2:complete>
        <xsl:attribute name="id">
          <xsl:value-of select="/ns2:read/@id"/>
        </xsl:attribute>
        <ns1:timeline>
          <xsl:attribute name="programId">
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:EPS[ns0:ObjectId=/ns0:APIBusinessObjects/ns0:EPS[ns0:ObjectId=/ns0:APIBusinessObjects/ns0:Project/ns0:ParentEPSObjectId]/ns0:ParentObjectId]/ns0:Id"/>
          </xsl:attribute>
          <xsl:attribute name="projectId">
            <xsl:value-of select="substring(/ns0:APIBusinessObjects/ns0:Project/ns0:Id,1.0,string-length(/ns0:APIBusinessObjects/ns0:Project/ns0:Id) - 4.0)"/>
          </xsl:attribute>
          <xsl:attribute name="referenceId">
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:WBSObjectId"/>
          </xsl:attribute>
          <xsl:attribute name="id">
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Id"/>
          </xsl:attribute>
          <ns1:name>
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Name"/>
          </ns1:name>
          <ns1:typeCode>
            <xsl:value-of select="substring(/ns0:APIBusinessObjects/ns0:Project/ns0:Id,string-length(/ns0:APIBusinessObjects/ns0:Project/ns0:Id) - 2.0,3.0)"/>
          </ns1:typeCode>
          <xsl:if test="/ns0:APIBusinessObjects/ns0:Project/ns0:StartDate">
            <ns1:startDate>
              <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:StartDate"/>
            </ns1:startDate>
          </xsl:if>
          <xsl:if test='/ns0:APIBusinessObjects/ns0:Project/ns0:FinishDate and not((/ns0:APIBusinessObjects/ns0:Project/ns0:FinishDate/@xsi:nil = "true"))'>
            <ns1:finishDate>
              <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:FinishDate"/>
            </ns1:finishDate>
          </xsl:if>
          <ns1:lastSummarizedDate>
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:LastSummarizedDate"/>
          </ns1:lastSummarizedDate>
          <ns1:createDate>
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:CreateDate"/>
          </ns1:createDate>
          <ns1:comments>
            <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Description"/>
          </ns1:comments>
          <xsl:if test="/ns0:APIBusinessObjects/ns0:Project/ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:baseline/ns2:ltcIdTypeId]">
            <ns1:ltcId>
              <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:baseline/ns2:ltcIdTypeId]/ns0:TextValue"/>
            </ns1:ltcId>
          </xsl:if>
          <ns1:wbsNodes>
            <xsl:for-each select="/ns0:APIBusinessObjects/ns0:Project/ns0:WBS">
              <ns1:wbs>
                <xsl:attribute name="timelineId">
                  <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Id"/>
                </xsl:attribute>
                <xsl:if test="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:studyIdTypeId]">
                  <xsl:variable name="studyIdVar"
                                select="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:studyIdTypeId]/ns0:TextValue"/>
                  <xsl:if test="string-length($studyIdVar) &lt; 20">
                    <xsl:attribute name="studyId">
                      <xsl:value-of select="$studyIdVar"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:if>
                <xsl:if test="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:placeholderTypeId]">
                  <xsl:if test='ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:placeholderTypeId]/ns0:TextValue !=""'>
                    <xsl:attribute name="placeholder">
                      <xsl:value-of select='"true"'/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:if>
                <xsl:if test='not(ns0:ParentObjectId/@xsi:nil = "true")'>
                  <xsl:attribute name="parentId">
                    <xsl:value-of select="ns0:ParentObjectId"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:attribute name="id">
                  <xsl:value-of select="ns0:ObjectId"/>
                </xsl:attribute>
                <ns1:code>
                  <xsl:value-of select="ns0:Code"/>
                </ns1:code>
                <ns1:name>
                  <xsl:value-of select="ns0:Name"/>
                </ns1:name>
                <xsl:if test='ns0:StartDate and not((ns0:StartDate/@xsi:nil = "true"))'>
                  <ns1:startDate>
                    <xsl:value-of select="ns0:StartDate"/>
                  </ns1:startDate>
                </xsl:if>
                <xsl:if test='ns0:FinishDate and not((ns0:FinishDate/@xsi:nil = "true"))'>
                  <ns1:finishDate>
                    <xsl:value-of select="ns0:FinishDate"/>
                  </ns1:finishDate>
                </xsl:if>
                <xsl:if test="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:studyPhaseTypeId]">
                  <ns1:studyPhase>
                    <xsl:value-of select="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:wbs/ns2:studyPhaseTypeId]/ns0:TextValue"/>
                  </ns1:studyPhase>
                </xsl:if>
                <xsl:if test='ns0:SequenceNumber and not((ns0:SequenceNumber/@xsi:nil = "true"))'>
                  <ns1:sequenceNumber>
                    <xsl:value-of select="ns0:SequenceNumber"/>
                  </ns1:sequenceNumber>
                </xsl:if>
              </ns1:wbs>
            </xsl:for-each>
          </ns1:wbsNodes>
          <ns1:wbsCategories>
            <!-- Root WBS category -->
            <xsl:if test="$P6xReadWBS_Out.payload/ns8:WBS/ns8:WBSCategoryName/text()">
              <ns1:wbsCategory>
                <xsl:attribute name="id">
                  <xsl:value-of select="$P6xReadWBS_Out.payload/ns8:WBS/ns8:ObjectId"/>
                </xsl:attribute>
                <ns1:name>
                  <xsl:value-of select="$P6xReadWBS_Out.payload/ns8:WBS/ns8:WBSCategoryName"/>
                </ns1:name>
                 <ns1:objectId>
                  <xsl:value-of select="$P6xReadWBS_Out.payload/ns8:WBS/ns8:WBSCategoryObjectId"/>
                </ns1:objectId>
              </ns1:wbsCategory>
            </xsl:if>
            <!-- WBS element category -->
            <xsl:for-each select="/ns0:APIBusinessObjects/ns0:Project/ns0:WBS[ns0:WBSCategoryObjectId/text()]">
              <ns1:wbsCategory>
                <xsl:attribute name="id">
                  <xsl:value-of select="ns0:ObjectId"/>
                </xsl:attribute>
                <xsl:attribute name="wbsId">
                  <xsl:value-of select="ns0:ObjectId"/>
                </xsl:attribute>
                <ns1:name>
                  <xsl:value-of select="/ns0:APIBusinessObjects/ns0:WBSCategory[ns0:ObjectId=current()/ns0:WBSCategoryObjectId]/ns0:Name"/>
                </ns1:name>
                <ns1:objectId>
                  <xsl:value-of select="current()/ns0:WBSCategoryObjectId"/>
                </ns1:objectId>
              </ns1:wbsCategory>
            </xsl:for-each>
          </ns1:wbsCategories>
          <!-- BEGIN: Activities -->
          <ns1:activities>
            <xsl:variable name="integrationTypeAutoId"
                          select="/ns0:APIBusinessObjects/ns0:ActivityCode[ns0:CodeTypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:integrationTypeId and ns0:CodeValue = 'Auto']/ns0:ObjectId"/>
            <xsl:for-each select="/ns0:APIBusinessObjects/ns0:Project/ns0:Activity">
              <xsl:if test='(((string-length(ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyElementIdTypeId]/ns0:TextValue) > 0) and (string-length(ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyElementIdTypeId]/ns0:TextValue) &lt; 40)) and ((ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:integrationTypeId]) and (ns0:Code[ns0:ValueObjectId = $integrationTypeAutoId]))) or ((ns0:Type="Start Milestone") or (ns0:Type="Finish Milestone")) or (ns0:WBSObjectId = /ns0:APIBusinessObjects/ns0:Project/ns0:WBS[starts-with(ns0:Name,"Project Activities")]/ns0:ObjectId)'>
                <ns1:activity>
                  <xsl:if test="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyElementIdTypeId]">
                    <xsl:attribute name="studyElementId">
                      <xsl:value-of select="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyElementIdTypeId]/ns0:TextValue"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="timelineId">
                    <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Id"/>
                  </xsl:attribute>
                  <xsl:if test='not(ns0:WBSObjectId/@xsi:nil = "true")'>
                    <xsl:attribute name="wbsId">
                      <xsl:value-of select="ns0:WBSObjectId"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:attribute name="id">
                    <xsl:value-of select="ns0:ObjectId"/>
                  </xsl:attribute>
                  <xsl:if test="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyIdTypeId]">
                    <xsl:attribute name="studyId">
                      <xsl:value-of select="ns0:UDF[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:studyIdTypeId]/ns0:TextValue"/>
                    </xsl:attribute>
                  </xsl:if>
                  <ns1:code>
                    <xsl:value-of select="ns0:Id"/>
                  </ns1:code>
                  <ns1:name>
                    <xsl:value-of select="ns0:Name"/>
                  </ns1:name>
                  <xsl:if test="ns0:Type">
                    <ns1:type>
                      <xsl:value-of select="ns0:Type"/>
                    </ns1:type>
                  </xsl:if>
                  <ns1:functions>
                    <xsl:for-each select="/ns0:APIBusinessObjects/ns0:Project/ns0:ResourceAssignment[ns0:ActivityObjectId = current()/ns0:ObjectId]">
                      <ns1:functionCode>
                        <xsl:value-of select="ns0:RoleId"/>
                      </ns1:functionCode>
                    </xsl:for-each>
                  </ns1:functions>
                  <ns1:planStart>
                    <xsl:value-of select="ns0:PlannedStartDate"/>
                  </ns1:planStart>
                  <ns1:planFinish>
                    <xsl:value-of select="ns0:PlannedFinishDate"/>
                  </ns1:planFinish>
                  <xsl:if test='ns0:ActualStartDate and not(ns0:ActualStartDate/@xsi:nil = "true")'>
                    <ns1:actualStart>
                      <xsl:value-of select="ns0:ActualStartDate"/>
                    </ns1:actualStart>
                  </xsl:if>
                  <xsl:if test='ns0:ActualFinishDate and not(ns0:ActualFinishDate/@xsi:nil = "true")'>
                    <ns1:actualFinish>
                      <xsl:value-of select="ns0:ActualFinishDate"/>
                    </ns1:actualFinish>
                  </xsl:if>
                  <xsl:if test="ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:integrationTypeId]">
                    <ns1:integrationType>
                      <xsl:value-of select="/ns0:APIBusinessObjects/ns0:ActivityCode[ns0:CodeTypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:integrationTypeId and ns0:ObjectId = current()/ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:integrationTypeId]/ns0:ValueObjectId]/ns0:CodeValue"/>
                    </ns1:integrationType>
                  </xsl:if>
                  <xsl:if test="ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:milestoneTypeId]">
                    <ns1:milestoneCode>
                      <xsl:value-of select="/ns0:APIBusinessObjects/ns0:ActivityCode[ns0:CodeTypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:milestoneTypeId and ns0:ObjectId = current()/ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:milestoneTypeId]/ns0:ValueObjectId]/ns0:CodeValue"/>
                    </ns1:milestoneCode>
                  </xsl:if>
                  <xsl:if test="ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:phaseTypeId]">
                    <ns1:phaseCode>
                      <xsl:value-of select="/ns0:APIBusinessObjects/ns0:ActivityCode[ns0:CodeTypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:phaseTypeId and ns0:ObjectId = current()/ns0:Code[ns0:TypeObjectId = $ReadConfigOut.payload/ns2:config/ns2:activity/ns2:phaseTypeId]/ns0:ValueObjectId]/ns0:CodeValue"/>
                    </ns1:phaseCode>
                  </xsl:if>
                  <ns1:createUser>
                    <xsl:value-of select="ns0:CreateUser"/>
                  </ns1:createUser>
                </ns1:activity>
              </xsl:if>
            </xsl:for-each>
          </ns1:activities>
          <!-- END: Activities -->
          <ns1:expenses>
            <xsl:for-each select="/ns0:APIBusinessObjects/ns0:Project/ns0:ActivityExpense[ns0:ActivityObjectId = //ns0:Activity[ns0:Type='WBS Summary']/ns0:ObjectId]">
              <ns1:expense>
                <xsl:attribute name="id">
                  <xsl:value-of select="ns0:ObjectId"/>
                </xsl:attribute>
                <xsl:if test="/ns0:APIBusinessObjects/ns0:Project/ns0:Activity[ns0:ObjectId = current()/ns0:ActivityObjectId]/ns0:WBSObjectId/node()">
                  <xsl:attribute name="wbsId">
                    <xsl:value-of select="/ns0:APIBusinessObjects/ns0:Project/ns0:Activity[ns0:ObjectId = current()/ns0:ActivityObjectId]/ns0:WBSObjectId"/>
                  </xsl:attribute>
                </xsl:if>
                <ns1:name>
                  <xsl:value-of select="ns0:ExpenseItem"/>
                </ns1:name>
                <ns1:functionCode>
                  <xsl:value-of select="/ns0:APIBusinessObjects/ns0:CostAccount[ns0:ObjectId=current()/ns0:CostAccountObjectId]/ns0:Id"/>
                </ns1:functionCode>
                <ns1:costType>
                  <xsl:value-of select="/ns0:APIBusinessObjects/ns0:ExpenseCategory[ns0:ObjectId=current()/ns0:ExpenseCategoryObjectId]/ns0:Name"/>
                </ns1:costType>
                <ns1:planCost>
                  <xsl:value-of select="format-number(ns0:PlannedCost, '0.00######')"/>
                </ns1:planCost>
                <xsl:if test="ns0:UDF[ns0:TypeObjectId=$ReadConfigOut.payload/ns2:config/ns2:activity/ns2:expenseCommentTypeId]/ns0:TextValue/node()">
                  <ns1:comments>
                    <xsl:value-of select="ns0:UDF[ns0:TypeObjectId=$ReadConfigOut.payload/ns2:config/ns2:activity/ns2:expenseCommentTypeId]/ns0:TextValue"/>
                  </ns1:comments>
                </xsl:if>
              </ns1:expense>
            </xsl:for-each>
          </ns1:expenses>
        </ns1:timeline>
      </ns2:complete>
    </ns2:response>
  </xsl:template>
</xsl:stylesheet>