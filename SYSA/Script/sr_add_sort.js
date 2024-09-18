
try
{window.Opener.location.reload();}
catch(e){}

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
 this.storeValueObj=document.getElementById(_storeValueObjName);
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
        _select.add(new Option("根分类",""));
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
   //选择第一项(根分类),没有下级选项,所以要返回
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
                    _siblingSelect.add(new Option("根分类",""));
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
        _select.add(new Option("根分类",""));
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
}

