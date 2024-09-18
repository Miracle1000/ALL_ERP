function itemadd() {
	bill.easyui.CAjaxWindow("nodeitemselect", 
		function(){
			var items = document.getElementsByName("nodedata");
			for (var i = 0; i < items.length ; i++ )
			{
				ajax.addParam("sortid", items[i].getAttribute("sort1"));
			}
		}
	);
}

function onitemboxchecked(box, ord) {
	if(box.checked==true){ 
		document.getElementById("v_" + ord).style.display="block"; 
	}
	else{ 
		document.getElementById("v_" + ord).style.display="none";
		var code_Values = document.all["jh" + ord]; 
		if(code_Values.length){ 
			for(var i=0;i<code_Values.length;i++) 
			{ 
				code_Values[i].checked = false; 
			}
		}
		else {
			code_Values.checked = false;
		}
	}
}

function checkitemsave(){
	var newsorts = new Array();
	var nsort = new Array();
	bill.refreshList("itemlist", "selectnewsort",
		function () {
			var allcheck = $ID("sortjhr2").checked;
			var jh = document.getElementsByName("jh");
			for (var i = 0; i < jh.length; i++)
			{
				var ck = jh[i];
				if(ck.checked || allcheck ) {
					nsort[nsort.length] = ck.value;
					var obj = $ID("nodedata_" + ck.value);
					if(obj) {
						newsorts[newsorts.length] = {join: obj.value, execors: $ID("nm_" + ck.value).innerHTML , jtype : $ID("jtype_" + ck.value).innerHTML}
					}
					else {
						newsorts[newsorts.length] = {join : "", execors : "", jtype : "" }
					}
				}  
			}
			ajax.addParam("newsorts", nsort.join(","))
		}
	);
	bill.easyui.closeWindow("nodeitemselect");
	for (var i = 0; i < nsort.length ; i++)
	{
		$ID("nodedata_" + nsort[i]).value = newsorts[i].join ;
		$ID("nm_" + nsort[i]).innerHTML = newsorts[i].execors;
		$ID("jtype_" + nsort[i]).innerHTML = newsorts[i].jtype;
	}
	nsort = null;
	nsort =  null;
}

function showEditItemNode(sortid) {
	window.open("URLProxy.asp?mbID=" + $ID("__ord").value + "&dataid=" +sortid,"jdSet22","width=900,height=600,fullscreen=no,toolbar=0,resizable=1,left=150,top=50,scrollbars=yes");
}