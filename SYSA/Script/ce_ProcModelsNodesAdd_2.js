
var row_count = $("#table1 tr").length; 
function addNew() 
{ 
var table1 = $('#table1'); 
var firstTr = table1.find('tbody>tr:first'); 
var row = $("<tr></tr>"); 
var td = $("<td width='180' valign='top' nowrap='nowrap'></td>"); 
td.append($("<input type='checkbox' name='count' id='count' value='"+row_count+"'><input type='text' id='zdymc"+row_count+"' name='zdymc"+row_count+"' size='15'>")); 
row.append(td); 
table1.append(row); 
var td = $("<td valign='top' width='20'></td>"); 
td.append($("<select onchange='TypeChange(this.value,"+row_count+")' id='zdyys"+row_count+"' name='zdyys"+row_count+"'><option value=1 selected>单行文本</option><option value=2>多行文本</option><option value=3>日期</option><option value=4>数字</option><option value=5>备注</option><option value=6>是/否</option><option value=7>自定义列表</option></select>")); 
row.append(td); 
table1.append(row); 
var td = $("<td valign='top' width='360'></td>"); 
td.append($("<table width='100%' border='0' cellpadding='3' cellspacing='1' id='tab"+row_count+"' style='display:none' bgcolor='#C0CCDD'><tr><td>字段内容</td><td>操作</td></tr><tr id='123tab' class='myxx"+row_count+"'><td colspan=3>没有信息<span class='blue2"+row_count+"' style='cursor:hand;'><img src='../images/jiantou.gif' border='0'>增加</span></td></tr></table>")); 
row.append(td); 
table1.append(row); 
row_count++; 
} 
function del() 
{ 
var checked = $("input[type='checkbox'][name='count']"); 
$(checked).each(function(){ 
if($(this).attr("checked")==true) 
{ 
$(this).parent().parent().remove(); 
} 
}); 
} 
//7 自定义列表值
function TypeChange(id,str){
	if(id == 7){
	 $("#tab"+str).css("display", "block");
	tabop(str);

	}else{
	 $("#tab"+str).css("display", "none");
	}
}

var _len  = 0;
var iv  = 0;

function tabop(str){
     $(document).ready(function(){
         //<tr/>居中
        $("#tab"+str+" tr").attr("align","center");
        //增加<tr/>
		iv ++
	    $(".blue2"+str).live('click',function(){
			 //alert(str);
           _len ++;
			var rowid = str + "_" + _len;
            $("#tab"+str).append("<tr id="+ rowid +" align='center' height='20'>"
                 +"<td><input type='text'  name='desc"+str+"' id='desc"+str+"' size='10'/></td>"
                 +"<td><input class='blue2"+str+"' type='button' value='增加' id='but"+rowid+"' style='color: #5B7CAE;background-image: url(../images/m_an2.gif);background-repeat: no-repeat;height: 20px;width: 49px;font-size: 12px;border:0;background-color:transparent;padding-top:3px;padding-left:0px;padding-right:0px;'/> <input class='page' type='button' value='删除' onclick=rowdel('"+rowid+"','"+str+"') /></td>"
                 +"</tr>");  			          
			 $(".myxx"+str).css("display", "none");
			// alert(str);
		})
    })
}	

//删除<tr/>
function rowdel(rowid,str){
		var myxxyc = $("#tab"+str+" tr").length; 
		if(myxxyc==2){
		$(".myxx"+str).css("display", "block");
		}
		if(myxxyc<2){
			alert("自定义列值不能为空！");
		}else{
		        $("tr[id='"+rowid+"']").remove();//删除当前行

		}
}
