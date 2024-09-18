
<!--
    function checkAll2(str){
        var a=document.getElementById("u"+str).getElementsByTagName("input");
        var b=document.getElementById("e"+str);
        for(var i=0;i<a.length;i++){
            a[i].checked=b.checked;
        }
    }

    function fixChk2(str){
        var a=document.getElementById("u"+str).getElementsByTagName("input");
        var b=document.getElementById("e"+str);
        for(var i=0;i<a.length;i++){
            if(a[i].checked==false){
                b.checked=false;
                return ;
            }
        }
        b.checked=true;
    }
	function selectAll(obj){
		var cout=document.getElementsByName("sptj").length;
		if (obj.checked==true)
		{		
			for (var i=0 ;i< cout; i++)
			{
				document.getElementsByName("sptj")[i].checked=true;
			}
		}
		else
		{
			for (var i=0 ;i< cout; i++)
			{
				document.getElementsByName("sptj")[i].checked=false;
			}
		}
	}
//-->
