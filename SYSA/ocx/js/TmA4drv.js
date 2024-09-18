
var	TEvent_InterOffHook		=0;		// 本地电话机摘机事件
//TV_Event.data.ptrData='1' 为一声震铃结束
//其它为开始震铃
var	TEvent_Ring			=3;		// 某一外线通道振铃事件
var	TEvent_DialEnd			=4;		// 拨号结束事件
var	TEvent_PlayEnd			=5;		// 放音结束事件
var	TEvent_NoPSTNLine		=6;		//没有接入PSTN外线，当调用TV_OffHookctrl()，让设备摘机后如果没有接入PSTN就触发该消息.(只适合B4)
var	TEvent_SendCallIDEnd		=7;		//发送震铃的号码结束
var	TEvent_Silence			=9;		//通话是一定时间的静音.默认为5秒
var	TEvent_GetChar			=10;	// 收到DTMF码事件
var	TEvent_OffHook			=11;	// 拨号后,被叫方摘机事件(不适用彩铃)
var	TEvent_HangUp			=12;	// 挂机事件
var	TEvent_Nobody			=13;	// 拨号后,没人接听事件
var	TEvent_Busy			=14;	// 检测到忙音事件
var	TEvent_InterHangUp		=19;	// 本地电话机挂机
var	TEvent_Dial			=28;	//检测到拨号音
var	TEvent_TelDial			=29;	//检测到话机拨号DTMF码
//TEvent.data.Result:0呼入来电(正常呼入来电)
//TEvent.data.Result:1呼入中第二次来电
var	TEvent_GetFsk			=30;	//得到FSK来电
var	TEvent_StopCallIn		=31;	//对方停止呼叫，（产生一个未接电话）
var	TEvent_GetDTMF			=32;	//得到DTMF码来电
var 	TEvent_TelCallOut		=33;	//电话机呼出。也就电话机拨号后听到回铃音
var 	TEvent_RingBack			=34;	//电脑拨号后接受到回铃音了
var 	TEvent_PlugOut			=36;	//设备被拔掉
var 	TEvent_PlugIn			=37;	//设备插入
var 	TEvent_RecordError		=38;	//录音发生错误(建议重新初始化设备)
var 	TEvent_PlayError		=39;	//播放错误(建议重新初始化设备)
var 	TEvent_GetDTMFTimeOut	=40;	//接收DTMF来电超时（未震铃）。
var 	TEvent_MicIn			=41;	//MIC插入状态
var 	TEvent_MicOut			=42;	//MIC拔出状态
//(调用TV_StartFlash后达到指定的时间就完成一个FLASH),不是用户按电话机的拍插簧动作
var 	TEvent_FlashEnd			=43;	//拍插簧(Flash)完成
//不能跟TEvent_GetFsk重复使用
//TEvent_GetFsk发送消息前会考虑是否有合法震铃，没有合法震铃就不发送
var 	TEvent_GetFskEx			=100;	//得到FSK EX来电(设备一直接收FSK来电)

var uPlayFileID=-1;
var uRecordID=-1;
var GetEventTimer;
var phone;
var adddate;
var changvalue;
var vbegin;
var vend;
var vhook=0;
var chenggong;
var phoneTpye=0;
function AppendStatus(szStatus)
{
	document.getElementById("StatusArea").value +=szStatus;
	document.getElementById("StatusArea").value +="\r\n";
}

function I_CheckActiveX()
{ 
	try{
	      var Ole = new ActiveXObject("TmA4drvOle.TmA4drvmOle");
	      AppendStatus("已经注册了ACTIVEX");
	  }catch(e)
   	  { 
    	      AppendStatus("未安装ACTIVEX,请使用regsvrer先注册");
			  alert("未安装ACTIVEX,请使用regsvrer先注册");
    	  }
}
function TV_Initialize()
{
 try{
	if(TmA4drvmOle.ITV_GetChannels() <= 0)
	{
 	TmA4drvmOle.ITma4drv_DLL_Version("http://www.quanova.com");
 	TmA4drvmOle.ITV_Initialize();
	}
 	if(TmA4drvmOle.ITV_GetChannels() > 0)
 	{
 		AppendStatus("打开设备成功");
		//alert(uID);
		callServer52();
		var now= new Date();
	    var date=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate();
		if (chenggong!=date)
		{
		//alert("打开设备成功");
		callServer51();
			  
		}
		
		//AppendStatus("通道数:"+TmA4drvmOle.ITV_GetChannels());
 		//AppendStatus("打开通道一自动增益控制");
		//TmA4drvmOle.ITV_ExecCmd(0,3,21,1,0,"",0);
		TmA4drvmOle.ITV_ExecCmd(0,3,21,0,0,"",0);//关闭通道一自动增益
		clearInterval(T_GetEvent);
		GetEventTimer=setInterval("T_GetEvent();" , 200);		
 	}else
 	{
	 	AppendStatus("打开设备失败");	
		alert("设备安装未成功！");
		window.location.href="../ocx/qpjA3.rar";


 	}	
 }catch(e)
 {
 }
}

