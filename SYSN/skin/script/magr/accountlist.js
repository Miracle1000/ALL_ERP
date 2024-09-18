window.onTreeViewNodeClick = function (eobj) {
    $ID("orgsid").value = eobj.node.id;
	Report.SetSearchData(0); 
    Report.ReportSubmit();
}

function exeButtonFun(t, id) {
	if (window.SysConfig.SystemType == 100) {
		switch (t) {
			//case 0: app.OpenUrl("../../../SYSC/view/content.asp?ord=" + app.pwurl(id) + "&view=power"); break; //权限
			case 1: app.OpenUrl("../../../SYSC/view/account/add.ashx?ord=" + app.pwurl(id) + "&view=details"); break;  //详情
			case 2: app.OpenUrl("../../../SYSC/view/account/add.ashx?ord=" + app.pwurl(id)); break;  //修改
		}
	} else {
		switch (t) {
			case 0: app.OpenUrl("../../../SYSA/manager/content.asp?ord=" + app.pwurl(id) + "&view=power"); break; //权限
			case 1: app.OpenUrl("../../../SYSA/manager/content.asp?ord=" + app.pwurl(id) + "&view=details"); break;  //详情
			case 2: app.OpenUrl("../../../SYSA/manager/correct.asp?ord=" + app.pwurl(id)); break;  //修改
		}
	}
}

window.AddAccount = function () {
	if (window.SysConfig.SystemType == 100) {
		app.OpenUrl("../../../SYSC/view/account/add.ashx");
	} else {
		app.OpenUrl("../../../SYSA/manager/addgate.asp");
	}
}

function FrozenUser(id, status) {
    if (window.confirm("确定要" + (status==1? "激活" : "冻结" ) + "吗？") == false) { return true; }
    app.ajax.regEvent("FrozenUser");
    app.ajax.addParam("id", id);
    app.ajax.addParam("status", status);
    app.ajax.send();
}

function GetHandleHtml(id, status, cnpower, uppower, supperAdmin, accadmin,  jobadmin) {
	var candel = (status != "冻结"  && ( (accadmin=="1"&&jobadmin=="1"&&supperAdmin=="1") ))
    return (cnpower==1? ("<button type='button' onclick='exeButtonFun(1," + id + ")'>详情</button>") :"")
    + (uppower==1 ? ("<button type='button'  onclick='exeButtonFun(2," + id + ")'>修改</button>") : "")
    + "<button type='button'   " + ( candel ?"disabled":"") + " onclick='FrozenUser(" + id + "," + (status == "冻结" ? 1 : 0) + ")'>" + (status == "冻结" ? "激活" : "冻结") + "</button>";
}

function CPhoneHtml(phone1, mobile, email){
	var lh = 0;
	if(phone1) { phone1 = phone1 + "<br>";  lh++;}
	if(mobile) { mobile = mobile + "<br>"; lh++;}
	if(email) { email = email + "<br>"; lh++;}
	return "<div style='line-height:" + (lh<2?"":(lh==3?"13px":"16px")) + ";margin-top:2px;margin-bottom:4px;'>" + phone1 + mobile + email + "</div>";
}

function CNameHtml(name, accadmin,  jobadmin, partadmin, status, id, cnpower){
	if(name=="") { name="<i>空</i>"}
	if(cnpower==1) { name="<a href='javascript:void(0)' class='link' onclick='exeButtonFun(1," + id + ")'>" + name + "</a>"; }
	if(jobadmin=="1") { name=name+" *"; }
	if(accadmin=="1") { name=name+"**"; }
	if(status!="正常") { 
		name = "<img src='" + window.SysConfig.VirPath + "SYSA/images/156.gif' title='已冻结账号'>" + name;  
	}
	else {
		if(partadmin=="1") { name = "<img src='" + window.SysConfig.VirPath + "SYSA/images/155.gif' title='部门主管账号'>" + name; }
		else {  name = "<img src='" + window.SysConfig.VirPath + "SYSA/images/b14.gif' title='普通账号'>" + name;  }
	}
	return "<div style='text-align:left;margin-left:10px'>" + name + "</div>";
}
