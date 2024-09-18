
var tem = "";
function checkqn(e,itemName,thisvalue,name)
{
  tem= document.getElementById(name).value;
  var aa=document.getElementsByName(itemName);
  var bb=document.getElementById(name);
  if(e.checked==true){
  	tem += thisvalue+",";
  }
else{
   tem = tem.replace(thisvalue+",","");
}
bb.value=tem;
  
  for (var i=0; i<aa.length; i++)
   aa[i].checked = e.checked;
}
