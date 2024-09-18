
    function pchkall(c) {
        var objs = document.getElementsByName("chkprod");
        for (var i = 0; i < objs.length; i++) {
            objs[i].checked = c;
        }
    }
    function pdelall() {
        var objs = document.getElementsByName("chkprod");
        var unchk = true;
        for (var i = 0; i < objs.length; i++) {
            if (objs[i].checked) {
                var vitem = objs[i].value.split("@");
                if (vitem.length == 2) {
                    var pobj = document.getElementById("tpx" + vitem[0]);
                    if (pobj.style.display == "") {
                        unchk = false;
                        break;
                    }
                }
            }
        }

        if (unchk) { 
            alert("您没有选择任何内容，请选择后再删除！");
        }
        else{
            if (confirm("是否确定要删除选定的明细?")) {
				var tpx = "";
				var pord = "";
                for (var i = 0; i < objs.length; i++) {
                    if (objs[i].checked) {
                        var vitem = objs[i].value.split("@");
                        if (vitem.length == 2) {
							if (pord=="")
							{
								tpx = "tpx" + vitem[0];
								pord = vitem[1];
							}
							else
							{
								tpx = tpx + ",tpx" + vitem[0];
								pord = pord + "," + vitem[1];
							}
						}
                    }
                }
                delall(tpx, pord); //直接调用现有单明细删除过程，不再另写批量删除代码了
            }
        }
    }

function delall(str,id){

	var w  = str.split(",");

	var url = "del_cp.asp?id="+escape(id)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100)
     	xmlHttp.open("GET", url, false);
 	xmlHttp.onreadystatechange = function(){
			if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
				  updatePage_delall(w);
			}
	  };
	  xmlHttp.send(null);
}

function updatePage_delall(str) {
	for (var i = 0; i < str.length; i++) {
	    document.getElementById(str[i]).style.display = "none";
		$("#"+str[i]).remove();
	}
	var h = 0;
	if($('#mxdiv').get(0).scrollWidth>$('#mxdiv').innerWidth()){
		h = 20;
	}
	$("#mxdiv").css({'height':$("#mxdiv").children().eq(0).height()+h});
}