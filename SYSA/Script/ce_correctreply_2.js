
    function checkAll(str){
        var a=document.getElementById("t"+str).getElementsByTagName("input");
        var b=document.getElementById("d"+str);

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

    }
  