function TV_Disable()
{
	clearInterval(GetEventTimer);
	TmA4drvmOle.ITV_Disable();
	AppendStatus("关闭设备完成.");
}

function TV_OffHookCtrl(uID)//软摘机
{
	TmA4drvmOle.ITV_OffHookCtrl(uID);
	if(phoneTpye==1)
	{
	vhook=1;
	var now= new Date();
	adddate=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
	vbegin=adddate;			
	try
	{
		var fsoFileName2=DateDemo();
		var fsoFolderName2=DateFolderName();
		var fso2 = new ActiveXObject("Scripting.FileSystemObject");
		try
		{
		f2=fso2.CreateFolder ("d:\\zbintel");
		}
		catch(e1)
		{
		}
		try
		{
		f2=fso2.CreateFolder ("d:\\zbintel\\ringin");
		}
		catch(e1)
		{
		}
		try
		{
			f2=fso2.CreateFolder ("d:\\zbintel\\ringin\\"+ fsoFolderName2 +"");
			f2.close();
			}
		catch(e1)
		{
			}
		var f1 = fso2.createtextfile("d:\\zbintel\\ringin\\"+ fsoFolderName2 +"\\"+ fsoFileName2 +".wav",true); 
		var wavFileUrl2="d:\\zbintel\\ringin\\"+ fsoFolderName2 +"\\"+ fsoFileName2 +".wav";
		f1.close();
		TV_StartRecordFile(uID,wavFileUrl2);
	}
	catch(e1)
	{
	//	alert(e1.message);
	}
	

		try
		{
		fso2.close();
		}
		catch(e1)
		{
		}
	}
}

function TV_HangUpCtrl(uID)//软挂机
{
	TmA4drvmOle.ITV_HangUpCtrl(uID);
	try
	{
	//alert(uID);
		TV_StopRecordFile(uID);
	}
	catch(e1)
	{
	}
	var now= new Date();
	vend=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
	callServer4(changvalue,phone,adddate,vhook,vbegin,vend);

	//alert(vhook);
}


function ITV_EnableMic(uID,bEnable)//控制MIC是否可用
{
	TmA4drvmOle.ITV_EnableMic(uID,bEnable);
}

function TV_EnableRing(uID,bEnable)
{
	TmA4drvmOle.ITV_EnableRing(uID,bEnable);
}

function TV_OpenDoPlay(uID)
{
	TmA4drvmOle.ITV_OpenDoPlay(uID);
}

function TV_CloseDoPlay(uID)
{
	TmA4drvmOle.ITV_CloseDoPlay(uID);
}

function TV_StartPlayFile(uID,szFile)
{
	uPlayFileID=TmA4drvmOle.ITV_StartPlayFile(uID,szFile,0,0,true,true,false,0);
	if(uPlayFileID < 0)
	{
	 	AppendStatus("播放失败:"+szFile);	
	}else
	{
		AppendStatus("开始播放文件:"+szFile);
	}
}

function TV_StopPlayFile(uID)
{
	TmA4drvmOle.ITV_StopPlayFile(uID,uPlayFileID);
	AppendStatus("停止播放");
}

