function selectHtCate(){
	var w="w";
	var cateid = document.getElementById("htcateid").value;
	var url = "../work/correctall_person.asp?cateid=" + cateid +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	xmlHttp.open("GET", url, false);
	xmlHttp.onreadystatechange = function(){
		updatePage_selectCate(w);
	};
	xmlHttp.send(null);  
}

function updatePage_selectCate(w) {
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
		document.getElementById(""+w+"").innerHTML=response;	
		var inttop=(55+document.documentElement.scrollTop+document.body.scrollTop)+"px";
		$('#'+w+'').show();
		$('#'+w+'').window({top:inttop});
	}
}

function select_person(khord,ord,strvalue)
{
	document.getElementById("htcateid").value = ord;
	document.getElementById("htcatename").value = strvalue;
	$('#w').window('close');
}

function setCateid(ord,strvalue){
	document.getElementById("htcateid").value = ord;
	document.getElementById("htcatename").value = strvalue;
}