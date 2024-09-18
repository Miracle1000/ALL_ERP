
function trim(str){return str.replace(/(^\s*)|(\s*$)/g, "");}
var XMlHttp = GetIE10SafeXmlHttp();
function callServers(m,urls,v) {
	document.getElementById(m).innerHTML="";
	var w2  = m;
	w2=document.all[w2];
	var allm=new Array(["tellist"],["tellist2"],["tellist3"]);
	var url = "../work/"+urls+"?timestamp=" + new Date().getTime() + v + "&date1="+ Math.round(Math.random()*100);
	if (m=="tellist"||m=="tellist2"||m=="tellist3")   //bug 2410 baiyong 原由：需要异步加载图片缓解计算慢的此三部分
	{
		//bug.2702.2013.10.21 baiyong 隐藏其他模块内容和加载项。
		for (var mi=0; mi<=allm.length-1 ; mi++ )
		{
			if (allm[mi]!=m&&document.getElementById(m))
			{
				document.getElementById(allm[mi]).innerHTML="";
			}
		}
	xmlHttp.open("GET", url, true);
	xmlHttp.onreadystatechange = function(){
		updatePages(w2);
	};
	}else{
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePages(w2);
	};
	}
	xmlHttp.send(null);  

}
function updatePages(w) {
	var test6=w
	if (xmlHttp.readyState < 4) {
		test6.innerHTML="<div><img src='../images/loading2.gif' border=0></div>";
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		test6.innerHTML=response;
	}
}

callServers("needdo","salecenter_needdo.asp");
callServers("report","salecenter_report.asp");
callServers("telsort","salecenter_telsort.asp");

function select_area(khord,ord,strvalue)
{
	if (khord==0)
	{
		document.getElementById("areaall").value=ord;
		document.getElementById("area_all").value=strvalue;
		var controls = document.getElementsByTagName('input');
	}
	$('#w11').window('close');
}
function selectArea()
{
	var arr_A2 = $("[name='A2']");
	var secA2 = "";
	for (i=0;i<arr_A2.length ;i++ )
	{
		if (arr_A2[i].checked)
		{
			secA2 = secA2 + arr_A2[i].value +" ";
		}
	}
	secA2 = trim(secA2);
	if (secA2==""){
		alert("请选择区域")
	}else{
		secA2 = secA2.replace(/\s/g,",");
		url = "../work/correctall_area_h.asp?act=read&area="+ secA2 +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState == 4) {
				var restxt = xmlHttp.responseText;
				var arr_res = "";
				if(restxt==""){
					alert("数据读取错误，请重试");
					return;
				}else{
					arr_res = restxt.split("|");
					if (arr_res[0]=="0"){
						alert("数据读取错误，请重试");
						return;
					}else if (arr_res[0]=="1"){
						document.getElementById("areaall").value=arr_res[2];
						document.getElementById("area_all").value=arr_res[1];
					}
				}
			}
		};
		xmlHttp.send(null); 
		$('#w11').window('close');
	}
}
function getTelist(jzs,trades,lys,areaall,zdy5,zdy6,ifpre){
   if (ifpre=="1")
   {
   var v1=document.getElementById("hiddenflag_1").value;
   }
   var v2=document.getElementById("hiddenflagdate1").value;
   callServers("telsort","salecenter_telsort.asp","&tel_jz="+jzs+"&tel_trade="+trades+"&tel_ly="+lys+"&areaall="+areaall+"&zdy5="+zdy5+"&zdy6="+zdy6+"&v1="+v1+"&v2="+v2);
}
function getreportlist(){
   var v1=document.getElementById("hiddenflag_2").value;
   var v2=document.getElementById("hiddenflagdate2").value;
   callServers("report","salecenter_report.asp","&v1="+v1+"&v2="+v2);
}
function getneeddolist(){
   var v1=document.getElementById("hiddenflag_0").value;
   var v2=document.getElementById("hiddenflagdate0").value;
   callServers("needdo","salecenter_needdo.asp","&v1="+v1+"&v2="+v2);
}
function movelist(ord,act){
   var v1=document.getElementById("hiddenflag_0").value;
   var v2=document.getElementById("hiddenflagdate0").value;
  callServers("tellist","salecenter_tellist.asp","&v1="+v1+"&v2="+v2+"&moveid="+ord+"&act="+act);
}
function movelist2(ord,act){
   var v1=document.getElementById("hiddenflag_0").value;
   var v2=document.getElementById("hiddenflagdate0").value;
  callServers("tellist2","salecenter_tellist2.asp","&v1="+v1+"&v2="+v2+"&moveid="+ord+"&act="+act);
}
function movelist3(ord,act){
   var v1=document.getElementById("hiddenflag_0").value;
   var v2=document.getElementById("hiddenflagdate0").value;
  callServers("tellist3","salecenter_tellist3.asp","&v1="+v1+"&v2="+v2+"&moveid="+ord+"&act="+act);
}
//获取选择的日期
function toggleDatePicker(eltName,formElt) {
  //alert(formElt);
  var x = formElt.indexOf('.');
  var formName = formElt.substring(0,x);
  var formEltName = formElt.substring(x+1);
  newCalendar(eltName,document.getElementsByName(formEltName)[0]);
}
//将获取到日期更新到显示页面
function setDay(day,eltName) {
  displayElement.value =displayYear+"-"+(displayMonth + 1)+ "-" +day;
  if (eltName=='daysOfMonth1')
  {
	getreportlist();
  }else if(eltName=='daysOfMonth3'){
    getTelist($('#jzs').val(),$('#trades').val(),$('#lys').val(),$('#areaall').val(),$('#zdy5').val(),$('#zdy6').val());
  }
  hideElement(eltName);
}
function test(thisobj){
    var v=event.toElement;
	var i=0;
	while (v&&i<100)
	{
		if(v==thisobj) {
			return false;
		}
		v = v.parentNode;
		i++;
	}
	return true;
} 

