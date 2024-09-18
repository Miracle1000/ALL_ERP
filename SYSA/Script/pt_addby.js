
function ask() { 
  date.submit(); 
}
function ask2() { 
document.all.date.action = "save.asp?sort3=2"; 
} 



function callServer(nameitr) {
  var u_name = document.getElementById("u_name"+nameitr).value;
   var w  = document.all[nameitr];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w);
  };
  xmlHttp.send(null);  
}

function updatePage(namei) {
var test7=namei
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }

}

function callServer2() {
  var unit1 = document.getElementById("unit1").value;
  if ((unit1 == null) || (unit1 == "")) return;

  var url = "cuunit.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(unit1);
  };
  xmlHttp.send(null);  
}


function updatePage2(unit1) {
  if (xmlHttp.readyState < 4) {
	trpx0.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx0.innerHTML=response;
	
  var url1 = "cuunit3.asp?unit1=" + escape(unit1)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage3();
   };
	 xmlHttp.send(null); 
	
  }
}


function updatePage3() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
 
  xmlHttp.abort();
  }
}



function callServer4(ord) {

 if ((ord == null) || (ord == "")) return;
  var url = "num_click.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage4(ord);
  };
  xmlHttp.send(null);  
}

function updatePage4(ord) {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var res = xmlHttp.responseText;
	var w  = "trpx"+res;
 w=document.all[w]
  var url = "cuunit2.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage5(w,ord);
  };
  xmlHttp.send(null);  
  }
}

function updatePage5(w,unitall) {
var test3=w;
  if (xmlHttp.readyState < 4) {
	test3.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test3.innerHTML=response;
	
 var url1 = "cuunit4.asp?unitall=" + escape(unitall)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage6();
   };
	 xmlHttp.send(null);
	
  }
}

function updatePage6() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
 
 	
  var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url1, true);
  xmlHttp.onreadystatechange = function(){
  updatePage7();
   };
	 xmlHttp.send(null);
	
  }
}
function updatePage7() {
  if (xmlHttp.readyState < 4) {
	trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit1.innerHTML=response;
 
  xmlHttp.abort();
  }
}

function del(str,id){
	
	var w  = str;
	
	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del(str) {

if (xmlHttp.readyState < 4) {
	trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
    document.getElementById(str).style.display="none";
    var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage8();
   };
	 xmlHttp.send(null);
  }
}

function updatePage_del2(str) {

if (xmlHttp.readyState < 4) {
	trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
    document.getElementById(str).style.display="none";
    var url1 = "cuunit5.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage7();
   };
	 xmlHttp.send(null);
  }
}

function updatePage8() {
  if (xmlHttp.readyState < 4) {
	trpx_unit1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit1.innerHTML=response;
 
 var url1 = "cuunit4.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
    xmlHttp.open("GET", url1, true);
    xmlHttp.onreadystatechange = function(){
    updatePage9();
   };
	 xmlHttp.send(null);
  }
}

function updatePage9() {
  if (xmlHttp.readyState < 4) {
	trpx_unit2.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx_unit2.innerHTML=response;
 
    xmlHttp.abort();
  }
}