function TV_StartRecordFile(uID,szFile)
{
//新版本将自动创建目录 如：c:\2009\07\15\a.wav 系统将自动创建 c:\2009\07\15
 //alert("ddd");
	uRecordID=TmA4drvmOle.ITV_StartRecordFile(uID,szFile,0,0);
	if(uRecordID < 0)
	{
	 	AppendStatus("录音失败:"+szFile);	
	}else
	{
		ITV_EnableMic(uID,true);
		AppendStatus("开始录音文件: id="+uRecordID+"  "+szFile);
	}
}

function TV_StopRecordFile(uID)
{
	//alert(uRecordID);
	if(uRecordID >= 0)
	{
	var vRecPath=TmA4drvmOle.ITV_GetRecFilePath(uID,uRecordID);
	TmA4drvmOle.ITV_StopRecordFile(uID,uRecordID,false);
	AppendStatus("停止录音:"+vRecPath);
	uRecordID=-1;
//压缩语音 0->压缩到(4k/s)左右 1->压缩到(2k/s)左右 其它->压缩到(1k/s)左右 压缩越大音质可能越差
	AppendStatus("正在压缩录音:"+vRecPath);
	TmA4drvmOle.ITV_ConvertFile(vRecPath,vRecPath,0);
	ITV_EnableMic(uID,false);
	AppendStatus("压缩完成");
	}else
	AppendStatus("还没录音");
}

function TV_StartDial(uID,szCode)
{
	TV_OffHookCtrl(uID);
	if(TmA4drvmOle.ITV_StartDialEx(uID,szCode,false,false) <= 0)
	{
		AppendStatus("拨号失败:"+szCode);
	}else
	{
		AppendStatus("开始拨号:"+szCode);
		phone=szCode;
	}
}

