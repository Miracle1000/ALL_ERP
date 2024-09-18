function doSave(ord) {
	var fromobj=document.getElementById("demo");
	var money1= parseFloat($("#money1").val().replace(",",""));
	var oldmoney = parseFloat($("#money1").attr("oldMoney").replace(",",""));
	if(money1>oldmoney){
		alert("计划应付金额不能大于" + $("#money1").attr("oldMoney"));
		return;
    }
    if (money1 === 0) {
        alert("计划付款金额不能为0！");
        return;
    }
	if(Validator.Validate(fromobj,2) ){		
		fromobj.submit();
	}
}
//
function changePlanDate(fkdays, fkdate) {
    var strJhDate = $("#jhDate").val();
    var jhDate = new Date(strJhDate);
    var strYfDate=""
	//无结算日期,按账期进行公式计算
	if (fkdate <= 0) {
		var yfDate = jhDate.setDate(jhDate.getDate() + fkdays);
		yfDate = new Date(yfDate);
		strYfDate = yfDate.format("yyyy-MM-dd");
	}
	//否则按账期进行计算
	else {
		var jhDay = jhDate.getDate();
		var nextMonth = 1;
		nextMonth += fkdate >= jhDay ? 0 : 1;
		var totalDay = mGetDate(jhDate.getFullYear(), jhDate.getMonth() + nextMonth);
		fkdate = fkdate > totalDay ? 30 : fkdate;
		var yfDate = jhDate.getFullYear() + "-" + (jhDate.getMonth() + nextMonth) + "-" + fkdate;
		strYfDate = new Date(yfDate).format("yyyy-MM-dd");
	}
	if (strJhDate != "") { $("#yfDate").val(strYfDate); }
}
//格式化日期字符串
Date.prototype.format = function (fmt) {
	var o = {
		"M+": this.getMonth() + 1, //月份
		"d+": this.getDate(), //日
		"h+": this.getHours() % 12 == 0 ? 12 : this.getHours() % 12, //小时
		"H+": this.getHours(), //小时
		"m+": this.getMinutes(), //分
		"s+": this.getSeconds(), //秒
		"q+": Math.floor((this.getMonth() + 3) / 3), //季度
		"S": this.getMilliseconds() //毫秒
	};
	if (/(y+)/.test(fmt))
		fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
	for (var k in o)
		if (new RegExp("(" + k + ")").test(fmt))
			fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
	return fmt;
}
//获取当月天数
function mGetDate(year, month) {
	var d = new Date(year, month, 0);
	return d.getDate();
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
	var newmoney = 0;
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

function updatemxmoney()
{
    var newplanmoney1 = $("#money1").val().replace(",", "");
    var oldplanymoney1 = $("#money1").attr("oldMoney").replace(",", "");
    var money = 0;
    var money1 = 0;
    var money3 = 0;
    var yhmoney = document.getElementById("yhmoney");
    var money_one = 0;
    if (yhmoney) {
         money_one = document.getElementById("yhmoney").value;
        if (money_one.replace(" ", "") != "") {
            newplanmoney1 = parseFloat(parseFloat(newplanmoney1) + (parseFloat(money_one))).toFixed(window.sysConfig.moneynumber);
        }

    }
    else { 
    }
    $(".tabledata").find("tr").not(':eq(0)').each(function () {
        //产品明细付款金额
        var oldmoney = $(this).find("td:last").find("input").attr("max");
        var oldnum = $(this).find("td").eq(4).find("input").attr("max");
        //依次扣减数量
        //money = parseFloat(parseFloat(oldmoney) - Math.abs(parseFloat(money))).toFixed(window.sysConfig.moneynumber)
        if ($(this).find("td:last").find("input").attr("id") != "yhmoney") {
        money1 += parseFloat(oldmoney);
        if (parseFloat(money1) >= parseFloat(newplanmoney1)) {
            money = parseFloat(parseFloat(oldmoney) - (parseFloat(money1) - parseFloat(newplanmoney1))).toFixed(window.sysConfig.moneynumber)
            if (money > 0) {
                $(this).find("td:last").find("input").val(FormatNumber(money, window.sysConfig.moneynumber));
            }
            else {
                $(this).find("td:last").find("input").val(FormatNumber(0, window.sysConfig.moneynumber));
            }
        }
        else {

            $(this).find("td:last").find("input").val(FormatNumber(oldmoney, window.sysConfig.moneynumber));
        }
        //计划付款金额为0
        if (parseFloat(newplanmoney1) == 0)
        {
            $(this).find("td:last").find("input").val(FormatNumber(0, window.sysConfig.moneynumber));
        }
        var  newnum = FormatNumber(parseFloat($(this).find("td:last").find("input").val()) / parseFloat(oldmoney) * parseFloat(oldnum), window.sysConfig.floatnumber);
        $(this).find("td").eq(4).find("input").val(newnum)
        //分配完明细后的明细总额
        money3 += parseFloat( $(this).find("td:last").find("input").val());
    }
 
    });
    money3 = money3.toFixed(window.sysConfig.moneynumber) * 1
    if (parseFloat(oldplanymoney1) > 0 && parseFloat(money3) > 0) {
        if ((parseFloat(newplanmoney1) - parseFloat(money_one)) > (parseFloat(money3) - parseFloat(money_one))) {
            alert("不允许大于剩余付款金额！");
            $("#money1").val(parseFloat(money3) - parseFloat(money_one));
        }
    }
    

}


function setshowcw() {
    $('.cwcss').each(function () {
        if ($(this).css("display") == "none") { $(this).css("display", ""); }
        else { $(this).css("display", "none"); }
    });
}

function del(obj)
{
    if ($('.tabledata tr.del').length ==1)
    {
        alert("至少保留一条明细！")
        return;

    }
    var money1 = 0;
    var money_one = "";
    $(obj).parents("tr.del").remove();
    $(".tabledata").find("tr").not(':eq(0)').each(function () {
        //产品明细付款金额.排除优惠金额
        if ($(this).find("td:last").find("input").attr("id") != "yhmoney") {
            var oldmoney = $(this).find("td:last").find("input").val();
            money1 += parseFloat(oldmoney);
        }

    });
    money1 = money1.toFixed(window.sysConfig.moneynumber);
    if (document.getElementById("yhmoney")!= null) {
        money_one = document.getElementById("yhmoney").value;
    }
    if (money_one.replace(" ", "") != "") {
        money1 = parseFloat(parseFloat(money1) -(parseFloat(money_one))).toFixed(window.sysConfig.moneynumber);
    }

    $("#money1").val(money1);
    $("#money1").attr('delbefore',parseFloat(money1));

}