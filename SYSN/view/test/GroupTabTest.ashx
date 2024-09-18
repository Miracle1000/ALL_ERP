<%@ WebHandler Language="C#" Class="ZBServices.view.SYSN.view.test.GroupTabTest" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ZBServices.sdk.bill;
using ZBServices.sdk.listview;
using ZBServices.ui;

namespace ZBServices.view.SYSN.view.test
{
    /// <summary>
    /// GroupTabTest 的摘要说明
    /// </summary>
    public class GroupTabTest : BillPage
    {
        public override void Bill_SetGlobalInformation(IBillGlobalInformation Ibill)
        {
            Ibill.BillType = BillApplyTypeEnum.B54002_生产派工单;
        }

        public override void OnBillInit(BillInitEventType callType)
        {
            Bill.UI.Title = "组标头选项卡测试";
            Bill.CommandButtons.Add(BillCommCmdButtonEnum.SaveButton);
            Bill.CommandButtons.Add(BillCommCmdButtonEnum.ResetButton);

            BillFieldGroupClass group = Bill.BaseCroup;
            group.DBName = "product";
            group.Title = "选项卡1";
            group.CollectionsTitle = "基本信息";
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab1";
            group.Fields.AddGateTree("人员", "cateid", "0", GatePowerTypeEnum.GP_档案列表_所有).CBlock();
            group.Fields.AddTextArea("简述", "intro1","");

            group = Bill.Groups.Add("选项卡2", "tab2");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab1";
            group.Fields.AddText("名称","name2");
            group.Fields.AddDate("日期","date2");
            group.Fields.AddEditor("备注", "intro2", "");

            group = Bill.Groups.Add("一个选项卡", "gtab1");
            group.CollectionsTitle = "选项卡组1";
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab2";
            group.Fields.AddGateTree("人员", "cateid", "0", GatePowerTypeEnum.GP_档案列表_所有).CBlock();

            group = Bill.Groups.Add("选项卡1", "gtab2");
            group.CollectionsTitle = "选项卡组3";
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddGateTree("人员", "cateid", "0", GatePowerTypeEnum.GP_档案列表_所有).CBlock();

            group = Bill.Groups.Add("选项卡2", "gtab3");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddText("名称","name3");
            group.Fields.AddDate("日期","date3");

            group = Bill.Groups.Add("选项卡3", "gtab4");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话","phone");
            group.Fields.AddEmail("邮件","email");

            
            group = Bill.Groups.Add("选项卡4", "gtab5");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话4","phone4");
            group.Fields.AddEmail("邮件4","email4");
            
                
            group = Bill.Groups.Add("选项卡6", "gtab6");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话6","phone6");
            group.Fields.AddEmail("邮件6","email6");

            
            group = Bill.Groups.Add("选项卡7", "gtab7");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话7","phone7");
            group.Fields.AddEmail("邮件7","email7");

            
            group = Bill.Groups.Add("选项卡8", "gtab8");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话8","phone8");
            group.Fields.AddEmail("邮件8","email8");

            
            group = Bill.Groups.Add("选项卡9", "gtab9");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话9","phone9");
            group.Fields.AddEmail("邮件9","email9");

            
            group = Bill.Groups.Add("选项卡10", "gtab10");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话10","phone10");
            group.Fields.AddEmail("邮件10","email10");
            
            
            group = Bill.Groups.Add("选项卡11", "gtab11");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话11","phone11");
            group.Fields.AddEmail("邮件11","email11");

            
            group = Bill.Groups.Add("选项卡12", "gtab12");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话12","phone12");
            group.Fields.AddEmail("邮件12","email12");

            
            group = Bill.Groups.Add("选项卡13", "gtab13");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话13","phone13");
            group.Fields.AddEmail("邮件13","email13");

            
            group = Bill.Groups.Add("选项卡14", "gtab14");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话14","phone14");
            group.Fields.AddEmail("邮件14","email14");

            
            group = Bill.Groups.Add("选项卡15", "gtab15");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话15","phone15");
            group.Fields.AddEmail("邮件15","email15");

            
            group = Bill.Groups.Add("选项卡16", "gtab16");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话16","phone16");
            group.Fields.AddEmail("邮件16","email16");

            
            group = Bill.Groups.Add("选项卡17", "gtab17");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab3";
            group.Fields.AddPhone("电话17","phone17");
            group.Fields.AddEmail("邮件17","email17");


            group = Bill.Groups.Add("图片选项选项卡一", "gtabp1");
            group.CollectionsTitle = "图片选项卡组4";
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab4";
            group.Ui.Ico = "writting.png";
            group.Fields.AddGateTree("人员", "cateid", "0", GatePowerTypeEnum.GP_档案列表_所有).CBlock();

            group = Bill.Groups.Add("图片选项选项卡二", "gtabp2");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab4";
            group.Ui.Ico = "gj399_3.jpg";
            group.Fields.AddText("名称2","namep2");
            group.Fields.AddDate("日期2","datep2");

            group = Bill.Groups.Add("图片选项选项卡三", "gtabp3");
            group.CollectionsUiType = CollectionsUiTypeEnum.SSTab;
            group.CollectionsSign = "groupTab4";
            group.Fields.AddText("名称3","namep3");
            group.Fields.AddDate("日期3","datep3");

        }
    }
}
