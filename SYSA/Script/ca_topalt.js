
function frameResize(){
    if(!I1){return;}
    document.getElementById("cFF").style.height = I1.document.body.scrollHeight + 0 + "px";
}

try {
	if(!HTMLElement.prototype.swapNode) {
		HTMLElement.prototype.swapNode = function(node2) {
				var node1=this;
				var parent=node1.parentNode;
				var parent2=node2.parentNode;
				var t1=node1.nextSibling;
				var t2=node2.nextSibling;

				if(t1) {
					parent.insertBefore(node2,t1);
				} else {
					parent.appendChild(node2);
				};

				if(t2) {
					parent2.insertBefore(node1,t2);
				} else {
					parent2.appendChild(node1);
				};
			}
		}
	}
catch (e){}

function altChgOrder(altord,subId,chgtp,obj){
	var tdobj=obj.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
	var trobj=tdobj.parentElement;
	var tbobj=trobj.parentElement.parentElement;
	var tmpord;

	if(chgtp==1){/*左移*/
		if(tdobj.cellIndex==0){//防止到顶，上移报错.binary
			try{
				if(trobj.rowIndex>0){
					tdobj.swapNode(tbobj.rows[trobj.rowIndex-1].cells[2]);
				}
			}catch(e){}
		}else{
			trobj.cells[tdobj.cellIndex - 1].swapNode(tdobj);
		}
	}else if(chgtp==2){/*上移*/
		if(trobj.rowIndex>0){
			tdobj.swapNode(tbobj.rows[trobj.rowIndex-1].cells[tdobj.cellIndex]);
		}
	}else if(chgtp==3){/*下移，当目标单元格是空时，不移动*/
		if(trobj.rowIndex<(tbobj.rows.length-1) && 
			tbobj.rows[trobj.rowIndex+1].cells[tdobj.cellIndex] && 
			tbobj.rows[trobj.rowIndex+1].cells[tdobj.cellIndex].getAttribute("ord")
			){
			tdobj.swapNode(tbobj.rows[trobj.rowIndex+1].cells[tdobj.cellIndex]);
		}
	}else if(chgtp==4){/*右移*/
		if(tdobj.cellIndex==2){//第三列向右移特殊处理，当目标单元格是空时，不移动
			if(trobj.rowIndex<(tbobj.rows.length-1) && 
				tbobj.rows[trobj.rowIndex+1].cells[0] &&
				tbobj.rows[trobj.rowIndex+1].cells[0].getAttribute("ord")
				){
				tdobj.swapNode(tbobj.rows[trobj.rowIndex+1].cells[0]);
			}
		}else{
           if (trobj.cells[tdobj.cellIndex + 1]!=null && trobj.cells[tdobj.cellIndex + 1].getAttribute("ord")){
			  trobj.cells[tdobj.cellIndex + 1].swapNode(tdobj);
           }
		}
	}else if(chgtp==5){/*关闭*/
		jQuery.ajax({
			url:'../inc/ReminderCall.asp?act=closeRemind',
			data:{ord:tdobj.getAttribute("ord"),subId:tdobj.getAttribute("subId")},
			cache:false/*,

			success:function(h){
				var $div = jQuery('<div style="position:absolute;left:0px;top:0px;width:100%;height:100%;z-index:9999"></div>');
				$div.html(h).appendTo(document.body);
			},
			error:function(rep){
				var $div = jQuery('<div style="position:absolute;left:0px;top:0px;width:50%;height:50%;z-index:9999"></div>');
				$div.html(rep.responseText).appendTo(document.body);
			}
*/
		});

		var ridx=trobj.rowIndex;
		var cidx=tdobj.cellIndex;
		tdobj.innerHTML="";
		tdobj.ord="";
		var tmpobj;
		for(var i=0;i<tbobj.rows.length;i++){
			for(var j=0;j<trobj.cells.length;j++){
				if(tmpobj&&tbobj.rows[i].cells[j]) tmpobj.swapNode(tbobj.rows[i].cells[j]);
				if(i>=ridx&&j>=cidx){
					tmpobj=tbobj.rows[i].cells[j];
				}
			}
		}
	}
	
	if (chgtp!=5){
		var cids = "";
		jQuery('.alt_cells').each(function(){
			cids+= (cids==""?"":",") + $(this).attr("ord") + "_" + $(this).attr("subId");
		});
		
		jQuery.ajax({
			url:'../inc/ReminderCall.asp?act=updOrder',
			data:{cids:cids},
			cache:false
		});
	}
}
