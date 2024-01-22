package com.redsam.audit.reqmonitor;


import com.redsam.audit.LogManager;

import java.io.CharArrayWriter;
import java.io.IOException;
import java.io.PrintWriter;

import java.util.Collections;
import java.util.HashMap;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

import oracle.adf.share.logging.ADFLogger;

/* todo:
 * . posponed: implement 'component with existing clientListeners' use case, but having different event types
 * . implement af:dialog properly: monitorStart on AFRichPopup 'popupOpening' and monitorEnd AFRichPopup 'popupOpening'
 * . customization in web.xml of script file name and ADF version name.
 *
 */
/**
 * Red Samurai Audit. Version 4.0
 */
public class ReqMonitorTimeFilter implements Filter {

    private static final String SCRIPT_TAG =
        "<script type=\"text/javascript\" language=\"javascript\" src=\"../js/redsamaudit.js\"></script>";

    private static final String MONITOR_DATA_FIELD =
        "<input type='hidden' name='redsam_audit_data' id='redsam_audit_data' value=''>";

    private static ADFLogger LOGGER =
        ADFLogger.createADFLogger("com.redsam.audit.ReqMonitorTimeFilter");

    private static enum COMPONENTS {
        BUTTON("AdfRichButton" + "('", "action"),
        LINK("AdfRichLink" + "('", "action"),
        CMDIMGLINK("AdfRichCommandImageLink" + "('", "action"),
        CMDBUTTON("AdfRichCommandButton" + "('", "action"),
        CMDLINK("AdfRichCommandLink" + "('", "action"),
        MENUITEM("AdfRichCommandMenuItem" + "('", "action"),
        TOOLBARBUTTON("AdfRichCommandToolbarButton" + "('", "action"),
        SHOWDETAILITEM("AdfRichShowDetailItem" + "('", "disclosure"),
        POPUP("AdfRichPopup" + "('", "popupOpening"),
        DIALOG("AdfRichDialog" + "('", "dialog"),
        QUERY("AdfRichQuery" + "('", "query"),
        NAVBUTTON("AdfRichCommandNavigationItem" + "('", "action");

        COMPONENTS(String html, String eventType) {
            this.html = html;
            this.eventType = eventType;
        }

        private String html;

        public void setHtml(String html) {
            this.html = html;
        }

        public String getEventType() {
            return eventType;
        }
        private String eventType;

        public String getHtml() {
            return html;
        }

        public static COMPONENTS getInstance(String html) {
            if (html == null)
                return null;
            for (COMPONENTS component : COMPONENTS.values()) {

                if (html.equals(component.getHtml())) {
                    return component;
                }
            }
            return null;
        }
    }


    protected FilterConfig config;

    public static final String CLIENT_LISTENER_TAG =
        "'clientListeners':{???:monitorStart},";
    public static final String CLIENT_LISTENER_SINGLETAG =
        ",{'clientListeners':{???:monitorStart}}";
    public static final String CLIENT_LISTENER_ALREADY_EXISTS_TAG =
        ",monitorStart";

    public String adfversion = "12c"; //default value
    //public static final String adfversion = "11gR1";

    public void init(FilterConfig config) throws ServletException {
        this.config = config;
        String adfver = config.getInitParameter("ADF_VERSION");
        if (adfver != null) {
            adfversion = adfver;
        }
        if (LOGGER.isInfo())
            LOGGER.info("\n\n\n\n\n\n\n\n Redsamurai Audit Request Monitoring service set up for ADF version: " +
                        adfversion);

    }

