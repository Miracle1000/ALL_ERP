
function callServer2() {
  var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);  
}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}
function go(loc){
window.location.href = loc;
}

function getPersons()
{
	var url = "AjaxPerson.asp?t=" + Math.round(Math.random()*100);
	xmlHttp.open("get",url,false);
	xmlHttp.onreadystatechange = function()
	{
		if (xmlHttp.readyState == 4)
		{
			document.getElementById("persons").innerHTML=xmlHttp.responseText.split("</noscript>")[1];
		}
	};
	xmlHttp.send(null);
}

    function checkAll(str){
        var a=document.getElementById("d"+str).getElementsByTagName("input");
        var b=document.getElementById("t"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk(str){
        var a=document.getElementById("t1").getElementsByTagName("input");
        var b=document.getElementById("d1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

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

    function checkAll23(str){
        var a=document.getElementById("FK"+str).getElementsByTagName("input");
        var b=document.getElementById("CW"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk23(str){
        var a=document.getElementById("FK1").getElementsByTagName("input");
        var b=document.getElementById("CW1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll3(str){
        var a=document.getElementById("h"+str).getElementsByTagName("input");
        var b=document.getElementById("i"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk3(str){
        var a=document.getElementById("h1").getElementsByTagName("input");
        var b=document.getElementById("i1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll7(str){
        var a=document.getElementById("Wd"+str).getElementsByTagName("input");
        var b=document.getElementById("Wt"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk7(str){
        var a=document.getElementById("Wd1").getElementsByTagName("input");
        var b=document.getElementById("Wt1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll4(str){
        var a=document.getElementById("j"+str).getElementsByTagName("input");
        var b=document.getElementById("k"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk4(str){
        var a=document.getElementById("j1").getElementsByTagName("input");
        var b=document.getElementById("k1");
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
function alert_fl(id,ord) {
	var w=document.getElementById("intro_msg");
	if(!w){w=document.createElement("DIV");document.body.appendChild(w);w.id="intro_msg";}
	w.style.cssText = "position:absolute;left:" + event.x + "px;top:" + (event.y*1 +document.body.scrollTop*1)+ "px;z-index:1000000;display:block;"
	var url = "content_fl.asp?id="+escape(id)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage2(w);
	};
	xmlHttp.send(null);
}