function TV_GetDiskList()
{
	var vDiskList=TmA4drvmOle.ITV_GetDiskList();
	AppendStatus("按逗号分隔的盘符列表:"+vDiskList);	
}
function TV_GetFreeSpace(szDiskname)
{
	var vFreeSpace=TmA4drvmOle.ITV_GetDiskFreeSpace(szDiskname);
	AppendStatus(szDiskname+" 空闲大小为:"+vFreeSpace+"(M)");	
}
function TV_GetTotalSpace(szDiskname)
{
	var vTotalSpace=TmA4drvmOle.ITV_GetDiskTotalSpace(szDiskname);
	AppendStatus(szDiskname+" 总共大小为:"+vTotalSpace+"(M)");	
}
function TV_BrowerPath()
{
	var vPath=TmA4drvmOle.ITV_BrowsePath("请选择目录","",0);;
	AppendStatus("选择目录:"+vPath);	
}
function TV_BrowerFile()
{
	var vPath=TmA4drvmOle.ITV_BrowseFile("wave Files(*.wav,*.wave)|*.wav;*.wave;|All Files(*.*)|*.*||",0);
	AppendStatus("选择文件:"+vPath);	
}
function  T_GetEvent()
{
	var uEventType,uResult,uRet;
	var uID;
	var vStr;
	
	
	var i=0;
	for ( var i = 0 ;i<TmA4drvmOle.ITV_GetChannels(); i++)
	{
		var vValueArray=TmA4drvmOle.ITV_GetEvent(i);
		var vValueEvent = vValueArray.split(","); 
		uRet=Number(vValueEvent[0]);
		uEventType=Number(vValueEvent[1]);
		uResult=Number(vValueEvent[2]);
		vStr=vValueEvent[3];
		if(uRet != 0)
		{
			uID=i+1;
			var vChannel="通道"+uID+":";
			var vGetSerial=TmA4drvmOle.ITV_GetSerial(uID-1);
			switch(uEventType)
			{
			case TEvent_InterOffHook:
					AppendStatus(vChannel+"电话摘机");
					var now= new Date();
					vbegin=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
					
			break;
			case TEvent_Ring:
					AppendStatus(vChannel+"来电震铃:"+vStr);	
			break;
			case TEvent_DialEnd:
					AppendStatus(vChannel+"拨号结束");
			break;
			case TEvent_PlayEnd:
					AppendStatus(vChannel+"播放结束");	
			break;
			case TEvent_NoPSTNLine:
					AppendStatus(vChannel+"检测到B4设备没接外线");	
			break;
			case TEvent_SendCallIDEnd:
					AppendStatus(vChannel+"给电话机发送号码结束");	
			break;
			case TEvent_Silence:
					AppendStatus(vChannel+"通话中一定时间静音了");	
			break;
			case TEvent_GetChar:
					AppendStatus(vChannel+"接收到按键:"+vStr+"");	
			break;
			case TEvent_OffHook:
					AppendStatus(vChannel+"检测到对方摘机了");
			
					var now= new Date();
					vbegin=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
			break;
			case TEvent_HangUp:
					AppendStatus(vChannel+"检测到对方摘机后挂机了");
						if(phoneTpye!=1)
	{
			vhook=2;
	}
					var now= new Date();
					vend=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
					try
								{
									//alert(uID);
										TV_StopRecordFile(uID-1);
								}
							catch(e1)
								{
									}

					callServer4(changvalue,phone,adddate,vhook,adddate,vend);
					TmA4drvmOle.ITV_HangUpCtrl(uID-1);
			break;
			case TEvent_Nobody:
					AppendStatus(vChannel+"无人接听");
					vhook=0;
					TV_HangUpCtrl(uID-1);
					
			break;
			case TEvent_Busy:
					AppendStatus(vChannel+"检测到忙音，没打通或者对方可能挂机了");
					TV_HangUpCtrl(uID-1);
			break;
			case TEvent_InterHangUp:
					AppendStatus(vChannel+"电话机挂机了");
					var now= new Date();
					vend=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
					//AppendStatus(vChannel+"传递回的数值:"+changvalue+"");
					//AppendStatus(vChannel+"来电号码:"+phone+"");
					//AppendStatus(vChannel+"开始通话时间:"+vbegin+"");
					//AppendStatus(vChannel+"结束通话时间:"+vend+"");
					//AppendStatus(vChannel+"来电状态:"+vhook+"");
					callServer4(changvalue,phone,adddate,vhook,vbegin,vend);
	
			break;
			case TEvent_Dial:
					AppendStatus(vChannel+"检测到拨号音");	
					var now= new Date();
					adddate=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
			break;
			case TEvent_TelDial:
					AppendStatus(vChannel+"电话拨号:"+vStr+"");	
					phone=vStr;
			break;
			case TEvent_GetFsk:
			case TEvent_GetDTMF:
					AppendStatus(vChannel+"接收到来电号码:"+vStr+"");	
					AppendStatus(vChannel+"设备序列号:"+vGetSerial+"");
					AppendStatus(vChannel+"来电时间:"+adddate+"");
					phone=vStr;
					var now= new Date();
					adddate=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
					vbegin=adddate;
					phoneTpye=1;
					refuseCall(uID,phone,vGetSerial,adddate);

					//TV_HangUpCtrl(uID-1);
					//callServer2(uID,phone,vGetSerial,adddate);
					
			break;
			case TEvent_StopCallIn:
					AppendStatus(vChannel+"传递回的数值:"+changvalue+"");
					AppendStatus(vChannel+"来电号码:"+phone+"");
					AppendStatus(vChannel+"来电时间:"+adddate+"");
					AppendStatus(vChannel+"来电状态:"+vhook+"");
					AppendStatus(vChannel+"外线停止呼入了");
				 	vhook=0;
					try
					{
					//alert(uID);
						TV_StopRecordFile(uID-1);
					}
					catch(e1)
					{
					}
					callServer3(changvalue,phone,adddate,vhook);			
			break;
			case TEvent_TelCallOut:
					AppendStatus(vChannel+"电话机拨号后检测到回铃了");
					var now= new Date();
					adddate=now.getYear()+"-"+(now.getMonth()+1)+"-"+now.getDate()+" "+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
					vbegin=adddate;
					callServer2(uID,phone,vGetSerial,adddate);
			break;
			case TEvent_RingBack:
					AppendStatus(vChannel+"电脑拨号后检测到回铃了");
					callServer2(uID,phone,vGetSerial,adddate);
					try
					{
						var fsoFileName1=DateDemo();
						var fsoFolderName1=DateFolderName();
						var fso1 = new ActiveXObject("Scripting.FileSystemObject");
						
						try
						{
							f2=fso1.CreateFolder ("d:\\zbintel");
						}
						catch(e5)
						{
						}
						try
						{
						
						f2=fso1.CreateFolder ("d:\\zbintel\\ringout");
						}
						catch(e6)
						{
						}
						try
						{
							f2=fso1.CreateFolder ("d:\\zbintel\\ringout\\"+ fsoFolderName1 +"");
							f2.close();
							}
						catch(e1)
						{
							}
					
						var f1 = fso1.createtextfile("d:\\zbintel\\ringout\\"+ fsoFolderName1 +"\\"+ fsoFileName1 +".wav",true); 
						var wavFileUrl1="d:\\zbintel\\ringout\\"+ fsoFolderName1 +"\\"+ fsoFileName1 +".wav";
						f1.close();
						TV_StartRecordFile(uID-1,wavFileUrl1);	
						try
						{
						fso1.close();
						}
						catch(e1)
						{
						}
						}
					catch(e1)
					{
					//	alert(e1.message);
					}
//					alert(wavFileUrl);

					
			break;
			case TEvent_PlugOut:
					AppendStatus(vChannel+"设备拔掉");	
			break;
			case TEvent_PlugIn:
					AppendStatus(vChannel+"设备插入");	
			break;
			case TEvent_MicIn:
					AppendStatus(vChannel+"MIC插入");
			break;
			case TEvent_MicOut:
					AppendStatus(vChannel+"MIC拔出");	
			break;
			case TEvent_FlashEnd:
					AppendStatus(vChannel+"拍插簧完成，可以开始拨分机号.");	
			break;
			default:
			if(uEventType < 255)
					AppendStatus(vChannel+"忽略其它事件发生:ID=" + uEventType);	
			break;
			}
		}
	}
}


