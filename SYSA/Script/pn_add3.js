
 function phoneCall(phoneNum)
{
if (phoneNum!="")
{
getCall('../china/bh.asp?phone='+ phoneNum +'');
return false;
}
else
{
alert("号码不能为空！");
}
}



 function callServer(m, strvalue) {
     var ID = m;
     //手机2
     if (m == 21||m==20) {
         m = 20
         if ($("#mobile").val() != "" && $("#mobile2").val() != "" && $("#mobile").val() == $("#mobile2").val()) {
             $("#ts_" + ID).html("相同手机号已存在！")
             return;

         }
     }
	var telid = document.getElementById("name_id").value;
	if (document.getElementById("ts_"+m))
	{
	    var w2 = "ts_" + ID;
		w2=document.all[w2]
		if ((strvalue == null) || (strvalue == "")) return;
		var url = "cu.asp?name=" + escape(strvalue)+"&ord="+escape(m)+"&telid="+escape(telid)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
		xmlHttp.open("GET", url, false);
		xmlHttp.onreadystatechange = function(){
		updatePage(w2);
		};
		xmlHttp.send(null);
	}
}

function updatePage(w)
{
	var test6=w
	if (xmlHttp.readyState == 4) {
	var response = xmlHttp.responseText;
	test6.innerHTML=response;
	}
}

function getBirthYear() {
    var val = $("#birthdayType").val();
    var s = "";
    xmlHttp.open("GET", "../person/getBirthJson.asp?v=getYear&birthType=" + val + "&r=" + Math.random(), false);
    xmlHttp.send();
    if (xmlHttp.readyState == 4) {
        var json = eval(xmlHttp.responseText);
        var objBirthYear = document.getElementById("birthYear");
        objBirthYear.options.length = 0;
        for (var i = 0; i < json.length; i++) {
            objBirthYear.options.add(new Option(json[i].yName, json[i].yValue));
            if (window.yearDate == json[i].yValue) { objBirthYear.options[i].selected = "selected"; }
        };
        getBirthMonth();
    }
}
function getBirthMonth() {
    var val = $("#birthdayType").val();
    var birthYear = $("#birthYear").val();
    xmlHttp.open("GET", "../person/getBirthJson.asp?v=getMonth&birthType=" + val + "&birthYear=" + birthYear + "&r=" + Math.random(), false);
    xmlHttp.send();
    if (xmlHttp.readyState == 4) {
        var json = eval(xmlHttp.responseText);
        var objBirthMonth = document.getElementById("birthMonth");
        objBirthMonth.options.length = 0;

        for (var i = 0; i < json.length; i++) {
            objBirthMonth.options.add(new Option(json[i].mName, json[i].mValue));
            if (window.monthDate+"-0" == json[i].mValue) { objBirthMonth.options[i].selected = "selected"; }
        };
        getBirthDay();
    }
	if (birthYear!=""){getAge(birthYear);}
}
function getBirthDay() {
    var val = $("#birthdayType").val();
    var birthYear = $("#birthYear").val();
    var birthMonth = $("#birthMonth").val();

    xmlHttp.open("GET", "../person/getBirthJson.asp?v=getDay&birthType=" + val + "&birthYear=" + birthYear + "&birthMonth=" + birthMonth + "&r=" + Math.random(), false);
    xmlHttp.send();
    if (xmlHttp.readyState == 4) {
        var json = eval(xmlHttp.responseText);
        var objBirthDay = document.getElementById("birthDay");
        objBirthDay.options.length = 0;
        for (var i = 0; i < json.length; i++) {
            objBirthDay.options.add(new Option(json[i].dName, json[i].dValue));
            if (window.dayDate == json[i].dValue) { objBirthDay.options[i].selected = "selected"; }
        };
    }
}

function getAge(birthYear)
{
	if (document.getElementById("age"))
	{
		var myDate=new Date();
		document.getElementById("age").value=myDate.getFullYear()-birthYear;
	}
}
