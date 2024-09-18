
function trim(str){return str.replace(/(^\s*)|(\s*$)/g, "");}

Array.prototype.remove=function(dx){ 	//重构数组的删除元素操作
    if(isNaN(dx)||dx>this.length){return false;} 
    for(var i=0,n=0;i<this.length;i++){ 
        if(this[i]!=this[dx]){ 
            this[n++]=this[i] 
        } 
    } 
    this.length-=1 
} 

function inselect()
{
	var sorce2 = document.getElementsByName("sorce2")[0];
	var sorce = document.getElementsByName("sorce")[0];
sorce2.length=0;
if(sorce.value=="0"||sorce.value==null)
sorce2.options[0]=new Option('--所属3地区--','0');
else
{
for(i=0;i<ListUserId[sorce.value].length;i++)
{
sorce2.options[i]=new Option(ListUserName[sorce.value][i],ListUserId[sorce.value][i]);
}
}
var index=sorce.selectedIndex;
//sname.innerHTML=document.date.sorce.options[index].text
}

function callServer(ord) {
  var cateid = document.getElementById("cateid").value;
  if ((cateid == null) || (cateid == "")) return;
  var url = "cu.asp?cateid=" + escape(cateid)+"&ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage();
  };
  xmlHttp.send(null);
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	bm.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	bm.innerHTML=response;
	xmlHttp.abort();
  }

}

function callServer2(nameitr,ord,sort1,sort2) {
   var w  = nameitr;
   w=document.all[w]
   var w2  = "tt"+nameitr;
   w2=document.all[w2];
   var w3  = document.all[nameitr];
   var id_show = document.getElementById("id_show").value;
   if (id_show != "") return;
  var url = "cu2.asp?ord="+escape(ord)+"&nameitr="+escape(nameitr)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2(w,w2);
  };
  xmlHttp.send(null);
}

function updatePage2(namei,w2) {
var test7=namei
var test6=w2
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	test6.innerHTML=response;
	var id_show= document.getElementById("id_show");
	id_show.value="1"
	xmlHttp.abort();
  }

}

function callServer3(e,ord,sort1,sort2) {

if(e.checked==true){
  	 qx_open=1;
  }
else{
    qx_open=0;
}

  var url = "add_qx.asp?ord="+escape(ord)+"&qx_open="+escape(qx_open)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}

function ajaxSubmit_yh(nameitr,ord,sort1,sort2){
    //获取用户输入
	 var w  = nameitr;
     w=document.all[w]
	 var wlist  = "tt"+nameitr;
     wlist=document.all[wlist]

	var W1 = document.forms[0].W1_intro.value;
	var W2 = document.forms[0].W2_intro.value;
	var W3 = document.forms[0].W3_intro.value;
	var member1 = document.forms[0].member.value;
    var W1 = W1.substring(0,W1.length-1)
	var W2 = W2.substring(0,W2.length-1)
	var W3 = W3.substring(0,W3.length-1)

    var url = "cu3.asp?timestamp=" + new Date().getTime() + "&nameitr="+escape(nameitr)+"&ord="+escape(ord)+"&sort1="+escape(sort1)+"&sort2="+escape(sort2)+"&W1="+escape(W1)+"&W2="+escape(W2) +"&W3="+escape(W3)+"&member1="+escape(member1)+"&date1="+ Math.round(Math.random()*100);

  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage_yh(w,wlist);
  };
  xmlHttp.send(null);
}

function updatePage_yh(w,wlist) {
 var test7=w
 var test6=wlist
  if (xmlHttp.readyState < 4) {
	test7.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {

    var response = xmlHttp.responseText;
	test7.innerHTML=response;
	test6.innerHTML=""
	var id_show= document.getElementById("id_show");
	id_show.value=""
	xmlHttp.abort();
  }
}


function ajaxSubmit_gb(nameitr){
    //获取用户输入
	 var wlist  = "tt"+nameitr;
     wlist=document.all[wlist]

  xmlHttp.onreadystatechange = function(){
  updatePage_gb(wlist);
  };
  xmlHttp.send(null);
}
function updatePage_gb(nameitr) {
 var wlist  = nameitr;
  if (xmlHttp.readyState < 4) {
	wlist.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {

    var response = xmlHttp.responseText;
	wlist.innerHTML=""

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

function check_ckxz(w) {
 var ck = document.getElementById(w);
   if(ck.checked)
   return true;
   return false;
}

function callServer3_lsclose(nameitr) {
   var w  = "tt"+nameitr;
   w=document.all[w]
   w.innerHTML="";
   var id_show= document.getElementById("id_show");
   id_show.value=""
   xmlHttp.abort();
}

function checkLoginName(){
	var name=document.getElementById("user").value;
	var url = "cu_loginname.asp?timestamp=" + new Date().getTime() + "&loginName="+escape(name);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;
			document.getElementById("flag").value=response;
			if(response=="1"){
				document.getElementById("checkflag").innerHTML="用户名已存在";
			}
		}
	};
	xmlHttp.send(null);
}
