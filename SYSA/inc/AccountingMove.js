//存放所有信息的对象
function MV_All()
{
	var me=new Object();
	me.Kinds=new Array();
	me.Kinds.Add = function(ki)
	{
		me.Kinds[me.Kinds.length]=new MV_Kinds(me,ki);
		return me.Kinds[me.Kinds.length-1];
	};
	
	me.Kinds.FindKind=function(kindid)
	{
		for(var i=0;i<me.Kinds.length;i++)
		{
			if(me.Kinds[i].KindsID==kindid) return me.Kinds[i];
		}
		return null;
	};

	me.getTxtData=function()
	{
		var rtn="";
		for(var i=0;i<me.Kinds.length;i++)
		{
			rtn+="\1\1"+me.Kinds[i].KindsID+"\2\2";
			//rtn+="，类别："+me.Kinds[i].KindsID+"，用户：";
			for(var j=0;j<me.Kinds[i].Accounts.length;j++)
			{
				rtn+=(j==0?"":"\2\2")+me.Kinds[i].Accounts[j].AccountID+"\3\3";
				//rtn+=(j==0?"":"，用户：")+me.Kinds[i].Accounts[j].AccountID+"，单据：";
				for(var k=0;k<me.Kinds[i].Accounts[j].Orders.length;k++)
				{
					rtn+=(k==0?"":"\3\3")+me.Kinds[i].Accounts[j].Orders[k];
					//rtn+=(k==0?"":"，单据：")+me.Kinds[i].Accounts[j].Orders[k];
				}
			}
		}
		return rtn;
	};

	return me;
}

//存放单据类型数据
function MV_Kinds(mvobj,ki)
{
	var me=new Object();
	me.Accounts=new Array();
	me.Accounts.Add = function(kindsobj,accid)
	{
		me.Accounts[me.Accounts.length]=new MV_Account(me.Accounts,accid);
		me.Accounts[me.Accounts.length-1].Idx=me.Accounts.length-1;
		return me.Accounts[me.Accounts.length-1];
	};

	me.FindAcc=function(accid)
	{
		for(var i=0;i<me.Accounts.length;i++)
		{
			if(me.Accounts[i].AccountID==accid) return me.Accounts[i];
		}
		return null;
	};
	
	me.DelAcc=function(accid)
	{
		var acc=me.FindAcc(accid);
		if(!acc) return;
		me.Accounts.splice(acc.Idx,1);
		for(var i=0;i<me.Accounts.length;i++)
		{
			me.Accounts[i].Idx=i;
		}
	};
	
	me.getAllOrders=function()
	{
		var result="";
		for(var i=0;i<me.Accounts.length;i++)
		{
			var tmp=me.Accounts[i].getTxTOrders();
			if(tmp=="") continue;
			if(result!="")
			{
				result=result+","+tmp
			}
			else
			{
				result=tmp;
			}
			
		}
		return result;
	};
	
	me.KindsID=ki;
	me.getParent = function(){return mvobj;};
	return me;
}

//存放指定用户的信息（包括用户指定的转移信息）
function MV_Account(kindsobj,accid)
{
	var me=new Object();
	me.Orders = new Array();
	me.Idx = 0;
	me.Orders.Add = function(oid)
	{
		for(var i=0;i<me.Orders.length;i++)
		{
			if(me.Orders[i]==oid) return;
		}
		me.Orders[me.Orders.length]=oid;
		return me.Orders[me.Orders.length-1];
	};
	
	me.Orders.DelOrder=function(orderid)
	{
		for(var i=0;i<me.Orders.length;i++)
		{
			if(me.Orders[i]==orderid)
			{
				me.Orders.splice(i,1);
				return;
			}
		}
	};
	
	me.getTxTOrders = function()
	{
		var result="";
		for(var i=0;i<me.Orders.length;i++)
		{
			if(result!="")
			{
				result=result+","+me.Orders[i]
			}
			else
			{
				result=me.Orders[i]
			}
		}
		return result;
	};
	
	me.AccountID=accid;
	me.Orders.getParent=function(){return me};
	me.getParent = function(){return kindsobj;};
	return me;
}
