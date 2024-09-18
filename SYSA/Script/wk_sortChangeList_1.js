
function Myopen_px(divID){
	if(divID.style.display==""){
		divID.style.display="none"
	}else{
		divID.style.display=""
	}
	divID.style.left=310;
	divID.style.top=-40;
}
function inselect4(id)
{
	if (id==1)
	{
	var sort=document.form2.sort2;
	var sort1=document.form2.sort2_1;
	}else{
	var sort=document.form2.sort3;
	var sort1=document.form2.sort3_1;
	}
	sort1.length=0;
	if(sort.value=="0"||sort.value==null || sort.value=="")
	{
		sort1.options[0]=new Option('客户分类','0');
	}
	else
	{
		for(i=0;i<ListUserId4[sort.value].length;i++)
		{
			sort1.options[i]=new Option(ListUserName4[sort.value][i],ListUserId4[sort.value][i]);
		}
	}
	var index=sort.selectedIndex;
} 
