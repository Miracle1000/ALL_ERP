function CheckChange(lvw, rowindex, cellindex)
{
	//处理变更通知的联动
    var linkageCheck = lvw.rows[rowindex][cellindex];
    var chindex = -1;
    var ntindex = -1;
    var treeindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "change") { chindex = i;}
        if (lvw.headers[i].dbname == "notice") { ntindex = i;}
        if (lvw.headers[i].dbname == "billtypename") { treeindex = i;}
    }
    if(linkageCheck){ __lvw_je_updateCellValue(lvw.id, rowindex, ntindex, linkageCheck); }
    
    //处理数节点层级联动
    var curTreenode = lvw.rows[rowindex][treeindex];
    var curlen = 0;
    if(curTreenode.deepData!=undefined){ curlen = curTreenode.deepData.length; }
    //勾选
    if(linkageCheck){//Ps:兄弟节点|父节点|父节点的兄弟节点
    	function CheckBroAndOnlyParent(rowindex,curlen,checkState){
	    	//处理兄弟节点
	    	for(var i = rowindex-1; i>=0; i--){
	    		var curNode = lvw.rows[i][treeindex];
	    		if(curNode.deepData!=undefined){
					if(curNode.deepData.length < curlen){ break;}
					if(curNode.deepData.length == curlen){
						lvw.rows[i][chindex] = checkState;
						lvw.rows[i][ntindex] = checkState;
					}
				}
	    	}
	    	for(var i = rowindex+1; i<lvw.rows.length;i++){
	    		var curNode = lvw.rows[i][treeindex];
	    		if(curNode.deepData!=undefined){
					if(curNode.deepData.length < curlen){ break;}
					if(curNode.deepData.length == curlen){
						lvw.rows[i][chindex] = checkState;
						lvw.rows[i][ntindex] = checkState;
					}
				}
	    	}
	    	//查找单一父节点
	    	for(var i = rowindex-1; i>=0; i--){
	    		var curNode = lvw.rows[i][treeindex];
	    		if(curNode.deepData!=undefined){
					if(curNode.deepData.length >= 0 && curNode.deepData.length == (curlen - 1)){ 
						lvw.rows[i][chindex] = checkState;
						lvw.rows[i][ntindex] = checkState;
						CheckBroAndOnlyParent(i,curNode.deepData.length,linkageCheck); //递归
						break;
					}
				}
	    	}
	    }
    	CheckBroAndOnlyParent(rowindex,curlen,linkageCheck);
    }//取消
    else{
    	for(var i = rowindex-1; i>=0; i--){
    		var curNode = lvw.rows[i][treeindex];
    		if(curNode.deepData!=undefined){
				if(curNode.deepData.length < curlen){ break;}
				if(curNode.deepData.length >= curlen){
					lvw.rows[i][chindex] = linkageCheck;
				}
			}
    	}
    	for(var ii = rowindex + 1; ii<lvw.rows.length; ii++){
			var cnode = lvw.rows[ii][treeindex];
			if(cnode.deepData!=undefined){
				if(cnode.deepData.length < curlen){ break;}
				if(cnode.deepData.length >= curlen){
					lvw.rows[ii][chindex] = linkageCheck;
				}
			}
		}
    }
	___RefreshListViewByJson(lvw);
	var canClick = true;
	for(var i=0;i<lvw.rows.length;i++){
		if(lvw.rows[i][chindex].toString() == "1"){ canClick = false;break; }
	}
	if(!canClick){ $("#zblibclsnotice").attr("disabled",""); }
	else{
		$("#zblibclsnotice").removeAttr("disabled");
	}
}

function SelectAllNotice(s,id){
	var lvw = window["lvw_JsonData_" + id];
    var chindex = -1;
    var ntindex = -1;
    for (var i = 0; i < lvw.headers.length; i++) {
        if (lvw.headers[i].dbname == "change") { chindex = i;}
        if (lvw.headers[i].dbname == "notice") { ntindex = i;}
    }
	if(s.checked){
	    for(var i = 0;i<lvw.rows.length;i++){
	    	lvw.rows[i][ntindex] = "1";
	    }
	    $("#zblibclsnotice").attr("disabled","");
	}else{
		$("#zblibclsnotice").removeAttr("disabled");
	}
}
