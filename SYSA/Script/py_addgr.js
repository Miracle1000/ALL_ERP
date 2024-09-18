
function ask()
{
	var fo = document.getElementById("demo");
	var result = Validator.Validate(fo,2);
	if (!result)
	{
		return false;
	}
	if(document.getElementById('title').value=="")
	{
		document.getElementById('tit').innerHTML="必填"
		return false;
	}
	if(document.getElementById('allpay').value=="")
	{
		document.getElementById('mone').innerHTML="必填"
		return false;
	}
	var membool=false
	var memarr=document.getElementsByName('member2');
	for (i=0;i<memarr.length;i++)
	{
		if(memarr[i].checked)
		{
			membool=true
		}
	}
	if(membool==false)
	{
		document.getElementById('ry').innerHTML="*必填"
		return false;
	}

	if (!isNaN(document.getElementById('allpay').value))
	{
		if(parseFloat(document.getElementById('allpay')).value<0)
		{
			document.getElementById('mone').innerHTML="金额不能小于0"
			return false;
		}
	}
	else
	{
		document.getElementById('mone').innerHTML="请输入金额"
		return false
	}
	if(document.getElementById('bh').value!="")
	{
		bh=document.getElementById('bh').value;
		payjkid=document.getElementById('payjkid').value;
		var bol=true;
		$.ajax({
		   url:"checkjkBH.asp?bh="+bh+"&payjkid="+payjkid+"&r="+ Math.random(),
		   async:false,
		   type:"get",
		   dataType:"txt",
		   success:function(j){
			  if (j=="1")
			  {
			    alert("借款编号已经存在,不允许保存!");
				bol=false;
			  }
		   }
	   });
	   if (!bol)
	   {
			return bol;
	   }
	}

	var fromobj=document.getElementById("demo");
	var moneyobj=document.getElementById("allpay");
	var bzobj=document.getElementById("bz");
	var jkm=document.getElementsByName("member2");
	var cid=0;
	for(var i=0;i<jkm.length;i++)
	{
		if(jkm[i].checked)
		{
			cid=jkm[i].value;
			break;
		}
	}
	//BUG:1370 费用借款 审批流程不正确 xieyanhui2014.2.28
	spclient.GetNextSP('payjk', 0, moneyobj.value, 0, cid);
	return true;
}
function chanceR(name)
{
	document.getElementById('sqr').innerHTML=name;
	hm=1
}
