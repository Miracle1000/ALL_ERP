
var num_dot_xs = window.sysConfig.floatnumber;	//系统小数位数

//修改质检数量的值
function setNumQC(txt){	
	txt.value=txt.value.replace(/[^\d\.]/g,'');
	var NumQC = parseFloat(txt.value);
//	var NumQCid = txt.id.toString();

	if ($("#QC_Num").val()==0 || NumQC>$("#QC_Num").val() )	//txt.getAttribute("max")==0
	{
		alert("请修改质检信息的质检数量！");
	}

/*	var tn = NumQCid.replace("NumQC","");
	var Num1 = parseFloat(document.getElementById("yNum1"+tn).value);
	var QCType = document.getElementById("QCType"+tn).value;
	if(QCType==""){
		QCType = -1;	
	}else{
		QCType = parseFloat(QCType);
	}
	if(NumQC>Num1){
		NumQC = Num1;
		document.getElementById("NumQC"+tn).value = NumQC;
	}else{
		if(QCType == 0){
			NumQC = Num1;
			document.getElementById("NumQC"+tn).value = NumQC;
		}
	}
	checkDot('NumQC'+tn,num_dot_xs);
	NumQCChance(tn)
*/
}

//到货数量改变后
function Num1Chance(tn){

	tn = parseFloat(tn);
	var Num1 = parseFloat(document.getElementById("NumQC"+tn).value);
	var yNum1 = parseFloat(document.getElementById("yNum1"+tn).value);

	if(Num1>yNum1){
		Num1 = yNum1;
		document.getElementById("NumQC"+tn).value = Num1;
	}else if(Num1>0 && Num1<yNum1){	
		var mxAll = parseFloat(document.getElementById("mxAll").value);	
		var qctable = document.getElementById("content3");
		var nowtx = document.getElementById("tr"+tn).rowIndex;
		document.getElementById("Result"+tn).value = "";
		var newQCR = document.getElementById("QCR"+tn).innerHTML;
		newQCR = newQCR.replace(" selected","");
		document.getElementById("QCR"+tn).innerHTML = newQCR;

		if(nowtx==mxAll){
			addRow(-1,tn);
		}else if(nowtx<mxAll){
			var index = mxAll+1;
			addRow(index,tn);
		}
	}	
}

//修改质检信息的质检类型
function setTypeQc(txt,obj){
	var select = obj[0];

	if (parseFloat(txt.value) == parseFloat($("#CountNum").val()) && parseFloat(txt.value)!=0)
	{
		for(var i=0; i<select.options.length; i++){
		    if(select.options[i].value == '0'){
				select.options[i].selected = true;   
		        break;
		    }
		}
	}else if(parseFloat(txt.value) < parseFloat($("#CountNum").val()) && parseFloat(txt.value)>0){
		for(var i=0; i<select.options.length; i++){
		    if(select.options[i].value == '1'){
				select.options[i].selected = true;   
		        break;
		    }
		}
	}
/*	else{
		for(var i=0; i<select.options.length; i++){
		    if(select.options[i].value == ''){
				select.options[i].selected = true;   
		        break;
		    }
		}
	}
*/
}

//修改质检数量的值
function setNum1(txt){
	var mxAll = parseFloat($("#mxAll").val());
	var j_num = 0;

	for(i=1;i<=mxAll;i++){
		j_num = j_num + parseFloat($("#NumQC"+i).val());
	}
	j_num = MRound(j_num);
	if (parseFloat(txt.value)>parseFloat($("#CountNum").val()))
	{
		alert("质检数量不能大于到货数量！");
		txt.value=$("#CountNum").val();
	}
	/*	else if (parseFloat(txt.value)<parseFloat(j_num))
	{
		if(confirm("您修改的质检数量小于明细总数量，将删除以前的质检记录，确定删除吗?")){
			Ajaxfresh();//重新载入质检明细
		}
		else{
			txt.value=j_num;
		}
	}
	*/
	if (event.keyCode == 13) {
		txt.blur();
	}else{
		txt.value=txt.value.replace(/[^\d\.]/g,'');
	}

	checkDot('QC_Num',num_dot_xs);

	setTypeQc(txt,$("#QC_Type"));

	if (mxAll == 1)
	{
		$("#NumQC1").val(txt.value);
		$("#NumQC1").attr("max",txt.value);
		$("#yNum11").val(txt.value);
	}
	else{
		if (parseFloat(txt.value) > parseFloat(j_num))
		{
			var k = parseFloat(txt.value) - parseFloat(j_num);
			setAddRow(mxAll,k);
			var POP = 0;
			if(txt.value != 0 && parseFloat($("#QCOKnum").val()) > 0){
				POP = MRound(parseFloat($("#QCOKnum").val())/parseFloat(txt.value)*100);		
			}
			$("#QC_POP").val(POP);
		}
	}

	SetAllInputText();

}

