function downloadFileWithTimestamp(uri,fileName){

var downloadLink = document.createElement("a");
downloadLink.href = uri;
downloadLink.download = Date.now()+"-"+fileName;

document.body.appendChild(downloadLink);
downloadLink.click();
document.body.removeChild(downloadLink);

}