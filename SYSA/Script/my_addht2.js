
function add() {
  var money1 = document.getElementById("money1").value;
  var money2 = document.getElementById("money2").value;
  var gdate = document.getElementById("ret6");
  var gdatev="";
  if ((typeof gdate == "object")&&gdate!=null) {
      gdatev = gdate.value;
  };
  if (gdatev == "undefined") {gdatev = ""; };
  var url = "cu.asp?money1=" + escape(money1) + "&money2=" + escape(money2) + "&timestamp=" + new Date().getTime() + "&gdate=" + gdatev + "&date1=" + Math.round(Math.random() * 100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage();
  };  
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	dybf.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	dybf.innerHTML=response;
	xmlHttp.abort();
  }
}

function check_ck() {
   var money1 = document.getElementById("money1").value; 
   var money2 = document.getElementById("money2").value; 

  if ( isNaN(money1) || (money1 == "") ) {
  return false;
  }
  if (Number(money1)==0)
  {
  	document.getElementById("txtmon").innerHTML="金额不能为0";  	
  	document.getElementById("butSubmit").disabled=true;
  	return false;
  }
  else
  {
  	document.getElementById("txtmon").innerHTML="*";
  	document.getElementById("butSubmit").disabled=false;
  } 
  if (Number(money1) > Number(money2)) {
  alert("大于应收账款！");
  document.getElementById("money1").value=money2;
  return false;
  }
  return true;
}
//选择余额回款
function setBackMode(ctype)
{
	if (ctype==1)
	{
		document.getElementById("fktr1").style.display="";
		document.getElementById("fktr2").style.display="";
		document.getElementById("yskTr").style.display="none";
	}
	else
	{
		document.getElementById("fktr1").style.display="none";
		document.getElementById("fktr2").style.display="none";
		document.getElementById("yskTr").style.display="";
	}
}
//单个收款编辑总金额
function setMoneyAll(money1)
{
	var moneyall=document.getElementById("money1");
	var oldmoney = moneyall.defaultValue.replace(",","")
	var checkYh=false ;
	var yhmoneyObj = document.getElementById("yhmoney");
	if (yhmoneyObj)
	{
		if (parseFloat(yhmoneyObj.value)!=parseFloat(yhmoneyObj.getAttribute("max")))
		{
			checkYh = true;
		}
	}
	if (parseFloat(oldmoney)!=money1 || checkYh)
	{
		document.getElementById("remainMoney").value=FormatNumber(parseFloat(oldmoney)-money1,window.sysConfig.moneynumber);
		document.getElementById("remainTr").style.display="";
		//document.getElementById("neecCheckTd").getElementsByTagName("TABLE")[0].style.display = "";
	}
	else
	{
		document.getElementById("remainTr").style.display="none";
		document.getElementById("remainMoney").value="0";
		//document.getElementById("neecCheckTd").getElementsByTagName("TABLE")[0].style.display = "none";
	}
}

function setNum(obj)
{
	var newnum = obj.value;
	var oldnum = obj.getAttribute("max");
	var moneyObj = document.getElementById("mx_"+obj.getAttribute("id").replace("num_",""));
	var oldmoney = moneyObj.getAttribute("max");
	if (newnum.length==0){ newnum = 0; }
	if (parseFloat(oldnum)==0 || parseFloat(oldnum)< parseFloat(newnum))
	{
		moneyObj.value=0;
	}
	else 
	{	
		newmoney = FormatNumber(parseFloat(newnum) /parseFloat(oldnum) * parseFloat(oldmoney),window.sysConfig.moneynumber) ;
		moneyObj.value=newmoney;
	}
	setMoney();
}

