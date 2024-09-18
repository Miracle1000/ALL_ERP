
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
