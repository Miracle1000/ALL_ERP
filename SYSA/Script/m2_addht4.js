
function getobj(str)
{
return document.getElementById(str)
}

function getyemoney()
{

	var bank = document.getElementById('bank')
	if (bank!="")
{	
	var bankval = bank[bank.selectedIndex].value;
	var yemoney =yearray[bankval];
	}
	else
	{
	var yemoney =0;
	}
	document.getElementById('money1_kh').value = yemoney;
}


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
	document.getElementById("money1").value=money2
	return true;
  }
  if (Number(money1)>=0)
  {  
	  if (Number(money1) > Number(money2)) {
		alert("大于应收账款！")
		document.getElementById("money1").value=money2
		return true;
	  }
  }
  return true;
}
function FormatNumber(srcStr,nAfterDot)        //nAfterDot小数位数
       {
　　        var srcStr,nAfterDot;
　　        var resultStr,nTen;
　　        srcStr = ""+srcStr+"";
　　        strLen = srcStr.length;
　　        dotPos = srcStr.indexOf(".",0);
　　        if (dotPos == -1){
　　　　        resultStr = srcStr+".";
　　　　        for (i=0;i<nAfterDot;i++){
　　　　　　        resultStr = resultStr+"0";
　　　　        }
　　　　        return parseFloat(resultStr);
　　        }
　　        else{
　　　　        if ((strLen - dotPos - 1) >= nAfterDot){
　　　　　　        nAfter = dotPos + nAfterDot + 1;
　　　　　　        nTen =1;
　　　　　　        for(j=0;j<nAfterDot;j++){
　　　　　　　　        nTen = nTen*10;
　　　　　　        }
　　　　　　        resultStr = Math.round(parseFloat(srcStr)*nTen)/nTen;
　　　　　　        return resultStr;
　　　　        }
　　　　        else{
　　　　　　        resultStr = srcStr;
　　　　　　        for (i=0;i<(nAfterDot - strLen + dotPos + 1);i++){
　　　　　　　　        resultStr = resultStr+"0";
　　　　　　        }
　　　　　　        return parseFloat(resultStr);
　　　　        }
　　        }
        } 
		
function changespUI() {
	if (document.getElementById("sptypebox1"))
	{	
		var t = document.getElementById("sptypebox1").checked ? 0 : 1;
		if(document.getElementById("sprow1")) { document.getElementById("sprow1").style.display = (t==0 ? "" : "none"); }
		if(document.getElementById("sprow2")) { document.getElementById("sprow2").style.display = (t==0 ? "" : "none"); }
		if(document.getElementById("sprow3")) { document.getElementById("sprow3").style.display = (t==0 ? "" : "none"); }
		if(document.getElementById("sprow4")) { document.getElementById("sprow4").style.display = (t==0 ? "" : "none"); }
		if(document.getElementById("sprow5")) { document.getElementById("sprow5").style.display = (t==1 ? "" : "none"); }
	}
}
