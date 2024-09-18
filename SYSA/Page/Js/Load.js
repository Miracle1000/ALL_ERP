
function GetUrl(InputId,strUrl,width,height)
{
	if(strUrl.indexOf("?")>=0)
	{
		strUrl=strUrl+"&InputId="+InputId
		}
	else
	{
		strUrl=strUrl+"?InputId="+InputId
		}
	var w = 960 , h = 640 ;
	window.open( strUrl ,'newwin','width=' + w + ',height=' + h + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=150,top=150');
}
function GetLinkNumVal(InputId,Val,title)
{
	var input =document.getElementsByName(InputId)[0];
	if(Val==""||title=="")
	{
	Val=0;
	title="点击选择";
	input.style.color="#999999";
	}
	else
	{
	input.style.color="#000000";
	}
	input.value=title;
	input.parentElement.children[0].value=Val;

}
function winClose()
{
	try
	{
		window.opener=null;
		window.open('','_self');
		window.close();
	}catch(e)
	{}
}

$(document).ready(function(){
//列表的批量删除
$("#Del_Batch").click(function(){
   if($(".Del_Item_List").attr("checked")){$(".Del_Item_List").removeAttr("checked"); }
   else{$(".Del_Item_List").attr("checked",'true');}
	});
});
//批量删除，如开启要重写这个函数
function DelBatch(TableID)
{
	var list="";
	var check=$('input[type="checkbox"][class="Del_Item_List"]:checked');
	
	check.each(function()
	{
		if(list=="")
		{
		list=$(this).val();
		}
		else
		{
		list=list+","+$(this).val();
		}
	});
	DelList(TableID,list);
}
function DelList(TableID,list) {
			//var parentDiv=window.DivOpen("div_DelList" ,"批量删除状态", 300,185,"dd","dd",false,2);
			ajax.regEvent("DelList");
			ajax.addParam("TableID",TableID);
			ajax.addParam("Ord",list);
			alert(ajax.send().split("</noscript>")[1]);
			//parentDiv.innerHTML= ajax.send();
			window.location.reload();
}
function SetPage(PageNum)
{
	gotourl('currPage='+PageNum+'');
}

function SearchShow(TableID)
{
			var parentDiv=window.DivOpen("div_SearchList" ,"高级检索", 640,376,"dd","dd",false,2);
			ajax.regEvent("SearchList");
			ajax.addParam("TableID",TableID);
			parentDiv.innerHTML= ajax.send();
}
function delClassItem(cid,TableListID,listid)
{
	if(listid!=0)//修改删除明细
	{
		ajax.regEvent("TableListDel");
		ajax.addParam("TableListID",TableListID);
		ajax.addParam("listid",listid);
		alert(ajax.send().split("</noscript>")[1]);
	}
	$("."+cid.parentElement.parentElement.parentElement.className).remove();
		try
	{ parent.frameResize();}
	catch(e){}
}
