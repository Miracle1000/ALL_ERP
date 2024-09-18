

//加载ajax
//仿造money/addht2.asp


function add() {
  var money1 = document.getElementById("money1").value;
  var money2 =  document.getElementById("money2").value;
  var url = "cu.asp?money1=" + escape(money1)+"&money2="+escape(money2)+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage();
  };  
  xmlHttp.send(null);  
}

function updatePage() {
  if (xmlHttp.readyState < 4) {
	dybf.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	dybf.innerHTML=response;
	xmlHttp.abort();
  }
}

function check_ck() {
   var money1 = document.getElementById("money1").value; 
   var money2 = document.getElementById("money2").value; 

  if ( isNaN(money1) || (money1 == "") ) {
  return false;
  }
  
  if (Number(money1) > Number(money2)) {
  alert("大于应退账款！")
  document.getElementById("money1").value=money2
  return false;
  }
  return true;
}

