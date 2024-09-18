function test()
{
  if(!confirm('您选择的是彻底删除，删除后不能再恢复，确认删除？')) return false;
}
 
function mm()
{
   var a = document.all("checkbox2");
   var c = document.getElementsByName("selectid")
	if(a.checked==true)
	{
   		for(var i=0;i<c.length;i++)
		c[i].checked=true;
   	}
	else
	{
		for(var i=0;i<c.length;i++)
		c[i].checked=false
	}
}
function ask2() { 
	var selectid = "";
	if(typeof(document.form1.selectid.length)=="undefined"){
		if(document.form1.selectid.checked==true){
			selectid = document.form1.selectid.value;
		}
	}else{
		for(i=0;i<document.form1.selectid.length;i++){
			if(document.form1.selectid[i].checked==true){
				selectid += document.form1.selectid[i].value+",";
			}
		}
	}
	if(selectid == ""){
		alert("请选择要批量恢复的合同");
	}else{
		nohf = 0;
		var selectid2 = "";
		if(selectid.indexOf(",")==-1){
			selectid = selectid;
		}else{
			selectid = selectid.substr(0,selectid.length-1);
		}
		var arr_secid = selectid.split(",");
		for(i=0; i<arr_secid.length; i++){
			if(checkCredit(arr_secid[i])==false){
				nohf = 1;	
				selectid2 = selectid2 + arr_secid[i] +",";
			}
		}
		if (nohf==1){
			alert("有合同高于信用额度无法恢复");
			if(selectid2.indexOf(",")==-1){
				selectid2 = selectid2;
			}else{
				selectid2 = selectid2.substr(0,selectid2.length-1);
			}
			arr_secid2 = selectid2.split(",");
			for (i=0;  i<arr_secid2.length; i++){
				document.getElementById("ht"+arr_secid2[i]).innerHTML=" 高于信用额度无法恢复";
			}
		}else{
			if (!confirm("确认要批量恢复选中的信息？")) {
						window.event.returnValue = false;
			}else{
				document.all.form1.action = "sethtall.asp?currPage="+window.currpage; 
				document.all.form1.submit();
			} 
		}
	}
} 

function recovery(htord){
	if (htord!=""){
		if(checkCredit(htord)==false){
			alert("高于信用额度无法恢复");
		}else{
			if(confirm("确认恢复？")){
				window.location.href="setht.asp?ord="+htord+"&CurrPage="+window.currpage;
			}
		}
	}
}

function checkCredit(htord){
	if (htord!=""){
		var url2 = "../event/tel_credit.asp?ty=3&ord="+htord+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		var XMlHttp2 =  GetIE10SafeXmlHttp();
		XMlHttp2.open("GET", url2, false);
		XMlHttp2.send(null);
			if (XMlHttp2.readyState == 4) {
				var restr = XMlHttp2.responseText;				
				if(restr=="0"){
					return true;
				}else if(restr=="1"){					
					return false;
				}else if(restr=="2"){					
					return true;
				}
				XMlHttp2.abort();
			}	
	}
}