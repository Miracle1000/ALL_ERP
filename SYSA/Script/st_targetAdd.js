

$.extend($.messager.defaults,{   
    ok:"确定",
    cancel:"取消"
});

function getTargetStr(intYear,examSort)
{
	if(intYear!="")
	{
		if(parseInt(intYear)==2011&&1==2)
		{
			document.location="getTargetStr2.asp?act="+window.actType+"&intYear="+intYear+"&examSort="+examSort+"&r="+ Math.random();
			return;
		}
		$.ajax({
			url:"getTargetStr2.asp?act="+window.actType+"&intYear="+intYear+"&examSort="+examSort+"&r="+ Math.random(),
			type:"post",
			success:function(msg)
			{
				$("#targetListStr"+examSort).html(msg);
				if(parent&&parent.frameResize){window.parent.document.getElementById("cFF").style.height=$("#targetListStr"+examSort)[0].offsetHeight+140;}
			}
		});
	}
	else
	{
		$("#targetListStr"+examSort).html("请选择目标年份");
	}
}

function assignValue(Id){
	$.ajax({
		url:"AssignAdd.asp?fromId="+Id+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			if(msg.length==0){
				alert("请先下达上级目标");
			}else{
				$("#targetAssign").html(msg);
				$.parser.parse($('#targetAssign'));
				$('#win').window({
					collapsible:false,
					minimizable:false,
					maximizable:true,
					modal:true
				});
				$('#win').window('open');
			}
		}
   });
}
function addValue(intYear,periodId,examSort,parentRoleId){
	$.ajax({
		url:"getAddStr.asp?aType=1&intYear="+intYear+"&periodId="+periodId+"&examSort="+examSort+"&parentRoleId="+parentRoleId+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			if(msg.length==0){
				alert('请先添加上级目标');
			}else{
				$("#c_"+periodId+"_"+examSort).html(msg);
			}
		}
   });
}
function saveValue(year,periodId,examSort,Id,parentRoleId){
	var val=$("#t_"+periodId+"_"+examSort).val();
	val=parseFloat(val);
	if(val==0||isNaN(val)){
		$("#s_"+periodId+"_"+examSort).show();
	}else{
		$("#s_"+periodId+"_"+examSort).hide();
		$.ajax({
			url:"targetSave.asp?intYear="+year+"&intPeriodId="+periodId+"&examSort="+examSort+"&Id="+Id+"&targetValue="+val+"&parentRoleId="+parentRoleId+"&r="+ Math.random(),
			type:"post",
			success:function(msg){
				$("#c_"+periodId+"_"+examSort).html(msg);
			}
		});
	}
}
function editValue(periodId,examSort,Id,parentRoleId){
	$.ajax({
		url:"getAddStr.asp?aType=2&Id="+Id+"&periodId="+periodId+"&examSort="+examSort+"&parentRoleId="+parentRoleId+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			if(msg.length==0){
				alert('已下达目标不可编辑');
			}else{
				$("#c_"+periodId+"_"+examSort).html(msg);
			}
		}
   });
}
function cancelValue(periodId,examSort,Id,parentRoleId,intYear){
	$.ajax({
		url:"getAddStr.asp?aType=3&Id="+Id+"&periodId="+periodId+"&examSort="+examSort+"&parentRoleId="+parentRoleId+"&intYear="+intYear+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#c_"+periodId+"_"+examSort).html(msg);
		}
   });
}
function setTarget(intYear,examSort,roleId){
	$.ajax({
		url:"setWeekDayTargetStr.asp?examSort="+examSort+"&intRoleId="+roleId+"&intYear="+intYear+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			if(msg.length==0){
				alert("请先设置年目标");
			}else{
				$("#setWeekDayTarget").html(msg);
				$.parser.parse($('#setWeekDayTarget'));
				$('#win1').window({
					collapsible:false,
					minimizable:false,
					maximizable:true,
					modal:true
				});
				$('#win1').window('open');
			}
		}
   });
}

function target_Show(flg,s)
{
	var tb=document.getElementById("AllTargets_"+s);
	if(!tb) return false;
	for(var i=0;i<tb.rows.length;i++)
	{
		if(tb.rows[i].gate=="1"&&tb.rows[i].NotShow!="1"){tb.rows[i].style.display=(flg?"block":"none");}
	}
	var obj=tb.parentElement;
	var h=document.getElementById("targetListStr"+s).offsetHeight;
	$("#jqtabs").tabs('resize');
	if(parent&&parent.frameResize){window.parent.document.getElementById("cFF").style.height=h+140;}
	return true;
}