self.onError=null;
currentX = currentY = 10; 
whichIt = null; 
lastScrollX = 0; lastScrollY = 0;
NS = (document.layers) ? 1 : 0;
IE = (document.all) ? 1: 0;
<!-- STALKER CODE -->
function heartBeat() {
if(IE) { diffY = document.body.scrollTop; diffX = document.body.scrollLeft; }
if(NS) { diffY = self.pageYOffset; diffX = self.pageXOffset; }
if(diffY != lastScrollY) {
percent = .1 * (diffY - lastScrollY);
if(percent > 0) percent = Math.ceil(percent);
else percent = Math.floor(percent);
if(IE) document.all.floater.style.pixelTop += percent;
if(NS) document.floater.top += percent; 
lastScrollY = lastScrollY + percent;}
if(diffX != lastScrollX) {
percent = .1 * (diffX - lastScrollX);
if(percent > 0) percent = Math.ceil(percent);
else percent = Math.floor(percent);
if(IE) document.all.floater.style.pixelLeft += percent;
if(NS) document.floater.left += percent;
lastScrollX = lastScrollX + percent;
}
}
function checkFocus(x,y) { 
stalkerx = document.floater.pageX;
stalkery = document.floater.pageY;
stalkerwidth = document.floater.clip.width;
stalkerheight = document.floater.clip.height;
if( (x > stalkerx && x < (stalkerx+stalkerwidth)) && (y > stalkery && y < (stalkery+stalkerheight))) return true;else return false;
}
function grabIt(e) {
if(IE) {
whichIt = event.srcElement;
while (whichIt.id.indexOf("floater") == -1) {
whichIt = whichIt.parentElement;
if (whichIt == null) { return true; }}
whichIt.style.pixelLeft = whichIt.offsetLeft;
whichIt.style.pixelTop = whichIt.offsetTop;
currentX = (event.clientX + document.body.scrollLeft);
currentY = (event.clientY + document.body.scrollTop); 
} else { 
window.captureEvents(Event.MOUSEMOVE);
if(checkFocus (e.pageX,e.pageY)) { 
whichIt = document.floater;
StalkerTouchedX = e.pageX-document.floater.pageX;
StalkerTouchedY = e.pageY-document.floater.pageY;} 
}
return true;
}
function moveIt(e) {
if (whichIt == null) { return false; }
if(IE) {
newX = (event.clientX + document.body.scrollLeft);
newY = (event.clientY + document.body.scrollTop);
distanceX = (newX - currentX); distanceY = (newY - currentY);
currentX = newX; currentY = newY;
whichIt.style.pixelLeft += distanceX;
whichIt.style.pixelTop += distanceY;
if(whichIt.style.pixelTop < document.body.scrollTop) whichIt.style.pixelTop = document.body.scrollTop;
if(whichIt.style.pixelLeft < document.body.scrollLeft) whichIt.style.pixelLeft = document.body.scrollLeft;
if(whichIt.style.pixelLeft > document.body.offsetWidth - document.body.scrollLeft - whichIt.style.pixelWidth - 20) whichIt.style.pixelLeft = document.body.offsetWidth - whichIt.style.pixelWidth - 20;
if(whichIt.style.pixelTop > document.body.offsetHeight + document.body.scrollTop - whichIt.style.pixelHeight - 5) whichIt.style.pixelTop = document.body.offsetHeight + document.body.scrollTop - whichIt.style.pixelHeight - 5;
event.returnValue = false;
} else { 
whichIt.moveTo(e.pageX-StalkerTouchedX,e.pageY-StalkerTouchedY);
if(whichIt.left < 0+self.pageXOffset) whichIt.left = 0+self.pageXOffset;
if(whichIt.top < 0+self.pageYOffset) whichIt.top = 0+self.pageYOffset;
if( (whichIt.left + whichIt.clip.width) >= (window.innerWidth+self.pageXOffset-17)) whichIt.left = ((window.innerWidth+self.pageXOffset)-whichIt.clip.width)-17;
if( (whichIt.top + whichIt.clip.height) >= (window.innerHeight+self.pageYOffset-17)) whichIt.top = ((window.innerHeight+self.pageYOffset)-whichIt.clip.height)-17;
return false;
}
return false;
}
function dropIt() {
whichIt = null;
if(NS) window.releaseEvents (Event.MOUSEMOVE);
return true;}
//<!-- DRAG DROP CODE -->
if(NS) {
window.captureEvents(Event.MOUSEUP|Event.MOUSEDOWN);
window.onmousedown = grabIt;
window.onmousemove = moveIt;
window.onmouseup = dropIt;
}
if(IE) {
document.onmousedown = grabIt;
//document.onmousemove = moveIt;
document.onmouseup = dropIt;
}
if(NS || IE) action = window.setInterval("heartBeat()",1);

	
function keydown() 
{ if(event.keyCode==13)
	{event.keyCode=9}
	else
	{


	keydowndeal(event)
	} 
} 

function keydown1() 
{
 if(event.keyCode==13)
	{
	event.keyCode=9
	hide_suggest()
	}
	}
	
function onKeyPress() 
	{
	
if (event.keyCode!=46 && event.keyCode!=45 && (event.keyCode<48 || event.keyCode>57)) event.returnValue=false
}
	
