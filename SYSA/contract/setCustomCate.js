
function selectHtCate() {
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
		$('#' + w + '').window({ top: inttop });
	}
}

function select_person(khord, ord, strvalue) {
    document.getElementById("htcateid").value = ord;
    document.getElementById("htcatename").value = strvalue;
    $('#w').window('close');
    if (window.BillExtSN.BindKeys && (window.BillExtSN.BindKeys.indexOf("htcateid") !== -1 || window.BillExtSN.BindKeys.indexOf("htcatename") !== -1)) {
        if (parent.window.BillExtSN && parent.window.BillExtSN.Refresh && !window.BillExtSN.NoRefresh) { parent.window.BillExtSN.Refresh(); }
        if (window.BillExtSN && window.BillExtSN.Refresh && !window.BillExtSN.NoRefresh) { window.BillExtSN.Refresh(); }
    }
}

function setCateid(ord, strvalue) {
    document.getElementById("htcateid").value = ord;
    document.getElementById("htcatename").value = strvalue;
    if (window.BillExtSN.BindKeys && (window.BillExtSN.BindKeys.indexOf("htcateid") !== -1 || window.BillExtSN.BindKeys.indexOf("htcatename") !== -1)) {
        if (parent.window.BillExtSN && parent.window.BillExtSN.Refresh && !window.BillExtSN.NoRefresh) { parent.window.BillExtSN.Refresh(); }
        if (window.BillExtSN && window.BillExtSN.Refresh && !window.BillExtSN.NoRefresh) { window.BillExtSN.Refresh(); }
    }
}

if (window.BillExtSN) {
    window.BillExtSN.AfterRefresh = function () {
        //如果需要合同主题跟随编号同步更新，放开这段代码
        if (document.getElementById("companyname") && document.getElementById("htid")) {
            var company = document.getElementById("companyname").value;
            var u_name = document.getElementById("htid").value;
            var title = document.getElementById("title");
            var zt = company + u_name;
            title.value = zt;
        }
    }
}