//单个收款编辑明细
function setMoney(obj)
{
    if(obj!=undefined&&obj.getAttribute("id") != "yhmoney") 
	{
		var newmoney = obj.value;
		var oldmoney = obj.getAttribute("max");
		var numObj = document.getElementById("num_"+obj.getAttribute("id").replace("mx_",""));
		var oldnum = numObj.getAttribute("max");
		if (newmoney.length==0){ newmoney = 0; }
		if (parseFloat(oldmoney)==0)
		{
			numObj.value=0;
		}
		else if (parseFloat(oldmoney)< parseFloat(newmoney))
		{
			return false ;
		}
		else 
		{	
			newnum = FormatNumber(parseFloat(newmoney) /parseFloat(oldmoney) * parseFloat(oldnum),window.sysConfig.floatnumber) ;
			numObj.value=newnum;	
		}
	}
	var money1=0;
	var money_one=0;
	$(".mxlistData").each(function()
		{
			money_one =$(this).val();
			if (money_one.replace(" ","")!="")
			{
				if ($(this).attr("id")=="yhmoney")
				{
					money1 -= parseFloat(money_one);
				}
				else
				{
					money1 += parseFloat(money_one);
				}
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
	setMoneyAll(money1);
	document.getElementById("money1").value=FormatNumber(money1,window.sysConfig.moneynumber);
}

function setMxNum(ord,obj)
{
	var newnum = obj.value;
	var oldnum = obj.getAttribute("max");
	var moneyObj = $(".paybackmx").find("#mx_"+obj.getAttribute("id").replace("num_",""))[0];
	if (moneyObj)
	{	
		var oldmoney = moneyObj.getAttribute("max");
		if (newnum.length==0){ newnum = 0; }
		if (parseFloat(oldnum)==0 || parseFloat(oldnum)< parseFloat(newnum) )
		{
			moneyObj.value=0;
		}
		else 
		{	
			newmoney = FormatNumber(parseFloat(newnum) /parseFloat(oldnum) * parseFloat(oldmoney),window.sysConfig.moneynumber) ;
			moneyObj.value=newmoney;	
		}
		setHtMoney(ord);
	}
}

//合并收款编辑明细合同产品金额
function setMxMoney(id,obj)
{
	if(obj!=undefined)
	{
		var newmoney = obj.value;
		var oldmoney = obj.getAttribute("max");
		var numObj = $(".paybackmx").find("#num_"+obj.getAttribute("id").replace("mx_",""))[0];
		if (numObj)
		{			
			var oldnum = numObj.getAttribute("max");
			if (newmoney.length==0){ newmoney = 0; }
			if (parseFloat(oldmoney)==0 || parseFloat(oldmoney)< parseFloat(newmoney) )
			{
				numObj.value=0;		
			}
			else 
			{
				newnum = FormatNumber(parseFloat(newmoney) /parseFloat(oldmoney) * parseFloat(oldnum),window.sysConfig.floatnumber) ;
				numObj.value=newnum;	
			}
		}
	}
	setHtMoney(id);
}
function setHtMoney(id){
	var money1 = 0;
	var isUp=false
	$(".paybackmx").find(".mxlistData").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){
			if ($(this).attr("id")=="yhmoney"){
				money1 -= parseFloat(money_one);
			}
			else{
				money1 += parseFloat(money_one);
			}
		}
		isUp = true ;
	})
	$(".paybackmx").find(".mxlistData_th").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){
			money1 -= parseFloat(money_one);
		}
		isUp = true ;
	})
	if (isUp){
		document.getElementById("ht_"+id).value=FormatNumber(money1,window.sysConfig.moneynumber);
		sethbMoney(id ,true);
	}
}

var isSaveMx = false ;//是否保存当前明细
//合并收款编辑汇总合同金额 isEditDiv 是否计算弹出层的数据
function sethbMoney(id ,isEditDiv)
{
	var money1=0;
	var money_one=0;
	$(".htlistData").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){money1 += parseFloat(money_one);}
	})
	document.getElementById("money1").value=FormatNumber(money1,window.sysConfig.moneynumber);
	var moneyall=document.getElementById("ht_"+id);
	var oldmoney = moneyall.defaultValue.replace(",","");
	var newmoney = moneyall.value;
	var obj = null;
	if (isSaveMx || isEditDiv){
		obj = $('.paybackmx');
	}else{
		obj = $("#payback_"+id);
	}
	var checkYh=false ;
	if (obj.find("#yhmoney").size()>0){
		var yhMoney=obj.find("#yhmoney").val();
		var maxMoney = obj.find("#yhmoney").attr("max");
		if (parseFloat(yhMoney)!=parseFloat(maxMoney)){checkYh = true;}
	}
	if (parseFloat(oldmoney)!=parseFloat(newmoney) || checkYh ){
		document.getElementById("money3_"+id).value=FormatNumber(parseFloat(oldmoney)-parseFloat(newmoney),window.sysConfig.moneynumber);
		document.getElementById("next_"+id).style.display="";
	}else{
		document.getElementById("next_"+id).style.display="none";
		document.getElementById("money3_"+id).value="0";
	}
	isSaveMx = false;
}

