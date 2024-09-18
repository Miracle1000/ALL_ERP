CountImage.width=" & Fix((n/C1) * 710) & ";" & VbCrLf
Response.Write "CountTXT.innerHTML=""处理进度:<font color=red><b>" & Clng(FormatNumber(n/C1*100,4,-1)) & "</b></font>"";" & VbCrLf
Response.Write "CountImage.title=""正在处理数据,请稍后..."";