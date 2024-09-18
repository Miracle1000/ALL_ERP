
    function checkAll(str){
        var a=document.getElementById("d"+str).getElementsByTagName("input");
        var b=document.getElementById("t"+str);
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
        var a=document.getElementById("j"+str).getElementsByTagName("input");
        var b=document.getElementById("k"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk4(str){
        var a=document.getElementById("j1").getElementsByTagName("input");
        var b=document.getElementById("k1");
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }
    function checkSLForm() {
        var minv = $("#Sxfmin").val() == "" ? 0 : $("#Sxfmin").val();
        var maxv = $("#Sxfmax").val() == "" ? 0 : $("#Sxfmax").val();
        flag = true;
        if ($("#IsOpenCharge2").is(":checked"))//开启手续费
        {
            if (parseFloat(minv) > parseFloat(maxv)) {
                $("#information").css("display", "");
                flag=false;
            } else {
                $("#information").css("display", "none");
            }
        }
        return flag;
    }