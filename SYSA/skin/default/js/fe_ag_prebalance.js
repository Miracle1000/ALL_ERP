function temp_dosave(){
	$("#typ").val(1);
	$("#mxListForm").submit();
}
//jd_preblance 余额方向是 借贷方的 历史余额
var addvalue = 0 , currRowDirection = -1, endRowDirection =-1, currCelDirection=0 , jd_preblance = 0;
function setMoney(obj,typ,hlnumber,moneynumber, attrstr1 ,attrstr2 , attrstr3)
{
	var ord=0;
	ord = obj.name.replace(attrstr1,""); 
	var moneyold = obj.getAttribute("oldMoneyValue");
	if(moneyold==null) { moneyold = obj.defaultValue;}
	if (moneyold.length==0){moneyold = 0;}
	var money = obj.value;
	if (money.length==0){money = 0 ;}
	if (typ<8){addvalue = parseFloat(money) - parseFloat(moneyold);}//比原值增加部分
	obj.setAttribute("oldMoneyValue", money);
	if ($(".moneysum").size()==6)
	{
		var balanceMoney = addvalue;
		switch(attrstr1)
		{
		case "money_year_j_b_":
			
			$(".moneysum")[0].innerText=FormatNumber($(".moneysum")[0].innerText.replace(/\,/g,"")*1 + addvalue,moneynumber);
			//$(".topsum")[0].innerText=$(".moneysum")[0].innerText;
			break;
		case "money_year_d_b_":
			$(".moneysum")[1].innerText=FormatNumber($(".moneysum")[1].innerText.replace(/\,/g,"")*1 + addvalue,moneynumber);
			//$(".topsum")[1].innerText=$(".moneysum")[1].innerText;
			break;
		case "money_amount_b_j_":
			$(".moneysum")[2].innerText=FormatNumber($(".moneysum")[2].innerText.replace(/\,/g,"")*1 + addvalue,moneynumber);
			//$(".topsum")[2].innerText=$(".moneysum")[2].innerText;
			break;
		case "money_amount_b_d_":
			$(".moneysum")[3].innerText=FormatNumber($(".moneysum")[3].innerText.replace(/\,/g,"")*1 + addvalue,moneynumber);
			//$(".topsum")[3].innerText=$(".moneysum")[3].innerText;
			break;
		case "money_part_j_b_":
			if (endRowDirection==2){
				balanceMoney= jd_preblance * -1;
			}else {
				if (currCelDirection==2){
					balanceMoney = balanceMoney * -1 - jd_preblance * 1;
				}else{
					balanceMoney = balanceMoney * 1 - jd_preblance * 1 ;
				}
			}
			$(".moneysum")[4].innerText=FormatNumber($(".moneysum")[4].innerText.replace(/\,/g,"")*1 + balanceMoney  ,moneynumber);
			//$(".topsum")[4].innerText=$(".moneysum")[4].innerText;
			break;
		case "money_part_d_b_":
			if (endRowDirection==1){
				balanceMoney= jd_preblance * -1;
			}else {
				if (currCelDirection==1){
					balanceMoney = balanceMoney * -1 - jd_preblance * 1;
				}else{
					balanceMoney = balanceMoney * 1 - jd_preblance * 1 ;
				}
			}
			$(".moneysum")[5].innerText=FormatNumber($(".moneysum")[5].innerText.replace(/\,/g,"")*1 + balanceMoney,moneynumber);
			//$(".topsum")[5].innerText=$(".moneysum")[5].innerText;
			break;
		default:
			break;
		}
	}
	var money_y = $(":input[name='" + attrstr2 + ord + "']").val();//年初余额_原币金额
	if (money_y!=undefined)
	{
		if (parseFloat(money_y)!=0 && !isNaN(money_y) && !isNaN(money))
		{
			var hl = FormatNumber((parseFloat(money)/parseFloat(money_y)),hlnumber);
			$("#"+ attrstr3 + ord).html(hl);//年初余额_汇率
		}
	}
	var parentIds = $(obj).attr("extAttr"); //扩展属性来自数据源
	if (parentIds.length>0)
	{
		var parentArr = parentIds.split(",")
		if (parentArr.length>2)
		{
			var balanceMoney = addvalue ;
			switch(attrstr1)
			{
				case "money_part_j_b_":
					if (endRowDirection==2){
						balanceMoney= jd_preblance * -1;
					}else {
						if (currCelDirection==2){
							balanceMoney = balanceMoney * -1 - jd_preblance * 1;
						}else{
							balanceMoney = balanceMoney * 1 - jd_preblance * 1 ;
						}
					}
					break;
				case "money_part_d_b_":
					if (endRowDirection==1){
						balanceMoney= jd_preblance * -1;
					}else {
						if (currCelDirection==1){
							balanceMoney = balanceMoney * -1 - jd_preblance * 1;
						}else{
							balanceMoney = balanceMoney * 1 - jd_preblance * 1 ;
						}
					}
					break;
				default:
					break;
			}

			for (var i=parentArr.length-2;i>0 ;i-- ){
				var obj1 = document.getElementsByName(attrstr1 + parentArr[i])[0]; //年初余额_借方本位币 (各级父节点)
				var objval = obj1.value;
				if (objval.length == 0){objval = 0 ;}
				var newmoney =  FormatNumber(objval*1 + balanceMoney,moneynumber);
				//var newmoney =  FormatNumber(objval*1 + addvalue,moneynumber);
				obj1.parentNode.parentNode.innerHTML =  newmoney + "<span style='display:none'><input name='" + attrstr1 + parentArr[i] + "' extAttr='" + $(obj1).attr("extAttr") +"' type='hidden' value='"+newmoney+"'/></span>" //重写父节点HTML
			}
		}
	}
	if (typ<8){
		//当前行期初余额
		setBalance(ord,money,typ,hlnumber,moneynumber); 
	}
	else{
		obj.parentNode.innerHTML =  money + "<input name='" + attrstr1 + ord + "'  extAttr='" + $(obj).attr("extAttr") +"' type='hidden' value='"+money+"'/>"
	}
}