    public void destroy() {
    }

    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws ServletException,
                                                   IOException {
        
        if (!LogManager.isVerboseDiagnosticLevel()) {
            chain.doFilter(request, response);
        } else {
            ServletResponse newResponse = response;

            if (request instanceof HttpServletRequest) {
                newResponse =
                        new CharResponseWrapper((HttpServletResponse)response);
            }

            chain.doFilter(request, newResponse);
            boolean noop = false;

            if (newResponse instanceof CharResponseWrapper) {

                String html = newResponse.toString();
                if (html != null) {
                    StringBuilder textToBeParsed = new StringBuilder(html);

                    //Step 1: on each ADF partial(ajax) request, we inject a MONITOR RESPONSE COMPLETE  event
                    long init = System.currentTimeMillis();
                    if (adfversion.equals("11gR1")) {
                        if (textToBeParsed.indexOf("<?Adf-Rich-Response-Type ?>") >=
                            0) {
                            int start = textToBeParsed.indexOf("</content>");
                            textToBeParsed.insert(start,
                                                  "<script>monitorEnd();</script>");
                        } else {

                            //Step 1.1: inject the <script> tag reference on FULL PAGE loads
                            int whereHeadEnds =
                                textToBeParsed.indexOf("</head>");
                            if (whereHeadEnds > 0) {
                                //insert the script tab
                                textToBeParsed.insert(whereHeadEnds,
                                                      SCRIPT_TAG);
                            }

                            //Step 1.2: inject the <input name="audit_data"> field FULL PAGE loads
                            int whereFormEnds =
                                textToBeParsed.indexOf("</form>");
                            if (whereFormEnds > 0) {
                                //insert the script tab
                                textToBeParsed.insert(whereFormEnds,
                                                      MONITOR_DATA_FIELD);
                            }

                        }
                    } else if (adfversion.equals("12c")) {
                        if (textToBeParsed.indexOf("<partial-response>") >=
                            0) {

                            if (textToBeParsed.indexOf("<partial-response><noop/></partial-response>") ==
                                -1 &&
                                textToBeParsed.indexOf("<redirect url=") ==
                                -1) {
                                int start =
                                    textToBeParsed.indexOf("</eval>") + "</eval>".length();
                                textToBeParsed.insert(start,
                                                      "<eval>monitorEnd();</eval>");
                            }

                            else {
                                noop = true;
                            }

                        } else {

                            //Step 1.1: inject the <script> tag reference on FULL PAGE loads
                            int whereHeadEnds =
                                textToBeParsed.indexOf("</head>");
                            if (whereHeadEnds > 0) {
                                //insert the script link
                                textToBeParsed.insert(whereHeadEnds,
                                                      SCRIPT_TAG);
                            }

                            //Step 1.2: inject the <input name="audit_data"> field FULL PAGE loads
                            int whereFormEnds =
                                textToBeParsed.indexOf("</form>");
                            if (whereFormEnds > 0) {
                                //insert the script tab
                                textToBeParsed.insert(whereFormEnds,
                                                      MONITOR_DATA_FIELD);
                            }


                        }
                    } else {
                        if (LOGGER.isInfo())
                            LOGGER.warning("\n\n\n\n\n\n\n\nConfiguration error: this ADF version is not supported: " +
                                           adfversion);

                    }

                    //Step 2: on each button we attach a clientListener
                    String text =
                        ReqMonitorTimeFilter.injectClientListeners(textToBeParsed);
                    if (LOGGER.isInfo())
                        LOGGER.info("Time elapsed with manipulating response : " +
                                    (System.currentTimeMillis() - init));
                    response.getWriter().write(text);
                    

                    //collect data
                    if (!noop) {
                        HttpServletRequest req = (HttpServletRequest)request;
                        String redsamuraiAudit =
                            System.getProperty("redsamurai.audit");
                        if (!"off".equals(redsamuraiAudit)) {
                            String input =
                                req.getParameter("redsam_audit_data");
                            LogManager.logClientRequest(input, 
                                                        req.getUserPrincipal() + "");


                        }
                    }
                }
            }
        }
    }

    public static void main(String[] asd) throws Exception {

        //TODO
        //new AdfRichInputListOfValues('r1:0:departmentIdId',{'clientListeners':{click:cocoKumbo},'popupTitle':'Search and Select: DepartmentId','converter':new TrNumberConverter(null,'number',null,null,false,false,null,null,null,null,null,null),'columns':4})
        //

        //TEST1 (simple button)
        String text =
            "new AdfRichLink('pt1:bBarFDC:logoLinkAlt',{'shortDesc':''})";
        text =
"AdfRichLink('pt1:cBodFDC:r1:0:mamamac',{'clientListeners':{action:dummyJs},'accessKey':'\uffff','partialSubmit':true})";

        //TEST2 ( button, extra attributes)
        //text =
        //    " new AdfRichLink('pt1:cBodFDC:r1:0:mocaboca2'),new AdfRichButton('pt1:bBarFDC:employeeBtn',{'selected':true}),new AdfRichLink('pt1:bBarFDC:employeeBtn2',{'selected':true})";

        //TEST3(button, extra attributes and clientListener)
        //        text =
        //            ",new AdfRichCommandLink('cl1',{'partialSubmit':true}),new AdfRichCommandImageLink('cil1',{'clientListeners':{action:dummyJS},'partialSubmit':true,'accessKey':'\uffff','text':'commandImageLink 1'})";
        text =
",new AdfRichCommandLink('aaa'),new AdfRichCommandImageLink('bbb',{'clientListeners':{action:dummyJS,keyUp:dummyJs}})";
        //text = "new AdfRichCommandButton('pt1:bBarFDC:commandButtonid',{'clientListeners':{action:dummyJs,keyUp:dummyJs,monitorStart]}";
        System.out.println("\nBefore:\n" +
                text);
        text = injectClientListeners(new StringBuilder(text));

        System.out.println("\nAfter:\n" +
                text);

        runTests();
    }

