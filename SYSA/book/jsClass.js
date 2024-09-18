// JavaScript Document
function sum(value1,value2,value3)
{
	a=document.getElementById(value1).value;
	b=document.getElementById(value2).value;
	c=document.getElementById(value3);
	if (a!="" && b!="")
	{
		try{
			//c.value=parseFloat(a)*parseFloat(b);
			c.value=formatNumDot(accMul(a,b),window.sysConfig.moneynumber);
		}catch(e){
			c.value=0;
		}
	}else{
		c.value=0;
	}
}