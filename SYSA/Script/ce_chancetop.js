
function superSearch(inttype){
	if (inttype==2)
	{
		document.getElementById('kh').style.display='';
		document.getElementById('ht1').value='';
		document.getElementById('ht1').style.display='none';
		document.getElementById('gd1').className='zdy';
		document.getElementById('gd2').className='zdy1 top tophead';
		return false;
	}
}

function callServer2() {
	document.getElementById('kh').style.display='none';
	document.getElementById('ht1').style.display='block';
	document.getElementById('ht1').style.position='relative';
	document.getElementById('ht1').style.zIndex=1;
	document.getElementById('gd1').className='';
	document.getElementById('gd2').className='top';
  var url = "liebiao_tj2.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2();
  };
  xmlHttp.send(null);
}
function updatePage2() {
var test7="ht1"
  if (xmlHttp.readyState < 4) {
	ht1.innerHTML="loading...";
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	ht1.innerHTML=response;
	xmlHttp.abort();
  }
}
