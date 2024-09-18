<%@ WebHandler Language="C#" Class="ZBServices.view.SYSN.view.test.test2" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ZBServices.ui;
using ZBServices.sdk;
using ZBServices.sdk.bill;

namespace ZBServices.view.SYSN.view.test
{
    /// <summary>
    /// test2 的摘要说明
    /// </summary>
    public class test2 : BillPage
    {
        public override void OnNoUserLogin()
        {
        }

        public override void OnBillInit(BillInitEventType callType)
        {
            Bill.UI.Title = "测试";
            Bill.BaseCroup.Fields.AddSelectBox("下拉选择框", "select1").CForeColor("green").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("下拉选择框2", "select12", "了接口了库间").CForeColor("#33cc99").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("只读下拉选择框", "select2", "3").CReadOnly().CForeColor("blue").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("锁定下拉选择框", "select3", "2").CDisplay(BFDisplayEnum.Locked).CForeColor("red").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("禁用下拉选择框", "select4", "3").CDisplay(BFDisplayEnum.Disabled).CForeColor("red").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("禁编下拉选择框", "select5", "4").CDisplay(BFDisplayEnum.DisEdit).CForeColor("red").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
            Bill.BaseCroup.Fields.AddSelectBox("隐藏下拉选择框", "select6", "5").CDisplay(BFDisplayEnum.Hidden).CForeColor("red").SetOptions("的非官方=1;的风高放火=2;发挂号费和个=3;了接口了库间=4;尔特人花=5");
        }
    }
}