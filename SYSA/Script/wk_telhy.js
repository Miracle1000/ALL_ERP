function superSearch(inttype){
	if (inttype==2)
	{
		document.getElementById('ht1').value='';
		document.getElementById('gd1').className='zdy';
		document.getElementById('gd2').className='zdy1 top tophead';
		return false;
	}
}
function callServer2() {
	document.getElementById('kh').style.display='none';
	document.getElementById('ht1').style.display='';
	document.getElementById('ht1').style.position='relative'; 
	document.getElementById('ht1').style.zIndex=1;
	document.getElementById("gd1").className="";
	document.getElementById("gd2").className="top";
	//任务：2148 销售工作台中点击销售漏斗，再点击检索可看到全部客户 xieyanhui2014.11.13
	var url = "liebiao_tj.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)+"&E=" + window.request_E + "&F=" + window.request_F + "&H2=" + window.request_H2;
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
		initW3();
		xmlHttp.abort();
	}
}

var strW1="," +  window.AspVar_strW1 + ",";
var strW2="," +  window.AspVar_strW2 + ",";
var strW3="," +  window.AspVar_strW3 + ",";
function initW3()
{
	var wobj=document.getElementById("ht1").getElementsByTagName("input");
	for(var i=0;i<wobj.length;i++)
	{
		if(wobj[i].name)
		{
			if(wobj[i].name=="W1"&&strW1.indexOf(','+wobj[i].value+',')>=0)
			{
				wobj[i].click();
			}
			else if(wobj[i].name=="W2"&&strW2.indexOf(','+wobj[i].value+',')>=0)
			{
				wobj[i].click();
			}
			else if(wobj[i].name=="W3")
			{
				wobj[i].checked=(strW3.indexOf(','+wobj[i].value+',')>=0)
			}
			else
			{
				var strcw=getUrl('');
				var strcw_item=strcw.split("&");
				for(var j=0;j<strcw_item.length&&strcw_item!='';j++)
				{
					var strcw_node=strcw_item[j].split("=");
					var strcw_key=strcw_node[0];
					var strcw_value=strcw_node[1];
					if (wobj[i].name==strcw_key)
					{
						if (wobj[i].name=="E"&&strcw_value.indexOf(wobj[i].value)>=0)
						{
							//wobj[i].click();
						}
						else
						{
							//wobj[i].checked=(strcw_value.indexOf(wobj[i].value)>=0)
						}
					}
				}
			}
		}
	}
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
	var a=document.getElementById("u"+str).getElementsByTagName("input");
	var b=document.getElementById("e"+str);
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

function batdel()
{
	document.all.form1.action = "delkhconfirm.asp?" + window.AspVar_UUrl;
	document.all.form1.submit();
}

function ask() {
	document.all.form1.action = "orderallhy.asp?" + window.AspVar_UUrl;
	document.all.form1.submit();
}
function ask2() {
	document.all.form1.action = "savebackallhy.asp?" + window.AspVar_UUrl;
	document.all.form1.submit();
}
function ask3() {
	document.all.form1.action = "shareall.asp?" + window.AspVar_UUrl;
	document.all.form1.submit();
}

function ask4() {
	document.all.form1.action = "correctall.asp?" + window.AspVar_UUrl;
	document.all.form1.submit();
}

function mm(form,obj){
	var chk = form.chkall1 || form.chkall2;

	if (form.chkall1) form.chkall1.checked=obj.checked;
	if (form.chkall2) form.chkall2.checked=obj.checked;
	for (var i=0;i<form.elements.length;i++){
		var e = form.elements[i];
		if (e.name != 'chkall1' || e.name != 'chkall2') e.checked = chk.checked;
	}
}

function Myopen(divID){
	if(divID.style.display=="")
	{
		divID.style.display="none"
	}
	else
	{
		divID.style.display=""
	}
	divID.style.zIndex=2;
	if(window.AspVar_H=="1000") {
		document.getElementById("pxtab").style.height=158;
	}
	divID.style.left=310;
	divID.style.top=document.body.scrollTop;
}

function inselect4()
{
	document.date.FE.length=0;
	if(document.date.E1.value==""||document.date.E1.value==null)
	{
		document.date.FE.options[0]=new Option(window.AspVar_arrName_5,'');
	}
	else
	{
		for(i=0;i<ListUserId4[document.date.E1.value].length;i++)
		{
			document.date.FE.options[i]=new Option(ListUserName4[document.date.E1.value][i],ListUserId4[document.date.E1.value][i]);
		}
	}
	var index=document.date.E1.selectedIndex;
} 

function openlist(id)
{
	if (id=="0")
	{
		window.location.href="telhy.asp?newopen=" + window.request_newopen;
	}
	else 
	{
		window.location.href="telhy_view.asp?viewid="+id+"&newopen=" +window.request_newopen;
	}
}
function add_view(){
	document.getElementsByName("date")[0].action="viewadd.asp";
	document.getElementsByName("date")[0].method="post";
	document.getElementsByName("date")[0].target="_blank";
	document.getElementsByName("date")[0].submit();
	document.getElementsByName("date")[0].action="telhy.asp";
	document.getElementsByName("date")[0].method="get";
	document.getElementsByName("date")[0].target="";
}

function moban_dy_send(){
	document.getElementById("mailprint").submit();
	return;
}