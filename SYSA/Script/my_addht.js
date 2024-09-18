function GetZQPayBackDate(htord) {
    var result = true;
    var $dt = jQuery(':input[name="date4"]');
    var dt = $dt.val().split(" ")[0];
    jQuery.ajax({
        url: '../contract/AjaxReturn.asp',
        data: {
            act: 'ZQPayBackDate',
            plandate: dt,
            ord: htord
        },
        cache: false,
        async: false,
        success: function (r) {
            var json = eval('(' + r + ')');
            if (json.success == false) {
                //alert('应收日期无法获取');
                result = false;
            } else {
                var $dtRet = jQuery(':input[name="ret"]');
                $dtRet.val(json.plandate);
            }
        },
        error: function () {
            result = false;
        }
    });
    return result;
}

function checkMoney()
{
	var paybackMode = document.getElementById("paybackMode").value;
	var moneyall=document.getElementById("money1");
	if (paybackMode=="2")
	{
		setMoney();
	}
	return true;
}
function setNum(obj)
{
	var newnum = obj.value;
	var oldnum = obj.getAttribute("max");
	var moneyObj = document.getElementById("mx_"+obj.getAttribute("id").replace("num_",""));
	var oldmoney = moneyObj.getAttribute("max");
	if (newnum.length==0){
		newnum = 0;
		obj.value=0;
		moneyObj.value=0;
	}
	if (parseFloat(oldnum)==0)
	{
		obj.value=0;
		moneyObj.value=0;		
	}
	else if (parseFloat(oldnum)< parseFloat(newnum))
	{
		//alert("计划回款数量"+newnum+"不能超过剩余回款数量"+oldnum);
		return false;
	}
	else 
	{		
		newmoney = FormatNumber(parseFloat(newnum) /parseFloat(oldnum) * parseFloat(oldmoney),window.sysConfig.moneynumber);
		moneyObj.value=newmoney;	
	}
	setMoney();
}

function setMoney(obj)
{
	if(obj!=undefined)
	{
		var newmoney = obj.value;
		var oldmoney = obj.getAttribute("max");
		var numObj = document.getElementById("num_"+obj.getAttribute("id").replace("mx_",""));
		var oldnum = numObj.getAttribute("max");
		if (newmoney.length==0){
			newmoney = 0;
			obj.value=0;
			numObj.value=0;
		}
	
		if (parseFloat(oldmoney)==0 )
		{
			obj.value=0;
			numObj.value=0;		
		}
		else if (parseFloat(oldmoney)< parseFloat(newmoney))
		{
			return false;
		}
		else 
		{	
			newnum = FormatNumber(parseFloat(newmoney) /parseFloat(oldmoney) * parseFloat(oldnum),window.sysConfig.floatnumber);
			numObj.value=newnum;	
		}
	}
	var moneyall=document.getElementById("money1");
	var money1=0;
	var money_one=0;
	$(".mxlistData").each(function()
		{
			money_one =$(this).val();
			if (money_one.replace(" ","")!="")
			{
				money1 += parseFloat(money_one);
			}
		}
	)
	$(".mxlistData_th").each(function()
		{
			money_one =$(this).val();
			if (money_one.replace(" ","")!="")
			{
				money1 -= parseFloat(money_one);
			}
		}
	)
	var yhmoney = document.getElementById("yhmoney");
	if (yhmoney)
	{	
		money_one = document.getElementById("yhmoney").value;
		if (money_one.replace(" ","")!="")
		{
			money1 -= parseFloat(money_one);
		}
	}
	moneyall.value=FormatNumber(money1,window.sysConfig.moneynumber);
}
