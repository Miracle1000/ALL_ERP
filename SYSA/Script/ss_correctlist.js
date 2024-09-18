
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
