
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
  var w =document.getElementById("intro_aaa_msg");
  if(!w) {
		w = document.createElement("div");
		w.id = "intro_aaa_msg";
		document.body.appendChild(w);
		w.style.position = "absolute";
  }
  w.style.left = (window.event.clientX + document.body.scrollLeft) + "px";
  w.style.top = (window.event.clientY  + document.body.scrollTop) + "px";
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
   document.getElementById("intro_aaa_msg").innerHTML="";
   xmlHttp.abort();
}

