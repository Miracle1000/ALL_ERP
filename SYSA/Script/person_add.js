 function phoneCall(phoneNum)
{
if (phoneNum!="")
{//window.open('../china/bh.asp?phone='+ phoneNum +'','newwin2','width=' + 400 + ',height=' + 300 + ',fullscreen =no,scrollbars=0,toolbar=0,resizable=0,left=200,top=200');
getCall('../china/bh.asp?phone='+ phoneNum +'');
return false;
}
else
{
alert("号码不能为空！");
}
}


function callServer(m,name1) {
  var u_name = document.getElementById(name1).value;
  var telid = document.getElementById("company2id").value;
  var w2  = "test"+m;
   w2=document.all[w2];
  if ((u_name == null) || (u_name == "")) return;
  var url = "cu.asp?name=" + escape(u_name)+"&ord="+escape(m)+"&telid="+escape(telid)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage(w2);
  };
  xmlHttp.send(null);
}

function updatePage(w)
{
	var test6=w
  if (xmlHttp.readyState < 4) {
	test6.innerHTML="loading...";
  }
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