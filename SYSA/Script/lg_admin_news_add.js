
function Dsy()
{
this.Items = {};
}
Dsy.prototype.add = function(id,iArray)
{
this.Items[id] = iArray;
}
Dsy.prototype.Exists = function(id)
{
if(typeof(this.Items[id]) == "undefined") return false;
return true;
}

function change(v){
var str="0";
for(i=0;i<v;i++){ str+=("_"+(document.getElementById(s[i]).selectedIndex-1));};
var ss=document.getElementById(s[v]);
with(ss){
  length = 0;
  options[0]=new Option(opt0[v],opt0[v]);
  if(v && document.getElementById(s[v-1]).selectedIndex>0 || !v)
  {
   if(dsy.Exists(str)){
    ar = dsy.Items[str];
    for(i=0;i<ar.length;i++)options[length]=new Option(ar[i],ar[i]);
    if(v)options[1].selected = true;
   }
  }
  if(++v<s.length){change(v);}
}
}
var dsy = new Dsy();
dsy.add("0",["餐饮美食","时尚购物","IT通讯","旅游休闲","车行天下","医疗保健","房产家居","文化娱乐","金融理财","教育培训"]);
dsy.add("0_0",["特色菜系","酒吧西餐","快餐茶点","酒楼推荐","综合美食","食品饮料","亚洲菜系"]);
dsy.add("0_1",["服装服饰","箱包皮具","化妆品","家用电器","金银首饰","文体用品","婴幼儿世界","鲜花礼品"]);
dsy.add("0_2",["手机","笔记本","电脑及周边","数码相机","mp3","其他","游戏周边"]);
dsy.add("0_3",["旅游服务","旅游交通","休闲娱乐","宾馆饭店","旅游用品"]);
dsy.add("0_4",["整车销售","配件维修","装饰养护","汽车运动","汽车租赁"]);
dsy.add("0_5",["整形美容","各类医院","运动健康","美体瘦身","药品保健"]);
dsy.add("0_6",["装饰装修","买房指南","家具用品","房屋租售","家政服务"]);
dsy.add("0_7",["票务入场券","夜生活","摄影摄像","图书音像"]);
dsy.add("0_8",["银行服务","保险","证券基金"]);
dsy.add("0_9",["专业培训","职业教育","中小学","会议讲座","留学移民","继续教育","学前教育"]);

var s=["s1","s2"];
var opt0 = ["请选择","请选择"];
function setup()
{
for(i=0;i<s.length-1;i++)
  document.getElementById(s[i]).onchange=new Function("change("+(i+1)+")");
change(0);
}

function Dsy2()
{
this.Items = {};
}
Dsy2.prototype.add = function(id,iArray)
{
this.Items[id] = iArray;
}
Dsy2.prototype.Exists = function(id)
{
if(typeof(this.Items[id]) == "undefined") return false;
return true;
}

function change2(v){
var str="0";
for(i=0;i<v;i++){ str+=("_"+(document.getElementById(t[i]).selectedIndex-1));};
var tt=document.getElementById(t[v]);
with(tt){
  length = 0;
  options[0]=new Option(opt1[v],opt1[v]);
  if(v && document.getElementById(t[v-1]).selectedIndex>0 || !v)
  {
   if(dsy2.Exists(str)){
    ar = dsy2.Items[str];
    for(i=0;i<ar.length;i++)options[length]=new Option(ar[i],ar[i]);
    if(v)options[1].selected = true;
   }
  }
  if(++v<t.length){change2(v);}
}
}
var dsy2 = new Dsy2();
dsy2.add("0",["代金券","现金折扣券","打折券","附赠券","赠品券","会员券"]);
dsy2.add("0_0",["5元","10元","15元","20元","25元","30元","35元","40元","45元","50元","60元","70元","80元","90元","100元","200元","300元"]);
dsy2.add("0_1",["5元","10元","15元","20元","25元","30元","35元","40元","45元","50元","60元","70元","80元","90元","100元","200元","300元"]);
dsy2.add("0_2",["9.5折","9折","8.5折","8折","7.5折","7折","6.5折","6折","5.5折","5折","4.5折","4折","3.5折","3折","2.5折","2折","1.5折","1折"]);
dsy2.add("0_3",["买一送一","买二送一","买三送一","买四送一","买五送一","买六送一","买一送二","买一送三",]);
dsy2.add("0_4",["请填写下列方框"]);
dsy2.add("0_5",["请填写下列方框"]);

var t=["t1","t2"];
var opt1 = ["请选择优惠券","优惠券内容"];
function setup2()
{
for(i=0;i<t.length-1;i++)
  document.getElementById(t[i]).onchange=new Function("change2("+(i+1)+")");
change2(0);
}

