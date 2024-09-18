
function MM_jumpMenu(targ,selObj,restore){ //v3.0
eval(targ+".location=\'"+selObj.options[selObj.selectedIndex].value+"\'");
if (restore) selObj.selectedIndex=0;
}
function ask() {
document.all.date.action = "?action=save&add=next";
}
function Mycheckdata(num_dot_xs){
var str = document.getElementById("NowMoney");
var reCat = /[^0-9\.-]|\d-|\.-|-\.|-{2,}|\.{2,}/g;
if(reCat.test(str.value) == true){
str.value = str.value.replace(/[^\d.-]|\d-|\.-|-\.|-{2,}|\.{2,}/g,'');
}else moneytwo.innerHTML = "";
if(str.value < 922337203685477.5808 && str.value > -922337203685477.5808)
{moneytwo.innerHTML = "";
if(str.value.indexOf(".") > 0 && str.value.indexOf(".") < str.value.length - 1){
var thisobj = str.value.split(".");if (thisobj.length > 1){
if(thisobj[1].length > num_dot_xs){
str.value = str.value.substring(0,str.value.length-1);}}}
return true;}else{str.focus();
moneytwo.innerHTML="金额太大";
selectText(str);}return false;
}