function handleMoney(obj,typ, hlnumber, moneynumber , needReSetPublic){
	// typ 类型 hlnumber 汇率销售位数 moneynumber 金额小数位数    该JS函数可以汇总归类执行(待完善)
	//needReSetPublic 是否需要重置参数
	if (needReSetPublic==undefined || needReSetPublic==true){
		addvalue = 0 ;			//变动金额
		currRowDirection = -1;	//操作行余额方向
		endRowDirection =-1;	//最终余额方向
		currCelDirection=0;		//操作单元格借贷方向
		jd_preblance = 0;		//余额方向是借贷方的科目 历史余额
	}
	var ord=0;
	switch(typ){
		case 1 : 
			currCelDirection = 1;
			 //年初余额_借方本位币
			setMoney(obj,typ,hlnumber,moneynumber ,"money_year_j_b_" ,"money_year_y_" , "hl_y_");
			break;
		case 2 :
			//年初余额_贷方本位币
			currCelDirection = 2;
			setMoney(obj,typ,hlnumber,moneynumber ,"money_year_d_b_" , "money_year_y_" , "hl_y_");
			break;			
		case 3 ://年初余额_原币
			ord = obj.name.replace("money_year_y_","");
			var money = obj.value;
			if (money.length==0){money = 0 ;}
			var money_j_b = $(":input[name='money_year_j_b_"+ord+"']").val();
			var money_d_b = $(":input[name='money_year_d_b_"+ord+"']").val();
			if (money_j_b.length==0){money_j_b = 0 ;}
			if (money_d_b.length==0){money_d_b = 0 ;}
			var money_b = parseFloat(money_j_b) + parseFloat(money_d_b) ;
			if (parseFloat(money_b)!=0 && money.length>0) //计算汇率
			{
				if (parseFloat(money)!=0 && !isNaN(money))
				{
					var hl = FormatNumber((parseFloat(money_b)/parseFloat(money)),hlnumber);
					$("#hl_y_"+ord).html(hl);
				}
			}
			setBalance(ord,money,typ,hlnumber,moneynumber);
			break;
		case 4 :
			currCelDirection = 1;
			//本年累计借方发生额_借方本位币
			setMoney(obj,typ,hlnumber,moneynumber ,"money_amount_b_j_" , "money_amount_y_j_" , "hl_j_");
			break;
		case 5 :
			ord = obj.name.replace("money_amount_y_j_","");
			var money = obj.value;
			if (money.length==0){money = 0 ;}
			var money_b = $(":input[name='money_amount_b_j_"+ord+"']").val();
			if (money_b.length>0)
			{
				if (parseFloat(money)!=0 && !isNaN(money) && !isNaN(money_b))
				{
					var hl = FormatNumber((parseFloat(money_b)/parseFloat(money)),hlnumber);
					$("#hl_j_"+ord).html(hl);
				}
			}
			setBalance(ord,money,typ,hlnumber,moneynumber);
			break;
		case 6 :
			currCelDirection = 2;
			//本年累计贷方发生额_贷方本位币
			setMoney(obj,typ,hlnumber,moneynumber ,"money_amount_b_d_" , "money_amount_y_d_" , "hl_d_");
			break;
		case 7 :
			ord = obj.name.replace("money_amount_y_d_","");
			var money = obj.value;
			if (money.length==0){money = 0 ;}
			var money_b = $(":input[name='money_amount_b_d_"+ord+"']").val();
			if (money_b.length>0)
			{
				if (parseFloat(money)!=0 && !isNaN(money) && !isNaN(money_b))
				{
					var hl = FormatNumber((parseFloat(money_b)/parseFloat(money)),hlnumber);
					$("#hl_d_"+ord).html(hl);
				}
			}
			setBalance(ord,money,typ,hlnumber,moneynumber);
			break;
		case 8 :
			//期初余额_借方本位币
			setMoney(obj,typ,hlnumber,moneynumber ,"money_part_j_b_" ,"money_part_y_" , "hl_c_");
			break;
		case 9 :
			//期初余额_贷方本位币
			setMoney(obj,typ,hlnumber,moneynumber ,"money_part_d_b_" , "money_part_y_" , "hl_c_");
			break;
		case 10 :	
			ord = obj.name.replace("money_part_y_","");
			var money = obj.value;
			if (money.length==0){money = 0 ;}
			var money_j_b = $(":input[name='money_part_j_b_"+ord+"']").val();
			var money_d_b = $(":input[name='money_part_d_b_"+ord+"']").val();
			if (money_j_b.length==0){money_j_b = 0 ;}
			if (money_d_b.length==0){money_d_b = 0 ;}
			var money_b = parseFloat(money_j_b) + parseFloat(money_d_b) ;
			if (money_b!=0)
			{
				if (parseFloat(money)!=0 && !isNaN(money) && !isNaN(money_b))
				{
					var hl = FormatNumber((parseFloat(money_b)/parseFloat(money)),hlnumber);
					$("#hl_c_"+ord).html(hl);
				}
			}
			obj.parentNode.innerHTML =  money + "<input name='money_part_y_" + ord + "'  extAttr='" + $(obj).attr("extAttr") +"'  type='hidden' value='"+money+"'/>"
			break;
	}
	
}