function showDlgDiv(html, dispos) {
	//页面的内容高度 
	var sTop = document.documentElement.scrollTop; 
	var sLeft =  document.documentElement.scrollLeft; 
	var div = document.getElementById("showDlgDivObj");
	if(!div) {
		div = document.createElement("showDlgDivObj");
		div.style.cssText = "position:absolute;display:block;z-index:10;display:none;margin-top:6px;margin-left:-3px;";
		div.id = "showDlgDivObj";
		document.body.appendChild(div);
	}
	var xy = fGetXY(window.event.srcElement);
	
	div.style.display = "block";
	div.style.margin = "-5px 0 0 -10px";
	div.innerHTML =  html;
	if(dispos!=true) {
		div.style.left = (xy.x + window.event.srcElement.offsetWidth) + "px";//window.event.clientX + sLeft - window.event.offsetX + window.event.srcElement.offsetLeft + window.event.srcElement.offsetWidth;
		div.style.top = (xy.y + window.event.srcElement.offsetHeight)+ "px"; //window.event.clientY + sTop - window.event.offsetY + window.event.srcElement.offsetTop + window.event.srcElement.offsetHeight;
	}
	
}
function fGetXY(aTag){
	var pt=new Point(0,0)
	var w = 200 , h = 215
	var oTmp=aTag;
	while(oTmp)
	{
		
			pt.x = pt.x + oTmp.offsetLeft- oTmp.scrollLeft;
			pt.y = pt.y + oTmp.offsetTop - oTmp.scrollTop;
			oTmp=oTmp.offsetParent;
	}
	var bodyw = document.body.offsetWidth;
	if(bodyw==0) {bodyw = document.documentElement.offsetWidth;}
	if (pt.x+w>bodyw){pt.x = bodyw -w;}
	if (pt.y+h>document.body.offsetHeight){
		pt.y = pt.y - h - aTag.offsetHeight;
		if (pt.y<0){pt.y = document.body.offsetHeight -h;}
	}
	pt.x = pt.x + document.body.scrollLeft;
	pt.y = pt.y + document.body.scrollTop;
	if(!isNaN(document.documentElement.scrollLeft))
	{
		pt.x = pt.x + document.documentElement.scrollLeft;
		pt.y = pt.y + document.documentElement.scrollTop;	
	}
	return pt;

}
