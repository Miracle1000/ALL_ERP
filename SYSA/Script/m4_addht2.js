

//加载ajax
//仿造money/addht2.asp


function add() {
	var money1 = document.getElementById("money1").value;
	var money2 =  document.getElementById("money2").value;
	var money3 = Number(money2)-Number(money1);
	if (money3>0){
		document.getElementById("dybf").style.display="";
		document.getElementById("money3").value = formatNumDot(money3,window.sysConfig.moneynumber);
		$("#daysOfMonth6Pos").attr("min","1");
		$("#money3").attr("min","1");
	}else{
		document.getElementById("dybf").style.display="none";
		document.getElementById("money3").value = 0;
		$("#daysOfMonth6Pos").attr("min","0");
		$("#money3").attr("min","0");
	}
}


function check_ck() {
   var money1 = document.getElementById("money1").value; 
   var money2 = document.getElementById("money2").value; 

  if ( isNaN(money1) || (money1 == "") ) {
  return false;
  }
  
  //if (Number(money1) > Number(money2)) {
  //alert("大于应收账款！")
  //document.getElementById("money1").value=money2
  //return false;
  //}
  return true;
}


