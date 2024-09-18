
function inselect(){
document.date.sorce2.length=0;
if(document.date.sorce.value=="0"||document.date.sorce.value==null)
document.date.sorce2.options[0]=new Option('--所属3地区--','0');
else
{
for(i=0;i<ListUserId[document.date.sorce.value].length;i++)
{
document.date.sorce2.options[i]=new Option(ListUserName[document.date.sorce.value][i],ListUserId[document.date.sorce.value][i]);
}
}
var index=document.date.sorce.selectedIndex;
//sname.innerHTML=document.date.sorce.options[index].text
} 

    function checkAll(str){
        var a=document.getElementById("t"+str).getElementsByTagName("input");
        var b=document.getElementById("d"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk(str){
        var a=document.getElementById("t1").getElementsByTagName("input");
        var b=document.getElementById("d1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }

