/**
 * 无限级联动选择菜单类
 * _storeValueObjName:存放选择项值的页面元素名称
 * _showSelectObjName:显示该菜单的页面元素名称
 * _sortArr:显示菜单所需的数组，格式如下
 * arrSorts[0] = ["类别ID1", "类别一", "父类ID1"];
 * arrSorts[1] = ["类别ID2", "类别二", "父类ID2"];
 *

 */
function sortMenu(_storeValueObjName, _showSelectObjName, _sortArr)
{
 this.storeValueObj=document.getElementsByName(_storeValueObjName)[0];
 this.showSelectObj=document.getElementById(_showSelectObjName);
 this.sortArr=_sortArr;

 /**
  * 获取第一层分类，并显示在showSelectObj中
  * _sortMenuObj:sortMenu的实例对象，指向自己
  */
 this.initSorts=function(_sortMenuObj)
 {
        this.storeValueObj.value=0;
        _select=document.createElement("select");
        this.showSelectObj.insertAdjacentElement("afterBegin",_select);
        _select.sortMenuObj=_sortMenuObj;
        _select.onchange=function()
        {
            this.sortMenuObj.setSorts(this,this.sortMenuObj);
        }
        _select.add(new Option("请选择",""));
  for (var i = 0; i < this.sortArr.length; i++)
  {
   if (this.sortArr[i][2] == 0)
   {
                _select.add(new Option(this.sortArr[i][1],this.sortArr[i][0]));
   }
  }  
 }

 /**
  * 下拉框联动
  * _curSelect:当前选择的下拉框
     * _sortMenuObj:sortMenu的实例对象，指向自己
  */
 this.setSorts=function(_curSelect,_sortMenuObj)
 {
  //若当前下拉框后面还有下拉框，即有下级下拉框时，清除下级下拉框，在后面会重新生成下级部分
  //下级下拉框与当前下拉框由于都是显示在showSelectObj中，故它们是兄弟关系，所以用nextSibling获取
  while (_curSelect.nextSibling)
  {
   _curSelect.parentNode.removeChild(_curSelect.nextSibling);
  }
  
  //获取当前选项的值
  _iValue = _curSelect.options[_curSelect.selectedIndex].value;
  //如果选择的是下拉框第一项(第一项的值为"")
  if (_iValue == "")
  {
   //若存在上级下拉框
   if (_curSelect.previousSibling)
   {
    //取值为上级下拉框选中值
    this.storeValueObj.value = _curSelect.previousSibling.options[_curSelect.previousSibling.selectedIndex].value;
   }
   else
   {
    //没上级则取值为0
    this.storeValueObj.value = 0;
   }
   //选择第一项(请选择...),没有下级选项,所以要返回
   return false;
  }
  //选择的不是第一项
  this.storeValueObj.value = _iValue;
  
  //去掉当前下拉框原来的选择状态
        //将选中的选项对应代码更改为 selected
        for (i=0;i<_curSelect.options.length;i++)
        {
            if (_curSelect.options[i].selected=="selected")
            {
                _curSelect.options[i].removeAttribute("selected");
            }
            if (_curSelect.options[i].value==_iValue)
            {
                _curSelect.options[i].selected="selected";
            }
        }
        //新生成的下级下拉列表
        _hasChild=false;
        for (var i = 0; i < this.sortArr.length; i++)
  {
            if (this.sortArr[i][2] == _iValue)
            {
                if (_hasChild==false)
                {
                    _siblingSelect=document.createElement("select");
                    this.showSelectObj.insertAdjacentElement("beforeEnd",_siblingSelect);
                    _siblingSelect.sortMenuObj=_sortMenuObj;
                    _siblingSelect.onchange=function()
                    {
                        this.sortMenuObj.setSorts(this,this.sortMenuObj);
                    }
                    _siblingSelect.add(new Option("请选择",""));
                    _siblingSelect.add(new Option(this.sortArr[i][1],this.sortArr[i][0]));
                    _hasChild=true;
                }
                else
                {                   
                    _siblingSelect.add(new Option(this.sortArr[i][1],this.sortArr[i][0]));
                }
            }
        }
 }

 /**
  * 根据最小类选取值生成整个联动菜单,由后往前递归完成
  * _minCataValue:最小类的取值
     * _sortMenuObj:sortMenu的实例对象，指向自己
  */
 this.newInit=function(_minCataValue,_sortMenuObj)
 {
        if (this.storeValueObj.value=="undefined" || this.storeValueObj.value=="")
        {
            this.storeValueObj.value=_minCataValue;
        }
  if (_minCataValue == 0)
  {
   //minCataValue为0，也就是初始化了
   this.initSorts(_sortMenuObj);
   //初始化完成后，退出函数
   return false;
  }
  //父级ID
  _parentID=null;
        _select=document.createElement("select");
        _select.sortMenuObj=_sortMenuObj;
        _select.onchange=function()
        {
            this.sortMenuObj.setSorts(this,this.sortMenuObj);
        }
        this.showSelectObj.insertAdjacentElement("afterBegin",_select);
        _select.add(new Option("请选择","")); 
  for (var i = 0; i < this.sortArr.length; i++)
  {
   if (_minCataValue == this.sortArr[i][0])
   {
    _parentID = this.sortArr[i][2];
    break;
   }
  }
  for (var i = 0; i < this.sortArr.length; i++)
  {
   if (this.sortArr[i][2] == _parentID)
   {
    if (this.sortArr[i][0] == _minCataValue)
    {
                    _opt=new Option(this.sortArr[i][1],this.sortArr[i][0]); 
                    _select.add(_opt);
                    _opt.selected="selected";
    }
    else     
    {
                    _select.add(new Option(this.sortArr[i][1],this.sortArr[i][0]));
                }
   }
  }  
  if (_parentID > 0)
  {
   this.newInit(_parentID,_sortMenuObj);
  }
 }
};
var gatePerson={
/*弹出选择用户框*/
		showGatePersonDiv:function(gateList,all)
		{
			var parentDiv=window.DivOpen("gateMune" ,"人员选择", 600,490,"50","dd",false,2,false,1);
			ajax.regEvent("showGatePerson");
			ajax.addParam("gateList",gateList);
			ajax.addParam("allPerson", all); //是否加载档案中的人员
			parentDiv.innerHTML= ajax.send();
		},
		showGatePersonDiv1:function(gateList,all)
		{
			var zt=document.getElementsByName("ygzt");
			var ztlist="";
			for(var i=0;i<zt.length;i++){
				 if(zt[i].checked){
					ztlist=ztlist+zt[i].value+",";
				 }
			   }
			if (ztlist.length>0)
			{
				ztlist=ztlist.substring(0,ztlist.length-1);
			}
			var parentDiv=window.DivOpen("gateMune" ,"人员选择", 600,490,"50","dd",false,2,false,1);
			ajax.regEvent("showGatePerson");
			ajax.addParam("nowstatus",ztlist);
			ajax.addParam("gateList",gateList);
			ajax.addParam("allPerson", all); //是否加载档案中的人员
			parentDiv.innerHTML= ajax.send();
		},
		getGateList:function()
		{
			var box= document.getElementsByName("gatePerson")[0];
			var hbox = document.getElementsByName(Bill.currSortBoxName)[0]
			var tbutton = hbox.parentElement.children[0];
			var member1 = $('input:radio[name="member1"]:checked').val();
			if (member1 && member1==0)
			{
				hbox.value = "0"
				tbutton.value =  "所有用户"
			} else {
				hbox.value = box.value;
				tbutton.value = box.getAttribute("text");
			}
			if(document.getElementById("divdlg_gateMune")){		document.getElementById("divdlg_gateMune").style.display="none";}
		},
		selectGateAll:function()
		{
			var win= document.getElementById(document.getElementsByName("gatePerson")[0].id.replace("_w3","")).contentWindow; 
			win.TreeView.CheckAll(win.TreeView.objects[0]);
		},
		selectGateSorce:function(cid)
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1&& input[i].id.indexOf("gateItem"+cid+"_") != -1)
				{
					if(input[i].checked)
					{
						input[i].checked=false;
						}
					else
					{
						input[i].checked=true;
						}
				}	
			}
		},
		selectGateSorce2:function(cid)
		{
			var input = document.getElementsByTagName("input");
			var r=document.getElementsByName("gatePerson"); 
			var valList="",strList="";
			for(var i = 0; i < input.length; i ++)
			{
				if(input[i].type == "checkbox" && input[i].id.indexOf("gateItem") != -1&& input[i].id.indexOf("_"+cid+"_") != -1)
				{
					if(input[i].checked)
					{
						input[i].checked=false;
						}
					else
					{
						input[i].checked=true;
						}
				}	
			}
		},
		selectGateUn:function()
		{
			var win= document.getElementById(document.getElementsByName("gatePerson")[0].id.replace("_w3","")).contentWindow; 
			win.TreeView.CheckXOR(win.TreeView.objects[0]);
		},
		showGateRadioDiv:function (obj,val,all)
		{
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false);
			ajax.regEvent("showGateRadio");
			ajax.addParam("gateRadio",val);
			ajax.addParam("DivID",obj.name);
			ajax.addParam("allPerson",all==1 ? 1 : 0); //是否显示所有人
			parentDiv.innerHTML= ajax.send();
		},
		gateShowRadioDiv:function (obj,val,ptype)
		{
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false);
			ajax.regEvent("GateshowRadio");
			ajax.addParam("gateRadio",val);
			ajax.addParam("DivID",obj.name);
			ajax.addParam("ptype",ptype); //显示所有人 范围
			parentDiv.innerHTML= ajax.send();
		},
		getRadioGate:function (obj,DivID)
		{

			var valList="",strList="";
			valList=obj.value;
			strList=obj.title;
			var hbox = document.getElementsByName(DivID)[0];
			var tbutton = hbox.parentElement.children[1];
			if(valList==""||strList=="")
			{
				valList=0;
				strList="点击选择";
				}
				hbox.value = strList;
				tbutton.value =valList;
			if(document.getElementById("divdlg_Select_div")){		document.getElementById("divdlg_Select_div").style.display="none";}
		},
		getGateRadio:function (obj,DivID)
		{

			var valList="",strList="";
			valList=obj.value;
			strList=obj.title;
			var hbox = document.getElementsByName(DivID)[0];
			var tbutton = hbox.parentElement.children[0];
			if(valList==""||strList=="")
			{
				valList=0;
				strList="点击选择";
				}
				hbox.value = strList;
				tbutton.value =valList;

			if(document.getElementById("divdlg_Select_div")){		document.getElementById("divdlg_Select_div").style.display="none";}
		},
		showGateRadioDiv1:function (name,val)
		{
			var zt=document.getElementsByName("ygzt");
			var ztlist="";
			for(var i=0;i<zt.length;i++){
				 if(zt[i].checked){
					ztlist=ztlist+zt[i].value+",";
				 }
			   }
			if (ztlist.length>0)
			{
				ztlist=ztlist.substring(0,ztlist.length-1);
			}
			var parentDiv=window.DivOpen("Select_div" ,"人员选择", 600,500,"dd","dd",false,2);
			ajax.regEvent("showGateRadio");
			ajax.addParam("nowstatus",ztlist);
			ajax.addParam("gateRadio",val);
			ajax.addParam("DivID",name);
			parentDiv.innerHTML= ajax.send();
		}
};
