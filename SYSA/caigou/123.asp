<html>  
  <head>  
  <meta   http-equiv="Content-Type"   content="text/html;   charset=UTF-8">  
  <style   type="text/css">*{font-size:14px}button{margin:3px}</style>  
  <script   type="text/javascript">  
   
  var   mytable=null,mytable2=null;  
   
  window.onload=function(){  
  mytable=new   CTable("tbl",10);  
  mytable2=new   CTable("tbl2",6);  
  }  
   
  Array.prototype.each=function(f){for(var   i=0;i<this.length;i++)   f(this[i],i,this)}  
   
  function   $A(arrayLike){  
  for(var   i=0,ret=[];i<arrayLike.length;i++)   ret.push(arrayLike[i]);  
  return   ret  
  }  
   
  Function.prototype.bind   =   function()   {  
      var   __method   =   this,   args   =   $A(arguments),   object   =   args.shift();  
      return   function()   {  
          return   __method.apply(object,   args.concat($A(arguments)));  
      }  
  }  
   
   
  function   CTable(id,rows){  
  this.tbl=typeof(id)=="string"?document.getElementById(id):id;    
  if   (rows   &&   /^\d+$/.test(rows))   this.addrows(rows)  
  }  
   
  CTable.prototype={  
  addrows:function(n){                     //随机添加n个tr  
  new   Array(n).each(this.add.bind(this))  
  },  
  add:function(){                       //添加1个tr  
  var   self=this;  
  var   tr   =   self.tbl.insertRow(-1),td1=   tr.insertCell(-1),td2=   tr.insertCell(-1),td3=   tr.insertCell(-1);  
  var   chkbox=document.createElement("INPUT")  
  chkbox.type="checkbox"  
  chkbox.onclick=self.highlight.bind(self)  
  td1.appendChild(chkbox)  
  td1.setAttribute("width","35")  
  td2.innerHTML=Math.ceil(Math.random()*99)  
  td3.innerHTML=Math.ceil(Math.random()*99)  
  },  
  del:function(){                       //删除所选tr  
  var   self=this  
  $A(self.tbl.rows).each(function(tr){if   (self.getChkBox(tr).checked)   tr.parentNode.removeChild(tr)})  
  },  
  up:function(){                             //上移所选tr  
  var   self=this  
  var   upOne=function(tr){                     //上移1个tr  
  if   (tr.rowIndex>0){  
  self.swapTr(tr,self.tbl.rows[tr.rowIndex-1])  
  self.getChkBox(tr).checked=true  
  }  
  }  
  var   arr=$A(self.tbl.rows).reverse()  
  if   (arr.length>0   &&   self.getChkBox(arr[arr.length-1]).checked){  
  for(var   i=arr.length-1;i>=0;i--){  
  if   (self.getChkBox(arr[i]).checked){  
  arr.pop()                        
  }else{  
  break  
  }  
  }  
  }  
  arr.reverse().each(function(tr){if   (self.getChkBox(tr).checked)   upOne(tr)});  
  },  
  down:function(){  
  var   self=this  
  var   downOne=function(tr){              
  if   (tr.rowIndex<self.tbl.rows.length-1)     {  
  self.swapTr(tr,self.tbl.rows[tr.rowIndex+1]);  
  self.getChkBox(tr).checked=true;  
  }  
  }  
  var   arr=$A(self.tbl.rows)  
   
  if   (arr.length>0   &&   self.getChkBox(arr[arr.length-1]).checked){  
  for(var   i=arr.length-1;i>=0;i--){  
  if   (self.getChkBox(arr[i]).checked){  
  arr.pop()  
  }else{  
  break  
  }  
  }  
  }  
  arr.reverse().each(function(tr){if   (self.getChkBox(tr).checked)   downOne(tr)});  
  },  
  sort:function(){                       //排序      
  var   self=this,order=arguments[0];  
  var   sortBy=function(a,b){  
  if   (typeof(order)=="number"){     //数字,则按数字指示的列排序  
  return   Number(a.cells[order].innerHTML)>=Number(b.cells[order].innerHTML)?1:-1;       //转化为数字类型比较大小  
  }else   if   (typeof(order)=="function"){           //为程序,按   程序的返回结果排序  
  return   order(a,b);  
  }else{  
  return   1;  
  }  
  }  
  $A(self.tbl.rows).sort(sortBy).each(function(x){  
  var   checkStatus=self.getChkBox(x).checked;  
  self.tbl.firstChild.appendChild(x);  
  if   (checkStatus)   self.getChkBox(x).checked=checkStatus;  
  });  
  },  
  rnd:function(){                       //随即选择几行tr  
  var   self=this,selmax=0,tbl=self.tbl;  
  if   (tbl.rows.length){  
    selmax=Math.max(Math.ceil(tbl.rows.length/4),1);     //选择的行数不超过tr数的1/4  
    $A(tbl.rows).each(function(x){  
  self.getChkBox(x).checked=false;  
  self.restoreBgColor(x)  

  })  
  }else{  
  return   alert("无数据可以选")  
  }  
  new   Array(selmax).each(function(){  
  var   tr=tbl.rows[Math.floor(Math.random()*tbl.rows.length)]  
  self.getChkBox(tr).checked=true;  
  self.highlight({target:self.getChkBox(tr)})  
  })  
  },  
  highlight:function(){                               //设置tr的背景色  
  var   self=this;  
  var   evt=arguments[0]   ||   window.event  
  var   chkbox=evt.srcElement   ||   evt.target  
  var   tr=chkbox.parentNode.parentNode  
  chkbox.checked?self.setBgColor(tr):self.restoreBgColor(tr)  
  },  
  swapTr:function(tr1,tr2){                           //交换tr1和tr2的位置  
  var   target=(tr1.rowIndex<tr2.rowIndex)?tr2.nextSibling:tr2;  
  var   tBody=tr1.parentNode  
  tBody.replaceChild(tr2,tr1);  
          tBody.insertBefore(tr1,target);  
  },  
  getChkBox:function(tr){                       //从tr得到   checkbox对象  
  return   tr.cells[0].firstChild  
  },  
  restoreBgColor:function(tr){                      
  tr.style.backgroundColor="#ffffff"    
  },  
  setBgColor:function(tr){  
  tr.style.backgroundColor="#c0c0c0"  
  }  
  }  
   
  function   f(a,b){  
  var   sumRow=function(row){return   Number(row.cells[1].innerHTML)+Number(row.cells[2].innerHTML)};  
  return   sumRow(a)>sumRow(b)?1:-1;  
  }  
   
  </script>  
   
  </head>  
  <body>  
   
  <button     onClick="javascript:mytable.rnd()">随机选择行</button>  
  <button     onClick="javascript:mytable.add()">添加一行</button>  
  <button     onClick="javascript:mytable.del()">删除选定行</button>  
  <button     onClick="javascript:mytable.up()">上移选定行</button>  
  <button     onClick="javascript:mytable.down()">下移选定行</button>  
  <button     onClick="javascript:mytable.sort(1)">按第一列数字排序</button>  
  <button     onClick="javascript:mytable.sort(f)">按每行数据的和排序</button>  
  <br><br>  
  <table   width=100%>  
  <tr>  
  <td   valign="top"><table   border   id="tbl"   width="80%"></table></td>  
  <td   valign="top"><table   border   id="tbl2"   width="80%"></table></td>  
  </tr>  
  </table>  
  <br><br>  
  <button     onClick="javascript:mytable2.rnd()">随机选择行</button>  
  <button     onClick="javascript:mytable2.add()">添加一行</button>  
  <button     onClick="javascript:mytable2.del()">删除选定行</button>  
  <button     onClick="javascript:mytable2.up()">上移选定行</button>  
  <button     onClick="javascript:mytable2.down()">下移选定行</button>  
  <button     onClick="javascript:mytable2.sort(2)">按第二列数字排序</button>  
  <button     onClick="javascript:mytable2.sort(f)">按每行数据的和排序</button>  
   
  </body>  
  </html>  