    /**
     * Injects dynamically into every commandButton a clientListener caling 'monitorStart' javascript function.
     * eg:
     * Replaces :
     *           new AdfRichButton('pt1:cBodFDC:r1:0:h_navb2')
     * with
     *           new AdfRichButton('pt1:cBodFDC:r1:0:h_navb2','clientListeners':{action:monitorStart})
     * @param text
     * @return
     */
    static String injectClientListeners(StringBuilder textToBeParsed) {

        int offset = 0;
        int prevOffset = 0;
        int loop = 0;
        while (offset >= 0) {
            loop++;
            //get the position  AdfRichButton('pt1:cBodFDC:r1:0:b1',
            prevOffset = offset;


            HashMap<Integer, String> offsets =
                new HashMap<Integer, String>(COMPONENTS.values().length);
            for (COMPONENTS component : COMPONENTS.values()) {
                int u = textToBeParsed.indexOf(component.getHtml(), offset);
                if (u >= 0) {
                    offsets.put(u, component.getHtml());
                }
            }
            if (offsets.isEmpty()) {
                break;
            }

            offset = Collections.min(offsets.keySet());
            String componentName = offsets.get(offset);
            COMPONENTS component = COMPONENTS.getInstance(componentName);
            if (component == null) {
                if (LOGGER.isInfo())
                    LOGGER.info("invalid component html: " + componentName);
                break;
            }

            if (offset < prevOffset) {
                break;
            }

            offset += componentName.length();

            if (offset >= 0) {
                //get the NEXT '{'  ocurence
                int startAttributesOffset =
                    textToBeParsed.indexOf("{", offset) + 1;

                //check the end of this tag
                int endTagOffset = textToBeParsed.indexOf(")", offset) + 1;
                int endTagOffset2 = textToBeParsed.indexOf("),", offset) + 1;
                
                if(endTagOffset == endTagOffset2) {
                    //this is good
                } else {
                    //System.out.println("lets check " +  endTagOffset  + " " + endTagOffset2);
                    if(endTagOffset > 0 && endTagOffset2 > 0) {
                        endTagOffset = Math.max(endTagOffset, endTagOffset2);
                    }
                
                }

                //if the button has no properties inside, eg: new AdfRichButton('pt1:cBodFDC:r1:0:mocaboca2')
                if (endTagOffset < startAttributesOffset ||
                    startAttributesOffset <= 0) {
                    //we insert CLIENT_LISTENER_SINGLETAG before end, in bracets
                    String singleClientListenerTag =
                        CLIENT_LISTENER_SINGLETAG.replace("???",
                                                          component.getEventType());
                    textToBeParsed =
                            textToBeParsed.insert(endTagOffset - 1, singleClientListenerTag);
                    offset = endTagOffset;

                } else {

                    if (startAttributesOffset <= 0) {
                        break;
                    }

                    //check if the tag already contains a clientListener
                    //AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:[calculatePageLoadTime,monitorStart]}
                    String tagContent =
                        textToBeParsed.substring(startAttributesOffset,
                                                 endTagOffset);

                    if (tagContent.indexOf("'clientListeners':{" +
                                           component.getEventType() + ":") ==
                        -1) {
                        String clientListenerTag =
                            CLIENT_LISTENER_TAG.replace("???",
                                                        component.getEventType());
                        textToBeParsed =
                                textToBeParsed.insert(startAttributesOffset,
                                                      clientListenerTag);
                    } else {
                        int endOfClientListenerOffset =
                            textToBeParsed.indexOf("}", startAttributesOffset);

                        //check if the clientListeners tag contains MORE listeners with DIFFERENT event types
                        int indexClLstart =
                            tagContent.indexOf("'clientListeners':");
                        int indexClLsEnd =
                            tagContent.indexOf("}", indexClLstart);
                        String clientListersContent =
                            tagContent.substring(indexClLstart, indexClLsEnd);
                        if (clientListersContent.split(":").length > 3) {
                            System.out.println("irnoring the case");
                            //ignore this use case for now
                        }

                        //check if button contains ONE LISTENER only
                        else if (tagContent.indexOf(component.getEventType() +
                                                    ":[") == -1) {


                            //if a single button, we insert bracets [] around the two function calls
                            String clientListenerTag =
                                CLIENT_LISTENER_ALREADY_EXISTS_TAG.replace("???",
                                                                           component.getEventType());

                            textToBeParsed =
                                    textToBeParsed.insert(endOfClientListenerOffset,
                                                          clientListenerTag +
                                                          "]");


                            int actionOffset =
                                textToBeParsed.indexOf(component.getEventType() +
                                                       ":", offset) +
                                (component.getEventType() + ".").length();

                            if (actionOffset > endTagOffset) {
                                throw new IllegalStateException("Injection algorithm is incompatible with response format");
                            }

                            textToBeParsed =
                                    textToBeParsed.insert(actionOffset, "[");

                        } else {
                            // if button contains MORE THAN ONE listener
                            String clientListenerTag =
                                CLIENT_LISTENER_ALREADY_EXISTS_TAG.replace("???",
                                                                           component.getEventType());

                            textToBeParsed =
                                    textToBeParsed.insert(endOfClientListenerOffset -
                                                          1,
                                                          clientListenerTag);
                        }
                    }
                }
                offset = endTagOffset;
            }
        }
        return textToBeParsed.toString();

    }


