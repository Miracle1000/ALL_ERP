function Myopen(divID){
	if(divID.style.display=="")
	{
		divID.style.display="none"
	}
	else
	{
		divID.style.display=""
	}
	divID.style.zIndex=2;
	divID.style.left=310;
	divID.style.top=document.body.scrollTop;
}