function setBalance(ord,money,typ,hlnumber,moneynumber){
	if (money.length==0){money = 0;}
	var money2=0 ; 
	var money3=0;
	var obj = null;
	var money1 = 0 ;
	var direction = $("input:[name=balanceDirection_"+ord+"]").val();
	//if (direction !="1" && direction !="2"){ return ;}
	currRowDirection = direction
	switch(typ){
		case 1 ://本身是借
			money1 = 0 ; //贷
			if ($("input:[name=money_amount_b_j_"+ord+"]").size()>0){
				money2=$("input:[name=money_amount_b_j_"+ord+"]").val();
				if (money2.length==0){money2 = 0;}
			}//借方本位币金额
			if ($("input:[name=money_amount_b_d_"+ord+"]").size()>0){
				money3 = $("input:[name=money_amount_b_d_"+ord+"]").val();
				if (money3.length==0){money3 = 0;}
			}//贷方本位币金额
			obj = $("input:[name=money_part_j_b_"+ord+"]");
			break;
		case 2 ://本身是贷
			money1 = money ; 
			money = 0
			if ($("input:[name=money_amount_b_j_"+ord+"]").size()>0){
				money2=$("input:[name=money_amount_b_j_"+ord+"]").val();
				if (money2.length==0){money2 = 0;}
			}//借方本位币金额
			
			if ($("input:[name=money_amount_b_d_"+ord+"]").size()>0){
				money3 = $("input:[name=money_amount_b_d_"+ord+"]").val();
				if (money3.length==0){money3 = 0;}
			}//贷方本位币金额
			obj = $("input:[name=money_part_d_b_"+ord+"]");
			break;		
		case 3 ://原币种
			if (direction =="1"){
				money1 = 0;
			}
			else if (direction =="2"){
				money1 = money;
				money = 0;
			}
			if ($("input:[name=money_amount_y_j_"+ord+"]").size()>0){
				money2=$("input:[name=money_amount_y_j_"+ord+"]").val();
				if (money2.length==0){money2 = 0;}
			}//借方原币
			if ($("input:[name=money_amount_y_d_"+ord+"]").size()>0){
				money3 = $("input:[name=money_amount_y_d_"+ord+"]").val();
				if (money3.length==0){money3 = 0;}
			}//贷方原币
			obj =$("input:[name=money_part_y_"+ord+"]"); 
			break;
		case 4 :
			money2 = money; //借方本位币金额
			var money_j_b = $(":input[name='money_year_j_b_"+ord+"']").val();
			var money_d_b = $(":input[name='money_year_d_b_"+ord+"']").val();
			if (money_j_b.length==0){money_j_b = 0 ;}
			if (money_d_b.length==0){money_d_b = 0 ;}
			money = money_j_b ; 
			money1 = money_d_b ; 
			if ($("input:[name=money_amount_b_d_"+ord+"]").size()>0){
				money3 = $("input:[name=money_amount_b_d_"+ord+"]").val();
				if (money3.length==0){money3 = 0;}
			}
			if (direction =="1"){
				obj = $("input:[name=money_part_j_b_"+ord+"]");
			}
			else if (direction =="2"){//贷
				obj = $("input:[name=money_part_d_b_"+ord+"]");
			}
			else{
				var moneyOld = parseFloat(money) + parseFloat(money2) - parseFloat(money1) - parseFloat(money3); 
				if (parseFloat(moneyOld)>=0){
					obj = $("input:[name=money_part_j_b_"+ord+"]");
					direction = "1";
					endRowDirection = 1;
					var obj1 = $("input:[name=money_part_d_b_"+ord+"]");
					jd_preblance = obj1.val();//剩于值
					obj1.val(FormatNumber(0,moneynumber));
					handleMoney(obj1[0],9, hlnumber, moneynumber,false);
				}else{
					obj = $("input:[name=money_part_d_b_"+ord+"]");
					direction = "2";
					endRowDirection = 2;
					var obj1 = $("input:[name=money_part_j_b_"+ord+"]");
					jd_preblance = obj1.val();//剩于值
					obj1.val(FormatNumber(0,moneynumber));
					handleMoney(obj1[0],8, hlnumber, moneynumber,false);
				}
			}
			break;
		case 5 :
			money2 = money;
			money=$("input:[name=money_year_y_"+ord+"]").val();
			if ($("input:[name=money_amount_y_d_"+ord+"]").size()>0){
				money3 = $("input:[name=money_amount_y_d_"+ord+"]").val();
				if (money3.length==0){money3 = 0;}
			}
			if (money.length==0){money = 0;}
			if (direction =="1"){
				money1 = 0;
			}
			else if (direction =="2"){
				money1 = money;
				money = 0 ;
			}
			else{
				money1 = 0 ;
				if (money2>money3){
					direction = "1";
				}
				else{
					direction = "2";
				}
			}
			obj = $("input:[name=money_part_y_"+ord+"]");
			break;
		case 6 :
			if ($("input:[name=money_amount_b_j_"+ord+"]").size()>0){
				money2=$("input:[name=money_amount_b_j_"+ord+"]").val();
				if (money2.length==0){money2 = 0;}
			}
			money3 = money;	
			var money_j_b = $(":input[name='money_year_j_b_"+ord+"']").val();
			var money_d_b = $(":input[name='money_year_d_b_"+ord+"']").val();
			if (money_j_b.length==0){money_j_b = 0 ;}
			if (money_d_b.length==0){money_d_b = 0 ;}
			money = money_j_b ; 
			money1 = money_d_b ; 
			if (direction =="1"){
				obj = $("input:[name=money_part_j_b_"+ord+"]");
			}
			else if (direction =="2"){//贷
				obj = $("input:[name=money_part_d_b_"+ord+"]");
			}
			else{
				var moneyOld = parseFloat(money) + parseFloat(money2) - parseFloat(money1) - parseFloat(money3); 
				if (parseFloat(moneyOld)>=0){
					obj = $("input:[name=money_part_j_b_"+ord+"]");
					direction = "1";
					endRowDirection = 1;
					var obj1 = $("input:[name=money_part_d_b_"+ord+"]");
					jd_preblance = obj1.val();//剩于值
					obj1.val(FormatNumber(0,moneynumber));
					handleMoney(obj1[0],9, hlnumber, moneynumber,false);
				}else {
					obj = $("input:[name=money_part_d_b_"+ord+"]");
					direction = "2";
					endRowDirection = 2;
					var obj1 = $("input:[name=money_part_j_b_"+ord+"]");
					jd_preblance = obj1.val();//剩于值
					obj1.val(FormatNumber(0,moneynumber));
					handleMoney(obj1[0],8, hlnumber, moneynumber,false);
				}
			}
			break;
		case 7 :
			if ($("input:[name=money_amount_y_j_"+ord+"]").size()>0){
				money2=$("input:[name=money_amount_y_j_"+ord+"]").val();
				if (money2.length==0){money2 = 0;}
			}
			money3 = money;
			money=$("input:[name=money_year_y_"+ord+"]").val();
			if (money.length==0){money = 0;}
			if (direction =="1"){
				money1 = 0;
			}
			else if (direction =="2"){
				money1 = money;
				money = 0 ;
			}
			else{
				money1 = 0;
				if (money2>money3)
				{
					direction = "1";
				}
				else
				{
					direction = "2";
				}	
			}
			obj = $("input:[name=money_part_y_"+ord+"]");
			break;
	}
	//money 借 money1 贷 money2 借 money3 贷
	if (direction =="1"){
		money = parseFloat(money) + parseFloat(money2) - parseFloat(money1) - parseFloat(money3); 
	}
	else if (direction =="2"){
		money = parseFloat(money1) + parseFloat(money3) - parseFloat(money) - parseFloat(money2) ;
	}
	money = FormatNumber(money,moneynumber);
	obj.val(money);
	if (typ ==1 || (typ==4 && direction=="1") || (typ==6 && direction=="1")){ //借
		handleMoney(obj[0],8, hlnumber, moneynumber,false);
	}
	else if (typ ==2 || (typ==4 && direction=="2") || (typ==6 && direction=="2")){ //贷
		handleMoney(obj[0],9, hlnumber, moneynumber,false);
	}
	else if (typ ==3 || typ == 5 || typ==7 ){//原币
		handleMoney(obj[0],10, hlnumber, moneynumber,false);
	}
}

window.onReportRefresh = function() {
	$("#typ").val(0);
	$("#subtn").attr("disabled",false) ;
	$("#subtn1").attr("disabled",false) ;
	//$(".topsum")[0].innerText=$(".moneysum")[0].innerText;
	//$(".topsum")[1].innerText=$(".moneysum")[1].innerText;
	//$(".topsum")[2].innerText=$(".moneysum")[2].innerText;
	//$(".topsum")[3].innerText=$(".moneysum")[3].innerText;
	//$(".topsum")[4].innerText=$(".moneysum")[4].innerText;
	//$(".topsum")[5].innerText=$(".moneysum")[5].innerText;
}

function doreset(){
	//lvw_refresh('mlistvw');
	window.location.reload();
}