function target_Save(act,s,y)
{
	$('#st_form'+s).form
	('submit',
		{
			url:"targetSave2.asp?actType="+act,
			onSubmit: function()
			{
        return checkForm(act,s);
			},
			success:function(data)
			{
				if(data.indexOf("~errmsg~:")!=0)
				{
					alert("保存成功");
					window.location="targetAdd.asp?intYear="+y+"&examSort="+s;
				}
				else
				{
					var msg=data.split("~errmsg~:");
	      	alert(msg[1].replace(/\<br\>/ig,"\n"));
	      	if(msg.length>2&&msg[2].length>0) execScript(msg[2]);
	    	}
			}
		}
	);
}

function checkColor(txtobj)
{
	var tdobj=txtobj.parentElement;
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var CellIdx=tdobj.cellIndex;
	var RowIdx=parseInt(trobj.gateparent);
	var CellID=parseInt(tdobj.periodID);
	var CellParentId=parseInt(tdobj.periodParent);
	var CellParentIdx=-1;
	//1.横向比
	//计算本级目标值之和是否超出其上级的值
	//如果是最上级目标，则不用考虑其上级
	//1.1本级之和与上级比
	if(CellParentId>0)
	{
		//根据上级ID寻找对应单元格
		for(var i=0;i<trobj.cells.length;i++)
		{
			if(parseInt(trobj.cells[i].periodID)==CellParentId)
			{
				CellParentIdx=i;
				break;
			}
		}
		var tmp=parseFloat(trobj.cells[CellParentIdx].getElementsByTagName("input")[0].value)
		var ParentValue=isNaN(tmp)?0:tmp;
		//获取上级目标值
		var TotalValue=0;
		for(var i=0;i<trobj.cells.length;i++)
		{
			if(parseInt(trobj.cells[i].periodParent)==CellParentId)
			{
				var tmp=parseFloat(trobj.cells[i].getElementsByTagName("input")[0].value)
				TotalValue+=isNaN(tmp)?0:tmp;
			}
		}
		var newColor="",newFColor="";
		if(ParentValue>TotalValue)
		{
			newColor="red"
			newFColor="white"
		}
		else if(ParentValue<TotalValue)
		{
			newColor="yellow"
			newFColor="red"
		}
		else
		{
			newColor=txtobj.oricolor;
			newFColor=txtobj.orifcolor;
		}
		for(var i=1;i<trobj.cells.length;i++)
		{
			if(parseInt(trobj.cells[i].periodParent)==CellParentId)
			{
				var tobj=trobj.cells[i].getElementsByTagName("input")[0];
				tobj.style.backgroundColor=newColor;
				tobj.style.color=newFColor;
			}
		}
	}
	//1.2下级之和与本级比
	//计算所有下级目标之和
	var TotalValue=0;
	for(var i=0;i<trobj.cells.length;i++)
	{
		if(parseInt(trobj.cells[i].periodParent)==CellID)
		{
			var tmp=parseFloat(trobj.cells[i].getElementsByTagName("input")[0].value)
			TotalValue+=isNaN(tmp)?0:tmp;
		}
	}
	var newColor="",newFColor="";
	var ThisValue=parseFloat(txtobj.value);
	if(ThisValue>TotalValue)
	{
		newColor="red"
		newFColor="white"
	}
	else if(ThisValue<TotalValue)
	{
		newColor="yellow"
		newFColor="red"
	}
	else
	{
		newColor=txtobj.oricolor;
		newFColor=txtobj.orifcolor;
	}
	for(var i=1;i<trobj.cells.length;i++)
	{
		if(parseInt(trobj.cells[i].periodParent)==CellID)
		{
			var tobj=trobj.cells[i].getElementsByTagName("input")[0];
			tobj.style.backgroundColor=newColor;
			tobj.style.color=newFColor;
		}
	}

	//2纵向比
	//2.1本级之和与上级比
	//第一级（总公司目标）无上级，不需要比较
	var ridx=parseInt(trobj.ridx);
	if(ridx>1)
	{
		var gateparent=parseInt(trobj.gateparent);
		var tobj=tbobj.rows[gateparent+1].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
		var ParentValue=tobj.value;
		var TotalValue=0;
		for(var i=2;i<tbobj.rows.length-1;i++)
		{
			if(parseInt(tbobj.rows[i].gateparent)==gateparent)
			{
				var tmp=parseFloat(tbobj.rows[i].cells[tdobj.cellIndex].getElementsByTagName("input")[0].value)
				TotalValue+=isNaN(tmp)?0:tmp;
			}
		}
		var newColor="",newFColor="";
		for(var i=2;i<tbobj.rows.length-1;i++)
		{
			if(parseInt(tbobj.rows[i].gateparent)==gateparent)
			{
				var tobj=tbobj.rows[i].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
				if(ParentValue>TotalValue)
				{
					newColor="red"
					newFColor="white"
				}
				else if(ParentValue<TotalValue)
				{
					newColor="yellow"
					newFColor="red"
				}
				else
				{
					newColor=tobj.oricolor;
					newFColor=tobj.orifcolor;
				}
				tobj.style.backgroundColor=newColor;
				tobj.style.color=newFColor;
			}
		}
	}
	//2.2下级之和与本级比
	//计算所有下级目标之和
	var TotalValue=0;
	for(var i=2;i<tbobj.rows.length;i++)
	{
		if(parseInt(tbobj.rows[i].gateparent)==ridx)
		{
			var tmp=parseFloat(tbobj.rows[i].cells[CellIdx].getElementsByTagName("input")[0].value)
			TotalValue+=isNaN(tmp)?0:tmp;
		}
	}
	var newColor="",newFColor="";
	for(var i=2;i<tbobj.rows.length-1;i++)
	{
		if(parseInt(tbobj.rows[i].gateparent)==ridx)
		{
			var tobj=tbobj.rows[i].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
			if(ThisValue>TotalValue)
			{
				newColor="red"
				newFColor="white"
			}
			else if(ThisValue<TotalValue)
			{
				newColor="yellow"
				newFColor="red"
			}
			else
			{
				newColor=tobj.oricolor;
				newFColor=tobj.orifcolor;
			}
			tobj.style.backgroundColor=newColor;
			tobj.style.color=newFColor;
		}
	}
}

