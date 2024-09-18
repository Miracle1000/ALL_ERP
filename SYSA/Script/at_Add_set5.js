function ask1(ord)
{
    var getValue = document.getElementById('set_note').value;
    var reg = /[\r\n]+/g;
    if (reg.test(getValue)) {
        alert("公式中包含换行符，请去掉后重新保存!");
        return;
    }
	for(i=0;i<getValue.length;i++)
	{
		getValue=getValue.replace('原值','(1)');
		getValue=getValue.replace('净残值率','(3)');
		getValue=getValue.replace('净残值','(2)');
		getValue=getValue.replace('工作量','(4)');
		getValue=getValue.replace('计提周期','(5)');
		getValue=getValue.replace('已提周期','(7)');
		getValue=getValue.replace('计提金额','(8)');
		getValue=getValue.replace('已提金额','(9)');
		getValue=getValue.replace(']','aa');
		getValue=getValue.replace('[','aa');
	}
	try
	{
		eval(getValue);
	}
	catch(e)
	{
		alert('公式不对，请重新编辑')
		return false;
	}
	if(Validator.Validate(document.all.date,2))
	{
		document.all.date.action = "save_set5.asp?tp=1&ord="+ord; 
		document.all.date.submit();
	}
}
function ask2(ord)
{
    var getValue = document.getElementById('set_note').value;
    var reg = /[\r\n]+/g;
    if (reg.test(getValue)) {
        alert("公式中包含换行符，请去掉后重新保存!");
        return;
    }
	for(i=0;i<getValue.length;i++)
	{
		getValue=getValue.replace('原值','(1)');
		getValue=getValue.replace('净残值率','(3)');
		getValue=getValue.replace('净残值','(2)');
		getValue=getValue.replace('工作量','(4)');
		getValue=getValue.replace('计提周期','(5)');
		getValue=getValue.replace('已提周期','(7)');
		getValue=getValue.replace('计提金额','(8)');
		getValue=getValue.replace('已提金额','(9)');
		getValue=getValue.replace(']','aa');
		getValue=getValue.replace('[','aa');
	}
	try
	{
		aa=eval(getValue);
	}
	catch(e)
	{
		alert('公式不对，请重新编辑')
		return false;
	}
	if(Validator.Validate(document.all.date,2))
	{
		document.all.date.action = "save_set5.asp?tp=2&ord="+ord; 
		document.all.date.submit();
	}
}
function getPosition(obj){
  var result = 0;
  if(obj.selectionStart){ //非IE浏览器
     result = obj.selectionStart
  }else{ //IE
     var rng;
     if(obj.tagName == "TEXTAREA"){ //如果是文本域
        rng = event.srcElement.createTextRange();
        rng.moveToPoint(event.x,event.y);
     }else{ //输入框
        rng = document.selection.createRange();
     }
    rng.moveStart("character",-event.srcElement.value.length);
    result = rng.text.length;
 }
 return result;
}
var focus1=0;
var pos=0;
function getValue(obj)
{
	pos = getPosition(obj);
}
function getadd(args)
{
	var p=document.getElementById('set_note');
	var p1=p.value.substr(0,pos);
	var p2=p.value.substr(pos,p.value.length);
	tmp=p1+args+p2
	p.value=tmp;
	pos=pos+args.length;
}
