
//'滕国辉 2010.8.11 显示账户的币种
function getbz()
{
var ck = document.getElementsByName('ck')[0]
var id = 'bz_'+ck[ck.selectedIndex].value;
var ye = ck[ck.selectedIndex].title;
document.getElementById('bzdiv').innerHTML = document.getElementById(id).innerHTML
document.getElementById('yefn').innerHTML = ye
}

function check_kh(ord) {
  
  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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

function setMoneyAll(){
	var yeMoney=0;
	$(".yelistData").each(function(){
		money=$(this).val();
		if (money==""){money = 0;}
		yeMoney += parseFloat(money);
	})
	$("#money1").val(yeMoney.toFixed(window.sysConfig.moneynumber));
}
function checkMoney()
{
	var yeMoney=$("#money1").val();
	if (parseFloat(yeMoney) == 0)
	{
		alert("请录入退款金额！");
		return false ;
	}
	else
	{
		if (!confirm("确认退款"))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
}