function autoJump(txtobj,examSort)
{
	if(event.keyCode!=13&&event.keyCode!=40) return;
	var tdobj=txtobj.parentElement;
	var trobj=tdobj.parentElement;
	var s1=document.getElementById("stp1"+examSort);
	if(event.keyCode==13)//回车向右移动
	{
		var CellId=parseInt(tdobj.periodID);
		for(var i=1;i<trobj.cells.length;i++)
		{
			if(parseInt(trobj.cells[i].periodParent)==CellId)
			{
				var tobj=trobj.cells[i].getElementsByTagName("input")[0];
				if(tobj.value.length==0||isNaN(tobj.value)||parseFloat(tobj.value=="0")){tobj.value=txtobj.value;}
				tobj.focus();
				return;
			}
		}
	}
	else if(event.keyCode==40)//下方向键向下移动
	{
		var tbobj=trobj.parentElement.parentElement;
		var RowIndex=trobj.rowIndex;
		if(RowIndex>=tbobj.rows.length-2) return;
		var NewRow=0
		if(s1.checked)
		{
			NewRow=RowIndex+1;
		}
		else
		{
			for(var i=RowIndex+1;i<tbobj.rows.length-2;i++)
			{
				if(tbobj.rows[i].style.display!="none")
				{
					NewRow=i;
					break;
				}
			}
			if(NewRow==0) return;
		}
		var gateparent=parseInt(tbobj.rows[NewRow].gateparent);
		var ridx=parseInt(tbobj.rows[NewRow].ridx);
		if(ridx>tbobj.rows.length-3) return;
		var tobj=tbobj.rows[NewRow].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
		if(tobj.value.length==0||isNaN(tobj.value)||parseFloat(tobj.value=="0"))
		{
			//计算本级已设定目标总和
			var TargetThisGrade=0;
			for(var j=2;j<tbobj.rows.length-2;j++)
			{
				if(parseInt(tbobj.rows[j].gateparent)==gateparent)
				{
					var tmpobj=tbobj.rows[j].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
					var v=tmpobj.value
					if(v.length>0&&!isNaN(v))	TargetThisGrade+=parseFloat(v);
				}
			}
			//计算上级设定目标的值
			var pobj=tbobj.rows[gateparent+1].cells[tdobj.cellIndex].getElementsByTagName("input")[0];
			var v=pobj.value
			if(v.length>0&&!isNaN(v)&&parseFloat(v)>=0)	tobj.value=parseFloat(v)-TargetThisGrade;
		}
		checkColor(tobj);
		tobj.focus();
	}
}

