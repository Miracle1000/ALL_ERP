
function add(ord,id,contractlist,kuout,kuoutlist,ckid,sort_ck) {
  var num1 = document.getElementById("num1"+ckid).value;
  var num1old = document.getElementById("num1old"+ckid).value;
  var num3 = document.getElementById("num1").value;
   var w2  = "trpx"+ckid;
   w2=document.all[w2]
  if  ( Number(num1) >  Number(num1old)) return;
  var url = "cu_kuin.asp?ord="+escape(ord)+"&num1="+escape(num1)+"&num1old="+escape(num1old)+"&num3="+escape(num3)+"&id="+escape(id)+"&contractlist="+escape(contractlist)+"&kuout="+escape(kuout)+"&kuoutlist="+escape(kuoutlist)+"&ckid="+escape(ckid)+"&sort_ck="+sort_ck+"&MOrderID="+window.MOrderID+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage(w2);
  };
  
  xmlHttp.send(null);  
}

function updatePage(w2) {
var test6=w2
  if (xmlHttp.readyState < 4) {
	trpx.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	trpx.innerHTML=response;
	xmlHttp.abort();
  }
}


function ck() { 
var w = document.getElementById("alli").value;

 for(var i=1; i<=w; i++)
　 {
document.getElementById("ck"+i).value = document.getElementById("ckall").value;

var id = document.getElementById("id"+i).value;
var ord = document.getElementById("ord_"+i).value;
ckxz(ord,i,id)
}
}

function del(str,id){
	
	var w  = str;
	
	var url = "../caigou/del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
 xmlHttp.onreadystatechange = function(){
  updatePage_del(w);
  };
  xmlHttp.send(null);  
}
function updatePage_del(str) {
document.getElementById(str).style.display="none";

}



function ajaxSubmit(sort1){
    //获取用户输入
    var B=document.forms[0].B.value;
    var C=document.forms[0].C.value;
	var top=document.forms[0].top.value;
    var url = "search_cp.asp?B="+escape(B)+"&C="+escape(C) +"&top="+escape(top) +"&sort1="+escape(sort1) + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_cp();
  };
  xmlHttp.send(null);  
}
function updatePage_cp() {
  if (xmlHttp.readyState < 4) {
	cp_search.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	cp_search.innerHTML=response;
  }
}

function ajaxSubmit_gys(nameitr,ord,unit){
    //获取用户输入
	var w  = "tt"+nameitr;
    var B=document.forms[1].B.value;
    var C=document.forms[1].C.value;
    var url = "cu2.asp?unit=" + escape(unit)+"&ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&B="+escape(B)+"&C="+escape(C) +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_gys(w);
  };
  xmlHttp.send(null);  
}
function updatePage_gys(w) {
 var test7=document.all[w]
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test7.innerHTML=response;
  }
}

function NoSubmit(ev)

{

    if( ev.keyCode == 13 )

    {

        return false;

    }

    return true;

}

function chtotal(id) 
{ 
var price= document.getElementById("pricetest"+id); 
var num= document.getElementById("num"+id); 
var moneyall= document.getElementById("moneyall"+id);
var money1=price.value * num.value 
moneyall.value=FormatNumber(money1,2)
}

function check_ck(ord,id,contractlist,kuout,kuoutlist,i,sort_ck) {
   var num1 = document.getElementById("num1"+i).value;
   var num1old = document.getElementById("num1old"+i).value;
   var num3 = document.getElementById("num3").value;
   var numsum=0;
   var allNum1=document.getElementsByName("num1_"+window.requestID);
   for(var j=0;j<allNum1.length;j++)
   {
   		if(allNum1[j].id.toString().indexOf("num1old")<0)
   		{
   			numsum=accAdd(numsum,(isNaN(allNum1[j].value)||allNum1[j].value=="")?0:parseFloat(allNum1[j].value));
//   			numsum+=(isNaN(allNum1[j].value)||allNum1[j].value=="")?0:parseFloat(allNum1[j].value);
   		}
   }
   var numall= document.getElementById("num1").value;

  if ( isNaN(num1) || (num1 == "") ) {
  alert("只能输入数字！")
  document.getElementById("num1"+i).value=0
  add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck)
  return false;
  }
  
  if (Number(num1) > Number(num1old)) {
  alert("大于库存量！")
  document.getElementById("num1"+i).value=0
  add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck)
  return false;
  }
/*
  if (Number(num1) > Number(num3)) {
  alert("大于未指定数量"+num3+"!")
  document.getElementById("num1"+i).value=0
  add(ord,id,contractlist,kuout,kuoutlist,i)
  return false;
  }
*/
  if (Number(numsum) > Number(numall)) {
  alert("大于应指定总数"+numall+"!")
  document.getElementById("num1"+i).value=0
  add(ord,id,contractlist,kuout,kuoutlist,i,sort_ck)
  return false;
  }
  document.getElementById("num1"+i).value=Number(num1)
  return true;
}

//flg表示是否在检索到结果后指定数量自动增加
var xlhLast="";
function PageSearch(obj,flg)
{
	if(event.keyCode!=13) return;
	var stxt=obj.value;
	var xlhfind=false;
	for(var i=2;i<tbobj.rows.length;i++)
	{
		//3序列号，6现有数量，7指定数量
		if(stxt.length>0)
		{
			if(tbobj.rows[i].cells[3].tag.toLowerCase().indexOf(stxt.toLowerCase())>=0)
			{
				tbobj.rows[i].style.display="block";
				if(flg)
				{
					var nowNum=parseFloat(tbobj.rows[i].cells[6].tag);
					var cobj=tbobj.rows[i].cells[7].getElementsByTagName("input")[0];
					var curNum=parseFloat(cobj.value);
					//if(nowNum>=curNum+1)
					if(nowNum>curNum)
					{
						
						if(!xlhfind)
						{
							//cobj.value=parseFloat(cobj.value)+1;
							cobj.value=nowNum;//定制的用这句，通用版用上面那句
							cobj.onchange();
							xlhfind=true;
						}
					}
				}
			}
			else
			{
				tbobj.rows[i].style.display="none";
			}
		}
		else
		{
			tbobj.rows[i].style.display="block";
		}
	}
	if(flg)
	{
		obj.value="";
	}
}
