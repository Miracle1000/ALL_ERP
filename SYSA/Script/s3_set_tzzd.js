
function chk_ditto(){
	var names="";
	var frm=document.getElementById("demo");
	for(var i=0;i<frm.elements.length;i++){
		var e = frm.elements[i];
		if (e.getAttribute('chk')== 'ditto'){
			names=e.value+"||"+names;
		}
	}
	names="|"+names;
	for(var k=0;k<frm.elements.length;k++){
		var el = frm.elements[k];
		if (el.getAttribute('chk')== 'ditto'){
			names=names.replace("|"+el.value+"|","");
			if(names.indexOf("|"+el.value+"|")>-1){
			alert('字段['+el.value+']出现重复！');
			return false;
			}
		}
	}
	return true;
}

function dataTypeChange(th,id){
	if (th.value==7)
	{
		document.getElementById("sz_"+id+"_4").style.display='';
		try{
		document.getElementById("MustFillin_"+id+"_1").style.display='none';
		document.getElementById("MustFillin_"+id+"_1").value="0";	//设置默认值0不显示的时候
		document.getElementById("MustFillin_"+id+"_2").style.display='none';
		}catch(e){}
	}
	else
	{
		if (th.value==3 || th.value==5 || th.value==6)
		{
			document.getElementById("sz_"+id+"_4").style.display='none';
			try{
			document.getElementById("MustFillin_"+id+"_1").style.display='none';
			document.getElementById("MustFillin_"+id+"_1").value="0";	//设置默认值0不显示的时候
			document.getElementById("MustFillin_"+id+"_2").style.display='none';
			}catch(e){}
		}
		else
		{
			document.getElementById("sz_"+id+"_4").style.display='none';
			try{
			document.getElementById("MustFillin_"+id+"_1").style.display='';
			document.getElementById("MustFillin_"+id+"_2").style.display='';
			}catch(e){}
		}
	}
}
function showLay(id){
	var objDiv = eval("sz_"+id+"_1");
	if (objDiv.style.display=="none")
	{
		document.getElementById("sz_"+id+"_1").style.display='';
		document.getElementById("sz_"+id+"_2").style.display='';
		document.getElementById("sz_"+id+"_3").style.display='';
		//document.getElementById("sz_"+id+"_4").style.display='';
	}
	else
	{
		document.getElementById("sz_"+id+"_1").style.display='none';
		document.getElementById("sz_"+id+"_2").style.display='none';
		document.getElementById("sz_"+id+"_3").style.display='none';
		document.getElementById("sz_"+id+"_4").style.display='none';
	}
}
