function dofun(ftype, id) {
    switch (ftype) {
        case 0:
            app.OpenUrl("Company.ashx?ord=1");
            break;
        case 1:
            app.OpenUrl("Company.ashx?ord=1&view=details");
            break;
        case 2:
            app.OpenUrl("Department.ashx?parentid=" + id);
            break;
        case 3:
            var btn = window.event.srcElement;
            setNodeState(btn, id);
            break;
        case 4:
            app.OpenUrl("Department.ashx?ord=" + id);
            break;
        case 5:
            app.OpenUrl("Department.ashx?ord=" + id + "&view=details");
            break;
		case 6:
			if(window.confirm("确定要删除该部门吗？")==false) {return;}
			DelNode(id);
			break;
    }
}

function setNodeState(btn, id) {
    var txt = btn.innerHTML;
	if (window.confirm("确定要" + txt + "此部门吗？")==false) {
		return;
	}
    app.ajax.regEvent("setstate");
    app.ajax.addParam("id", id);
    app.ajax.addParam("state", (txt == "停用" ? 0 : 1))
    app.ajax.send();
}

function DelNode(id) {
    app.ajax.regEvent("DelNode");
    app.ajax.addParam("id", id);
    app.ajax.send();
}

function GetHandleHtml(id, stoped, account, childrencount) {
    if (id == -1) {
        return "<button onclick='dofun(2,0)'>添加</button><button onclick='dofun(0)'>修改</button><button onclick='dofun(1)'>详情</button>";
    } else {
		//stoped = 0 正常  stoped=1 已停用 stoped=100 上级停用
        return    (stoped >= 1? "" : "<button onclick='dofun(2," + id + ")'>添加</button>")
					+ "<button onclick='dofun(4," + id + ")'>修改</button>"
					+ ((account*1 + childrencount*1)==0 ? "<button onclick='dofun(6," + id + ")'>删除</button>" : "")
					+ "<button onclick='dofun(3," + id + ")'>" + (stoped == 1 ? "启用" : "停用") + "</button>"
					+ "<button onclick='dofun(5," + id + ")'>详情</button>";
    }
}

function doOrgsSel(id, fullpath) {
    Report.FieldAutoCompleteCallBack(id, window.event.srcElement.innerHTML, { "fullpath": fullpath });
}

function GetSelHtml(NodeText, NodeId, fullpath, BaseID){
	if(BaseID=='1') {
		return ("<a href='javascript:void(0)' onclick='doOrgsSel(" + NodeId +",\"" + fullpath +"\")'>" + NodeText + "<a>");
	} else {
		return ("<span style='color:#aaa'>" + NodeText + "</span>");
	}
}

Report.MyConvertFormatHtmlRow = function(Rows){
	ConvertStopedNodeHtml(Rows, 0);
}

function  ConvertStopedNodeHtml(Rows, parentstop) {
    if(!Rows)return;
	for (var i = 0;  i < Rows.length ; i ++ )
	{
		childrenstop = 0;
		if(parentstop==1) {
			Rows[i].stoped = Rows[i].stoped==1?1:100;
			childrenstop = 1;
			Rows[i].NodeText = "<span style='color:#ccc'>" +  Rows[i].NodeText + "</span>" + (Rows[i].stoped==1?" <span style='color:red'>【已停用】</span>" : "") ;
		}
		else {
			if(Rows[i].stoped=="1") {
				childrenstop = 1;	
				Rows[i].NodeText = "<span style='color:#ccc'>" +  Rows[i].NodeText + "</span> <span style='color:red'>【已停用】</span>";
			}
		}
		if(Rows[i].childrencount>0) {
			ConvertStopedNodeHtml(Rows[i].children, childrenstop);
		}
	}
}