//检测下次回款日期
function checkReminDate(ctype)
{
	var isSub=true;
	$("#money1Tip").html("");
	if (ctype == 3)
	{//合并收款
		$(".htlistData").each(function()
			{
				if (isSub)
				{				
					id = $(this).attr("name").replace("ht_","");
					oldmoney = document.getElementById("ht_"+id).defaultValue.replace(",","");
					money_one =$(this).val();
					var checkYh=false ;
					if ($("#payback_"+id).find("#yhmoney").size()>0)
					{
						var yhMoney=$("#payback_"+id).find("#yhmoney").val();
						var maxMoney = $("#payback_"+id).find("#yhmoney").attr("max");
						if (parseFloat(yhMoney)!=parseFloat(maxMoney))
						{
							checkYh = true;
						}
					}
					if (money_one.replace(" ","")!="")
					{
						if ((parseFloat(oldmoney)!=parseFloat(money_one) || checkYh ) && isSub)
						{
							if(document.getElementById("daysdate1_"+id+"Pos").value == "")
							{
								alert("请填写下次回款日期");
								isSub = false ;
							}
						}
					}
				}
			}
		)
	}
	else 
	{
		var moneyall=document.getElementById("money1");
		var checkYh=false ;
		var yhmoneyObj = document.getElementById("yhmoney");
		if (yhmoneyObj)
		{
			if (parseFloat(yhmoneyObj.value)!=parseFloat(yhmoneyObj.getAttribute("max")))
			{
				checkYh = true;
			}
		}
		var oldmoney = moneyall.defaultValue.replace(",","");
		if ((parseFloat(oldmoney)!=parseFloat(moneyall.value) || checkYh) && isSub)
		{
			if(document.getElementById("daysOfMonth6Pos").value == "")
			{
				alert("请填写下次回款日期");
				isSub=false ;
			}
		}
		
	}
	if (isSub)
	{	
		$("input[name$='sort1']:checked").each(function(){
			sort1=$(this).attr("value");
			if (sort1=="2")
			{
				var yeMoney=0;
				var money=0;
				if ($("input[name$='yelist']:checked").size()==0)
				{
					alert("请选择预收款并正确填写预收款金额！");
					isSub=false ;
				}
				else 
				{
				    $("input[name$='yelist']:checked").each(function () {
				        yelistid = $(this).attr("value");
				        money = $("#ye_" + yelistid).attr("value");
				        yeMoney += parseFloat(money);
				    })

				    yeMoney = parseFloat(FormatNumber(yeMoney, window.sysConfig.moneynumber)) * 1.00;

					money1 = $("#money1").attr("value");
					if (yeMoney<parseFloat(money1))
					{
						alert("预收款小于本次收款总额，请继续使用预收款！");
						isSub=false ;
					}
					else if (yeMoney>parseFloat(money1))
					{
						alert("预收款大于本次收款总额，请减少使用预收款！");
						isSub=false ;
					}
				}
			}
		})
	}
	if (isSub)
	{
		if (Validator.Validate(document.getElementById("demo"),2)){
			document.getElementById("demo").submit();
		}
	}		
}
//打开编辑明细
function editMx(id, type, lvType) {
    if (!!!lvType)
        lvType = "ht";
	if(typeof(type) == "undefined"){type = 1;}
	var newplanmoney1 = parseFloat($("#" + lvType + "_" + id).val().replace(",", ""));
	if ($("#isEditMx_"+id).val()=="1"){
		$('.paybackmx').html($("#payback_"+id).html());	
		if (type == 1) {
	        $('#w').window({
	            title: '产品明细',
	            width: 670,
	            height: 420,
	            closeable: true,
	            collapsible: false,
	            modal: true,
	            minimizable: false,
	            maximizable: false,
	            onClose: function () { resetMxMoney(id); },
	            onOpen: function () {
	                $("#btnDiv").show();
					$("#savebtn").unbind("click");
					$("#rebtn").unbind("click");
					$("#savebtn").bind("click",function(){saveEditMx(id)});
					$("#rebtn").bind("click",function(){$("#w").window("close");});
	            }
	        }).window('open');
	        $('.paybackmx').show();
	        updatemxmoney(newplanmoney1, id);
	    } else {	       
	        updatemxmoney1(newplanmoney1, id);
	        $('.paybackmx').hide();
	    }
	}
	else
	{		
		$.ajax({
			url:"GetPaybacklist.asp?paybackID="+id,
			success:function(r){
				$('.paybackmx').html(r);
				$("#payback_"+id).html(r);
				if (type == 1) {
					$('#w').window({
						title:'产品明细',
						width:670,
						height:420,
						closeable:true,
						collapsible:false,
						minimizable:false,
						maximizable:false,
						onClose:function(){resetMxMoney(id);},
						onOpen:function(){
							$("#btnDiv").show();
							$("#savebtn").unbind("click");
							$("#rebtn").unbind("click");
							$("#savebtn").bind("click",function(){saveEditMx(id)});
							$("#rebtn").bind("click",function(){$("#w").window("close");});
						}				
					}).window('open');
					$('.paybackmx').show();
					updatemxmoney(newplanmoney1, id);
					
				}else{
					updatemxmoney1(newplanmoney1, id);
					$('.paybackmx').hide();
				}				
				
			}
		});	
		$("#isEditMx_"+id).val(1);
	}
}

