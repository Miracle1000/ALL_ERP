
    var errorcount = 0;
    function returnStr() {
        var str = " ";
        if (errorcount > 0) {
            str = "<"
            for (i = 0; i < errorcount; i++)
                str = str + "-";
        } errorcount++; return str
    }
    function checkdata() {
        var str = document.getElementById("NowMoney");
        if (str) {
            var Expression = eval("/[^0-9.-]+/gi");
            var objExp = new RegExp(Expression);
            if (objExp.test(str.value) == true) {
                str.focus(); moneytwo.innerHTML = returnStr() + "输入的金额格式有错误";
                selectText(str);
                return false;
            } else moneytwo.innerHTML = " *";
            if (str.value < 922337203685477.5808 && str.value > -922337203685477.5808) {
                moneytwo.innerHTML = " "; errorcount = 0; return true;
            }
            else {
                str.focus();
                moneytwo.innerHTML ="金额太大";
                selectText(str);
            }
            return false;
        }
    }

    function selectText(str) {
        var txt = str.createTextRange();
        var sel = txt.duplicate();
        sel.moveStart("character", str.value.length);
        sel.setEndPoint("EndToStart", txt);
        sel.select();
    }
	
	function checkNowMoney(){
		var NowMoney = document.getElementById("NowMoney").value;
		if(NowMoney==""){NowMoney=0}
		NowMoney = Number(NowMoney);
		
		if(NowMoney<1){
			document.getElementById("moneytwo").innerHTML="金额须大于0";
			return false;
		}else if(NowMoney>922337203685477.5808){
			document.getElementById("moneytwo").innerHTML="金额太大";
			return false;
		}
	}

function checkCustomFields(){
	var iframeWindow = document.getElementById('customFieldsFrame').contentWindow;
	return (iframeWindow.Validator.Validate(iframeWindow.document.getElementById('demo'),2));
}

function addField(){
	document.getElementById('customFieldsFrame').contentWindow.document.getElementById('btn_fieldAdd').click();
}

function saveFields(){
	var iframe = document.getElementById('customFieldsFrame');
	iframe.contentWindow.document.getElementById('btn_fieldSave').click();
	iframe.onload();
}
