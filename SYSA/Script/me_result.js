
function test()
{
  if(!confirm('确认删除吗？')) return false;
}
 
function mm(form) 
{ ///定义函数checkall,参数为form 

for (var i=0;i<form.elements.length;i++)

///循环,form.elements.length得到表单里的控件个数
{

///把表单里的内容依依付给e这个变量 
var e = form.elements[i]; 
if (e.name != 'chkall') 
e.checked = form.chkall.checked; 
} 
} 
