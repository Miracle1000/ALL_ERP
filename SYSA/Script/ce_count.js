Validator =
{
	Require : /.+/,
	Email : /^$|^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/,
	EmailList : /^([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?((\;([a-zA-Z0-9_\u4e00-\u9fa5]+\[)?\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*(\])?)*[\;]?)+$/,
	EmailNull :/^(\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*)?$/,
	Phone : /^(((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7}|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)$/,
	PhoneNull : /^((((0[1|2]\d{1})-?(\d{8}))|(\d{8})|(\d{7})|((0[1|2]\d{1})-?(\d{8}))-(\d+)|((0[3-9]\d{2})-?(\d{7,8}))|((0[3-9]\d{2})-?(\d{7,8}))-(\d+)|0085[2|3]-?(\d{8})|0085[2|3]-?(\d{8})-(\d+)|400[1|6|7|8]\d{6}|800\d{7})|10000|10086|10001|110|120|119|114|199|122|95588|95533|95599|95566)?$/,
	Mobile : /^(13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8}$/,
	MobileNull : /^((13[0-9]|14[0-9]|15[^4]|17[0-9]|18[0-9])\d{8})?$/,
	DateTime : /^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)(\ ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9])?$/,
	Url : /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/,
	Money : /^\-?[0-9]+[\.]?[0-9]{0,4}$/,
	IdCard : /^\d{15}(\d{2}[A-Za-z0-9])?$/,
	Currency : /^\d+(\.\d+)?$/, Number : /^\d+$/,
	Zip : /^$|^[0-9]\d{5}$/,
	QQ : /^$|^[1-9]\d{4,9}$/,
	Integer : /^[-\+]?\d+$/,
	Double : /^[-\+]?\d+(\.\d+)?$/,
	English : /^[A-Za-z]+$/,
	Chinese :  /^[\u0391-\uFFE5]+$/,
	FloatNum :  /^([0-1](\.[\d]+)?)?$/,
	UnSafe : /^(([A-Z]*|[a-z]*|\d*|[-_\~!@#\$%\^&\*\.\(\)\[\]\{\}<>\?\\\/\'\"]*)|.{0,5})$|\s/,
	IsSafe : function(str){return !this.UnSafe.test(str);},
	SafeString : "this.IsSafe(value)",
	Limit : "this.limit(value.replace(/^\\s*/,'').replace(/\\s*$/,'').length,getAttribute('min'),  getAttribute('max'))",
	LimitB : "this.limit(this.LenB(value.replace(/^\\s*/,'').replace(/\\s*$/,'')), getAttribute('min'), getAttribute('max'))",
	Date : "this.IsDate(value, getAttribute('min'), getAttribute('format'),getAttribute('required'))",
	Repeat : "value == document.getElementsByName(getAttribute('to'))[0].value",
	Range : "(!getAttribute('min') || getAttribute('min') <= Number(value.replace(/\,/g,''))) && (!getAttribute('max') || Number(value.replace(/\,/g,'')) <= getAttribute('max').replace(/\,/g,'')*1)",
	Compare : "this.compare(value,getAttribute('operator'),getAttribute('to'))",
	Custom : "this.Exec(value, getAttribute('regexp'))",
	Group : "this.MustChecked(getAttribute('name'), getAttribute('min'), getAttribute('max'))",
	number:  /.+/,
	ErrorItem : [document.forms[0]],
	ErrorMessage : ["以下原因导致提交失败：\t\t\t\t"],
	Validate : function(date, mode)
	{
		if(window.onBeforeValidate) {
			if(window.onBeforeValidate()==false) {
				return false;
			}
		}
		var obj = date || event.srcElement;
		var count = obj.elements.length;
		this.ErrorMessage.length = 1;
		this.ErrorItem.length = 1;
		this.ErrorItem[0] = obj;
		try{
			if(jQuery){
				jQuery(obj).find("iframe[src*='ewebeditor.asp']").each(function(){
					this.contentWindow.syncText();
				});
			}
		}
		catch(e){}

		for(var i=0;i<count;i++)
		{
			with(obj.elements[i])
			{
				var _dataType = getAttribute("dataType");
				if(typeof(_dataType) == "object" || typeof(this[_dataType]) == "undefined")  continue;
				this.ClearState(obj.elements[i]);
				if(getAttribute("require") == "false" && value == "") continue;
				switch(_dataType)
				{
					case "Date" :
					case "Repeat" :
					case "Range" :
					case "Compare" :
					case "Custom" :
					case "Group" :
					case "Limit" :
					case "LimitB" :
					case "SafeString" :
						if(!eval(this[_dataType])){this.AddError(i, getAttribute("msg"));}
						break;
					case "DateTime":
						if(value=="" && getAttribute("min")==0) {break;}
					default :
						if(_dataType.toLowerCase()!='number'&&!this[_dataType].test(value)){this.AddError(i, getAttribute("msg"));}//
						break;
				}
				if(_dataType.toLowerCase()=="number"){
					if(!(getAttribute("cannull")=="1" && value.toString().length==0)) {
						if (isNaN(value)==true || value.toString().length==0){
							setAttribute("msg","请输入正确数字");
							this.AddError(i, getAttribute("msg"));
						}
						else{
							var limit = getAttribute("limit");
							if(limit!=null && !isNaN(limit) && (value-limit<=0)){
								setAttribute("msg","必须大于" + limit); 
								this.AddError(i, getAttribute("msg")); 
								break;
							}
							var max = getAttribute("max");
							max = (max ==null || isNaN(max) || max=="") ? null : max.toString().replace(/\,/g,'')*1;
							if(max!=null && !isNaN(max) && (value-max>0)){setAttribute("msg","不能大于" + max); this.AddError(i, getAttribute("msg")); break;}
							var min = getAttribute("min");
							min = (min ==null || isNaN(min) || min=="") ? null : min.toString().replace(/\,/g,'')*1;
							if(min!=null && !isNaN(min) && (value-min<0)){setAttribute("msg","不能小于" + min); this.AddError(i, getAttribute("msg")); break;}
						}
					}
					//break;
				}
			}
		}

		if(this.ErrorMessage.length > 1){
			mode = mode || 1;
			var errCount = this.ErrorItem.length;
			var $topErrorItem = jQuery(this.ErrorItem[1]);
			if ($topErrorItem.size()>0){
				var msgWhenHide = $topErrorItem.attr('msgWhenHide');
				if ($topErrorItem.height()==0 || 
						$topErrorItem.width()==0 || 
						$topErrorItem.css('display')=='none' || 
						$topErrorItem.css('visiblity')=='hidden'){
					if (msgWhenHide){
						alert(msgWhenHide);
					}
				}
			}

			switch(mode){
				case 2 :
					for(var i=1;i<errCount;i++)	this.ErrorItem[i].style.color = "red";
				case 1 :
					for(var i=1;i<errCount;i++){
						try{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}
						catch(e){
							alert(e.description);
						}
					}
					try{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				case 3 :
					for(var i=1;i<errCount;i++){
						try{
							var span = document.createElement("SPAN");
							span.id = "__ErrorMessagePanel";
							span.style.color = "red";
							this.ErrorItem[i].parentNode.appendChild(span);
							span.innerHTML = this.ErrorMessage[i].replace(/\d+:/,"");
						}catch(e){
							alert(e.description);
						}
					}
					try{
						this.ErrorItem[1].focus();
					}
					catch(e){}
					break;
				default :
					alert(this.ErrorMessage.join("\n"));
					break;
			}
			return false;
		}
		if(window.onAfterValidate) {
			if(window.onAfterValidate()==false) {
				return false;
			}
		}
		return true;
	},
	limit : function(len,min, max){
		min = min || 0;
		max = max || Number.MAX_VALUE;
		return min <= len && len <= max;
	},
	LenB : function(str){
		return str.replace(/[^\x00-\xff]/g,"**").length;
	},
	ClearState : function(elem){
		with(elem){
			if(style.color == "red") style.color = "";
			var lastNode = parentNode.childNodes[parentNode.childNodes.length-1];
			if(lastNode.id == "__ErrorMessagePanel") parentNode.removeChild(lastNode);
		}
	},
	AddError : function(index, str){
		this.ErrorItem[this.ErrorItem.length] = this.ErrorItem[0].elements[index];
		this.ErrorMessage[this.ErrorMessage.length] = this.ErrorMessage.length + ":" + str;
	},
	Exec : function(op, reg){
		return new RegExp(reg,"g").test(op);
	},
	compare : function(op1,operator,op2){
		switch (operator){
			case "NotEqual":
				return (op1 != op2);
			case "GreaterThan":
				return (op1 > op2);
			case "GreaterThanEqual":
				return (op1 >= op2);
			case "LessThan":
				return (op1 < op2);
			case "LessThanEqual":
				return (op1 <= op2);
			default:
				return (op1 == op2);
		}
	},
	MustChecked : function(name, min, max){
		var groups = document.getElementsByName(name);
		var hasChecked = 0;
		min = min || 1;
		max = max || groups.length;
		for(var i=groups.length-1;i>=0;i--)	if(groups[i].checked) hasChecked++;
		return min <= hasChecked && hasChecked <= max;
	},
	IsDate : function(op, min,formatString,required){
		if (required != undefined && ((op == null) || (op == ""))) return false;
		if (((op == null ) || (op =="") ) && ( (min == null ) || (min =="") ) ) return true;
		formatString = formatString || "ymd";
		var m, year, month, day;
		switch(formatString){
			case "ymd" :
				m = op.match(new RegExp("^((\\d{4})|(\\d{2}))([-./])(\\d{1,2})\\4(\\d{1,2})$"));
				if (m == null ) return false;
				day = m[6];
				month = m[5]--;
				year =  (m[2].length == 4) ? m[2] : GetFullYear(parseInt(m[3], 10));
				break;
			case "dmy" :
				m = op.match(new RegExp("^(\\d{1,2})([-./])(\\d{1,2})\\2((\\d{4})|(\\d{2}))$"));
				if(m == null ) return false;
				day = m[1];
				month = m[3]--;
				year = (m[5].length == 4) ? m[5] : GetFullYear(parseInt(m[6], 10));
				break;
			default :
				break;
		}
		if(!parseInt(month)) return false;
		month --;
		var date = new Date(year, month, day);
		return (typeof(date) == "object" && year == date.getFullYear() && month == date.getMonth() && day == date.getDate());
		function GetFullYear(y){
			return ((y<30 ? "20" : "19") + y)|0;
		}
	}
}

function $ID(v) {return document.getElementById(v)}