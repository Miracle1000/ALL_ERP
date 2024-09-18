function bntClick(obj,typ)
{
	document.getElementsByName("@typ")[0].value=typ;
	bill.doSave(obj);
}

function OperateAddheader()
{
	obj = document.getElementById("_app_div");
	if(!obj) {
		obj=document.createElement("div");
		obj.id="_app_div";
		obj.cssName="easyui-dialog";
		obj.title="报表结构项目设置";
		obj.style.cssText="width:500px;height:260px;padding:5px;background: #fafafa;";
		obj.closed="true";
		obj.modal="true";
		document.body.appendChild(obj);
	}
	//obj.closable="false";
	html = "<div id='spdiv'>";
	html = html+"<table width='100%' border='0' cellpadding='5' cellspacing='0' bgcolor='#C0CCDD' id='content'>";
	html = html+"<tr class='panel-title'><td colspan='4'>结构项目添加</td></tr>";
	html = html+"<tr><td class='fcell sub-title' style='width:35%'>栏    目：</td>";
	html = html+"<td colspan='3'><div align='left'><span class='gray'>";
	html = html+"<select name='w_groups' id='w_groups'><option value='1'>1</option><option value='2'>2</option></select>";
	html = html+"</span></div></td></tr>";
	html = html+"<tr><td class='fcell sub-title'><div align='right'>列    名：</div></td>";
	html = html+"<td colspan='3'><div align='left'>";
	html = html+"<input type='text' name='w_headerName' id='w_headerName' size='20' maxlength=30>";
	html = html+" <span class='red'>*</span> <span id='show1' class='red'></span></div></td></tr>";
	html = html+"<tr><td class='fcell sub-title'><div align='right'>属    性：</div></td>";
	html = html+"<td colspan='3'><div align='left'><span class='gray'>";
	html = html+"<input type='radio' name='w_attr' id='w_attr_1' value='0' checked>非计算项&nbsp;&nbsp;<input type='radio' name='w_attr' id='w_attr_2' value='1'>计算项";
	html = html+"</span></div></td></tr>";
	html = html+"<tr><td class='fcell sub-title'><div align='right'>重要指数：</div></td>";
	html = html+"<td colspan='3'><div align='left'>";
	html = html+"<input type='text' name='w_gate' id='w_gate' size='20' maxlength='3' min='0' max='500' onkeyup=\"value=value.replace(/[^\\d]/g,'')\">";
	html = html+" <span class='red'>*</span> <span id='show2' class='red'></span></div></td></tr>";
	html = html+"<td colspan=4 align='center'><input type='button' class='oldbutton anybutton' value=' 确定 ' id='_app_sbmit'>&nbsp;&nbsp;<input type='button' class='oldbutton anybutton' value=' 增加 ' id='_app_re_add'>&nbsp;&nbsp;<input type='button' class='oldbutton anybutton' value=' 取消 ' onclick=\"$('#_app_div').window('close');\"></td></tr>";
	html = html+"</table></div>";
	obj.innerHTML=html;
	document.getElementById("_app_sbmit").onclick = submithandle(0);
	document.getElementById("_app_re_add").onclick = submithandle(1);
	var inttop=(200+document.documentElement.scrollTop+document.body.scrollTop)+"px";
	$('#_app_div').window({top:inttop});
	$('#_app_div').window('open');
}

submithandle=function(typ){
	return function()
	{
		var w_groups = $("#w_groups").val();
		var w_headerName = $("#w_headerName").val();
		
		var w_attr = $("#w_attr_2").attr("checked")==true ? 1 : 0;
		var w_gate = $("#w_gate").val();
		var canAdd = true ; 
		if (w_headerName.length==0)
		{
			$("#show1").html("必填");
			canAdd = false ;
		}
		else
		{
			$("#show1").html("");
		}
		if (w_gate.length==0)
		{
			$("#show2").html("必填");	
			canAdd = false ;
		}
		else
		{
			$("#show2").html("");
		}
		
		try{
			if (parseFloat(w_gate)>500 || parseFloat(w_gate)<0)
			{
				$("#show2").html("数字必须在1到500之间");
				canAdd = false ;
			}
			else{
				$("#show2").html("");
			}
		}
		catch(e){
			$("#show2").html("必须是1到500之间的数字");
			canAdd = false ;
		}
		if (!canAdd){return false ;}
		app.lvweditor.insertRow($(".fun")[0],0, "["+w_groups+"]\1\2["+w_headerName+"]\1\2["+w_attr+"]\1\2["+w_gate+"]\1\2[]\1\2");
		if (typ==0)
		{
			$("#_app_div").window("close");
		}
		else
		{
			$("#show1").html("");
			$("#show2").html("");
		}
	}
}