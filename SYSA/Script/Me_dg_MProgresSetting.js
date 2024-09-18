
	var lvobj=document.getElementsByTagName("div");
	var sourceobj;
	for(var i=0;i<lvobj.length;i++)
	{
		if(lvobj[i].PageType)
		{
			sourceobj=lvobj[i];
			var basename=lvobj[i].id.replace("listview_","");
			var tmpobj=lvobj[i].parentElement.parentElement.parentElement.parentElement;
			var tmpHTML=tmpobj.outerHTML;
			var tdobj=window.getParent(detailidx,5).nextSibling;
			var t=tmpobj.all;
			
			for(var j=0;j<t.length;j++)
			{
				if(t[j].id && t[j].id.indexOf(basename)>0)
				{
					tmpHTML=tmpHTML.replace(t[j].id,t[j].id.replace(basename,"88a"));
				}
			}
			document.getElementById("dlgbackdiv").innerHTML=tmpHTML;
			var dlgobj=document.getElementById("listview_88a")
			var baseobj=document.getElementById("listview_"+basename);
			dlgobj.hdataArray=baseobj.hdataArray;
			dlgobj.all[0].rows[0].cells[4].edit=1;
			dlgobj.all[0].rows[0].cells[4].save=1;
			dlgobj.autosum=0;

			var strNum=tdobj.innerText;
			
			if(strNum=="")
			{//如果是第一次编辑则全部用料设置为0
				for(var j=0;j<dlgobj.hdataArray.length;j++)
				{
					dlgobj.hdataArray[j][4]='0';
				}
			}
			else
			{//否则读取保存的值
				var numArr=strNum.split(";");
				for(var j=0;j<numArr.length;j++)
				{
					numArr[j]=numArr[j].split(",");
				}

				for(var j=0;j<dlgobj.hdataArray.length;j++)
				{
					for(var m=0;m<numArr.length;m++)
					{
						if(numArr[m][0]==dlgobj.hdataArray[j][2].split("^tag~")[0]) 
						{
							dlgobj.hdataArray[j][4]=numArr[m][1];
							break;
						}
					}
				}
			}
			lvw.UpdateScrollBar(dlgobj);
			lvw.Refresh(dlgobj);
			break;
		}
	}

	var topbarTr = window.getParent(document.getElementById("dlgbackdiv"),5).rows[0]
	var currDivCloseBar =  topbarTr.cells[1].all[0];
	currDivCloseBar.style.display = "none";
	
	function SaveValue()
	{
		var detailobj=window.getParent(detailidx,9);
		var tdobj=window.getParent(detailidx,5).nextSibling;
		var strValue="";
		var dlgobj=document.getElementById("listview_88a");
		var strValue=lvw.GetSaveDetailData(dlgobj).replace(/\#or/g,";").replace(/\#oc/g,",");
		var linktd=window.getParent(detailidx,5);
		var linkvalue=lvw.getCellValue(linktd);

		lvw.updateDataCell(linktd,linkvalue.replace("添加","编辑"));
		lvw.updateDataCell(tdobj,strValue)
		lvw.Refresh(detailobj);

		//刷新总计列表数字
		for(j=0;j<sourceobj.hdataArray.length;j++){sourceobj.hdataArray[j][4]="0";}
		var strValue2=lvw.GetSaveDetailData(detailobj);
		var tmpArr=strValue2.split("#or");
		for(j=0;j<tmpArr.length;j++)
		{
			tmpArr[j]=tmpArr[j].split("#oc");
		}

		for(j=0;j<tmpArr.length;j++)
		{
			//取出保存的字符串还原成数组
			var tmpValue=tmpArr[j][7].split(";");
			for(k=0;k<tmpValue.length;k++)
			{
				tmpValue[k]=tmpValue[k].split(",");
			}

			//将所有物料的数量各自累加
			for(m=0;m<tmpValue.length;m++)
			{
				for(n=0;n<sourceobj.hdataArray.length;n++)
				{
					if(tmpValue[m][0]==sourceobj.hdataArray[n][2].split("^tag~")[0])
					{
						sourceobj.hdataArray[n][4]=(parseFloat(tmpValue[m][1])+parseFloat(sourceobj.hdataArray[n][4].split("^tag~")[0]))+"^tag~";
						break;
					}
				}
			}
		}

		lvw.Refresh(sourceobj);
		return true;
	}
