
function getconttitle(name)
{
  var ContType=getSelectedText(name);
  var Contcompany=document.getElementById("companyname").value;
  //alert(Contcompany);
  if((ContType!="")&&(Contcompany==""))
  {
    document.getElementById("title").value=ContType;
  }
  if((ContType!="")&&(Contcompany!=""))
  {
    document.getElementById("title").value=Contcompany + ContType;
  }
  if((ContType=="")&&(Contcompany!=""))
  {
    document.getElementById("title").value=Contcompany;
  }

}
//获取下拉列表值
function getSelectedText(name){
var obj=document.getElementById(name);
for(i=0;i<obj.length;i++){
   if(obj[i].selected==true){
    return obj[i].innerText;      //关键是通过option对象的innerText属性获取到选项文本
   }
}
}

