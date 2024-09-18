
		function addreply(){
		    var lenths=document.getElementById("replysobj").rows.length;
			var ntr=document.getElementById("replysobj").insertRow(lenths);
			ntr.id="reply_"+vi.toString();
			var ntd=ntr.insertCell(0);
			ntd.width='20%';
			ntd.innerHTML="<div align='right'>第"+vi.toString()+"次联系：</div>";
			var ntd=ntr.insertCell(1);
			ntd.colSpan='2';
			ntd.width='45%';
			ntd.innerHTML="<div align='left'><input name='reply"+vi.toString()+"' type='text' id='reply"+vi.toString()+"' size='15' dataType='Number' min='0' max='10000'  msg='数字在0-10000之间' value='1' onKeyUp='autoztday()' onpropertychange='totalday()'> 天（与上一次联系天数间隔）</div>"
			var ntd=ntr.insertCell(2);
			ntd.width='30%';
			ntd.innerHTML="<div align='left' style='cursor:pointer;' onclick=\"deleterow('reply_"+vi.toString()+"')\">删除</div>"
			vi=parseInt(vi)+1;
			autoztday();
		}
		function deleterow(rowid){
			var tb=document.getElementById("replysobj");
			var lenths=tb.rows.length
			var needResetId=0;
			for (var ii=0;ii<lenths ; ii++)
			{
			  if (tb.rows[ii] && tb.rows[ii].id==rowid)
			  {
				document.getElementById("replysobj").deleteRow(ii);vi=parseInt(vi)-1;needResetId=1;
			  }
			}
			if (needResetId!=0)  //需要重新生成排列序号
			{
				for(var ii=0;ii<lenths-1;ii++){
				var rowobj_id=document.getElementById("replysobj").rows[ii].id.toString();
				rowobj_id=rowobj_id.replace(/reply_/g,'');
				document.getElementById("replysobj").rows[ii].id="reply_"+(ii+2).toString();
				document.getElementById("replysobj").rows[ii].cells[0].innerHTML = "<div align='right'>第"+(ii+2).toString()+"次联系：</div>";
				document.getElementById("replysobj").rows[ii].cells[2].innerHTML="<div align='left' style='cursor:pointer;' onclick=\"deleterow('reply_"+(ii+2).toString()+"')\">删除</div>";
				document.getElementById("replysobj").rows[ii].cells[1].innerHTML=document.getElementById("replysobj").rows[ii].cells[1].innerHTML.replace(new RegExp('reply'+rowobj_id,"g"),'reply'+(ii+2).toString())
				}
			}
			autoztday();
		}
		
		function autoztday(){
			var ztday=0;
			var lenths=document.getElementById("replysobj").rows.length;
			if(document.getElementById("reply1").value!=""){
				ztday += Number(document.getElementById("reply1").value);
			}
			if(lenths>0){
				for(n=2;n<(lenths+2);n++){
					ztday += Number(document.getElementById("reply"+n).value);	
				}
			}
			ztday += Number(document.getElementById("replycommon").value);
			document.getElementById("replypause").value = ztday;
			var hasReply = (document.getElementById("replysobj").innerHTML.replace(/\s/g,"").length>0);
			document.getElementById("replysobj").style.display=(hasReply?"":"none");
		}
	