//还原合并收款编辑明细合同产品金额
function resetMxMoney(id)
{		
	var money1 = 0;
	var obj = null;
	if (isSaveMx){
		obj = $('.paybackmx');
	}else{
		obj = $("#payback_"+id);
	}
	obj.find(".mxlistData").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){
			if ($(this).attr("id")=="yhmoney"){
				money1 -= parseFloat(money_one);
			}else{
				money1 += parseFloat(money_one);
			}
		}
	})
	obj.find(".mxlistData_th").each(function(){
		money_one =$(this).val();
		if (money_one.replace(" ","")!=""){money1 -= parseFloat(money_one);}
	})
	document.getElementById("ht_"+id).value=FormatNumber(money1,window.sysConfig.moneynumber);
	$(".paybackmx").html("");
	sethbMoney(id);
}

function saveEditMx(id){
	var isSave= true ;
	$(".paybackmx").find(".mxlistData").each(function(){
		money_one =$(this).val();
		min = $(this).attr("min");
		max = $(this).attr("max");
		if (money_one.replace(" ","")!=""){
			var ts="";
			if (parseFloat(money_one)<parseFloat(min)||parseFloat(money_one)>parseFloat(max)){
				$(this).attr("style","color:red");
				if (parseFloat(money_one)<parseFloat(min)){
					ts="<br>不能小于"+FormatNumber(min,window.sysConfig.moneynumber);
				}else{
					ts="<br>不能大于"+FormatNumber(max,window.sysConfig.moneynumber);
				}
				isSave= false ;
			}
			$(".paybackmx").find("#ts_"+$(this).attr("name").replace("mx_","")).html(ts);
		}
	})
	isSaveMx = isSave;
	if (isSave){
		//$("#payback_"+id).html($('.paybackmx').html());
		$(".paybackmx").find("input").each(function(){
			$("#payback_"+id).find("#"+$(this).attr("id")).val($(this).val());
		})
		$("#w").window("close");
	}
}
//
function selectYSK(obj)
{
	if (obj.checked==true){
		document.getElementById("ye_"+obj.value).setAttribute("dataType","number");
	}else{
		document.getElementById("ye_"+obj.value).setAttribute("dataType","");
	}
}

