
   function getHtmx(value)
   {
     //alert(value);
     if(value!="")
	 {
	    document.getElementById("htI3").src='../event/htmx.asp?ID=company&ContectType='+ value;
		//document.getElementById("htI3").src='../event/htmx1.asp?ID=company&ContectType='+ value;
	 }
	 else
	 {
	    document.getElementById("htI3").src='../event/htmx.asp?ID=company&ContectType=0';
	 }
   }