function checkValue(txtobj)
{
	txtobj.value=txtobj.value.replace(/[^\d\.]/g,'');
	if(isNaN(txtobj.value))
	{
		txtobj.value=0;
	}
}

function targetConfirm(lkobj)
{
	var tdobj=lkobj.parentElement;
	var trobj=tdobj.parentElement;
	var n=tdobj.getElementsByTagName("input")[0].name.split("_");
	var idx=n[1];
	var i=n[2];
	var txtobjs=tdobj.getElementsByTagName("input");
	var tValue=txtobjs[0].value;
	var tid=txtobjs[1].value;
	var tStamp=txtobjs[2].value;
	//var url="updateTarget.asp?act=Confirm&tid="+escape(tid)+"&tvalue="+escape(tValue)+"&st="+escape(tStamp)+"&idx="+idx+"&i="+i+"&tstamp="+Math.round(Math.random()*100);
	txtobjs[4].value=1;
	changeStyle(txtobjs[0],"1,3,4,7");
	//targetLockChild(txtobjs[0],true);
}

function targetRefresh(txtobj)
{
	var tdobj=txtobj.parentElement;
	var trobj=tdobj.parentElement;
	var n=txtobj.name.split("_");
	var tid=n[1];
	var ti=n[2];
	var txtobjs=tdobj.getElementsByTagName("input");
	var tValue=txtobjs[0].value;
	var tid=txtobjs[1].value;
	var tStamp=txtobjs[2].value;
	var url="updateTarget.asp?act=Refresh&";
	
}

function targetLockChild(txtobj,flg)
{
	var tdobj=txtobj.parentElement;
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var CellIdx=tdobj.cellIndex;
	var RowIdx=parseInt(trobj.gateparent);
	var ridx=parseInt(trobj.ridx);
	for(var i=ridx+2;i<tbobj.rows.length-1;i++)
	{
		if(parseInt(tbobj.rows[i].gateparent)==ridx)
		{
			changeStyle(tbobj.rows[i].cells[CellIdx].getElementsByTagName("input")[0],"1,7");
		}
	}
}

var tps;
function targetPropertyShow(flg,obj)
{
	tps=obj;
	var tdobj=obj.parentElement;
	while(tdobj.tagName!="TD"){tdobj=tdobj.parentElement;}
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	document.getElementById("curperson").innerHTML=tdobj.getElementsByTagName("input")[4].pname;
	$("#dd").dialog({title:'选择【'+trobj.cells[0].innerText+'】【'+tbobj.rows[1].cells[tdobj.cellIndex].innerText+'】接收人'});
	$("#dd").dialog('open');
	$("#dd").dialog('move',{top:event.y});
	if(parent.document.getElementById("cFF"))
	{
		if(event.y+350>parseInt(parent.document.getElementById("cFF").style.height))
		{
			parent.document.getElementById("cFF").style.height=event.y+350;
		}
	}
	var ckobjs=document.getElementsByName("W3");
	for(var i=0;i<ckobjs.length;i++){ckobjs[i].checked=(ckobjs[i].value==tdobj.getElementsByTagName("input")[4].value);}
	return;
}

function SelectPerson(chkobj)
{
	var tdobj=tps.parentElement;
	while(tdobj.tagName!="TD"){tdobj=tdobj.parentElement;}
	var cidx=tdobj.cellIndex;
	tdobj.getElementsByTagName("input")[4].value=chkobj.value;
	tdobj.getElementsByTagName("input")[4].pname=chkobj.pname;
	tps.title="接收人："+chkobj.pname;
	if(cidx==0)
	{
		var trobj=tdobj.parentElement;
		for(var i=1;i<trobj.cells.length;i++)
		{
			var cobj=trobj.cells[i].getElementsByTagName("input");
			if(cobj[0].readOnly) continue;
			cobj[4].value=chkobj.value;
			cobj[4].pname=chkobj.pname;
			trobj.cells[i].getElementsByTagName("img")[0].title="接收人："+chkobj.pname;
		}
	}
	$("#dd").dialog('close');
}

