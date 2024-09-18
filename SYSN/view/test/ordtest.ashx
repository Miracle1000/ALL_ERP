<%@ WebHandler Language="C#" Class="ZBServices.view.SYSN.view.test.ordtest" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ZBServices.ui;
using ZBServices.sdk;

namespace ZBServices.view.SYSN.view.test
{
    /// <summary>
    /// ordtest 的摘要说明
    /// </summary>
    public class ordtest : BillPage
    {
        public override void OnNoUserLogin()
        {
        }

        public override void OnBillInit(BillInitEventType callType)
        {
            Bill.UI.Title = "测试";

            string session = GetText("session").Trim();// 9d5ee58f206581ac8c7d3ac6260e6e35e070dca75146c96f81de23d484a4fdf0c40e4d3ff9be18979b4e2b3fb30f3e05ec6aa7158cdaae76050dcdca3625f3f22cadd09e96ab671765a7864537b168608da93a221a2afc25f50f4596c69d60adf28d8843a3e10bc82599d116dae7433672266984fd680fcfd0e6be427984bf3b4788b1fbc91181f7";
            if (session == "")
            {
                Bill.BaseCroup.Fields.AddEditor("", "tip", "<h2 color='red'>请录入session参数值</h2>").CValue("<h2 color='red'>请录入session参数值</h2>").CDisplay(sdk.bill.BFDisplayEnum.ReadOnly);
            }
            else
            {
                string token = TextCoderClass.DesDeCode(session, "zbintel4");
                Bill.BaseCroup.Fields.AddText("Session", "session", token).CValue(token);
                string[] items = token.Split("|");
                Bill.BaseCroup.Fields.AddInt("长度", "length", items.Length.ToString()).CValue(items.Length.ToString());
                Bill.BaseCroup.Fields.AddText("mUserID", "mUserID", items[1].ToString()).CValue(items[1].ToString());
                Bill.BaseCroup.Fields.AddText("items[7]", "items7", items[7].ToString()).CValue(items[7].ToString());
            }
        }
    }
}