    private static void runTests() {
        //TEST1 (simple button)
        String text = "new AdfRichButton('pt1:cBodFDC:r1:0:mocaboca2')";
        String endResult =
            ReqMonitorTimeFilter.injectClientListeners(new StringBuilder(text));

        if (!endResult.equals("new AdfRichButton('pt1:cBodFDC:r1:0:mocaboca2',{'clientListeners':{action:monitorStart}})")) {
            System.out.println("before:" + text);
            System.out.println("endResult:" + endResult);


            throw new IllegalStateException("Simple button conversion doesn't work anymore");
        } else {
            System.out.println("Simple button test: PASSED");
        }


        //TEST2 ( button, extra attributes)
        text =
"new AdfRichButton('pt1:bBarFDC:employeeBtn',{'depressedIcon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_act.png','hoverIcon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_hov.png','icon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_ena.png','selected':true,'type':'radio'}),";
        endResult =
                ReqMonitorTimeFilter.injectClientListeners(new StringBuilder(text));
        //        if (!endResult.equals("new AdfRichButton('pt1:cBodFDC:r1:0:mocaboca2',{'clientListeners':{action:monitorStart}}),new AdfRichButton('pt1:bBarFDC:employeeBtn',{'clientListeners':{action : monitorStart},'depressedIcon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_act.png','hoverIcon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_hov.png','icon':'/redsamapp/resources/images/naviBarFaces/navi_person_24_ena.png','selected':true,'type':'radio'}),")) {
        //            System.out.println("before   :  " + text);
        //            System.out.println("endresult:  " + endResult);
        //            throw new IllegalStateException("Button with  attributes injection doesn't work anymore");
        //        } else {
        //            System.out.println("Button with  attributes test: PASSED");
        //        }


        //TEST3(button, extra attributes one clientListener)
        text =
"AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:dummyJS},'accessKey':'?'})";
        endResult =
                ReqMonitorTimeFilter.injectClientListeners(new StringBuilder(text));
        if (!endResult.equals("AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:[dummyJS,monitorStart]},'accessKey':'?'})")) {
            System.out.println("before  : " + text);
            System.out.println("after   : " + endResult);
            System.out.println("expected: " +
                               "AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:[dummyJS,monitorStart]},'accessKey':'?'})");

            throw new IllegalStateException("Button with  ONE client Listener test doesn't work anymore");
        } else {
            System.out.println("Button with  ONE Client Listener test: PASSED");
        }

        //TEST3(button, extra attributes one clientListener)
        text =
"AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:[dummyJS,tests]},'accessKey':'?'})";
        endResult =
                ReqMonitorTimeFilter.injectClientListeners(new StringBuilder(text));
        if (!endResult.equals("AdfRichButton('pt1:bBarFDC:b2',{'clientListeners':{action:[dummyJS,tests,monitorStart]},'accessKey':'?'})")) {
            System.out.println("endResult: " + endResult);
            throw new IllegalStateException("Button with  attributes injection doesn't work anymore");
        } else {
            System.out.println("Button with  MULTIPLE Client Listeners test: PASSED");
        }
    }

}

class CharResponseWrapper extends HttpServletResponseWrapper {
    protected CharArrayWriter charWriter;

    protected PrintWriter writer;

    protected boolean getOutputStreamCalled;

    protected boolean getWriterCalled;

    public CharResponseWrapper(HttpServletResponse response) {
        super(response);

        charWriter = new CharArrayWriter();
    }

    public ServletOutputStream getOutputStream() throws IOException {
        if (getWriterCalled) {
            throw new IllegalStateException("getWriter already called");
        }

        getOutputStreamCalled = true;
        return super.getOutputStream();
    }

    public PrintWriter getWriter() throws IOException {
        if (writer != null) {
            return writer;
        }
        if (getOutputStreamCalled) {
            throw new IllegalStateException("getOutputStream already called");
        }
        getWriterCalled = true;
        writer = new PrintWriter(charWriter);
        return writer;
    }

    public String toString() {
        String s = null;

        if (writer != null) {
            s = charWriter.toString();
        }
        return s;
    }


}
