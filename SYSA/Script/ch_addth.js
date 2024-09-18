
function check_kh(ord) {	//查看关联客户信息
	var resTxt, arr_res
	ajax.regEvent("getTelInfo");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		resTxt = r
		arr_res = resTxt.split("{|}");
		if(arr_res[0]=="0"){
			app.Alert("没有关联的客户，请重新选择");
			return;
		}else if(arr_res[0]=="1"){
			$ID("companyOrd").value = ord
			$ID("khmc").value = arr_res[1];
			$ID("W3").value = arr_res[3];
			$ID("gatestreeselbox").value = arr_res[4];
		}else{
			app.Alert("未知错误，请重试");
			return;
		}
		
	}
}


function frameResize(){
	document.getElementById("mxlist").style.height=(I3.document.getElementById("mxPos").offsetTop+76)+"px";
}

function CheckMxlist(ord){
	ajax.regEvent("CheckMxlist","../contractth/eventlistadd.asp");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		if(!isNaN(r)){
			return r;
		}else{
			app.Alert("未知错误");
			return 0;
		}
	}else{
		app.Alert("未知错误");
		return 0;
	}
}

function GetMxAttr1(ord,funName){			//查看当前添加的明细中的客户，参数为当前退货单的id
	ajax.regEvent(funName,"../contractth/eventlistadd.asp");
	$ap("ord",ord)
	var r = ajax.send();
	if(r != ""){
		if(!isNaN(r)){
			return r;
		}else{
			app.Alert("未知错误");
		}
	}else{
		app.Alert("未知错误");
	}
}


function checkSLForm() {
    try { var editor = document.getElementById("eWebEditor1"); editor.contentWindow.syncText() } catch (e) { }
	var obj=document.getElementById("demo");
	if (Validator.Validate(obj,2))
	{	
		var thid = $ID("thid").value;
		if(thid!=""){
			ajax.regEvent("checkSLid");
			$ap("thid",thid);			
			var r2 = ajax.send();
			if(r2 != "0"){
				if(r2 == "2"){
					app.Alert("退货编号【"+thid+"】已存在");
				}else{
					app.Alert("未知错误");
				}
				canSubmit = false ;
				return false ;	
			}			
		}
		/*BUG 5655 Sword 2014-9-1 销售退货添加和修改页面问题 
		if ($("input[name=complete1]:checked").size()==0)
		{
			app.Alert("请设置退货状态");
			return false ;	
		}*/
		var canSubmit = true ;
		ajax.regEvent("checkMxCount");
		$ap("thord",window.billTHrd);
		var r = ajax.send();
		var mxCount = 0;
		if(r == "0"){
				app.Alert("请添加退货明细");
				canSubmit = false ;
				return false ;
		}

		var cateid = $ID("W3").value;//销售人员
		var Contracttcateid = GetMxAttr1(window.billTHrd, "getContractth");
		var currTel = $ID("companyOrd").value;
		var dataTel = GetMxAttr1(window.billTHrd,"getMxCompany1");
		if(currTel!=""){ currTel = Number(currTel); }
		if(dataTel!=""){ dataTel = Number(dataTel); }
		if(dataTel>0 && currTel != dataTel){
			app.Alert("关联客户与退货明细不符");
			canSubmit = false ;
			return false ;
		}

		if (Contracttcateid > 0 && cateid != Contracttcateid) {
		    app.Alert("关联销售人员与退货明细不符");
		    canSubmit = false;
		    return false;
		}
		var currBz = $ID("bz").value;
		var dataBz =  GetMxAttr1(window.billTHrd,"GetMxBz1");
		if(currBz!=""){ currBz = Number(currBz); }
		if(dataBz!=""){ dataBz = Number(dataBz); }
		if(dataBz>0 && currBz != dataBz){
			app.Alert("退货明细与币种不符");
			canSubmit = false ;
			return false ;
		}
		var checkPass = CheckMxlist(window.billTHrd);
		if (checkPass=="1")
		{
			app.Alert("有明细已经超出合同可退数量");
			canSubmit = false ;
			return false ;
		}

		if (canSubmit ==true)
		{
			var moneyall = document.getElementById("moneyall").value;
			spclient.GetNextSP('contractth',window.billTHrd,moneyall,0,0,1);
			return false;
		}
	}
}

function selectHtCate() {
    var w = "w";
    var cateid = document.getElementById("htcateid").value;
    var url = "../work/correctall_person.asp?cateid=" + cateid + "&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage_selectCate(w);
    };
    xmlHttp.send(null);
}

function updatePage_selectCate(w) {
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        document.getElementById("" + w + "").innerHTML = response;
        var inttop = (55 + document.documentElement.scrollTop + document.body.scrollTop) + "px";
        $('#' + w + '').show();
        $('#' + w + '').window({ top: inttop });
    }
}
function select_person(khord, ord, strvalue) {
    document.getElementById("htcateid").value = ord;
    document.getElementById("htcatename").value = strvalue;
    $('#w').window('close');
}
//销售人员
window.gateTreeSearchClickTH = function (box, evt) {

        var l = parseInt(((window.screen.availWidth || window.screen.width) - 600) / 2) + "px";
        var ismulti = box.getAttribute("ismulti") || 0;
        var sid = box.getAttribute("SID") || 5;
        var canselectOrgSid = box.getAttribute("CanSelectOrgsid") || 0;
        /*  SID含义如下： 
			dlg_档案列表_正常 = 0,
			dlg_产品分类选择 = 1,
			dlg_仓库选择 = 2,
			dlg_档案列表_正常_带选项 = 3,
			dlg_账号列表_检索 = 4,
			dlg_账号列表_指派 = 5,
			dlg_账号列表_统计 = 6,
			dlg_账号列表_共享 = 7,
			dlg_账号列表_所有 = 8,
		*/
        window.open("../../SYSN/view/init/home.ashx?ismulti=" + ismulti + "&__sys_msgid=sdk_sys_AutoCompleteHelperURLPage&SID=" + sid + "&"
			+ "dbname=W3&__displayuitype=urlpage&__title=人员选择&__ac_srcobjid=W3"
			+ "&__canselectorgs=" + canselectOrgSid, "asasasxsdsd", "width=600px; height=500px; left=" + l + "px; top=150px");
        window.CGateTreeResult();
}


function setCateid(ord, strvalue) {
    document.getElementById("W3").value = ord;
    document.getElementById("gatestreeselbox").value = strvalue;
}
function choose(type) {
    document.getElementById("W3").value = 0;
    document.getElementById("gatestreeselbox").value = "无";

}