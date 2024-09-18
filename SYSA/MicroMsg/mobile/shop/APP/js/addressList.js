window.RefreshAddress = function(id, value,changedeep) {
	function $id(id) {return document.getElementById(id);}
	//if(value){return;}
	var vs = eval("("+($id(id).getAttribute("_jsl")||"[]")+")");
	var deep = -1;
	changedeep = (changedeep||0);
	if (value>0)
	{
		for (var i = 0 ; (i < vs.length && deep==-1) ; i++)
		for (var ii = 0; ii < vs[i].length ; ii++ )
		if(vs[i][ii][1]==value){
			vs[i][ii][2] = 1; //表示选中
//			document.title = "deep=" + i + "==" + vs[i][ii][1] ;
			deep = i;	
		}else {
			if(changedeep == i) vs[i][ii][2] = 0;
		}
	}
	if(deep>=-1) { vs.splice(deep+1, vs.length-deep+1); }
	var xhttp = new (XMLHttpRequest?XMLHttpRequest:ActiveXObject)("Msxml2.XMLHTTP");
	xhttp.open("GET","../../../../addresses.asp?__msgId=getArea&Id=" + value, false);
	xhttp.send();
	var obj = eval("("+ xhttp.responseText + ")");
	xhttp = null;
	var list = new Array();
	for (var i = 0; i<obj.length ; i ++ )
	{
		list.push([obj[i].name, obj[i].id, 0]);
	}
	vs.push(list);
	var  htmls = new Array();
	console.log("vs.length1");
	for (var i = 0; i < vs.length ; i ++ )
	{console.log("vs.length2");
		if(vs[i].length>0) {
			console.log("vs.length3");
			var hm = new Array();
			hm.push("<select style='width:50%;font-size:14px;margin-bottom:12px' id='" + id + "_s" + i + "' onchange='window.RefreshAddress(\"" + id + "\",this.value,"+i+")'>");
//		    if(i==0){hm.push('<option value=0>请选择</option>');}
		    hm.push('<option>请选择</option>');
			for (var ii=0; ii<vs[i].length ;ii++ )
			{
				hm.push("<option value='" + vs[i][ii][1] + "' " + (vs[i][ii][2]?"selected":"") + ">" + vs[i][ii][0] + "</option>")
			}
			hm.push("</select>");
			htmls.push(hm.join(""));
		}
	}
	$id(id).innerHTML = htmls.join("<br>");
	$id(id).setAttribute("_jsl",JSON.stringify(vs));
	if($id(id+"_s"+deep)) { $id(id+"_s"+deep).focus();}
}