function del(contract)
{
	var num_dot_xs = window.sysConfig.moneynumber;
	var money =parseFloat($("#ysMoney").val())-parseFloat($("#ht_"+contract).val());
	$("#yshtm").html("&nbsp;"+$("#bzintro").val()+FormatNumber(money,num_dot_xs)+'<input Name="bzintro" id="bzintro"  value="RMB"  type="hidden"><input type="hidden" Name="ysMoney" id="ysMoney"  value="'+money+'">');
	$("#ysMoney").val(money);
	var allmoney1 = parseFloat($("#money1").val());
	var delHtMoney = parseFloat($("#ht_"+contract).val())
	var newAllMoney = allmoney1 - delHtMoney
	$("#money1").val(FormatNumber(newAllMoney,num_dot_xs));
	$("#money1").attr("max",FormatNumber(newAllMoney,num_dot_xs));
	$("#money1").attr("msg",($("#money1").attr("min")=="0"?"金额必须大于0且小于等于":"金额不能大于")+FormatNumber(newAllMoney,num_dot_xs));
	$("#contract_"+contract).remove(); 
}


function chtotalMoney(lvType){
	var num_dot_xs = window.sysConfig.moneynumber;
	var newMoney1 = parseFloat($("#money1").val());
	var oldMoney1 = parseFloat($("#money1").attr("max"));
	var money = 0;
	var money1 = 0;
	if(newMoney1 > oldMoney1){
		$("#money1Tip").html(" 不能大于"+FormatNumber(oldMoney1,num_dot_xs));
		try{
			if($("#money1Tip").next().next().attr("id").indexOf("__ErrorMessagePanel")>-1){
				$("#money1Tip").next().next().html("");
			}
		}catch(e){}		
		return;
	}else{
	    $("#money1Tip").html("");
	}
  
    $("input[name^='" + lvType + "_']").each(function () {
		var newplanmoney1 = parseFloat($(this).val().replace(",", ""));
		var id = $(this).attr("id").replace(lvType + "_", "");
		var oldmoney = parseFloat($(this).attr("ymax"));
		var newMoney = newplanmoney1;
		money1 += parseFloat(oldmoney);
		if (parseFloat(money1) >= parseFloat(newplanmoney1)) {
			money = parseFloat(parseFloat(oldmoney) - (parseFloat(money1) - parseFloat(newMoney1))).toFixed(num_dot_xs)
			if (money > 0) {
				if(money>=oldmoney){
					newMoney = FormatNumber(oldmoney, num_dot_xs);
				}else{
					newMoney = FormatNumber(money, num_dot_xs);
				}				
			} else {
				newMoney = FormatNumber(0, num_dot_xs);
			}
		} else {
			newMoney = FormatNumber(oldmoney, num_dot_xs);
		}
		$(this).val(FormatNumber(newMoney, num_dot_xs));
		if (lvType == "mx")
		    setMoney(this);
		if (id != "yhmoney") {
		    chtotal2(id, 2, lvType);
		}
		if (oldmoney > newMoney) {
			var date1 = $("#date1_"+id).html();
			$("#daysdate1_"+id+"Pos").val(date1);
		}
	});
}

function chtotal2(id, type, lvType) {
	var num_dot_xs = window.sysConfig.moneynumber;
	var money1 = $("#" + lvType + "_" + id).val().replace(",", "");
	if(money1 == ""){
		money1 = 0;
		$("#" + lvType + "_" + id).val(FormatNumber(money1, num_dot_xs));
	} else {
	    money1 = parseFloat($("#" + lvType + "_" + id).val().replace(",", ""));
	}	
	var oldmoney = parseFloat($("#" + lvType + "_" + id).attr("ymax").replace(",", ""));
	var moneyall = 0;
	if(money1 > oldmoney){
		alert("大于应收金额！");
		money1 = oldmoney;
		$("#" + lvType + "_" + id).val(oldmoney);
	}
	$("input[name^='" + lvType + "_']").each(function () {
		var currMoney = parseFloat($(this).val().replace(",",""));
		moneyall += currMoney;
	});
	if(type == 1){ $("#money1").val(FormatNumber(moneyall, num_dot_xs)); }
	if(money1 != oldmoney){
		$("#money3_"+id).val(FormatNumber(oldmoney-money1,num_dot_xs));
		$("#next_"+id).show();
	}else{
		$("#money3_"+id).val(0);
		$("#next_"+id).hide();
	}
	editMx(id, 2, lvType)
}