function targetShow(s)
{
	/*
	需要的信息
	是否显示确认按钮
	是否显示确认状态
	是否显示下达状态
	是否可编辑
	是否已审批
	行是否显示
	*/
	var tb=document.getElementById("AllTargets_"+s);
	if(!tb) return false;
	for(var i=2;i<tb.rows.length-1;i++)
	{
		for(var j=1;j<tb.rows[i].cells.length;j++)
		{
			
		}
	}
}

function changeStyle(obj,cgtpArgs)
{
	var cgtps=cgtpArgs.split(",");
	for(var i=0;i<cgtps.length;i++)
	{
		switch(parseInt(cgtps[i]))
		{
			case 1://只读
				obj.readOnly=true;
				break;
			case 2://后面加确认按钮
				var lkobj=document.createElement("a");
				lkobj.href="###"
				lkobj.onclick=function()
				{
					targetConfirm(lkobj);
				};
				lkobj.innerHTML="确认";
				obj.parentElement.appendChild(lkobj);
				break;
			case 3://后面加已确认图标
				var imgobj=document.createElement("img");
				imgobj.src="../images/ok.gif";
				imgobj.border=0;
				obj.parentElement.appendChild(imgobj);
				break;
			case 4://清除确认按钮
				var lkobj=obj.parentElement.getElementsByTagName("a")[0];
				obj.parentElement.removeChild(lkobj);
				break;
			case 5://清除已确认图标
				var imgobj=obj.parentElement.getElementsByTagName("img")[0];
				obj.parentElement.removeChild(imgobj);
				break;
			case 6://取消只读
				obj.readOnly=false;
				break;
			case 7://取消边框
				obj.style.border=0;
				break;
			case 8://恢复边框
				obj.style.border=1;
				break;;
			default:
				break;
		}
	}
}

function checkForm(act,s)
{
	var tb=document.getElementById("AllTargets_"+s);
	for(var i=2;i<tb.rows.length;i++)
	{
		if(tb.rows[i].gate=="0"&&tb.rows[i].disp=="1")
		{
			for(var j=1;j<tb.rows[i].cells.length;j++)
			{
				var objs=tb.rows[i].cells[j].getElementsByTagName("input")
				if(objs[0].value!="" && parseFloat(objs[0].value)>0 && objs[4].value=="0")
				{
					alert("【"+tb.rows[1].cells[j].innerText+"】【"+tb.rows[i].cells[0].tag+"】未选择接收人");
					tb.rows[i].cells[j].oribgcolor=tb.rows[i].cells[j].style.backgroundColor;
					tb.rows[i].cells[j].style.backgroundColor="red";
					objs[0].focus();
					return false;
				}
				else
				{
					if(tb.rows[i].cells[j].style.backgroundColor=="red") tb.rows[i].cells[j].style.backgroundColor=tb.rows[i].cells[j].oribgcolor;
				}
			}
		}
	}
}

var wps=null
function setWeekTarget(obj,s,y)
{
	var nowy=event.y;
	wps=obj;
	var wkv=obj.parentElement.getElementsByTagName("input")[5].value;
	var tdobj=obj.parentElement;
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var periodID=obj.parentElement.periodID;
	var tvobj=tdobj.getElementsByTagName("input")[0];
	if(tvobj.value=="")
	{
		alert("请先设置【"+tbobj.rows[1].cells[tdobj.cellIndex].innerText+"】目标值再设置周和日目标！");
		tvobj.focus();
		return;
	}
	//if(wkv.length>0) document.location="setWeekTarget.asp?examSort="+s+"&intYear="+y+"&pid="+periodID+"&wkv="+escape(wkv)+"&r="+ Math.random()
	$.ajax({
		url:"setWeekTarget.asp?examSort="+s+"&intYear="+y+"&pid="+periodID+"&wkv="+escape(wkv)+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#ww").html(msg);
			$.parser.parse($('#ww'));
			$('#win').window({collapsible:false,minimizable:false,maximizable:false,left:(document.body.scrollWidth-600)/2,modal:true,
				onResize:function(w,h){
				}
			});
			$("#win").window({title:'【'+trobj.cells[0].innerText+'】【'+tbobj.rows[1].cells[tdobj.cellIndex].innerText+'】周与日目标设置'});
			$('#win').window('open');
			$("#win").window('move',{top:nowy});
			if(parent.document.getElementById("cFF"))
			{
				if(nowy+380>parseInt(parent.document.getElementById("cFF").style.height))
				{
					parent.document.getElementById("cFF").style.height=nowy+380;
				}
			}
		}
   });
}

