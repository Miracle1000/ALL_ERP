 //项目添加js函数
 function onProcChange(Selectbox, ord) {
    var procid = Selectbox.value;
    document.getElementById("ProcNodeArea").style.display=procid > 0? "" : "none";
    if(procid > 0) {
		var url = "ProcInit.asp?ord="+escape(ord)+"&ProcId=" +  procid + "&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	    xmlHttp.open("GET", url, false);
        xmlHttp.send()
        document.getElementById("ProcNodeData").innerHTML = xmlHttp.responseText;
	}
    else {
        document.getElementById("ProcNodeData").innerHTML = "";
	}
}

function showHide(img, id) {
	img.src = img.src.indexOf("5.gif") > 0 ? "../images/smico/7.gif" : "../images/smico/5.gif";
	var tb = document.getElementById("ProcNodeTable");
	for (var i = 1; i < tb.rows.length ; i++ )
	{
		var tr = tb.rows[i];
		if(tr.getAttribute("parent")==id) {
			tr.style.display = (tr.style.display == "none" ? "" : "none");
		}
	}

}
//暂时不处理流程改变的检验
function checkProcChange() {
	return true
}

window.onBeforeValidate = function() {
	var ds = document.getElementsByName("N_TimeBegin");
	for (var i = 0 ; i < ds.length ; i ++ )
	{
		var di = ds[i];
		var id = di.id.replace("v_4_", "v_5_");
		var di2 = document.getElementById(id);
		if(di.value.length > 0 && di2.value.length > 0 && di.value > di2.value) {
			di2.value = "";
			di2.setAttribute("msg", "必须大于开始时间");
			setTimeout("document.getElementById('" + di2.id + "').value = ''", 100);
		}

	}
	return true;
}

window.onAfterValidate = function() {
	var ds = document.getElementsByName("N_TimeEnd");
	for (var i = 0 ; i < ds.length ; i ++ )
	{
		ds[i].setAttribute("msg", "日期格式不正确");
	}
	return true;
}

//变更、执行、审批的js函数
 function GetlogNextNodes(logid, nextnodes, goType) {
	goType = (goType==-1 ? -1 : 1); // -1表示往回推进, 1表示往下推进 
	ajax.regEvent("GetlogNextNodes", "ProcInit.asp");
	ajax.addParam("logid", logid);
	ajax.addParam("nextnodes", nextnodes);
	ajax.addParam("goType", goType);
	//保存当前编辑值
	var inputs =  document.getElementsByName("N_ID");
	var vars = new Array();
	for (var i = 0; i < inputs.length; i++ )
	{
		var id = inputs[i].id;
		vars[vars.length] = [inputs[i].value, $ID(id.replace("i",1)).value, $ID(id.replace("i",2)).value, $ID(id.replace("i",3)).value, $ID(id.replace("i",4)).value,  $ID(id.replace("i",5)).value];
	}
	//更新下级阶段
    document.getElementById("ProcNodeData").innerHTML  =  ajax.send();
	//回写编辑的值
	var inputs =  document.getElementsByName("N_ID");
	for (var i = 0; i < inputs.length; i++ )
	{
		var id = inputs[i].id;
		for (var ii=0; ii < vars.length; ii++)
		{
			if(vars[ii][0]== inputs[i].value) {
				$ID(id.replace("i",1)).value = vars[ii][1];
				$ID(id.replace("i",2)).value = vars[ii][2];
				$ID(id.replace("i",3)).value = vars[ii][3];
				$ID(id.replace("i",4)).value = vars[ii][4];
				$ID(id.replace("i",5)).value = vars[ii][5];
			}
		}
	}
}

function loadnextnodes(goType){
	var ems = document.getElementsByName("nextnodes");
	var nodes = new Array();
	for (var i = 0; i < ems.length ; i++ )
	{
		if(ems[i].checked) {
			nodes[nodes.length] = ems[i].value;			
		}
	}
	GetlogNextNodes($ID("__ord").value,nodes.join(","),goType);
	autoSetTime();
}
//删除下级节点事件
function delnextnode(ord) {
	$ID("nextnodes" + ord).checked = false;
	loadnextnodes();
}

