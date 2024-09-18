
function openwin()
{
window.open("../search/result4.asp","","height=250,width=450,resizable=yes,scrollbars=yes,status=no,toolbar=no,menubar=yes,location=no");
}

function check_kh(ord) {
  var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	  if (xmlHttp.readyState < 4) {
		khmc.innerHTML="loading...";
	  }
	  if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		if(response!=""){
			var arr_res = response.split("<noscript></noscript>") ;
			var res2 = arr_res[1];
			var resTxt = "";
			if(res2!=""){
				resTxt = res2.replace("size=\"25\"","size=\"20\"");
				khmc.innerHTML=resTxt;	
			}
		}
		xmlHttp.abort();
	  }
  };
  xmlHttp.send(null);
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
