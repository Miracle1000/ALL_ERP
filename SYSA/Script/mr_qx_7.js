
function dochange(str)
{
var obj=document.getElementsByTagName("input")
for(var i=0;i<obj.length;i++)
if(obj[i].type=="radio" && obj[i].value==str)
obj[i].checked=true;
}
function doradio(){
var obj=document.getElementsByTagName("input")
for(var i=0;i<obj.length;i++)
if(obj[i].type=="radio" && obj[i].checked)
document.all.member.value=obj[i].value
}
