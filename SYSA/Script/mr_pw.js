
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location=\'"+selObj.options[selObj.selectedIndex].value+"\'");
if (restore) selObj.selectedIndex=0;
}
function updatejmg(){
	var jmgold=document.getElementById("jmgold");
	if (jmgold)
	{
		if (jmgold.value.length>0)
		{
			var NT120Client=document.getElementById("NT120Client");
			var inputjmg=document.getElementById("inputjmg");
			var tishi=document.getElementById("tishi");
			var hasjmg=CheckData(NT120Client,inputjmg,tishi);
			if (hasjmg)
			{
				var jmgpwdnew=document.getElementById("jmgnew1");
				return SetJmgPWD(jmgold,NT120Client,jmgpwdnew,tishi)
			}
			else
			{
				return false ;
			}
		}
	}
	return true ;
}
//-->
