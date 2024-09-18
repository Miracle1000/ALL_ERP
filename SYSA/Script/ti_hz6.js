
    function checkAll2(str){
        var a=document.getElementById("u"+str).getElementsByTagName("input");
        var b=document.getElementById("e"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }
	function fixChk2(str){
        var a=document.getElementById("u1").getElementsByTagName("input");
        var b=document.getElementById("e1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

function alert_jg(id,ord) {
  var id  = "intro_msg";
   var w=document.getElementById(id);
   if(!w){w=document.createElement("DIV");document.body.appendChild(w);w.id=id;}
   w.style.cssText = "position:absolute;left:" + event.x + "px;top:" + (event.y*1 +document.body.scrollTop*1)+ "px;z-index:1000000;display:block;"
  var url = "../product/content_list.asp?id="+escape(id)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(w);
  };
  xmlHttp.send(null);
}
function updatePage2(w) {
var test=w
  if (xmlHttp.readyState < 4) {
	test.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test.innerHTML=response;
    xmlHttp.abort();
}
}

function alert_jgclose(id,ord) {
 var id  = "intro_msg";
 var w=document.getElementById(id);
   w.style.cssText = "display:none";
   w.innerHTML="";
   xmlHttp.abort();
}

