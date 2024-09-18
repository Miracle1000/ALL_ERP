
//'滕国辉 2010.8.11 显示账户的币种
function getbz()
{
var ck = document.getElementsByName('ck')[0]
var id = 'bz_'+ck[ck.selectedIndex].value;
document.getElementById('bzdiv').innerHTML = document.getElementById(id).innerHTML
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
		money = $(this).val();
		if (money==""){money = 0;}
		yeMoney += parseFloat(money);
	})
	$("#money1").val(yeMoney.toFixed(window.sysConfig.moneynumber));
}

function checkMoney()
{
	var obj = document.getElementById("money1");
	if (obj.value=="")
	{
		obj.setAttribute("min","1");
		obj.setAttribute("msg","退款金额不能为空");
		obj.setAttribute("dataType","Limit");
	}
	else
	{
		obj.setAttribute("min","0");
		obj.setAttribute("msg","高于可退余额");
		obj.setAttribute("dataType", "Range");
		if (parseFloat(obj.value) == 0) {
		    alert("请录入退款金额!");
		    return false;
		}
	}
	return true;
}