function callServer2(s1,s2,s3,s4) {
  var url = "tc.asp?s1=" + s1 + "&s2=" + s2 + "&s3=" +s3 + "&s4=" +s4 +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage2(s2,s4);
  };
  xmlHttp.send(null);
}
//function callServer22(s1,s2,s3,s4) {
//  var url = "tc.asp?s1=" + s1 + "&s2=" + s2 + "&s3=" +s3 + "&s4=" +s4 +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
//  xmlHttp.open("GET", url, false);
//  xmlHttp.onreadystatechange = function(){
//  updatePage22(s2,s4);
//  };
//  xmlHttp.send(null);
//}

//function recordFilRequest() {
//  var url = "../test/creatFile.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
//  xmlHttp.open("GET", url, false);
//  xmlHttp.onreadystatechange = function(){
//  updateFilRequest();
//  };
//  xmlHttp.send(null);
//}

//function updateFilRequest() {
//  if (xmlHttp.readyState < 4) {
//  }
//  if (xmlHttp.readyState == 4) {
//    var response = xmlHttp.responseText;
//	alert(response);
//	if(response!="")
//	{
//TV_StartRecordFile(uID-1,response);
//	}
//	//else { //页面不正常 
//	//alert("您所请求的页面有异常。"); 
//	//} 
//	xmlHttp.abort();
//  }
//}

function refuseCall(s1,s2,s3,s4)
{
	var url = "refuseTel.asp?s2=" + s2 ;
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updateRefuse(s1,s2,s3,s4);
  };
  xmlHttp.send(null);
	}
function updateRefuse(s1,s2,s3,s4) {
	if (xmlHttp.readyState < 4) {
	}
	if (xmlHttp.readyState == 4) {
		var response = xmlHttp.responseText;
	//alert(response);
	if(response!="")
	{
		if(response=="no")
		{
		
		TV_OffHookCtrl(s1-1);
		window.setTimeout("TV_HangUpCtrl("+(s1-1)+")",1000);
	//	callServer3(changvalue,phone,adddate,vhook);
		callServer42(phone,adddate,3);
	 // callServer22(s1,s2,s3,s4);
		}
		else if(response=="ok")
		{
		callServer2(s1,s2,s3,s4);
		}
		else
		{
		alert(response);
		}


}
//else { //页面不正常 
//alert("您所请求的页面有异常。"); 
//} 
xmlHttp.abort();
}
}

