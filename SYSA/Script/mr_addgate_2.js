
    function checkAll(str){
        var a=document.getElementById("j"+str).getElementsByTagName("input");
        var b=document.getElementById("k"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk(str){
        var a=document.getElementById("p"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll2(str){
        var a=document.getElementById("u"+str).getElementsByTagName("input");
        var b=document.getElementById("e"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk2(str){
        var a=document.getElementById("u1").getElementsByTagName("input");
        var b=document.getElementById("e1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll3(str){
        var a=document.getElementById("h"+str).getElementsByTagName("input");
        var b=document.getElementById("i"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk3(str){
        var a=document.getElementById("h1").getElementsByTagName("input");
        var b=document.getElementById("i1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll7(str){
        var a=document.getElementById("Wd"+str).getElementsByTagName("input");
        var b=document.getElementById("Wt"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk7(str){
        var a=document.getElementById("Wd1").getElementsByTagName("input");
        var b=document.getElementById("Wt1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

    function checkAll4(str){
        var a=document.getElementById("k"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
         if(b.checked==false){
		 for(var i=0;i<a.length;i++){
                a[i].checked=b.checked;
                return ;
            }
			b.checked=false;
        }

    }

    function fixChk4(str){
        var a=document.getElementById("k"+str).getElementsByTagName("input");
        var b=document.getElementById("r"+str);
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }

    }

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
