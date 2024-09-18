function frameResize1(){
    document.getElementById("mxlist").style.height = I3.document.body.getElementsByTagName('TABLE')[0].scrollHeight + "px";
    window.setTimeout("$('#mxlist').css('height',I3.document.body.getElementsByTagName(\"TABLE\")[0].scrollHeight + 20);", 200);
}

function frameResize2(){
    document.getElementById("hklist").style.height = P3.document.body.getElementsByTagName('TABLE')[0].scrollHeight + "px";
    //window.setTimeout("$('#hklist').css('height',P3.document.body.getElementsByTagName(\"TABLE\")[0].scrollHeight + 20);", 200);
}

var XMlHttp = GetIE10SafeXmlHttp();

function selectHtCate(BillType){
	var w="w";
	var cateid = document.getElementById("htcateid").value;
	var url = "../work/correctall_person.asp?BillType=" + BillType + "&cateid=" + cateid + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
	XMlHttp.open("GET", url, false);
	XMlHttp.onreadystatechange = function(){
		updatePage_selectCate(w);
	};
	XMlHttp.send(null);  
}

function updatePage_selectCate(w) {
	if (XMlHttp.readyState == 4) {
		var response = XMlHttp.responseText;
		document.getElementById(""+w+"").innerHTML=response;	
		var inttop=(55+document.documentElement.scrollTop+document.body.scrollTop)+"px";
		$('#'+w+'').show();
		$('#'+w+'').window({top:inttop});
	}
}

function select_person(khord,ord,strvalue){
	document.getElementById("htcateid").value = ord;
	document.getElementById("htcatename").value = strvalue;
	$('#w').window('close');
}

function callcompany(str ,canedit , fromtype){
	var cgord=document.getElementById("caigou").value;
	if (str==""){canedit=0;}
    document.getElementById("mxlist").src="../event/cgmx.asp?Ismode=1&ID=company&company="+str+"&caigou="+cgord + "&canedit="+canedit+"&fromtype="+fromtype;
	if (!isNaN(str)){
	    check_kh(str, 'caigou_add', fromtype);
	}
	$("#select_gys").val(str);
	if (str=="0"){
		$("#khmc").show();
	}else{
		$("#khmc").hide();
	}

}

function check_kh(ord, from, fromtype) {
	from = from || '';
	var url = "../event/search_gys.asp?ord=" + escape(ord) + "&from=" + from + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100) + "&fromtype=" + fromtype;
	XMlHttp.open("GET", url, false);
	XMlHttp.onreadystatechange = function(){
	    updatePage2(fromtype);
	};
	XMlHttp.send(null);
}

function updatePage2(fromtype) {
  if (XMlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
    khmc.innerHTML = response;
    if (fromtype == "0" || (fromtype == "5" && (document.getElementById("title").value.length == 0 || document.getElementById("title").value == document.getElementById("htid").value)) || window.currForm.length > 0) {
        updatePage3();//直接添加采购单的时候需要进行采购主题的重新赋值
    }
    else {
        XMlHttp.abort();
    } 
  }
}

function updatePage3() {
	var company1 = document.getElementById("companyname").value;
	var u_name = document.getElementById("htid").value;
	var title = document.getElementById("title");
	var zt=company1+u_name
	title.value=zt;
	XMlHttp.abort();
}

function doSave(ord , status) {
	var fromobj=document.getElementById("demo");
	if(Validator.Validate(fromobj,2) && checklimit() && DelUnusedFilesBeforeSubmit()&& checkQualifications()){		
		var mxobj=document.getElementById("mxlist").contentWindow.document.getElementsByTagName("table")[0];
		if(mxobj.rows.length<3){alert('请添加产品明细！');return false;}
		var moneyobj=document.getElementById("moneyall");
		var fkplan = jQuery("select[name='plan']").val();
		if(fkplan == "5"){
			var fqfkMoney = jQuery("#hklist").contents().find(".fqfkMoney");
			if(fqfkMoney.size()==0){
				alert('请添加分期付款计划！');return false;
			}else{
				var sumfqMoney = 0;
				fqfkMoney.each(function(){
					sumfqMoney += parseFloat(jQuery(this).html().replace(/\,/g,""))
				});
				sumfqMoney = parseFloat(formatNumDot(sumfqMoney,window.sysConfig.moneynumber));
				if(sumfqMoney!=parseFloat(moneyobj.value.replace(/\,/g,""))){
					alert("采购单金额与分期付款计划不一致")
					return;
				}
			}
		}
		var json = {};
		json.ord = ord;
		json.money1 = moneyobj.value;
		var aj = $.ajax({
			type:'post',
			url:'checkCGMXPrice.asp',
			cache:false,  
			dataType:'html', 
			data:json,
			success: function(data){
				if (data==""){
					fromobj.submit();//不需要审批
				}else if (data.indexOf("ok=")==0){
					var sort1 = document.getElementById("sort1").value;//--采购分类
					if (sort1 == ""){sort1 = 0;}
					spclient.GetNextSP('caigou', 0, moneyobj.value, sort1, 0 ,"",fromobj);
				}else if (data.indexOf("err=")==0){
					alert(data.replace("err=",""));
				}
			},
			error:function(e){
				 (e.responseText);
			}
		});
	}
}

function checklimit(){
	var paylimits=document.getElementById("paylimit").value;
	//是否开启限制策略
	if (paylimits=="1"){
		document.getElementById("limittips").innerHTML="";
		//金额限制策略 (按金额数量限制)
		if(document.getElementById('limit1').checked==true){  
			var limitmoneys=document.getElementById("limit3").value;    
			if (isNaN(limitmoneys)||limitmoneys.toString().length==0||limitmoneys==null){
				document.getElementById("limittips").innerHTML="请输入付款金额";
				return false;
			}else{
				if (parseFloat(limitmoneys)<0||parseFloat(limitmoneys)>999999999999.9999){
					document.getElementById("limittips").innerHTML="付款金额不正确";
					return false;
				}else{
					return true;
				}
			}
		}else{
			//按付款比例限制
			var limitpercents=document.getElementById("limit4").value;    
			if (isNaN(limitpercents)||limitpercents.toString().length==0||limitpercents==null){
				document.getElementById("limittips").innerHTML="请输入付款比例";
				return false;
			}else{
				if (parseFloat(limitpercents)<0||parseFloat(limitpercents)>100){
					document.getElementById("limittips").innerHTML="付款比例不正确";
					return false;
				}else{
					return true;
				}
			}
		}
   }else{
		return true;
   }
}
