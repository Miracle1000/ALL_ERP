
function frameResize(){
document.getElementById("mxlist").style.height=I3.document.body.scrollHeight+0+"px";
}

function beforeSave()
{
	var fromobj=document.getElementById("demo");
	if(Validator.Validate(fromobj,2))
	{
		var strateget=window.strateget;
		var mxobj=document.getElementById("mxlist").contentWindow.document.getElementsByTagName("table")[0];
		if(mxobj.rows.length<3){alert('未选择报销明细！');return false;}
		var moneyobj=document.getElementById("bxmoney");
		var bzobj=document.getElementById("bz");
		var bxuid=document.getElementById("bxuid");
		var bxtype = document.getElementById("bxtype").value;//--报销类型
		if (bxtype == "")
		{
			bxtype = 0;
		}
		
		if (strateget==0)
		{
			document.getElementById("sptype").value = bxtype;
			//spclient.nextSP(fromobj, 2 , 0 , 'paybx' , moneyobj.value , 0) //page, spord , money, sptype, ADDobj
			spclient.GetNextSP('paybx', 0, moneyobj.value, bxtype, bxuid.value);
			return true;
		}
		else 
		{
			var budgetMoney=GetBudgetMoney(bxuid.value, bzobj.value, document.getElementsByName("ret")[0].value,moneyobj.value, document.getElementsByName("paybxid")[0].value);
			if (budgetMoney=="")
			{
				document.getElementById("sptype").value = bxtype;
				spclient.GetNextSP('paybx', 0, moneyobj.value, bxtype, bxuid.value);
				return true ;
			}
			else if (budgetMoney.indexOf("err=")==0)
			{
				alert(budgetMoney.replace("err=",""));
				return false ;
			}	
			else if (budgetMoney.indexOf("ok=")==0)
			{
					if (strateget==1)
					{
						alert(budgetMoney.replace("ok=","")+"\n不能报销！");
						return false ;
					}
					else
					{
						var ExCSp = HasExCSp();//--如果设置了超额审批流程，就走超额审批；否则走分类审批
						if (ExCSp == "true")
						{
							alert(budgetMoney.replace("ok=","")+"\n进入超额预算审批流程！");
							document.getElementById("sptype").value = "1";
							spclient.GetNextSP('paybx', 0,moneyobj.value, 1, bxuid.value);
						}
						else
						{
							document.getElementById("sptype").value = bxtype;
							spclient.GetNextSP('paybx', 0, moneyobj.value, bxtype, bxuid.value);
						}
						//spclient.GetNextSP(fromobj, 2 , 0 , 'paybx' , moneyobj.value , 1)
						return true;
					}
			}
		}	
	}
}

function GetBudgetMoney(uid,bz, ret, money, bxid){
	if (uid=="0" || uid.length==0 || bz=="0" || bz.length==0)
	{
		return "err=报销人员或币种有误，无法使用预算。"
	}
	var returnStr="";
	var xmlHttp2 = new getxmlhttp();
	var my_url="getBudgetMoney.asp"
	xmlHttp2.open('post',my_url,false);
	xmlHttp2.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	var postStr = "uid="+ uid +"&bz="+bz+"&ret="+ret+"&money="+ money +"&bxid="+ bxid +"&date1="+Math.round(Math.random()*100);
	xmlHttp2.onreadystatechange=function()
	{
		if(xmlHttp2.readyState==4)
		{
			if(xmlHttp2.status==200)
			{
				returnStr=xmlHttp2.responseText;
			}
		}
	}
	xmlHttp2.send(postStr);
	return returnStr;
}

function HasExCSp(){
	var returnStr="";
	var xmlHttp2 = new getxmlhttp();
	var my_url="HasExCSp.asp"
	xmlHttp2.open('post',my_url,false);
	xmlHttp2.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	//var postStr = "uid="+ uid +"&bz="+bz+"&ret="+ret+"&money="+ money +"&bxid="+ bxid +"&date1="+Math.round(Math.random()*100);
	xmlHttp2.onreadystatechange=function()
	{
		if(xmlHttp2.readyState==4)
		{
			if(xmlHttp2.status==200)
			{
				returnStr=xmlHttp2.responseText;
			}
		}
	}
	xmlHttp2.send();
	return returnStr;
} 