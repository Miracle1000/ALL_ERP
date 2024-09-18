
var XMlHttp = GetIE10SafeXmlHttp();

function check_kh(ord) {

  var url = "../event/search_kh.asp?ord="+escape(ord)+"&cc=2&N=1&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
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
  }
}
function check_xm(ord) {
  var url = "../event/search_xm.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  XMlHttp.open("GET", url, false);
  XMlHttp.onreadystatechange = function(){

  updatePage3();
  };
  XMlHttp.send(null);
}

function updatePage3() {
  if (XMlHttp.readyState < 4) {
	xmmc.innerHTML="loading...";
  }
  if (XMlHttp.readyState == 4) {
    var response = XMlHttp.responseText;
	xmmc.innerHTML=response;
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