var position = 0 ;
function setFormula(header,rowindex,sourceSort,obj)
{	//app.Alert("header="+header+",rowindex="+rowindex+",sourceSort="+sourceSort);
	try{
		var body = obj.value;
		var rowcount = $("#rowcount").val();	
		var html="<div style='" + (rowcount>36 ? "overflow:auto;height:400px":"") + "'>";
		html = html + "<div id='target' class='div_li' style='border:1px solid #ccc;width:98%;height:70px;float:left;margin:5px;overflow:auto;cursor:default'>"
		html = html + "</div>" ;
		html = html + "<table style='height:300px'><tr><td height='100%' width='50%' rowspan=2 valign='top'>" ;
		if (sourceSort ==3 )
		{
			html = html + "<iframe src='../../finance/config/setFlowSubject.asp?sort=3' frameborder=0  style='margin:0px;border:0px;width:100%;height:100%;overflow:auto;'></iframe>";
		}
		else
		{
			html = html + "<iframe src='../../finance/config/setaccountsubject.asp?sort=4' frameborder=0  style='margin:0px;border:0px;width:100%;height:100%'></iframe>";
		}
		html = html + "</td><td  height='50%' valign='top' style='padding-left:10px'>";
		html = html + "<div class='div_li' style='cursor:default'>&nbsp;";
		if (sourceSort ==3)
		{
			html = html + "<li title='点击设置 本年累计金额' style='width:80px' onclick='copyClick(this)'>本年累计金额</li>";
			html = html + "<li title='点击设置 本月金额' style='width:60px' onclick='copyClick(this)'>本月金额</li>";
			html = html + "<li title='点击设置 本年期初现金余额' style='width:100px' onclick='copyClick(this)'>本年期初现金余额</li>";
			html = html + "<li title='点击设置 本月期初现金余额' style='width:100px' onclick='copyClick(this)'>本月期初现金余额</li>";
		}
		else
		{
			html = html + "<li title='点击设置 期末借方余额' style='width:80px' onclick='copyClick(this)'>期末借方余额</li>";
			html = html + "<li title='点击设置 期末贷方余额' style='width:80px' onclick='copyClick(this)'>期末贷方余额</li>";
			html = html + "<li title='点击设置 年初借方余额' style='width:80px' onclick='copyClick(this)'>年初借方余额</li>";
			html = html + "<li title='点击设置 年初贷方余额' style='width:80px' onclick='copyClick(this)'>年初贷方余额</li>";
			html = html + "<li title='点击设置 本月借方金额' style='width:80px' onclick='copyClick(this)'>本月借方金额</li>";
			html = html + "<li title='点击设置 本月贷方金额' style='width:80px' onclick='copyClick(this)'>本月贷方金额</li>";
			html = html + "<li title='点击设置 本年累计借方金额' style='width:100px' onclick='copyClick(this)'>本年累计借方金额</li>";
			html = html + "<li title='点击设置 本年累计贷方金额' style='width:100px' onclick='copyClick(this)'>本年累计贷方金额</li>";
		}

		for (var i = 1 ;i<=rowcount ;i++ )
		{
			html = html + "<li title='点击设置 行"+i+"' style='width:30px;"+(i==1?"clear:left;":"")+"' onclick='copyClick(this)'>H"+i+"</li>";
		}
		html = html + "<li title='点击设置 +' style='width:30px' onclick='copyClick(this)'>+</li>";
		html = html + "<li title='点击设置 -' style='width:30px' onclick='copyClick(this)'>-</li>";
		html = html + "<li title='点击设置 *' style='width:30px' onclick='copyClick(this)'>*</li>";
		html = html + "<li title='点击设置 /' style='width:30px' onclick='copyClick(this)'>/</li>";
		html = html + "<li title='点击设置 (' style='width:30px' onclick='copyClick(this)'>(</li>";
		html = html + "<li title='点击设置 )' style='width:30px' onclick='copyClick(this)'>)</li>";
		html = html + "</div><div align=center style='clear:both;padding-top:10px;'><input type='button' value='确定' class='oldbutton' onclick='setFormulaCell("+header+","+rowindex+")' >&nbsp;&nbsp;<input type='button' value='取消' class='oldbutton' onclick=$('#w').window('close') ></div>" ;
		html = html + "</td></tr></table></div>";
		$('#w').html(html).window({
			title:'报表公式设置',
			width:630,
			height:420,
			top:100+document.body.scrollTop + document.documentElement.scrollTop,
			closeable:true,
			collapsible:false,
			minimizable:false,
			maximizable:false,
			resizable:true,
			onOpen:function(){			
					$('#target').mouseleave(function(){
						$("span:[name=del_span]").remove();
					 });
				}
		}).window('open');
		resolveFormula(body,rowcount,sourceSort);
	}
	catch(e){}
}