//操作ifram 弹框table数据
function updatemxmoney(newplanmoney1, id) {
    var money = 0;
    var money1 = 0
    var yhmoney = document.getElementById("yhmoney");
    if (yhmoney) {
        var money_one = $(".neecCheckTd input[id='yhmoney']").val();
        if (money_one.replace(" ", "") != "") {
            newplanmoney1 = parseFloat(parseFloat(newplanmoney1) + (parseFloat(money_one))).toFixed(window.sysConfig.moneynumber);
        }
    }
    //判断是否获取到计划付款金额
    $(".neecCheckTd").find("tr").not(':eq(0)').each(function () {
		var moneyInput = $(this).find("td:last").find("input");
		if (typeof (moneyInput.attr("max")) != "undefined" && moneyInput.attr("id") != "yhmoney") {
            //产品明细付款金额
            var oldmoney = moneyInput.attr("max");
            var oldnum = $(this).find("td").eq(4).find("input").attr("max");
            money1 += parseFloat(oldmoney);

            if (parseFloat(money1) >= parseFloat(newplanmoney1)) {
                money = parseFloat(parseFloat(oldmoney) - (parseFloat(money1) - parseFloat(newplanmoney1))).toFixed(window.sysConfig.moneynumber)
                if (money > 0) {
                    moneyInput.val(FormatNumber(money, window.sysConfig.moneynumber));
                }
                else {
                    moneyInput.val(FormatNumber(0, window.sysConfig.moneynumber));
                }
            }
            else {

                moneyInput.val(FormatNumber(oldmoney, window.sysConfig.moneynumber));
            }
            //计划付款金额为0
            if (parseFloat(newplanmoney1) == 0) {
                moneyInput.val(FormatNumber(0, window.sysConfig.moneynumber));
            }
            var newnum = FormatNumber(parseFloat(moneyInput.val()) / parseFloat(oldmoney) * parseFloat(oldnum), window.sysConfig.floatnumber);
            $(this).find("td").eq(4).find("input").val(newnum)
            }
        });


}


//操作主单改变数值改变隐藏table（数据源）
function updatemxmoney1(newplanmoney1,id) {
    var money = 0;
    var money1 = 0
    var yhmoney = document.getElementById("yhmoney");
    if (yhmoney) {
		var money_one = "0";
		if($("#payback_" + id + "").find("input[id='yhmoney']").size()>0){
			money_one = $("#payback_" + id + "").find("input[id='yhmoney']").val();
		}
        if(money_one==""){money_one = "0";}
        if (money_one.replace(" ", "") != "") {
            newplanmoney1 = parseFloat(parseFloat(newplanmoney1) + (parseFloat(money_one))).toFixed(window.sysConfig.moneynumber);
        }
    }
    //判断是否获取到计划付款金额e
    $("#payback_" + id).find("tr").not(':eq(0)').each(function () {
		var moneyInput = $(this).find("td:last").find("input");
		if (typeof (moneyInput.attr("max")) != "undefined" && moneyInput.attr("id") != "yhmoney") {
            //产品明细付款金额
            var oldmoney = moneyInput.attr("max");
            var oldnum = $(this).find("td").eq(4).find("input").attr("max");
            money1 += parseFloat(oldmoney);

            if (parseFloat(money1) >= parseFloat(newplanmoney1)) {
                money = parseFloat(parseFloat(oldmoney) - (parseFloat(money1) - parseFloat(newplanmoney1))).toFixed(window.sysConfig.moneynumber)
                if (money > 0) {
                    moneyInput.val(FormatNumber(money, window.sysConfig.moneynumber));
                }
                else {
                    moneyInput.val(FormatNumber(0, window.sysConfig.moneynumber));
                }
            }
            else {

                moneyInput.val(FormatNumber(oldmoney, window.sysConfig.moneynumber));
            }
            //计划付款金额为0
            if (parseFloat(newplanmoney1) == 0) {
                moneyInput.val(FormatNumber(0, window.sysConfig.moneynumber));
            }
            var newnum = FormatNumber(parseFloat(moneyInput.val()) / parseFloat(oldmoney) * parseFloat(oldnum), window.sysConfig.floatnumber);
			$(this).find("td").eq(4).find("input").val(newnum)
        }
    });


}
