
function inselect4()
{

document.FrontPage_Form1.sort.length=0;
if(document.FrontPage_Form1.sort1.value=="0"||document.FrontPage_Form1.sort1.value==null)
document.FrontPage_Form1.sort.options[0]=new Option('一级分类','0');
else
{
for(i=0;i<ListUserId4[document.FrontPage_Form1.sort1.value].length;i++)
{
document.FrontPage_Form1.sort.options[i]=new Option(ListUserName4[document.FrontPage_Form1.sort1.value][i],ListUserId4[document.FrontPage_Form1.sort1.value][i]);
}
}
var index=document.FrontPage_Form1.sort1.selectedIndex;
//sname.innerHTML=document.FrontPage_Form1.E1.options[index].text
} 

//-->