function getWeekTarget(obj,s,y)
{
	var nowy=event.y;
	wps=obj;
	var wkv=obj.parentElement.getElementsByTagName("input")[5].value;
	var tdobj=obj.parentElement;
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var periodID=obj.parentElement.periodID;
	var tvobj=tdobj.getElementsByTagName("input")[0];
	if(tvobj.value=="")
	{
		alert("请先设置【"+tbobj.rows[1].cells[tdobj.cellIndex].innerText+"】目标值再设置周和日目标！");
		tvobj.focus();
		return;
	}
	if(wkv.length>0)
	{
		//document.write("getWeekTarget.asp?examSort="+s+"&intYear="+y+"&pid="+periodID+"&wkv="+escape(wkv)+"&r="+ Math.random());
		//return;
	 	//document.location="getWeekTarget.asp?examSort="+s+"&intYear="+y+"&pid="+periodID+"&wkv="+escape(wkv)+"&r="+ Math.random()
	}
	$.ajax({
		url:"getWeekTarget.asp?examSort="+s+"&intYear="+y+"&pid="+periodID+"&wkv="+escape(wkv)+"&c="+(tvobj.readOnly?1:0)+"&r="+ Math.random(),
		type:"post",
		success:function(msg){
			$("#ww").html(msg);
			$.parser.parse($('#ww'));
			$('#win').window({collapsible:false,minimizable:false,maximizable:false,left:(document.body.scrollWidth-600)/2,modal:true,
				onResize:function(w,h){
				}
			});
			$("#win").window({title:'【'+trobj.cells[0].innerText+'】【'+tbobj.rows[1].cells[tdobj.cellIndex].innerText+'】周与日目标设置'});
			$('#win').window('open');
			$("#win").window('move',{top:nowy});
			if(parent.document.getElementById("cFF"))
			{
				if(nowy+380>parseInt(parent.document.getElementById("cFF").style.height))
				{
					parent.document.getElementById("cFF").style.height=nowy+380;
				}
			}
		}
   });
}

function saveWeekDays()
{
	var tdobj=wps.parentElement;
	var wdobj=document.getElementById("wdtarget");
	var wdtb=wdobj.getElementsByTagName("table")[0];
	var allValue="";
	for(var i=0;i<wdtb.rows.length;i++)
	{
		var txtobj=wdtb.rows[i].getElementsByTagName("input");
		var wtv="",dtv="";
		var dflg=false;
		for(var j=0;j<txtobj.length;j++)
		{
			var tmpvalue="";
			tmpvalue=(!isNaN(txtobj[j].value)||txtobj[j].value=="\1")?txtobj[j].value:"0";
			tmpvalue=(tmpvalue==""?"0":tmpvalue);
			if(txtobj[j].name=="wtv")
			{
				wtv=txtobj[j].wtid+"\2"+txtobj[j].wid+"\2"+tmpvalue+"\2"+txtobj[j].stamp;
			}
			else if(txtobj[j].name=="dtv")
			{
				if(!dflg)
				{
					dtv=txtobj[j].did+"\3"+txtobj[j].dt+"\3"+tmpvalue+"\3"+txtobj[j].stamp;
					dflg=true;
				}
				else
				{
					dtv+=","+txtobj[j].did+"\3"+txtobj[j].dt+"\3"+tmpvalue+"\3"+txtobj[j].stamp;
				}
			}
		}
		allValue+=(allValue==""?"":"\4")+wtv+"\5"+dtv;
	}
	tdobj.getElementsByTagName("input")[5].value=allValue;
	$('#win').window('close');
}

var toolPannel=null;
function showPannel()
{
	if(!toolPannel)
	{
		toolPannel=document.createElement("div");
		document.body.appendChild(toolPannel);
		toolPannel.innerHTML="";
	}
	//toolPannel
}
