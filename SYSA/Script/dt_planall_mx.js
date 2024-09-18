function setall(ids) {
	var ordlist="";
	if (ids==0)
	{	
		$(".lvcbox").each(
			function(){
				if($(this).attr("checked")==true)
				{
					if (ordlist.length!="")
					{
						ordlist = ordlist + ",";
					}
					ordlist = ordlist + $(this).val();
				}
			}
		)
		if (ordlist.length=="")
		{
			app.Alert("您没有选择任何文件,请选择后再归档！");
			return ;
		}
	}
	else
	{
		ordlist=ids;
	}
	if(confirm('确认归档？')){
		ajax.regEvent("setall")
		ajax.addParam('ordlist', ordlist);
		ajax.send(function(r){
			 if (r == "0") {
				app.Alert("没有选择可归档的文件,请重新选择后再归档！");
			 }
			 else
			 {	
				$("#gdlist").val(r);
				var pindex = (document.getElementById("pindex")?document.getElementById("pindex").value:1)
				select_psize(pindex);
				$("#gdlist").val("");
			 }
		});
	}
}

function setUnPlace(id)
{
	if(confirm('确认取消归档？')){
		ajax.regEvent("setunplace")
		ajax.addParam('ordlist', id);
		ajax.send(function(r){
			 if (r == "0") {
				app.Alert("没有选择可取消归档的文件,请重新选择后再取消归档！");
			 }
			 else
			 {	
				$("#gdlist").val("");
				var pindex = (document.getElementById("pindex")?document.getElementById("pindex").value:1)
				select_psize(pindex);
			 }
		});
	}	
}

function select_psize(pIndex)
{
	var jstype=$("#jstype").val();
	if (jstype=="0")
	{
		doSearch(pIndex);
	}
	else
	{
		doAllSearch(pIndex);
	}
}

function doSearch(pIndex) {
	$("#jstype").val(0);
	ajax.regEvent("dosearch")
	ajax.addParam('jstype', 0);
	ajax.addParam('indate1', $('#indate1').val());
	ajax.addParam('indate2', $('#indate2').val());
	ajax.addParam('spflag', $('#spflag').val());
	ajax.addParam('tbi', $('#tbi').val());
	ajax.addParam('key', $('#key').val());
	ajax.addParam('areamenu_list', $('#areamenu_list').val());
	ajax.addParam('areamenu2', $('#areamenu2').val());
	ajax.addParam('remind', $('#remind').val());
	ajax.addParam('lie_1', $('#lie_1').val());
	ajax.addParam('lie_2', $('#lie_2').val());
	ajax.addParam('lie_3', $('#lie_3').val());
	ajax.addParam('px', $('#px').val());
	ajax.addParam("Psize",$('#sizepage').val());
	ajax.addParam("gdlist",$('#gdlist').val());
	
	//pIndex==1表示要带上当前的翻页条件
	try{
		ajax.addParam("pageindex",pIndex==1?1:document.getElementById("pindex").value);
	}catch(e){}
	ajax.send(function(r){
		document.getElementById("lvwbody").innerHTML = r;
	});
}
function searchClick() {
	doAllSearch(0);
	if(document.getElementById("kh")){document.getElementById("kh").style.display="";}
	if(document.getElementById("toolbar1")){document.getElementById("toolbar1").style.display="";}
	document.getElementById("as_ing").value=0;
	document.getElementById("searchitemsbutton").style.display="block";
	document.getElementById("searchitemspanel").style.display="none"
}

