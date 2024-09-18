
function frameResize(){
	try
	{
		document.getElementById("mxlist").style.height=I4.document.body.scrollHeight+0+"px";
		document.getElementById("mxlist5").style.height=I5.document.body.scrollHeight+0+"px";
		document.getElementById("mxlist3").style.height=I3.document.body.scrollHeight+0+"px";
	}
	catch(e){}
}
function ask2() {
	document.all.date.action = "save.asp?ord="+window.pricerd+"&sort3=2";
}
function ask3() {
	document.all.date.action = "save.asp?ord="+window.pricerd+"&sort3=3";
}
function   strDateTime(){
	var strDateTime = document.getElementById("daysOfMonthPos").value;
	var regDateTime = /^(\d{4})[\-\/](\d{2}|\d)[\-\/](\d{2}|\d)\s(\d{1,2}):(\d{1,2}):(\d{1,2})$/;
    if (!regDateTime.test(strDateTime))  {
	alert("报价时间格式错误");
	return false;
	}

// 将年、月、日、时、分、秒的值取到数组arr中，其中arr[0]为整个字符串，arr[1]-arr[6]为年、月、日、时、分、秒
    var arr = regDateTime.exec(strDateTime);

    // 判断年、月、日的取值范围是否正确
    if (!IsMonthAndDateCorrect(arr[1], arr[2], arr[3]))
        {alert("报价时间年月日格式错误");
		return false;
		}


    // 判断时、分、秒的取值范围是否正确
    if (arr[4] >= 24)
        {alert("报价时间小时格式错误");
		return false;
		}
    if (arr[5] >= 60)
        {alert("报价时间分钟格式错误");
		return false;
		}
    if (arr[6] >= 60)
        {alert("报价时间秒格式错误");
		 return false;
		}

    // 正确的返回
    return true;
}

// 判断年、月、日的取值范围是否正确
function IsMonthAndDateCorrect(nYear, nMonth, nDay)
{
    // 月份是否在1-12的范围内，注意如果该字符串不是C#语言的，而是JavaScript的，月份范围为0-11
    if (nMonth > 12 || nMonth <= 0)
        {alert("报价时间月份格式错误");
		 return false;
		}

    // 日是否在1-31的范围内，不是则取值不正确
    if (nDay > 31 || nMonth <= 0)
        {alert("报价时间日期格式错误");
		return false;
		}

    // 根据月份判断每月最多日数
    var bTrue = false;
    switch(nMonth)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            bTrue = true;    // 大月，由于已判断过nDay的范围在1-31内，因此直接返回true
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            bTrue = (nDay <= 30);    // 小月，如果小于等于30日返回true
            break;
    }

    if (!bTrue)
        return true;

    // 2月的情况
    // 如果小于等于28天一定正确
    if (nDay <= 28)
        return true;
    // 闰年小于等于29天正确
    if (IsLeapYear(nYear))
        return (nDay <= 29);
    // 不是闰年，又不小于等于28，返回false
	 {
      alert("报价时间格式错误，不是闰年，只能是28");
	  return false;
	 }
}

// 是否为闰年，规则：四年一闰，百年不闰，四百年再闰
function IsLeapYear(nYear)
{
    // 如果不是4的倍数，一定不是闰年
    if (nYear % 4 != 0)
        return false;
    // 是4的倍数，但不是100的倍数，一定是闰年
    if (nYear % 100 != 0)
        return true;

    // 是4和100的倍数，如果又是400的倍数才是闰年
    return (nYear % 400 == 0);
}



function check_kh(ord) {
	var xmlHttp = false;
	try {
	  xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
	} catch (e) {
	  try {
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	  } catch (e2) {
		xmlHttp = false;
	  }
	}
	if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
	  xmlHttp = new XMLHttpRequest();
	}
  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState < 4) {
		khmc.innerHTML="loading...";
	  }
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		khmc.innerHTML=response;	
		document.getElementById("mxlist3").src="../event/personbj.asp";
		xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);
}
function Calculation(n){
	var m1=$("#premoney");//项目总额
	var yh=$("#yhvalue");
	var ma=$("#moneyall");//优惠后总额	
	var m1value=m1.val();
	var yhvalue=yh.val();
	var mavalue=ma.val();
	if (m1value.length==0){m1value=0;}
	if (yhvalue.length==0){yhvalue=0;}
	if (mavalue.length==0){mavalue=0;}
	var ctype=$('input[name="yhtype"]:checked').val();	//优惠类型
	if(n==1)
	{
		if(yh.val().length>1 && yh.val().substring(0,1)=="0" && yh.val().substring(1,2)!="." ){yh.val(parseFloat(yhvalue));}
		if (ctype=="0")//优惠金额
		{
			if (parseFloat(yhvalue)>parseFloat(m1value))
			{			
				yh.val(0);
				yhvalue=0;
				$("#ts2").html("不能大于报价总额");
			}
			else 
			{
				$("#ts2").html("");
				$("#ts1").html("");
			}
			ma.val(parseFloat(m1value)-parseFloat(yhvalue));
			if (parseFloat(m1value)==0)
			{
				ma.val(0);
			}
		}
		else //折扣
		{
			$("#ts2").html("");
			$("#ts1").html("");
			ma.val(parseFloat(m1value)*parseFloat(yhvalue)/10);
		}
		checkDot('moneyall',window.sysConfig.moneynumber);
		$("#Inverse").val(0);
	}
	else if (n==2)
	{	
		yh.val(0);
		if(ma.val().length>1 && ma.val().substring(0,1)=="0" && ma.val().substring(1,2)!="." ){ma.val(parseFloat(mavalue));}
		if (parseFloat(m1value)>0)
		{
			if (ctype=="0")//优惠金额
			{
				if (parseFloat(mavalue)>parseFloat(m1value))
				{
					yh.val(0);
					$("#ts1").html("不能大于报价总额");
					ma.val(parseFloat(m1value));
				}
				else
				{
					$("#ts2").html("");
					$("#ts1").html("");
					yh.val(parseFloat(m1value)-parseFloat(mavalue));
				}
			}
			else //折扣
			{
				$("#ts2").html("");
				$("#ts1").html("");
				yh.val((parseFloat(mavalue))*10/parseFloat(m1value));	
			}
		}
		checkDot('yhvalue',window.sysConfig.moneynumber);
		$("#Inverse").val(1);
	}
	else
	{
		$("#Inverse").val(0);
		ma.val(m1value);
		if (ctype=="0")//优惠金额
		{
			yh.val(0);
		}
		else //折扣
		{
			yh.val(10);
		}
	}
}
