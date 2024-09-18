
function frameResize(){
document.getElementById("cFF").style.height=I1.document.body.scrollHeight+0+"px";
}

function $(name){
	return document.getElementById(name);
}
function showmenu(self,showname){
	var tableObj=self.parentNode.parentNode;
	for(var i=0;i<tableObj.rows.length;i++){
		var tdObj=tableObj.rows[i].cells[0];
		if(tdObj==self){
			var old=tdObj.className;
			tdObj.className=(old=="menutab"?"menutab_hover":"menutab");
		}else if(tdObj==$(showname)){
			var old=tdObj.className;
			tdObj.className=(old=="menulist"?"menulist_hover":"menulist");
		}else{
			if(tdObj.id){
				tdObj.className="menulist";
			}else{
				tdObj.className="menutab";
			}
		}
	}
}
function switchMenu(self){
	var subobj=self.getElementsByTagName("ul")[0];
	if(self.className=="hover"){
		self.className="";
		subobj.style.display="none";
	}else{
		self.className="hover";
		subobj.style.display="block";
	}
}
function showHidaLeftMenu(self){
	var leftObj=$("leftmenuall");
	if(leftObj.style.display=="none"){
		leftObj.style.display="block";
		self.src="../images/hideleft.gif";
	}else{
		leftObj.style.display="none";
		self.src="../images/showleft.gif";
	}
}



function searchMe(obj,pgnum)
{
	if(obj.value.length>=0)
	{
		var tdobj=document.getElementById("showArea");
	  var url = "ajax_area.asp?t=" + escape(obj.value)+"&cp="+pgnum+"&stamp=" + new Date().getTime() + "&date1="+ Math.round(Math.random()*100);
	  xmlHttp.open("GET", url, false);
	  xmlHttp.send(null);
		tdobj.innerHTML=xmlHttp.responseText;
		document.getElementById("showlink").onclick=function(){window.location="arealist.asp?f="+(document.getElementById("showlink").getElementsByTagName("u")[0].innerHTML=="全部收缩"?"1":"2")};
	}
}

function tu(obj){
	obj.className = "toolitem"
}

function tm(obj){
	obj.className = "toolitem_hover"
}

function chgStat(lobj,flag,statonly)
{
	trobj=document.getElementById("showArea").getElementsByTagName("tr");
	for(var i=0;i<trobj.length;i++)
	{
		if(trobj[i].id)
		{
			var tdobj=trobj[i].cells[0];
			if(tdobj.className!="menu1"&&tdobj.className!="menu2")
			{
				trobj[i].style.display=(flag==1?"":"none");
			}
		}
	}

	if(!statonly)
	{
		if(flag==2)
		{
			lobj.innerHTML="<font class='red'><u>全部展开</u></font>";
			lobj.onclick=function(){
				saveStat(1);
				chgStat(this,1,false);
			};
		}
		else
		{
			lobj.innerHTML="<font class='red'><u>全部收缩</u></font>";
			lobj.onclick=function(){
				saveStat(2);
				chgStat(this,2,false);
			};
		}
	}
}
