
function showLogList(ord,today)
{var url = "getLoginList.asp?ord="+ord+"&Date="+today+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  if (xmlHttp.readyState < 4) {
	strlog="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText.split("</noscript>")[1];
		//alert(response);
		strlog=response;
  }
  };

  xmlHttp.send(null);
	//	return strlog;
	var scrollWhdth=document.body.scrollWidth;
var leftWidth=scrollWhdth/2;
	var topHeight=document.body.scrollTop+window.event.clientY;
if((leftWidth-scrollWhdth)>=-700){leftWidth=leftWidth-300;}
	//if((leftWidth-scrollWhdth)>=-50){leftWidth=leftWidth-300;}
	div_loginList=window.DivOpen("hr_loginList" ,"登录明细", 700,0,topHeight,leftWidth,false,0);
	div_loginList.innerHTML = strlog;
}
function setDay(day,eltName) {
			var thisday=displayYear+"-"+(displayMonth + 1)+ "-" +day;
			displayElement.value =thisday;
			hideElement(eltName);
	   document.location.href="LoginListDay.asp?date="+thisday+"";
     }
