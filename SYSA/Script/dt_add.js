
	function toclick(objname) {
		document.getElementById(objname).click();
	}
	window.onIdChange = function(id) {
	//alert(id);
	    $BI("ordtype").value = id;
	    $BI("ordtype").onchange();
		return Fnsplc(id);
	}
//接受抛来数据
function setValue(q,m){ 
$BI("chkSon").value = q; 	//浏览 复选框
$BI("vchkSon").value = m; 	//下载 复选框
	return ajax_showgxr(q,m);		//刷新共享人
} 

function openvch(ch,vch){
var urlp = "set_gxrlist.asp?ch="+ch+"&vch="+vch;
window.open(urlp,'neww37win','width=420,height=500,fullscreen=no,scrollbars=1,toolbar=0,resizable=1,left=300,top=200');
}