var t=1;
function updatePage2(s2,s4) {
  var s2=s2;
  var s4=s4;
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    var response = xmlHttp.responseText;
	if(response!="")
	{
		changvalue=response;
		var url="PopupForm.asp?s2="+s2+"&s4="+s4+"&s1="+changvalue;
		var winName=s2+t;
		MM_openBrWindow(url,winName,'features', 700, 700, 'true')
		t=t+1;



	}
	//else { //页面不正常 
	//alert("您所请求的页面有异常。"); 
	//} 
	xmlHttp.abort();
  }
}
//function updatePage22(s2,s4) {
//  var s2=s2;
//  var s4=s4;
//  if (xmlHttp.readyState < 4) {
//  }
//  if (xmlHttp.readyState == 4) {
//    var response = xmlHttp.responseText;
//	//alert(response);
//	if(response!="")
//	{
//		changvalue=response;
//		var url="PopupForm.asp?s2="+s2+"&s4="+s4+"&s1="+changvalue;
//		xmlHttp.open("GET", url, false);
//		var winName=s2+t;
//		t=t+1;
//
//
//
//	}
//	//else { //页面不正常 
//	//alert("您所请求的页面有异常。"); 
//	//} 
//	xmlHttp.abort();
//  }
//}


function MM_openBrWindow(theURL,winName,features, myWidth, myHeight, isCenter) 
{
  if(window.screen)if(isCenter)if(isCenter=="true")
{
    var myLeft = (screen.width-myWidth)/2;
    var myTop = (screen.height-myHeight)/2;
    features+=(features!='')?',':'';
   
features+=',left='+myLeft+',top='+myTop+',scrollbars=yes';
  }
<!--
  window.open(theURL,winName,features+((features!='')?',':'')+'width='+myWidth+',height='+myHeight);
-->
}


function callServer3(s2,s3,s4,s5) {
	//TV_StartRecordFile(1,"c:\2009\07\15\a.wav");
	//TV_StopRecordFile(1);
	
  var url = "xr.asp?s2=" + s2 + "&s3=" +s3 + "&s4=" +s4 + "&s5=" +s5 +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage3();
  };
  xmlHttp.send(null);
}
function updatePage3() {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) { 
  	changvalue="";
	phone="";
	adddate="";
	vbegin="";
	vend="";
	vhook=0;
	phoneTpye=0;
	xmlHttp.abort();
  }
}

function callServer4(s2,s3,s4,s5,s6,s7) {
  var url = "yj.asp?s2=" + s2 + "&s3=" +s3 + "&s4=" +s4 + "&s5=" +s5 + "&s6=" +s6 + "&s7=" +s7 +"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
	//	TV_StartRecordFile(1,"c:\2009\07\15\a.wav");
	//TV_StopRecordFile(1);
	updatePage4();
		  };
  xmlHttp.send(null);
}
function callServer42(s2,s3,s4) {
  var url = "refuseTelAdd.asp?s2=" + s2 + "&s3=" +s3 + "&s4=" +s4+"&timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){

  updatePage4();
  };
  xmlHttp.send(null);
}
function updatePage4() {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
  	changvalue="";
	phone="";
	adddate="";
	vbegin="";
	vend="";
	vhook=0;
	xmlHttp.abort();
  }
}

function callServer51() {
  var url = "set.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.send(null);
}

function callServer52() {
  var url = "hq.asp?timestamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
  xmlHttp.open("GET", url, false);
  xmlHttp.onreadystatechange = function(){
  updatePage52();
  };
  xmlHttp.send(null);
}

function updatePage52() {
  if (xmlHttp.readyState < 4) {
  }
  if (xmlHttp.readyState == 4) {
    response = xmlHttp.responseText;
	if(response!="")
	{
		chenggong=response;
	}
	xmlHttp.abort(); 
  }
}

function DateDemo()
{
	var d, s = "";           // 声明变量。
	d = new Date();                           // 创建 Date 对象。
	s += d.getYear();                         // 获取年份。
	s += (d.getMonth() + 1);            // 获取月份。
	s += d.getDate();                   // 获取日。
	s += d.getHours(); 
	s += d.getMinutes(); 
	s += d.getSeconds(); 
	return(s);                                // 返回日期。
} 
function DateFolderName(){
		var d, s = "";           // 声明变量。
		d = new Date();                           // 创建 Date 对象。
		s += d.getYear();                         // 获取年份。
		s += (d.getMonth() + 1);            // 获取月份。
		s += d.getDate();                   // 获取日。
		 return(s);                                // 返回日期。
	 
} 