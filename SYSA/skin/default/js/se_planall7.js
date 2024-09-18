window.onReportRefresh=function(){
	var strh=$ID("commfieldsBox").getAttribute("connHTML");
	if (strh!=null && strh!="")
	{
		$("#searchitemsbutton2").click();
	}
}

function ShowSerialNumber(obj, billType, billID, listID) {
    $("#w" + listID).html("<iframe src='../../SYSN/view/store/SerialNumber/serialList.ashx?billType=61001&billID=" + billID + "&listID=" + listID + "&isKu=1' style='width:100%;height:98%' frameborder='0'></iframe>").window({
        title: "序列号",
        width: 285,
        height: 450,
        top: window.event ? window.event.clientY + document.body.scrollTop + document.documentElement.scrollTop - 150 : 150 + document.body.scrollTop + document.documentElement.scrollTop,
        left: window.event ? window.event.clientX + 10 : 150,
        closeable: true,
        collapsible: false,
        minimizable: false,
        maximizable: false,
        resizable: true
    }).window("open");
}

function lockKuCP(idx,status, Rid){
	if(idx!=""){
		var lockStr = "冻结";
		if(status==0){ lockStr = "冻结";}else if(status==1){lockStr = "解冻";}
		if(confirm("确定要"+lockStr+"吗？")){
			ajax.regEvent("lockKuCP");
			ajax.addParam("idx", idx);
			ajax.addParam("status", status);
			ajax.addParam("rid", Rid);
			var html = ajax.send();
			window.DoRefresh();
		}
	}
}

window.onReportExtraHandle = function(text , arrValue){
    var ids = arrValue.join(",");
    var rids = "";
    $("input[name='sys_lvw_ckbox']:checked").each(function () {
        var id = $(this).val();
        var rid = $(this).attr("rid");
        rids += (rids == "" ? "" : ",") + rid;
    });
	switch(text){
		case "养护":
		    var selectid = "";
		    rids = "";
			$("input[name='sys_lvw_ckbox']:checked").each(function(){
				var id = $(this).val();
				var canyh = $(this).attr("canyh");
				if(canyh == "0"){
					try{$("#tip_"+id).html("不允许养护！");}catch(e){}
				} else {
				    var rid = $(this).attr("rid");
				    selectid += (selectid == "" ? "" : ",") + id;
				    rids += (rids == "" ? "" : ",") + rid;
				}
			});
			window.open('../maintain/add.asp?kuids=' + selectid + "&rids=" + rids, 'newwin', 'width=' + 900 + ',height=' + 520 + ',fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=250,top=150');
			break;
		case "批量冻结":
		    lockKuCP(ids, 0, rids);
			break;
		case "批量解冻":
		    lockKuCP(ids, 1, rids);
			break;
	}
}

var $addrModifyWindow = null;
isClick = false;
function addrModify(num) {
    if (isClick) {
        window.open("../../sysn/view/statistics/store/SerialNumberRemove.ashx");
    } else {
        if (!$addrModifyWindow) {
            $addrModifyWindow = $('<div id="addrModifyWindow" class="easyui-window" title="序列号检测结果" style="top:100px;width:550px;height:330px;padding:5px;background: #fafafa;"></div>');
            $addrModifyWindow.html('' +
                '<div id="addrContent" border="false" style="width:auto; height:auto;margin-top:2px;position:relative;">' +
                '&nbsp&nbsp系统检测到现有库存数据中存在<span style="color:red">序列号使用不规范，无法出库的数据 ' + num + ' 条</span>；请查看并进行序列号数据迁移，避免出现无法出库的情况。<br>' +
                '&nbsp&nbsp温馨提示：<br>' +
                '&nbsp&nbsp1.序列号数据迁移指的是将现有库存中，不规范序列号的数据迁移至另一字段中；<br>' +
                '&nbsp&nbsp2.序列号数据迁移为数据追加式；<br>' +
                '&nbsp&nbsp例：<br>' +
                '&nbsp&nbsp现有数据：序列号：A001，批号：B；<br>' +
                '&nbsp&nbsp选择迁移至批号<br>' +
                '&nbsp&nbsp迁移后：序列号：空，批号：BA001<br>' +
                '&nbsp&nbsp3.序列号数据迁移后不可重新迁移，请谨慎使用！</div>' +
                '<button class="oldbutton" style="display:block;margin:5px auto" onclick="goto();">序列号迁移</button>'
            );
        }

        var top = ($(window).height() - 400) / 2 + $(document).scrollTop();
        var left = ($(window).width() - 600) / 2 + $(document).scrollLeft();

        $addrModifyWindow.dialog({
            left: left,
            top: top,
            modal: true
        }).dialog('open');
        ajax.regEvent("removeDialogFlag");
        ajax.send();
        isClick = true;
    }
}
function goto() {
    $("#addrModifyWindow").dialog("close");
    window.open("../../sysn/view/statistics/store/SerialNumberRemove.ashx");
}