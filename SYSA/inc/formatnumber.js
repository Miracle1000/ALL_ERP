function FormatNumber(srcStr,nAfterDot)        //nAfterDot表示小数位数
{
	if(nAfterDot==0) {return parseInt(srcStr);}
	srcStr=(srcStr+'').replace(",","");
	if (isNaN(srcStr)) return  "0";
	srcStr=(Math.round(srcStr*Math.pow(10,nAfterDot))/Math.pow(10,nAfterDot)).toString();
	var v=srcStr.split(".");
	var num=v.length==1?(srcStr+ "."+"000000000000".substr(0,nAfterDot)):(srcStr + "000000000000").substr(0,srcStr.indexOf(".")+1+nAfterDot*1);
	return num;
}
