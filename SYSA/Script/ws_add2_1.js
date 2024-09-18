
function showCover(){
		$("#progress").show();
		$("#progress").height(document.body.scrollHeight);
		$("#progress").width(document.body.scrollWidth);
		$("#imgs").css("top",document.body.scrollHeight/2+document.body.scrollTop/2-50);
		$("#imgs").css("left",document.body.scrollWidth/2+document.body.scrollLeft/2-50);
}


function ask2() {
	var frm = document.all.date; 
	var gztitle = document.getElementsByName('title')[0].value	
	if(gztitle.length==0){ 
		alert('请输入工资单主题,长度必须在1至50个字之间!');
		document.getElementsByName('title')[0].focus();
		return false;
	}

	$("#gzact").val("zancun");
	showCover();
	frm.action = "save.asp";
	frm.submit();
}

// -->
