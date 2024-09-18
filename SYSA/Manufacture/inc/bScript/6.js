window.bill_onLoad = function(){
	var rank = -1000 , nBox = null , rBox = null
	var  inputs = document.getElementById("billBodyTable").getElementsByTagName("input")
	
	for (var i=0;i<inputs.length ; i ++ )
	{
		if(inputs[i].dbname && inputs[i].dbname.toLowerCase()=="rankcode"){
			rank  = inputs[i].value
			rBox = inputs[i]
		}
		if(inputs[i].dbname && inputs[i].dbname.toLowerCase()=="num"){
			nBox = inputs[i]
		}
		if(nBox && rank!=-1){
			if(rank==0){
				
				nBox.value = 1;
				nBox.className = "billreadonlytext";  //对于根节点,数量只能固定为1
				nBox.readOnly = true;
			}
			break;
		}
	}

	var pNameBox = Bill.getinputbyywname("产品名称");
	if(pNameBox){
		pNameBox.onchange = function(){
			var selectNode = tvw.getselectNode(document.getElementById("treeview_idmenutvw"));
			if(selectNode && selectNode.innerText!="产品结构" && pNameBox.value.length>0){
				tvw.updateNodeText(selectNode,pNameBox.value)
			}
		}
		pNameBox.onchange();//加载的时候更新一下节点名称
	}

	var tb = document.getElementById("listview_71").children[0];
	var tr = tb.rows[0]

	tr.cells[lvw.getCellIndexByName(tb,tr,"物品名称")].disztlr=1;
	tr.cells[lvw.getCellIndexByName(tb,tr,"存货位置")].disztlr=0;
}
var oldfun = lvw.oncallback;

 lvw.oncallback = function(div) {
	if(oldfun) {oldfun(div);}
	var tb = document.getElementById("listview_71").children[0];
	var tr = tb.rows[0]

	tr.cells[lvw.getCellIndexByName(tb,tr,"物品名称")].disztlr=1;
	tr.cells[lvw.getCellIndexByName(tb,tr,"存货位置")].disztlr=0;
 }


