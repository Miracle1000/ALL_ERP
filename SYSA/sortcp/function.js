// JavaScript Document
function change1(a,b)
{
	if(eval(a).style.display=='')
	{
		eval(a).style.display='none';
		eval(b).className='menu4';
	}
	else
	{
		eval(a).style.display='';
		eval(b).className='menu3';
	}
}
function change2(a,b)
{
	if(eval(a).style.display=='')
	{
		eval(a).style.display='none';
		eval(b).className='menu1';
	}
	else
	{
		eval(a).style.display='';
		eval(b).className='menu2';
	}
}
function changeleft1(a,b)
{
	if(eval(a).style.display=='')
	{
		eval(a).style.display='none';
		eval(b).className='menuleft1';
	}
	else
	{
		eval(a).style.display='';
		eval(b).className='menuleft2';
	}
}
function change_gx1(a,b)
{
	if(eval(a).style.display=='')
	{
		eval(a).style.display='none';
		eval(b).className='menu_gx3';
	}
	else
	{
		eval(a).style.display='';
		eval(b).className='menu_gx4';
	}
}
function change_gx2(a,b)
{
	if(eval(a).style.display=='')
	{
		eval(a).style.display='none';
		eval(b).className='menu_gx1';
	}
	else
	{
		eval(a).style.display='';
		eval(b).className='menu_gx2';
	}
}


function showMenu(stype){
	var show = $("#showCls").text();
	if (show == "全部收缩" || stype == 2){
		$("td[id^='b']").each(function(){
			if($(this).attr("class")=="menu2"){
				$(this).attr("class","menu1");
			}else if($(this).attr("class")=="menu4"){
				$(this).attr("class","menu3");
			}
		});
		$("tr[id^='a']").css("display","none");
		$("#showCls").text("全部展开");
	}else if(show == "全部展开"){
		$("td[id^='b']").each(function(){
			if($(this).attr("class")=="menu1"){
				$(this).attr("class","menu2");
			}else if($(this).attr("class")=="menu3"){
				$(this).attr("class","menu4");
			}
		});
		$("tr[id^='a']").css("display","");
		$("#showCls").text("全部收缩");
	}
}


function openMenuWin(act, args){
	var arr_arg = "";
	if (args.toString() != ""){
		args = args.toString();
		if (args.indexOf("|")==-1){
			args += "|";
		}
		arr_arg = args.split("|");
	}
	switch(act){
	case "add":		
		window.open('add_cp.asp?id='+arr_arg[0]+'&gate2='+arr_arg[1]+'','newwinadd','width=' + 800 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
		break;
	case "edit":
		window.open('correct_cp.asp?rd='+arr_arg[0]+'','newwincorrect','width=' + 800 + ',height=' + 400 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100');
		break;	
	case "del":
		if (confirm('建议不要轻易删除设置好的参数，以免影响到其他关联的数据。确认删除?'))	{
			window.location.href = "menu.asp?action=del&id="+arr_arg[0]
		}	
		break;	
	case "fanwei":
		var ToSame1 = document.getElementById("ToSame" + arr_arg[0] + "_1");
		var ToSame0 = document.getElementById("ToSame" + arr_arg[0] + "_0");
		var ToSame = 0;
		if (ToSame1.checked)
		{
			ToSame = 1;
		}
		if (ToSame0.checked)
		{
			ToSame = 0;
		}
		window.open('share_person_all.asp?rd='+arr_arg[0]+'&ToSame='+ToSame+'','newwincorrect','width=' + 600 + ',height=' + 300 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=100,top=100')
		break;	
	}
	
}

function ChangeToSame(ord,val){		//--处理产品分类及其子项的【影响已存在产品】值，并根据返回信息设置子项的【影响已存在产品】选中状态
	var resTxt, arr_res
	var url = "../sortcp/menu_ajax.asp?ord="+ord+"&ToSame="+val;
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		if (xmlHttp.readyState == 4) {
			var r = xmlHttp.responseText;
			if(r != ""){
				resTxt = r
				arr_res = resTxt.split(",");
				for (var i = 0; i < arr_res.length; i++)
				{
					 if (document.getElementById("ToSame" + arr_res[i] + "_"+val))
					 {
						 document.getElementById("ToSame" + arr_res[i] + "_"+val).checked = true;	//--根据返回信息设置子项的【影响已存在产品】选中状态
					 }
				}
			}
		}
	};
	xmlHttp.send(null);
}