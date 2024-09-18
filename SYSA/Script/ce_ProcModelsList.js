
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location=\'"+selObj.options[selObj.selectedIndex].value+"\'");
if (restore) selObj.selectedIndex=0;
}
//-->
function openupdate(ord){
	window.open('ProcModelsAdd.asp?mbID='+ord+'&act=update','newwincor','width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')
}

function openuCopy(ord){
//if(confirm('修改阶段会影响项目流程模板，确认修改此阶段？')==true){
	window.open('ProcModelsAdd.asp?mbID='+ord+'&act=openuCopy','newwincor','width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=50,top=50')
//}else{}
}

function Addzjd(ord,idx){
	window.open('SetSubclass.asp?ord='+ord+'&idx='+idx+'&act=a','newwincor','width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
}

function openlook(ord,dp){
	if(dp==""){
		alert("该模板还未设置阶段工作！");
	}else{
	window.open('PMPreview.asp?pmord='+ord,'newwincor','width=1000,height=600,fullscreen =no,scrollbars=1,toolbar=0,resizable=1,left=200,top=150')
	}
}