function setAddRow(mxAll,newyNum1){
	var ajax_id = $("#ajax_id").val().split(",");

	var qctable = document.getElementById("content3");
	var countCell=qctable.rows.item(0).cells.length; 
	var newtr = qctable.insertRow(mxAll+1);
	
	var tn2 = mxAll +1		//新tn值
	var newQCR = document.getElementById("QCR"+mxAll).innerHTML;
	var rp = document.getElementById("QCR"+mxAll).getElementsByTagName("select")[0].name;
	newQCR = newQCR.replace(" selected","").replace(rp,"QCRank"+tn2).replace(rp,"QCRank"+tn2);
	document.getElementById("mxAll").value = tn2;
	newtr.id = "tr"+tn2;
	newtr.className = "blue2";

	var url = "AjaxGetExtended.asp?t=1&ajaxid="+ajax_id[0]+"&ajaxid2="+ajax_id[1]+"&ajaxid3=" + tn2;
	var r ="";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			r = xmlHttp.responseText.split("{^}");
			//if(r==""){
			//	alert("获取明细数据失败！");	
			//}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  

	for(var i=0;i<countCell;i++){
		var cell = newtr.insertCell(i);
		cell.height = 27;
		cell.width = "10%";
		if(i==0){
			cell.innerHTML="<div align=\"center\">"+tn2+"</div>";
		}else if(i==1){
			cell.innerHTML="<div align=\"center\"><input type=\"text\" name=\"NumQC"+tn2+"\" id=\"NumQC"+tn2+"\" value=\""+newyNum1+"\" size=\"6\" onKeyUp=\"setNumQC(this)\" onBlur=\"Num1Chance("+tn2+")\" onpropertychange=\"if(this.value.match(/[^\\d\\.]/g)){setNumQC(this)}\" dataType=\"Range\" min=\"0.0001\" max=\""+newyNum1+"\"  msg=\"质检数量须大于0\"> <span class=\"red\">*</span><input type=\"hidden\" name=\"qclist\" value=\"0\"><input type=\"hidden\" name=\"yNum1\" id=\"yNum1"+tn2+"\" value=\""+newyNum1+"\"></div>";
		}else if(i==countCell-2){
			cell.innerHTML="<div align=\"center\"><select name=\"Result"+tn2+"\" id=\"Result"+tn2+"\" dataType=\"Limit\" min=\"1\" msg=\"请选择\" onChange=\"ResultYesNo(this,"+tn2+")\"><option value=\"\">请选择</option><option value=\"1\">合格</option><option value=\"0\">不合格</option></select> <span class=\"red\">*</span></div>";
		}else if(i==countCell-1){
			cell.innerHTML="<div align=\"center\" id=\"QCR"+tn2+"\">"+newQCR+"</div>";
		}else if(i>1 && i<countCell-2){
			cell.innerHTML=r[i-2];
		}else{
			cell.innerHTML="";
		}
	}
}

function Ajaxfresh() {
	var ajax_id = $("#ajax_id").val().split(",");
	var url = "AjaxfreshMx.asp?t=1&qc_id="+ajax_id[0]+"&CurrBookID="+ajax_id[1];
	var r ="";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			r = xmlHttp.responseText;
			if(r==""){
				alert("获取明细数据失败！");	
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);
	
	$("#qcDIV").html(r);
}        

