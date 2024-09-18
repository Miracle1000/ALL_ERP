function XMlHttpAjax() {
    var XMlHttp;
    try {
        XMlHttp = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
        try {
            XMlHttp = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e2) {
            XMlHttp = false;
        }
    }
    if (!XMlHttp && typeof XMLHttpRequest != 'undefined') {
        XMlHttp = new XMLHttpRequest();
    }
    return XMlHttp
}
function check_kh(ord) {
    XMlHttp = XMlHttpAjax();
    var url = "../event/search_kh.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
    XMlHttp.open("GET", url, false);
    XMlHttp.onreadystatechange = function(){
        updatePage2();
    };
    XMlHttp.send(null);
}
function updatePage2() {
    if (XMlHttp.readyState < 4) {
        khmc.innerHTML="loading...";
    }
    if (XMlHttp.readyState == 4) {
        var response = XMlHttp.responseText;
        khmc.innerHTML=response;
        updatePage3();
    }
}

function updatePage3() {
	var company = document.getElementById("companyname").value;
	XMlHttp.abort();
}
function getcontent(tempid)
{
    XMlHttp = XMlHttpAjax();
	var url = "getcontent.asp?tempid="+tempid+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	XMlHttp.open("GET", url, false);
	XMlHttp.onreadystatechange = function(){
        if (XMlHttp.readyState < 4) {
            Cproc.innerHTML="loading...";
        }
        if (XMlHttp.readyState == 4) {
            var response = XMlHttp.responseText;
            allcontent.innerHTML=response;
            Cproc.innerHTML="";
            XMlHttp.abort();
        }
	};
	XMlHttp.send(null);
}