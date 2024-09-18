//返回自动完成结果
window.SetAutoCompleteResultAtEvent = function (evid) {
    var urlatts = window.location.href.split("?")[1].split("&");
    var result = { "value": "", "text": "", keys: {}, "tag": null };
    for (var i = 0; i < urlatts.length; i++) {
        var item = urlatts[i].split("=");
        result.keys[item[0]] = encodeURI(item[1]);
    }
    switch (evid) {
        case "gatetree.radio.click":  
            window.Set_Gatetree_Radio_Result(result);
            break;
        case "gatetree.checkboxs.click":
            window.Set_Gatetree_Checkboxs_Result(result);
            break;
    }
}

window.Set_Gatetree_Checkboxs_Result = function (result) {
    var cnodes = window.TreeView.GetCheckedNodes(window.TreeView.objects[0]);
    var texts = [], values = [];
    for (var i = 0; i < cnodes.length; i++) {
        var n = cnodes[i];
        //类似于人员/仓库选择树前端这边用datas接收树节点外挂信息，用datas第二位卡位区分是否是叶子节点;1.data[1]==1;2.数组长度小于2都代表叶子节点
        if (((n.datas && n.datas[1] == "1") || (n.datas && n.datas.length < 2) || !n.datas) && n.checked) {
            texts.push(n.text);
            values.push(n.value);
        }
    }
    result.text = texts.join(" ");
    result.texts = texts;
    result.value = values.join(",");
    result.tag = cnodes;
    result.tree = window.TreeView.objects[0];
	var objid = $ID("OptionValue_0check");
	if(objid && objid.checked) { //所有人员
        result.text = "所有人员";
        result.texts = ["所有人员"];
		result.value = "0";
		result.tag = [];
	}
    if (opener && opener.OnFieldAutoCompleteCallBack) {
        opener.OnFieldAutoCompleteCallBack(result);
        setTimeout("window.close()", 50);  //加定时器，防止谷歌死锁
    }
}

window.Set_Gatetree_Radio_Result = function (result) {
    var jnode = window.TreeView.GetCurrEventJNode(window.TreeView.objects[0]);
    if (jnode && jnode.discheck != true && jnode.nodescount == 0) {
        if (opener && opener.OnFieldAutoCompleteCallBack) {
            result.text = jnode.text;
            result.texts = [jnode.text];
            result.value = jnode.value;
            result.tag = jnode;
            result.tree = window.TreeView.objects[0];
            opener.OnFieldAutoCompleteCallBack(result);
            setTimeout("window.close()", 50);  //加定时器，防止谷歌死锁
        }
    }
}

window.createOldPage = window.createPage;
window.createPage = function() {
    if(opener&&opener.AutoCompleteShowUrlPageCurrDefaultValue) {
		var fields = window.PageInitParams[0].groups[0].fields;
		for (var i = 0; i < fields.length ; i ++ )
		{
			var fd = fields[i];
			if (fd.uitype == "gatestree") {
				var jtvw = fd.tree;
				jtvw.gateuimodel = true;
				window.TreeView.SetNodesChecked(jtvw, opener.AutoCompleteShowUrlPageCurrDefaultValue, true);
				break;
			}
			if (fd.uitype == "treeview") {
			    var jtvw = fd.tree;
			    if (opener.AutoCompleteShowUrlPageCurrDefaultValue == "0") {
			        window.TreeView.CheckAll(jtvw,true);
			    } else {
			        window.TreeView.SetNodesChecked(jtvw, opener.AutoCompleteShowUrlPageCurrDefaultValue, true);
			    }
			    break;
			}
		}
    };
    if ((opener && opener.AutoCompleteShowUrlPageCurrDefaultValue + "") !== "0") {
		setTimeout(function(){ if($ID("OptionValue_1check")){$ID("OptionValue_1check").click();} },100);
	}
	window.createOldPage();
}