function FormatNumber(srcStr,nAfterDot)        //nAfterDot小数位数
{
   if(isNaN(srcStr)) return "NaN";
　　        var srcStr,nAfterDot;
　　        var resultStr,nTen;
　　        srcStr = ""+srcStr+"";
　　        strLen = srcStr.length;
　　        dotPos = srcStr.indexOf(".",0);
　　        if (dotPos == -1){
　　　　        resultStr = srcStr+".";
　　　　        for (i=0;i<nAfterDot;i++){
　　　　　　        resultStr = resultStr+"0";
　　　　        }
　　　　        return resultStr;
　　        }
　　        else{
　　　　        if ((strLen - dotPos - 1) >= nAfterDot){
　　　　　　        nAfter = dotPos + nAfterDot + 1;
　　　　　　        nTen =1;
　　　　　　        for(j=0;j<nAfterDot;j++){
　　　　　　　　        nTen = nTen*10;
　　　　　　        }
　　　　　　        resultStr = Math.round(parseFloat(srcStr)*nTen)/nTen;
　　　　　　        return resultStr;
　　　　        }
　　　　        else{
　　　　　　        resultStr = srcStr;
　　　　　　        for (i=0;i<(nAfterDot - strLen + dotPos + 1);i++){
　　　　　　　　        resultStr = resultStr+"0";
　　　　　　        }
　　　　　　        return resultStr;
　　　　        }
　　        }
}

function setyemoney()
{
    var ck2 = document.getElementById('ck2');
    var ck2val = ck2[ck2.selectedIndex].value;
    var yemoney = bzname[ck2val] +" " + yearray[ck2val];
    document.getElementById('yemoney').innerHTML = yemoney;
    document.getElementById('rmoney').value = marray[ck2val];
    if (minusarray[ck2val].length != 0) {
        document.getElementById("minusvalue").innerHTML = minusarray[ck2val];
        document.getElementById("minusvalue").style.display = "";
    }
    else {
        document.getElementById("minusvalue").style.display = "none";
    }
}

function setrzmoney(){
	var ck1 = document.getElementById('ck1');
	var ck1val = ck1[ck1.selectedIndex].value;
	var yemoney =ck1val.length==0? "" : bzname[ck1val] +" " + yearray[ck1val];
    document.getElementById('zrmoney').innerHTML = yemoney;
	var ck2 = document.getElementById('ck2');
    var ck2val = ck2[ck2.selectedIndex].value;
    var hl =ck1val.length==0 ? 1: bzarray[ck2val]/bzarray[ck1val];
	var hl_dot = document.getElementById('hl_dot').value;
	if(hl_dot.length==0){hl_dot = 0;}
	document.getElementById('hl').value = FormatNumber(hl, hl_dot);
	document.getElementById('hl2').value = hl;
	getbzmoney(window.sysConfig.moneynumber)
}

function getbzmoney(num_dot_xs) {
	var ck1 = document.getElementById('ck1');
	var ck2 = document.getElementById('ck2');
	if (ck1.selectedIndex <= 0) return;
	var ck1val = ck1[ck1.selectedIndex].value;
	var ck2val = ck2[ck2.selectedIndex].value;
	if (ck1val!='')
	{
	    var hl = document.getElementById('hl2').value;
		if(hl==""){hl = 0};
		var money1 = document.getElementById('money1').value;
		if (money1.length!=0)
		{
			var mumbr=FormatNumber(hl * money1, num_dot_xs);
			if("NaN"!=mumbr)
		    document.getElementById('bzmoney').value = mumbr;
			if(parseFloat(money1)>parseFloat(marray[ck2val]))
			{	alert("超过账户余额！");
			    document.getElementById('money1').value = marray[ck2val];
			    document.getElementById('bzmoney').value = FormatNumber(hl * marray[ck2val],num_dot_xs);
			}
		}
	}
}
function ask() {
    document.getElementById("date").action = "save.asp?sort2=1";
}
function ask2() {
    document.getElementById("date").action = "checkwork.asp";
    document.getElementById("date").submit();
}
function inselect4() {
	document.getElementById("ck1").length = 0;
	var ck2 = document.getElementById("ck2");
    if (ck2.value == "0" || ck2.value == null || ck2.value.length < 1) {

        document.getElementById("ck1").options[0] = new Option('　　　　', '');
        document.getElementById('yemoney').innerHTML = '';
    }
    else {
        for (i = 0; i < ListUserId4[ck2.value].length; i++) {
            document.getElementById("ck1").options[i] = new Option(ListUserName4[ck2.value][i], ListUserId4[ck2.value][i]);
		}
		document.getElementById('zrmoney').innerHTML = '';
		var index = ck2.selectedIndex;
		setyemoney();
    }
}
