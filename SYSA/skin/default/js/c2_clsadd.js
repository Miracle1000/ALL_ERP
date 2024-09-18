function showZdyDlg(box) {
	var td = box.parentNode.nextSibling;
	td.getElementsByTagName("span")[0].innerHTML = box.value == 8 ? "&nbsp;<a href='javascript:void(0)' onclick='showZdyEdit(this)'>编辑</a>" : "";
}

var txtid = (new Date()).getTime();
function showZdyEdit(box) {
	var txtbox = box.parentNode.parentNode.getElementsByTagName("TextArea")[0]
	txtid ++;
	if(txtbox.id=="") {txtbox.id = "A" + txtid;}
	var win = bill.easyui.CAjaxWindow("zdydlg", function() {ajax.addParam("id", txtbox.id); ajax.addParam("text", txtbox.value)});
}

function zdyDataChange(box) {
	showZdyEdit(box);
}

function openZdyUpdateDlg(id, r)
{
	var txt = $ID(id).value.split("\7")[r-1].split("\6");
	window.open("clszdy.asp?view=update&r=" +r+ "&txtid=" + id + "&nv=" + ajax.UrlEncode(txt[0]) + "&ni=" + txt[1] , "", "width=500px,height=300,left=300px,top=100px,resizable=1")
}

window.onBillLoad = function() {
	if(window.location.href.indexOf("ord=")==-1) {
		//当网址中没有ord,表示添加模式
		$ID("lvw_alink_bllst_@lst").children[0].click();
	}
	setTimeout("updateFirstRowOption()",100);
}

function updateFirstRowOption() {
	var tb = $ID("lvw_dbtable_bllst_@lst");
	var uTypes = document.getElementsByName("uType");
	var uNames = document.getElementsByName("uName");
	var lststops = document.getElementsByName("lststop");
	if(uNames.length>0) {
		if($ID("__ord").value==0) { 
			uNames[0].value = "主题字段";
			var pn = lststops[0].parentNode.parentNode;
			pn.innerHTML = pn.innerHTML + "是";
		};
		var sbox = uTypes[0];
		for (var i = sbox.options.length - 1; i >= 0; i-- )
		{
			var txt = sbox.options[i].text;
			if(txt.indexOf("单行文本")==-1 && txt.indexOf("多行文本")==-1 && txt.indexOf("数字")==-1) {
				sbox.options.remove(i);
			}
		}
	}
}

function dodelzdyItem(txtid, rowindex) {
	var box = $ID(txtid);
	var s = box.value.split("\7");
	s.splice(rowindex-1,1);
	box.value =s.join("\7");
	showZdyEdit(box.parentNode.getElementsByTagName("a")[0]);
}