function copyClick(obj){
	var $li = $(obj).clone();
	$li.attr("onclick","");
	$li.attr("del",position).mouseover(function(){
		$("span:[name=del_span]").remove();
		var $obj = $(this);
		var pos = $obj.attr("del");
		var $close = $('<span name="del_span" id="del_'+pos+'" style="position:absolute;height:5px;color:red" onclick="deleteSpan('+pos+')">x</span>');
		$close.appendTo($("#target"));
		$close.css({
			left:$obj.position().left + $obj.width(),
			top:$obj.position().top-$close.height()
		});
	}).appendTo($("#target"));

	$li.draggable({
			proxy:'clone',
			revert:true,
			cursor:'auto'
	}).droppable({
		//accept:'#d1,#d3',
		onDragEnter:function(e,source){
			try{
			$(source).draggable('options').cursor='auto';
			}catch(e){}
		},
		onDragLeave:function(e,source){
			$(source).draggable('options').cursor='auto';
		},
		onDrop:function(e,source){
			$(source).insertBefore(this);// insertAfter
		 }
	})

	position++;
}

function deleteSpan(pos){
	$("li[del="+pos+"]").remove();
	$("span:[name=del_span]").remove();
}
function checkSubject(typ,ord)
{
	ajax.regEvent("searchSubject")
	ajax.addParam('ord', ord);
	ajax.addParam('typ', typ);
	var r = ajax.send();
	if (r.length>0)
	{
		var width = r.split("||")[0].length * 12 ; 
		var $s = $("<li title='点击设置 "+r.replace("||"," ")+"' style='width:"+width+"px' >"+r.split("||")[0]+"</li>");
		copyClick($s);
	}
}
//保存设置的公式
function setFormulaCell(header,rowindex){
	var formula = "";
	$("#target").find("li").each(function(){
		formula = formula + $(this).html();
	});
	//此处缺少初步 公式 验证的过程
	$("#cell_"+header+"_"+rowindex+"").val(formula);
	$('#w').window('close');
}

//初步解析公式
function resolveFormula(body , rowcount ,sourceSort){
	if (body.length>0)
	{	
		var html = "";
		var min_index = minIndex(body);

		html=getLiHtml(body ,min_index , rowcount , sourceSort);
		if (html.length>0)
		{
			copyClick($(html));
		}
		var leftbody = "";
		if (min_index == 0 )
		{	
			leftbody = body.substring(1);
		}
		else if (min_index>0)
		{
			leftbody = body.substring(min_index);
		}
		
		resolveFormula(leftbody , rowcount ,sourceSort);
	}
}
//获取计算符号最小位置
function minIndex(body) //返回大于等于0 的值 
{
	var fz_index = body.indexOf("(");
	var fy_index = body.indexOf(")");
	var add_index = body.indexOf("+");
	var stn_index = body.indexOf("-");
	var mpt_index = body.indexOf("*");
	var dvs_index = body.indexOf("/");
	var min_index = -1;
	if (fz_index>=0){min_index = fz_index ;}
	if ((fy_index<min_index && fy_index>=0) || min_index == -1){ min_index = fy_index ;}
	if ((add_index<min_index && add_index>=0) || min_index == -1){ min_index = add_index ;}
	if ((stn_index<min_index && stn_index>=0) || min_index == -1){ min_index = stn_index ;}
	if ((mpt_index<min_index && mpt_index>=0) || min_index == -1){ min_index = mpt_index ;}
	if ((dvs_index<min_index && dvs_index>=0) || min_index == -1){ min_index = dvs_index ;}
	return min_index;
}

