

function check_kh(ord) { 
  var url = "../event/search_cp.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(ord);
  };
  xmlHttp.send(null);  
}

function updatePage2(ord) {
  if (xmlHttp.readyState < 4) {
	khmc.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	khmc.innerHTML=response;
	jQuery('#parentProduct').val(ord);
	callServer2(ord)
  }
}

function callServer2(ord) { 
  var url = "../event/search_unit.asp?ord="+escape(ord)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage3(ord);
  };
  xmlHttp.send(null);  
}

function updatePage3(ord) {
    if (xmlHttp.readyState < 4) {
        unit.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        unit.innerHTML = response;
        callServer3(ord);
    }
}

function callServer3(ord) {
    var url = "../event/search_unit.asp?ord=" + escape(ord) + "&isProductAttrs=1&timestamp=" + new Date().getTime() + "&date1=" + Math.round(Math.random() * 100);
    xmlHttp.open("GET", url, false);
    xmlHttp.onreadystatechange = function () {
        updatePage4(ord);
    };
    xmlHttp.send(null);
}

function updatePage4(ord) {
    if (xmlHttp.readyState < 4) {
        unit.innerHTML = "loading...";
    }
    if (xmlHttp.readyState == 4) {
        var response = xmlHttp.responseText;
        if (response) {
            var responseText = response.split("|@|@|@|");
            if (responseText.length == 4) {
                document.getElementById("ProductAttr1Name").innerHTML = responseText[0];
                document.getElementById("ProductAttr2Name").innerHTML = responseText[1];
                document.getElementById("ProductAttr1").innerHTML = responseText[2];
                document.getElementById("ProductAttr2").innerHTML = responseText[3];
            } else {
                document.getElementById("ProductAttr1Name").innerHTML = "产品属性1";
                document.getElementById("ProductAttr2Name").innerHTML = "产品属性2";
                document.getElementById("ProductAttr1").innerHTML = "";
                document.getElementById("ProductAttr2").innerHTML = "";
            }
        }
        xmlHttp.abort();
    }
}