function getChecked(obkstr)
{
	var checkszt="";	
	var dtypes=document.getElementsByName(obkstr);	
	for (var i=0;i<dtypes.length ;i++ )
	{		
		if (dtypes[i].checked==true)
		{			
			if (checkszt.length==0)
			{
				checkszt=dtypes[i].value;
			}
			else
			{
				checkszt = checkszt + "," + dtypes[i].value;
			}
		}
	}	
	return checkszt;
}
function doAllSearch(pIndex)
{	
	var w1 = getChecked("W1");
	var w2 = getChecked("W2");
	var w3 = getChecked("W3");
	var checkszt=getChecked("c_zt");
	$("#jstype").val(1);
	ajax.regEvent("dosearch")
	ajax.addParam('jstype', 1);
	ajax.addParam('indate1', $('#date7_0').val());
	ajax.addParam('indate2', $('#date7_1').val());
	ajax.addParam('date3', $('#date3_0').val());
	ajax.addParam('date4', $('#date3_1').val());
	ajax.addParam('spflag', checkszt);
	ajax.addParam('w1', w1);
	ajax.addParam('w2', w2);
	ajax.addParam('w3', w3);
	ajax.addParam('swdname_0', $('#swdname_0').val());
	ajax.addParam('swdname', $('#swdname_1').val());
	ajax.addParam('swdtitle_0', $('#swdtitle_0').val());
	ajax.addParam('swdtitle', $('#swdtitle_1').val());
	ajax.addParam('swdid_0', $('#swdid_0').val());
	ajax.addParam('swdid', $('#swdid_1').val());
	ajax.addParam('WDType_0', $('#WDType_0').val());
	ajax.addParam('WDType', $('#WDType_1').val());
	ajax.addParam('WDSize_0', $('#WDSize_0').val());
	ajax.addParam('WDSize_1', $('#WDSize_1').val());
	ajax.addParam('WDunit', $('#f_unit').val());
	ajax.addParam('areamenu_list', $('#areamenu_list').val());
	ajax.addParam('areamenu2', $('#areamenu2').val());
	
	ajax.addParam('lie_1', $('#lie_1').val());
	ajax.addParam('lie_2', $('#lie_2').val());
	ajax.addParam('lie_3', $('#lie_3').val());
	ajax.addParam('px', $('#px').val());
	ajax.addParam("Psize",$('#sizepage').val());
	ajax.addParam("pageindex",pIndex==1?(document.getElementById("pindex")?document.getElementById("pindex").value:1):1);
	ajax.send(function(r){
		document.getElementById("lvwbody").innerHTML = r;
	});	
}
document.body.onload = function(){
	document.getElementById("toolbar1").style.width=document.body.scrollWidth+"px";//document.getElementById("lvw_dbtable_ids1").style.width;
	document.getElementById("lvwbody").style.width=document.body.scrollWidth+"px";
	window.onresize=function() {
		document.getElementById("toolbar1").style.width=document.body.scrollWidth+"px";
		document.getElementById("lvwbody").style.width=document.body.scrollWidth+"px";
	}
}

function checkall(obj)
{
	$(".lvcbox").attr("checked", obj.checked);  
}

function showmenu(tag) {
	if (document.getElementById('asasd'))
	{
		document.getElementById("asasd").style.display='';
	}
	else 
	{	
		var obj=document.createElement("div");
		obj.id="asasd";
		obj.style.cssText="Z-INDEX:20000; POSITION: absolute; HEIGHT: 270px; TOP: 48px; LEFT: 166px";
		var html;
		html="";
		html=html+"<TABLE border=0 cellSpacing=-2 cellPadding=-2 width=160 height=300>";
		html=html+"<TBODY><TR><TD height=139>";
		html = html + "<TABLE border=0 width=160 bgColor=#ecf5ff class='resetTableBgColor' height=115><TBODY>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(1);select_psize(1);\"><FONT color=#2f496e>按照上传时间排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(2);select_psize(1);\"><FONT color=#2f496e>按照上传时间排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(3);select_psize(1);\"><FONT color=#2f496e>按照文件名称排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(4);select_psize(1);\"><FONT color=#2f496e>按照文件名称排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(5);select_psize(1);\"><FONT color=#2f496e>按照类型排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(6);select_psize(1);\"><FONT color=#2f496e>按照类型排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(7);select_psize(1);\"><FONT color=#2f496e>按照大小排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(8);select_psize(1);\"><FONT color=#2f496e>按照大小排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(9);select_psize(1);\"><FONT color=#2f496e>按照所有者排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(10);select_psize(1);\"><FONT color=#2f496e>按照所有者排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(11);select_psize(1);\"><FONT color=#2f496e>按照阅读数排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(12);select_psize(1);\"><FONT color=#2f496e>按照阅读数排序(升)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(13);select_psize(1);\"><FONT color=#2f496e>按照下载数排序(降)</FONT></A></span></TD></TR>";
		html=html+"<TR vAlign=center><TD height=24 colSpan=2><span style='margin-left:20px;'><A href='###' onclick=\"document.getElementById('asasd').style.display='none';$('#px').val(14);select_psize(1);\"><FONT color=#2f496e>按照下载数排序(升)</FONT></A></span></TD></TR>";
		html=html+"</TBODY></TABLE>";
		html=html+"</TD></TR></TBODY>";
		html=html+"</TABLE>";
		obj.innerHTML=html;
		document.body.appendChild(obj);
		//预算主题、预算编号、预算状态、开始日期、截止日期、添加时间和添加人员的升降序进行排列数据
	}
}

function setLockItems(obj,strVal)
{
	obj.title = obj.checked ? "取消标题栏" : "默认标题栏";
	ajax.regEvent("setheads")
	ajax.addParam('isopen', obj.checked?"1":"0");
	ajax.addParam('ldata', strVal);
	ajax.send();
}

function page_Pre_Next(pIndex)
{
	document.getElementById("pindex").value=pIndex;
	select_psize(pIndex);
}