function getLiHtml(str, min_index , rowcount ,sourceSort)
{
	var s="" ;
	var str_cell = "";
	if (min_index == -1){
		min_index =str.length;//当min_index = -1 时 说明内容中没有符号
	}
	else if (min_index == 0)
	{
		min_index =1;//当min_index = 0 时 说明第一位为符号
	}
	if (min_index>0 )
	{
		str_cell = str.substring(0,min_index);
	}	
	if (str_cell.length>0)
	{
		var cells = "期末借方余额,期末贷方余额,年初借方余额,年初贷方余额,本年累计借方金额,本年累计贷方金额,本月借方金额,本月贷方金额,本年累计金额,本月金额,本年期初现金余额,本月期初现金余额,+,-,*,/,(,)" ;
		for (var i = 1 ;i<=rowcount ;i++ )
		{
			cells = cells + ",H"+i;
		}
		var cellarr = cells.split(",");
		var width = 0 ;
		for (var i=0;i<cellarr.length ;i++ )
		{
			if (str_cell==cellarr[i])
			{	
				if(i==0||i==1||i==2||i==3||i==6||i==7||i==8)
				{
					width = 80 ;
				}
				else if(i==4||i==5||i==10||i==11){
					width = 100 ;
				}
				else if(i==9){
					width = 60 ;
				}
				else
				{
					width = 30;
				}
				s = "<li title='点击设置 "+str_cell+"' style='width:" + width +"px'>"+str_cell+"</li>" ; 
				break;
			}
		}
		if (s.length==0) //界面设置没有的时 从服务端检测会计科目 和现金流量项目
		{
			var typ = 1 ;
			if (sourceSort==3) { typ = 2 ;}
			ajax.regEvent("searchSubject_bh")
			ajax.addParam('bh', str_cell);
			ajax.addParam('typ', typ);
			var r = ajax.send();
			if (r.length>0)
			{
				width = r.split("||")[0].length * 12 ; 
				s = "<li title='点击设置 "+r.replace("||"," ")+"' style='width:"+width+"px' >"+r.split("||")[0]+"</li>" ;
			}
		}
	}
	return s;
}
var editObj = null;
function setRow(obj)
{
	var rowcount = $("#rowcount").val();
	if (rowcount=="1"){return;}
	editObj = obj;
	var dhtml=document.getElementById('dhtml');
	//var obj=event.srcElement;
	var x=obj.offsetLeft,y=obj.offsetTop;
	var obj2=obj;
	var offsetx=25;
	//var mousePos = mouseCoords(event);
	while(obj2=obj2.offsetParent)
	{
		x+=obj2.offsetLeft;
		y+=obj2.offsetTop;
	}
	var left=parseInt(x);
	var top=parseInt(y);
	//dhtml.innerHTML = "点击编辑行" ;
	dhtml.style.top=top;
	dhtml.style.left=left+$(obj).width()-2; //;+ mousePos.x;
	//app.Alert(left);
	dhtml.style.display='block';
	$("#dhtml").bind("mouseleave",function(){
		$('#dhtml').css('display','none');
	});
	$("#dhtml").bind("mouseover",function(){
		$('#dhtml').css('display','');
	});
	//app.Alert("点击编辑行");
}
/*
function mouseCoords(ev) 
{ 
	if(ev.pageX || ev.pageY){ 
		return {x:ev.pageX, y:ev.pageY}; 
	} 
	return{ 
		x: document.body.scrollLeft - document.body.clientLeft, 
		y: document.body.scrollTop - document.body.clientTop 
	}; 
}
*/

