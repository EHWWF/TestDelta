              var startTime;
              var process = false;
              var data;
              

              function getStartTime(){
                if(hasStorage) {
                  return sessionStorage.startTime;
                } else {
                  return top.startTime; 
                }
              }
              function setStartTime(st) {
               if(hasStorage) {
                  sessionStorage.startTime =  st;
                } else {
                  top.startTime = st;
                }
              }
              
              function getProcess(){
                
                if(hasStorage) {
                  var p = sessionStorage.process;
                  //console.log("getProcess: " + p + "-- " + (p== true));
                  if(p == true || p == 'true')
                    return true;
                  else
                    return false;
                    
                } else {
                  return top.process; 
                }
              }
              
              function setProcess(p) {
                console.log("hasStorage: " + hasStorage);
               if(hasStorage) {
                  sessionStorage.process = p;
                } else {
                  top.process = p;
                }
              }
              
              function getData(){
                if(hasStorage) {
                  return sessionStorage.data;
                } else {
                  return top.data;
                }
              }
              
              function setData(d) {
               if(hasStorage) {
                  sessionStorage.data =  d;
                } else {
                  top.data = d;
                }
              }
              

              function getPathForComponent(component) {
                  console.log("getPathFromButton start");
                  var path = "";
                  var parentComp = component._parent;
                  //console.log("getPathFromButton " + parentComp);
                  while(parentComp != null) {
                      if(parentComp._props.title != null) {
                        path ="&&&&" + parentComp._props.title + path;
                      } else if(parentComp._props.text != null) {
                        path ="&&&&" + parentComp._props.text + path;
                      } else if(parentComp._props.value != null) {
                        path ="&&&&" + parentComp._props.value + path;
                      } else {
                      
                      //*************START PENFAX SPECIFIF LOGIC*************
                        //pt_ps1 exists  in GenericTabFragmTemplate.jspx
                        if(parentComp._clientId.indexOf("pt_ps1") >= 0  &&  parentComp._componentType =="oracle.adf.RichPanelSplitter") {
                           var children = parentComp.getDescendantComponents();
                           for(k = 0; k < children.length; k++) {
                              var childComp  = children[k];
                              //console.log("children sss " + children[k]);
                              if(childComp._clientId.indexOf("pt_ph1") >= 0  &&  childComp._componentType =="oracle.adf.RichPanelHeader") {
                                var v = childComp.getText();
                                if(v != null && path.indexOf(v) == -1){
                                  path ="&&&&" + childComp.getText() + path;
                                }
                                break;
                              }
                           }   
                        }
                      }
                      //*************END PENFAX SPECIFIF LOGIC***************
                      parentComp = parentComp._parent;
                  }
                  
                  if (path == '') {
                      path = '&&&&' + location.pathname;
                  }
                  
                  return path;
              }
              
              var preventInfiniteLoop = 0;
              function getTextFromDOM(domElement) {
                preventInfiniteLoop++;
                if (preventInfiniteLoop > 25){
                  //prevent too much looping 
                  //console.log(stamp + " return 3 domElement coco: " + domElement.children.length + " " + domElement + " - " + domElement.id);
                  return "$undefined$";
                }
                
                 if(domElement.children.length == 0) {
                      return domElement.innerHTML;
                 } else {
                        
                        for(i=0; i< domElement.children.length;i++ ) {
                           var t =  getTextFromDOM(domElement.children[i]); 
                           if(t != null && t != '' && t != '&nbsp;' && t != '…') 
                              return t;
                        }
                 }
                
              }
              
              
              function getTextForComponent(component) {
              
                  var clientId = component._clientId;
                  var text = "";
                  var domElement = document.getElementById(clientId);
                  preventInfiniteLoop = 0;
                  var t = getTextFromDOM(domElement);
                  if(t != null && t != "" && t.indexOf("<") == -1) {
                    text = t;
                    
                  }
                  
                  return text;
        }
              
             
              //called before any button is executed
              function monitorStart(evt) {
                  console.log("monitorStart..... " );
                  var text =  getTextForComponent(evt.getSource());
                  var path =  getPathForComponent(evt.getSource());
                  var clientId = evt.getSource()._clientId;
                  var pageLoadTime = sessionStorage.getItem('pageLoadTime');
       
                  setStartTime( new Date().getTime());
                  setProcess(true);
                  setData(path + "&&&&" + text + "&&&&" + clientId + "&&&&" + pageLoadTime);

                  console.log("monitorstart, process:.." + getProcess() + ", start time:  " + getStartTime() + ", data: " + getData());
              }
              
              

              //executed after each page load
              function monitorEnd(evt) {
                  if (getProcess()) {
                      var now = new Date().getTime();
                      var loadTime = now - getStartTime();
                      console.log('Request processing time: ' + loadTime);
                      var comp = top.document.getElementById('pt1:bBarFDC:ot2');
                      if(comp)
                        comp.innerHTML = 'Page load time (ms.): ' + loadTime;
                      
                      var data = document.getElementById('redsam_audit_data');
                      if(data) {
                        data.value = loadTime  + getData();
                        console.log("info sent to the server" +data.value);
                      }
                      setProcess(false);
                  }
              }
              
          //Feature test
          var hasStorage = typeof (Storage) !== "undefined";
          

        function calculatePageLoadTime(evt) {
              var now = new Date().getTime();
              var loadTime = now - performance.timing.navigationStart;
              
              console.log("Page load time (ms.): " + loadTime);

              sessionStorage.setItem('pageLoadTime', loadTime);
          }
          
          
//          
//          function getTextFromDOM(domElement)
//{
//  count++;
//  var stamp = count;
//  console.log(stamp + " domElement coco: " + domElement.children.length + " " + domElement + " - " + domElement.id + "---" + (domElement.tagName));
//  if (count > 100)
//  {
//    //prevent too much looping 
//    console.log(stamp + " return 3 domElement coco: " + domElement.children.length + " " + domElement + " - " + domElement.id);
//    return "$undefined$";
//  }
//
//  if (domElement.tagName == 'TABLE')
//  {
//    for (var ii = 0, row;row = domElement.rows[ii];ii++)
//    {
//      //iterate through rows
//      //rows would be accessed using the "row" variable assigned in the for loop
//      var cnt = 0
//      for (var jj = 0, col;col = row.cells[jj];jj++)
//      {
//        cnt++;
//        if(cnt > 20)
//            return;
//        var moc = getTextFromDOM(col);
//        console.log("moc: " + moc);
//        if(moc != null) {
//          return moc;
//        }
//      }
//    }
//  }
//  else 
//  {
//
//    if (domElement.children.length == 0)
//    {
//      console.log(stamp + " return innerHTML: " + domElement.innerHTML);
//      return domElement.innerHTML;
//    }
//    else 
//    {
//
//      for (i = 0;i < domElement.children.length;i++)
//      {
//        var t = getTextFromDOM(domElement.children[i]);
//        if (t != null && t != '' && t != '&nbsp;' && t != '…')
//        {
//          console.log(stamp + " return 2 domElement coco: " + domElement.children.length + " " + domElement + " - " + domElement.id);
//          return t;
//        }
//      }
//      console.log(stamp + " return 2 domElement coco: " + domElement.children.length + " " + domElement + " - " + domElement.id);
//      return "";
//    }
//
//  }
//
//}