//节点状态改变
window.statuschance = function() {
	var status = 0;
	var ems = document.getElementsByName("status");
	for (var i = 0; i < ems.length ; i++ )
	{
		if(ems[i].checked==true) {
			status = ems[i].value*1;
			break;
		}
	}
	bill.groupvisible("NextProc", (status==7 || status==2)); //7=终止 2=完成
	if($ID("execstatusv")) {
		$ID("execstatusv").style.visibility = (status == 9 ? "visible" : "hidden")
		$ID("MustBillResult").value = (status == 9 ? "1" : $ID("MustBillResult").getAttribute("hidevalue"));
	}
	if($ID("ProcNodeData")){
		if (status == 9 || status == 0 || status == 1){
			var arr_nextNode = $("input[name='nextnodes'][disabled=false][checked=true]");
			if (arr_nextNode.length>0){
				$("input[name='nextnodes'][disabled=false][checked=true]").attr("checked",false);
				$ID("ProcNodeData").innerHTML = ""
			}
		}
	}
}

if(window.bill) {
	window.bill.onPageLoad = function() {
		window.statuschance();
		GetlogNextNodes($ID('__ord').value,'');
	}
}

//审批结果修改
window.spstatuschance =  function (statue) {
	ajax.regEvent("spstatuschance");
	ajax.addParam("status",$ID("status5").checked ? 5 : 4);
	ajax.addParam("log", $ID('__ord').value);
	$ID("NextNodesHtml").innerHTML = ajax.send();
	$ID("nextitems_tit").innerHTML = $ID("status5").checked ? "下级阶段：" : "上级阶段：";
	GetlogNextNodes($ID('__ord').value,'',statue==5?1:-1); //避免晃动
}

//html字段校验
window.onbillcellValid = function(cell) {
	var id = cell.id;
	switch(id) {
		case "@CNextNodesHtml_cel":
			var sboxs = document.getElementsByName("status");
			for (var i = 0; i < sboxs.length ; i++)
			{
				if(sboxs[i].checked) {
					bill.showValidMsg(cell, "", "red");
					return true;
				}
			}
			bill.showValidMsg(cell, "必填", "red");
			return false;
		case "@CLinkBillHtml_cel":
			if($ID("MustBillResult")) {
				if($ID("MustBillResult").value=="0") {
					bill.showValidMsg(cell, "还有关联栏目未完成", "red");
					return false;
				}
			}
			return true;
		default:
			return true;
	}
}

//自动更改阶段的开始、截止时间
$(function(){
	try{
		$("#EndTime_0").get(0).onpropertychange = function() { 
			autoSetTime();
		};
	}catch(e){}
}); 

function autoSetTime(){
	var autoTime = "";	
	var i;
	var execStatus = 0;
	try{
		if($ID("status2").checked || $ID("status7").checked){execStatus = 1;}
	}catch(e){}
	if(execStatus == 1){
		var ptime = $("#EndTime_0").val();
		var arr_nextnodes = $("input[name=nextnodes][checked]");
		var gq, beginTime, endTime;
		for(i = 1; i<=arr_nextnodes.length; i++){
			if($("#st_"+i).attr("disabled")==false){
				autoTime = $("#st_"+i).val();
				if(autoTime=="1"){
					gq = Number($("#v_1_"+i).val());
					beginTime = $("#v_4_"+i).val();
					endTime = $("#v_5_"+i).val();
					if(ptime!=""){
						beginTime = ptime;
						$("#v_4_"+i).attr("value",beginTime);

						if(gq>0){
							endTime = addDate(beginTime, gq);
							$("#v_5_"+i).attr("value",endTime);
						}
					}		
				}
			}
		}
	}
}

function addDate(dtDate,NumDay){ 
	var date = new Date(dtDate.replace(/\-/g, "/")) 
	lIntval = parseInt(NumDay)//间隔 
	date.setDate(date.getDate() + lIntval) ;
	var month, day, hour, minute, seconds;
	month = date.getMonth()+1;
	day = date.getDate();
	hour = date.getHours();
	minute = date.getMinutes();
	seconds = date.getSeconds();
	if(month<10){month = "0"+month;}
	if(day<10){day = "0"+day;}
	if(hour<10){hour = "0"+hour;}
	if(minute<10){minute = "0"+minute;}
	if(seconds<10){seconds = "0"+seconds;}
	return date.getYear() +'-' +  month + '-' +day+ ' '+ hour+':'+minute+':'+seconds; 
}  