function editRow(typ,ord)
{
	var rowcount = $("#rowcount").val();

	if (typ==0 || typ==3)
	{
		ajax.regEvent("editRow")
		ajax.addParam('ord', ord);
		ajax.addParam('typ', typ);
		ajax.addParam('rowcount', rowcount);
		var r = ajax.send();
	}
	var cellIndex = $(editObj).parent().parent().index(); //当前列index
	//app.Alert(td_index);
	var cell = []
	//deleted.push(p1);
	//deleted.push(p2);
	//deleted.push(p3);

	switch (typ)
	{
	case 0: //添加
		var currentRow=$('.content:first tbody tr:eq('+(Number(rowcount)+1)+')');
		currentRow.before(r);
		$("#rowcount").val(Number(rowcount)+1);
		break;
	case 1: //上移
		var td = editObj.parentNode.parentNode;
		var cindex = td.cellIndex;
		var tr = td.parentNode;
		if(tr.rowIndex<=1) { break; }
		var preRow = tr.parentNode.rows[tr.rowIndex-1];
		for (var i = cindex+1 ; i<tr.cells.length;i++ )
		{
			if(tr.cells[i].className=="xh") { break;}
			tr.cells[i].swapNode(preRow.cells[i]);
		}
		break;
	case 2: //下移
		var td = editObj.parentNode.parentNode;
		var cindex = td.cellIndex;
		var tr = td.parentNode;
		if(tr.rowIndex>=tr.parentNode.rows.length-2) { break; }
		var preRow = tr.parentNode.rows[tr.rowIndex+1];
		for (var i = cindex+1 ; i<tr.cells.length;i++ )
		{
			if(tr.cells[i].className=="xh") { break;}
			tr.cells[i].swapNode(preRow.cells[i]);

		}
		break;
	case 3: //插入
		var td = editObj.parentNode.parentNode;
		var cindex = td.cellIndex;
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		var rowindex = tr.rowIndex;
		var lastRow = tbody.rows[tbody.rows.length-2];
		
		var isnulltr = true;
		for (var i = cindex+1 ; i<lastRow.cells.length;i++ )
		{
			if(lastRow.cells[i].className=="xh") { break;}
			if(lastRow.cells[i].getElementsByTagName("input")[0].value.length>0) {
				isnulltr = false;
				break;
			}
		}
		
		if(isnulltr == false) {
			var currentRow=$('.content:first tbody tr:eq('+(Number(rowcount)+1)+')');
			currentRow.before(r);
			rowcount =  rowcount*1 + 1;
			$("#rowcount").val(rowcount);
		}
		for (var ii = rowcount*1; ii >  rowindex ; ii-- )
		{
			tr = tbody.rows[ii];
			preRow = tbody.rows[ii-1];
			for (var i = cindex+1 ; i<tr.cells.length;i++ )
			{
				if(tr.cells[i].className=="xh") { break;}
				tr.cells[i].swapNode(preRow.cells[i]);

			}
		}
		break;
	case 4: //删除
		var td = editObj.parentNode.parentNode;
		var cindex = td.cellIndex;
		var tr = td.parentNode;
		var tbody = tr.parentNode;
		if(tbody.rows.length<=3) { break; }
		var rowindex = tr.rowIndex;
		for (var ii = rowindex ; ii < rowcount*1 ; ii++)
		{
			tr = tbody.rows[ii];
			var nextRow = tbody.rows[tr.rowIndex+1];
			for (var i = cindex+1 ; i<tr.cells.length;i++ )
			{
				if(tr.cells[i].className=="xh") { break;}
				tr.cells[i].swapNode(nextRow.cells[i]);

			}
		}
		var tr = tbody.rows[tbody.rows.length-2]
		for (var i = cindex+1 ; i<tr.cells.length;i++ )
		{
			if(tr.cells[i].className=="xh") { break;}
			tr.cells[i].getElementsByTagName("input")[0].value = "";
		}
		var isnulltr = true ;
		for (var i = 1 ; i<tr.cells.length;i++ )
		{
			if(tr.cells[i].className!="xh") { 
				if(tr.cells[i].getElementsByTagName("input")[0].value.length>0) {
					isnulltr = false;
					break;
				}
			}
		}
		if (isnulltr){
			tbody.deleteRow(tbody.rows.length-2);
			$("#rowcount").val(rowcount*1-1);
		}
		break;
	default :
		app.Alert("请正确操作");
		break;
	}
	$('#dhtml').css('display','none');
	editObj = null ;
}

  function addRowByID(currentRowID){
       //遍历每一行，找到指定id的行的位置i,然后在该行后添加新行
       $.each($('table:first tbody tr'), function(i, tr){
           if($(this).attr('id')==currentRowID){
               //获取当前行
               var currentRow=$('table:first tbody tr:eq('+i+')');
               //要添加的行的id
               var addRowID=currentRowID+1;
               str = "<tr id = '"+addRowID+"'><td>"+addRowID+"</td><td>row"+addRowID+"</td>"+
               "<td><input id= '"+addRowID+"' type='button' value='添加行' onclick='addRowByID(this.id);' /></td></tr>";
               //当前行之后插入一行
               currentRow.after(str);
           }
       });
   }