function addRow(ri,tn){
	var ajax_id = $("#ajax_id").val().split(",");

	var qctable = document.getElementById("content3");
	var countCell=qctable.rows.item(0).cells.length; 
	var newtr = qctable.insertRow(ri);
	
	var yNum1 = parseFloat(document.getElementById("yNum1"+tn).value);
	var lastNum1 = parseFloat(document.getElementById("NumQC"+tn).value);
	var newyNum1 = MRound(yNum1-lastNum1);	
	var mxAll = parseFloat(document.getElementById("mxAll").value);
	var tn2 = mxAll +1		//新tn值
	var newQCR = document.getElementById("QCR"+tn).innerHTML;
	var rp = document.getElementById("QCR"+tn).getElementsByTagName("select")[0].name;
	newQCR = newQCR.replace(" selected","").replace(rp,"QCRank"+tn2).replace(rp,"QCRank"+tn2);
	document.getElementById("mxAll").value = tn2;
	document.getElementById("yNum1"+tn).value = lastNum1;
	document.getElementById("NumQC"+tn).setAttribute("max",lastNum1);
	newtr.id = "tr"+tn2;
	newtr.className = "blue2";

	var url = "AjaxGetExtended.asp?t=1&ajaxid="+ajax_id[0]+"&ajaxid2="+ajax_id[1]+"&ajaxid3=" + tn2;
	var r ="";
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			if(xmlHttp.responseText !=""){
				r = xmlHttp.responseText.split("{^}");
				if(r==""){
					alert("获取明细数据失败！");	
				}
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  

	for(var i=0;i<countCell;i++){
		var cell = newtr.insertCell(i);
		cell.height = 27;
		cell.width = "10%";
		if(i==0){
			cell.innerHTML="<div align=\"center\">"+tn2+"</div>";
		}else if(i==1){
			cell.innerHTML="<div align=\"center\"><input type=\"text\" name=\"NumQC"+tn2+"\" id=\"NumQC"+tn2+"\" value=\""+newyNum1+"\" size=\"6\" onKeyUp=\"setNumQC(this)\" onBlur=\"Num1Chance("+tn2+")\" onpropertychange=\"if(this.value.match(/[^\\d\\.]/g)){setNumQC(this)}\" dataType=\"Range\" min=\"0.0001\" max=\""+newyNum1+"\"  msg=\"质检数量须大于0\"> <span class=\"red\">*</span><input type=\"hidden\" name=\"qclist\" value=\"0\"><input type=\"hidden\" name=\"yNum1\" id=\"yNum1"+tn2+"\" value=\""+newyNum1+"\"></div>";
		}else if(i==countCell-2){
			cell.innerHTML="<div align=\"center\"><select name=\"Result"+tn2+"\" id=\"Result"+tn2+"\" dataType=\"Limit\" min=\"1\" msg=\"请选择\" onChange=\"ResultYesNo(this,"+tn2+")\"><option value=\"\">请选择</option><option value=\"1\">合格</option><option value=\"0\">不合格</option></select> <span class=\"red\">*</span></div>";
		}else if(i==countCell-1){
			cell.innerHTML="<div align=\"center\" id=\"QCR"+tn2+"\">"+newQCR+"</div>";
		}else if(i>1 && i<countCell-2){
			cell.innerHTML=r[i-2];
		}else{
			cell.innerHTML="";
		}
	}
}

function MRound(Num){
	var fNum2 = 1;
	for(m=0;m<num_dot_xs;m++){
		fNum2 = fNum2 * 10
	}
	return Math.round(Num * fNum2)/fNum2;
}

//质检数量改变后
/*function NumQCChance(tn){
	var NumQC = document.getElementById("NumQC"+tn).value;
	var OKNum = parseFloat(document.getElementById("OKNum"+tn).value);
	var FailNum = 0;
	var POP = 0;
	if(NumQC==""){
		NumQC = 0;
		document.getElementById("OKNum"+tn).value = "";
		document.getElementById("FailNum"+tn).value = 0;
		document.getElementById("POP"+tn).value = 0;

	}else{
		NumQC = parseFloat(NumQC);
	}
	if(NumQC>0 && OKNum>0){
		if(NumQC<OKNum){
			OKNum=NumQC;
			document.getElementById("OKNum"+tn).value = OKNum;
		}
		FailNum = MRound(NumQC-OKNum);
		if(NumQC==0){
			POP = 0
		}else{
			POP = MRound((OKNum / NumQC)*100);
		}
		document.getElementById("FailNum"+tn).value = FailNum;
		document.getElementById("POP"+tn).value = POP;
	}

}
*/
//合格数量改变后
function ResultYesNo(obj,tn){
	if (parseFloat($("#NumQC"+tn).val())==0)
	{
		alert("本行质检明细质检数量不能为0");
		return;
	}
	SetAllInputText();
}
//处理明细
function SetAllInputText(){
	var mxAll = parseFloat($("#mxAll").val());
	var OKNum = 0;
	var NoNum = 0;
	//获取合格数量
	for(i=1;i<=mxAll;i++){
		if (parseFloat($("#Result"+i).val())==1)
		{
			OKNum = OKNum + parseFloat($("#NumQC"+i).val());
		}
	}
	//获取不合格数量
	for(i=1;i<=mxAll;i++){
		if (parseFloat($("#Result"+i).val())==0 && $("#Result"+i).val()!="")
		{
			NoNum = NoNum + parseFloat($("#NumQC"+i).val());
		}
	}

	$("#QCOKnum").val(OKNum);
	$("#QCFailNum").val(NoNum);

	var POP = 0;
	if(OKNum != 0 || NoNum !=0){
		POP = MRound((OKNum/(OKNum+NoNum))*100);		
	}
	$("#QC_POP").val(POP);
	
	if (OKNum == $("#QC_Num").val())
	{	//合格
		for(var i=0; i<$("#Qc_Result")[0].options.length; i++){
		    if($("#Qc_Result")[0].options[i].value == '1'){
				$("#Qc_Result")[0].options[i].selected = true;   
		        break;
		    }
		}
	}else{
		//不合格
		for(var i=0; i<$("#Qc_Result")[0].options.length; i++){
		    if($("#Qc_Result")[0].options[i].value == '0'){
				$("#Qc_Result")[0].options[i].selected = true;   
		        break;
		    }
		}
	}
}


//修改合格数量的值
/*function setOKNum(txt){
	txt.value=txt.value.replace(/[^\d\.]/g,'');
	var OKNum = parseFloat(txt.value);
	var OKNumid = txt.id.toString();
	var tn = OKNumid.replace("OKNum","");
	checkDot('OKNum'+tn,num_dot_xs);
	OKNumChance(tn);
}
*/
//质检类型
function setQCType(qctype,tn){
	var txt = document.getElementById("QC_Num");
	if(qctype == "0"){
		var Num1 = $("#CountNum").val();
		txt.value =Num1;
		setNum1(txt);
	}else{
		$("#QC_Num").val(0);
		txt.value =0;
		setNum1(txt);
	}
}

function getScrollTop()
{
    var scrollTop=0;
    if(document.documentElement&&document.documentElement.scrollTop)
    {
        scrollTop=document.documentElement.scrollTop;
    }
    else if(document.body)
    {
        scrollTop=document.body.scrollTop;
    }
    return scrollTop;
}


//查看是否有不合格产品
function checkFail(){
	document.date.act.value = "save";

	if (Validator.Validate(document.getElementById("demo"),2)==false) {
		return ;	
	}
	var mxAll = parseFloat($("#mxAll").val());
	var failNum = 0;

	var QcAllNum = parseFloat($("#QC_Num").val());
	var j_num = 0;

	for(i=1;i<=mxAll;i++){
		j_num = j_num + parseFloat($("#NumQC"+i).val());
	}
	j_num = MRound(j_num);
	if (j_num > QcAllNum)
	{
		alert("质检明细总数量不能大于质检数量！");
		return false;
	}
	
	var Qc_Result = $("#Qc_Result").val();
	if(Qc_Result=="0"){failNum = 1;}
	
	if (failNum == 1) {
	    var STop = getScrollTop();
	    var RHeight = STop + 300;
	    $('#w').window('open', { top: RHeight});
	    $('#w').window('resize', { top: RHeight});
	}else{
		document.date.submit();
	}
}

//保存审批人
function savespr(){
	if(document.getElementById("cateid_sp").value==""){
		alert("请选择审批人");
	}else{
		var cateid_sp = document.getElementById("cateid_sp").value;
		var caigouQC = document.getElementById("caigouQC").value;
		var url = "savespr.asp?ord="+caigouQC+"&sp="+cateid_sp+"&remind=205&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState == 4) {
				var response = xmlHttp.responseText;
				if(response=="1"){
					document.date.submit();
				}else{
					alert("保存审批人出现未知错误，请重试");	
				}
				xmlHttp.abort();
			}
		};
		xmlHttp.send(null);  
	}
}

function submitForm(){
	document.date.act.value = "zancun";

	var mxAll = parseFloat($("#mxAll").val());
	var QcAllNum = parseFloat($("#QC_Num").val());
	var j_num = 0;

	for(i=1;i<=mxAll;i++){
		j_num = j_num + parseFloat($("#NumQC"+i).val());
	}
	j_num = MRound(j_num);
	if (j_num > QcAllNum)
	{
		alert("质检明细总数量不能大于质检数量！");
		return false;
	}

	if (false==Validator.Validate(document.getElementById("demo"),2)) {
		return ;	
	}else{
		document.date.submit();
	}
}

function loadqc(act){
	var page = "qcheck"
	var noword = document.getElementById("caigouQC").value;
	var url = "loadqc.asp?ord="+noword+"&act="+act+"&page="+page+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var response = xmlHttp.responseText;	
			var arr_res = response.split("|");
			if(arr_res[0]=="0"){
				alert("没有了");
			}else if(arr_res[0]=="1"){
				var tourl = arr_res[1];
				if(tourl != ""){
					window.location.href=page+".asp?ord="+tourl;
				}
			}
			xmlHttp.abort();
		}
	};
	xmlHttp.send(null);  
}

