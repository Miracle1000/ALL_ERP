
function inselect4()
{
	document.date.bank.length=0;
	if(document.date.bz.value=="0"||document.date.bz.value==null || document.date.bz.value=="")
	{
		document.date.bank.options[0]=new Option('入账账户','0');
	}
	else
	{
		for(i=0;i<ListUserId4[document.date.bz.value].length;i++)
		{
			document.date.bank.options[i]=new Option(ListUserName4[document.date.bz.value][i],ListUserId4[document.date.bz.value][i]);
		}
	}
	var index=document.date.bz.selectedIndex;
} 

function setInvoiceMode(Ttype)
{
	if (Ttype==1)
	{
		document.getElementById("invoiceTr").style.display="none";
		$("#InvoiceType").attr("min","0");
	}
	else if ( Ttype==2)
	{
		document.getElementById("invoiceTr").style.display="";
		$("#InvoiceType").attr("min","1");
	}
}
function check_kh(ord) {
  
  var url = "../event/search_kh1.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage2();
  };
  xmlHttp.send(null);  
}

function updatePage2() {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	khmc.innerHTML=response;
	xmlHttp.abort();
  }
}

function setkpTr()
{
	if ($("#pre_InvoiceMode").val()!="2")
	{
		$("#invoiceTr").attr("style","display:none");
	}
	else
	{
		$("#invoiceTr").attr("style","");
	}
}
