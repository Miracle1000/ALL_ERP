
function add() {
  var money1 = document.getElementById("money1").value;
  var money2 =  document.getElementById("money2").value;
  var url = "cu.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
    updatePage();
  };  
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	dybf.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	dybf.innerHTML=response;
	xmlHttp.abort();
  }
}

function check_ck() {
    var money1 = document.getElementById("money1").value; 
    var money2 = document.getElementById("money2").value; 
    if ( isNaN(money1) || (money1 == "") ) {
        return false;
    }
  
    if (Number(money1) > Number(money2)) {
        alert("大于应退账款！")
        document.getElementById("money1").value=money2
        return false;
    }
    return true;
}

function check_ck2(id,money2) {
    var money1 = document.getElementById("money1_" + id).value;
    var money3obj = $(".money3_" + id)[0];
    if ((isNaN(money1) || (money1 == "")) && !money3obj) {
        return false;
    }
    if (isNaN(money1) || (money1 == "")) money1 = 0;
    if (Number(money1) > Number(money2)) {
        alert("大于应退账款！");
        if(money3obj){
            var money3 = money3obj.value;
            if (isNaN(money3) || (money3 == "")) return false;
            document.getElementById("money1_" + id).value = parseFloat(money2) - parseFloat(money3);
        }
        return false;
    }
    return true;
}

function FormatNumber(srcStr,nAfterDot)        //nAfterDot表示小数位数
{
	srcStr=(srcStr+'').replace(",","");
	if (isNaN(srcStr)) return  "0";
	srcStr=(Math.round(srcStr*Math.pow(10,nAfterDot))/Math.pow(10,nAfterDot)).toString();
	var v=srcStr.split(".");
	var num=v.length==1?(srcStr+ "."+"000000000000".substr(0,nAfterDot)):(srcStr + "000000000000").substr(0,srcStr.indexOf(".")+1+nAfterDot*1);
	return num;
}

function chtotal(id,num_dot_xs) 
{ 
    var price= document.getElementById("money1_"+id); 
    var moneyall= document.getElementById("moneyall_"+id);
    var money1 = document.getElementById("money1");
    money3=accSub(parseFloat(money1.value),parseFloat(moneyall.value));
    money3=accAdd(money3,parseFloat(price.value));
    moneyall.value=FormatNumber(parseFloat(price.value),num_dot_xs);
    money1.value=FormatNumber(money3,num_dot_xs);
    add_hb(id);
    xmlHttp.abort();
}

function add_hb(id) {
  var money1 = document.getElementById("money1_"+id).value;
  var money2 =  document.getElementById("moneyall2_"+id).value;
  var url = "cu_hb.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
    updatePage_hb(id);
  };  
  xmlHttp.send(null);  
}

function updatePage_hb(id) {
var w="next_"+id
w=document.all[w]
  if (xmlHttp.readyState < 4) {
	w.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	w.innerHTML=response;
	xmlHttp.abort();
  }
}

function del(str,id,rd,num_dot_xs){
	var w  = document.all[str];
	
    var money1= document.getElementById("money1"); 
    num1=document.getElementById("money1_"+id).value;
    num_zs=money1.value
    num_zs-=num1
    money1.value=num_zs
	
	var url = "../money4/del_cp.asp?id="+escape(id)+"&rd="+escape(rd)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     xmlHttp.open("GET", url, false);
     xmlHttp.onreadystatechange = function(){
      updatePage_del(w,id,num_dot_xs);
      };
      xmlHttp.send(null);  
}
function updatePage_del(str,id,num_dot_xs) {
     str.innerHTML="";

}

