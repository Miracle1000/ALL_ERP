<%@ WebHandler Language="C#" Class="ZBServices.SYSN.view.attendance.workforcemanage.AddPersonGroup" %>
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using ZBServices.sdk.bill;
using ZBServices.sdk.listview;
using ZBServices.ui;

namespace ZBServices.SYSN.view.attendance.workforcemanage
{
    /// <summary>
    /// 排班管理-人员分组-添加人员分组
    /// </summary>
    public class AddPersonGroup : BillPage
    {
        public override void OnBillInit(BillInitEventType callType)
        {
            Bill.UI.Title = "添加分组";
            AddScriptPath("attendance/workforcemanage.js");
            Bill.UI.MaxSpan = 2;
            Bill.Source.MainSql = @"SELECT hp.*,hc.Device,hc.ModeType Mode,hc.RangeM FROM dbo.HrKQ_PersonGroup hp 
                                    LEFT JOIN dbo.HrKQ_CardSetting hc ON hp.ID = hc.GroupID
                                    WHERE hp.ID = " + Bill.Ord;
            BillTextBoxField HID = Bill.Groups[0].Fields.AddText("", "ID");
            HID.Display = BFDisplayEnum.Hidden;
            BillTextBoxField GroupName = Bill.Groups[0].Fields.AddText("分组名称", "GroupName");
            GroupName.NotNull = true;
            GroupName.Max = 50;
            GroupName.ColSpan = 2;
            //BillHtmlField f = Bill.Groups[0].Fields.AddHtml("选择人员", "cccc");
            //BillFieldCollection nfs = f.Children;
            BillRadioBoxsField RangeType = Bill.Groups[0].Fields.AddRadios("选择人员", "RangeType");
            DataSourceClass RangeTypeSource = new DataSourceClass(DataSourceTypeEnum.OptionValues);
            RangeTypeSource.Options.Add("所有人员", 0);
            RangeTypeSource.Options.Add("调取人员", 1);
            RangeType.Source = RangeTypeSource;
            RangeType.DefValue = "0";
            RangeType.ColSpan = 2;
            RangeType.CallBack = new BillFieldCallBackClass(BFCallBackEventEnum.Click, SelectPerson_CallBack, BillCallBackPostTypeEnum.OnlyField);
            
            if (Bill.Ord > 0)
            {
                Bill.UI.Title = "人员分组修改";
                //判断如果是修改模式，是否要显示人员范围选择字段
                if (Sql.GetTable("SELECT 1 FROM dbo.HrKQ_PersonGroup WHERE ID = " + Bill.Ord + " and  RangeType = 1").Rows.Count > 0)
                {
                    BillGatesTreeField Range = Bill.Groups[0].Fields.AddGateTree("范围选择", "Range", "", GatePowerTypeEnum.GP_档案列表_所有_带选项);
                    Range.ColSpan = 2;
                    Range.NotNull = true;
                }
            }
           // f.FormatHTML = "@RangeType<br>@Range";
           BillFieldGroupClass KQConfig = Bill.Groups.Add("考勤配置", "KQConfig");
           BillCheckBoxsField Device = KQConfig.Fields.AddCheckBoxs("考勤设备", "Device", "0,1");
           DataSourceClass DeviceSource = new DataSourceClass(DataSourceTypeEnum.OptionValues);
           DeviceSource.Options.Add("电脑", 0);
           DeviceSource.Options.Add("手机", 1);
           Device.Source = DeviceSource;
           Device.ColSpan = 2;
           Device.CallBack = new BillFieldCallBackClass(BFCallBackEventEnum.Change, Device_CallBack, BillCallBackPostTypeEnum.MainFields);

           BillHtmlField ModeHtm = KQConfig.Fields.AddHtml("考勤方式", "ModeHtm");
           BillCheckBoxsField Mode = ModeHtm.Children.AddCheckBoxs("考勤方式", "Mode", "0,1");
           DataSourceClass ModeSource = new DataSourceClass(DataSourceTypeEnum.OptionValues);
           ModeSource.Options.Add("按地点考勤", 0);
           ModeSource.Options.Add("按WiFi考勤", 1);
           Mode.Source = ModeSource;
           ModeHtm.FormatHTML = "<div style='float:left'>@Mode</div><div style='margin-left:20px;float:left'>注：（1）考勤设备勾选“手机”前提下，才允许选择考勤方式；（2）同时勾选两个考勤方式，满足一项即可完成考勤。</div>";
           Mode.CallBack = new BillFieldCallBackClass(BFCallBackEventEnum.Change, Mode_CallBack, BillCallBackPostTypeEnum.MainFields);

           BillHtmlField AddressHtm = KQConfig.Fields.AddHtml("考勤地点", "AddressHtm");
           AddressHtm.Children.AddInt("", "rangeM", "300").CUnit("米").CMin(100).CMax(2000).CallBack = new BillFieldCallBackClass(BFCallBackEventEnum.Blur, rangeM_CallBack, BillCallBackPostTypeEnum.MainFields);
           BillListViewField addressConfig = AddressHtm.Children.addListView("考勤地点", "KQAddress");
           ListViewClass lvw = addressConfig.ListView;
           lvw.Page.PageSize = 99999;
           lvw.Source.MainSql = @"SELECT cm.* FROM dbo.HrKQ_PersonGroup hp 
                                INNER JOIN dbo.HrKQ_CardSetting hc ON hp.ID = hc.GroupID
                                INNER JOIN dbo.HrKQ_CardSettingMode cm ON cm.ModeType = 0 AND hc.RangeID = cm.RangeID
                                WHERE hp.ID =" + Bill.Ord;
           lvw.Headers["name"].CTitle("地址名称").CUIType(FieldUITypeEnum.TextBox).CNotNull().CMax(100);
           lvw.Headers["TextContent"].CTitle("详细地址").CUIType(FieldUITypeEnum.TextBox).CNotNull().CDisplay(BFDisplayEnum.Locked).CUnit("<img onclick='PBManage.showForMapWindow(this)' style='width:25px;height:25px;' src='" + this.VirPath + "SYSA/images/coordinate.png'/>");
           lvw.Headers["RangeID"].CDisplay(BFDisplayEnum.Hidden).CCanSave();
           lvw.Headers["ModeType"].CDisplay(BFDisplayEnum.Hidden).CCanSave().CDefValue("0");
           lvw.Headers["Coordinate"].CDisplay(BFDisplayEnum.Hidden).CCanSave();
           lvw.UI.IsAbsWidth = false;
           lvw.UI.IsHidePageBar = true;
           lvw.UI.IsHideTopToolBar = true;
           lvw.UI.IsHideBottomToolBar = true;
           lvw.UI.AllSum = false;
           lvw.UI.CurrSum = false;
           lvw.UI.IndexBox = false;
           lvw.UI.CanDelete = true;  //允许删除
           lvw.UI.RowMove = false;  //允许拖动
           lvw.UI.CanInsert = true;
           lvw.UI.FixedCols = 2;  //固定表头数量
           lvw.UI.CanMove = true;
           lvw.UI.IsHideBatchInputBar = true;
           AddressHtm.FormatHTML = "<div style='float:left'>设置打卡有效范围：</div><div style='float:left'>@rangeM</div>@KQAddress";

           BillHtmlField WIFIHtm = KQConfig.Fields.AddHtml("考勤WiFi", "WIFIHtm");
           BillListViewField KQWIFI = WIFIHtm.Children.addListView("考勤WiFi", "KQWIFI");
           ListViewClass lvw2 = KQWIFI.ListView;
           lvw2.Page.PageSize = 99999;
           lvw2.Source.MainSql = @"SELECT cm.* FROM dbo.HrKQ_PersonGroup hp 
                                INNER JOIN dbo.HrKQ_CardSetting hc ON hp.ID = hc.GroupID
                                INNER JOIN dbo.HrKQ_CardSettingMode cm ON cm.ModeType = 1 AND hc.RangeID = cm.RangeID
                                 WHERE hp.ID =" + Bill.Ord;
           lvw2.Headers["name"].CTitle("名称").CUIType(FieldUITypeEnum.TextBox).CNotNull().CMax(20);
           lvw2.Headers["TextContent"].CTitle("MAC地址").CUIType(FieldUITypeEnum.TextBox).CNotNull().PlaceHolder = "示例：9C:21:6A:04:ED:OE";
           lvw2.Headers["RangeID"].CDisplay(BFDisplayEnum.Hidden).CCanSave();
           lvw2.Headers["ModeType"].CDisplay(BFDisplayEnum.Hidden).CCanSave().CDefValue("1");
           lvw2.Headers["Coordinate"].CDisplay(BFDisplayEnum.Hidden);
           lvw2.UI.IsAbsWidth = false;
           lvw2.UI.IsHidePageBar = true;
           lvw2.UI.IsHideTopToolBar = true;
           lvw2.UI.IsHideBottomToolBar = true;
           lvw2.UI.AllSum = false;
           lvw2.UI.CurrSum = false;
           lvw2.UI.IndexBox = false;
           lvw2.UI.CanDelete = true;  //允许删除
           lvw2.UI.RowMove = false;  //允许拖动
           lvw2.UI.CanInsert = true;
           lvw2.UI.FixedCols = 2;  //固定表头数量
           lvw2.UI.CanMove = true;
           lvw2.UI.IsHideBatchInputBar = true;
           WIFIHtm.FormatHTML = "@KQWIFI 注：名称尽量保持与考勤WiFi名称一致，避免员工产生误解。";

           if (Bill.UiState != BillViewStateEnum.Add && Bill.Ord > 0)
           {
               if (Bill.Source.Items["Device"].IsNull("").IndexOf("1") == -1)
               {
                   ModeHtm.Visible = false;
                   AddressHtm.Visible = false;
                   WIFIHtm.Visible = false;
               }
               if (Bill.Source.Items["Mode"].IsNull("").IndexOf("0") == -1)
               {
                   AddressHtm.Visible = false;
               }
               if (Bill.Source.Items["Mode"].IsNull("").IndexOf("1") == -1)
               {
                   WIFIHtm.Visible = false;
               }
           }
           BillCmdButtonClass saveBtn = Bill.CommandButtons.Add("保存", "save", "bill.dosave");
           BillCmdButtonClass reloadBtn = Bill.CommandButtons.Add("重填", "reloadBtn", "location.reload()");
        }

        public void SelectPerson_CallBack(BillSaveDataCollection savedata)
        {
            if (savedata["RangeType"].Value == "0")
            {
                CallBacker.DeleteFields("Range");
                //CallBacker.SetFieldsVisible("Range", false);
            }
            else
            {
                BillGatesTreeField Range = CallBacker.NewBill.Groups[0].Fields.AddGateTree("范围选择", "Range", "", GatePowerTypeEnum.GP_档案列表_所有_带选项);
                Range.ColSpan = 2;
                Range.NotNull = true;
                CallBacker.InsertFieldsAfter("RangeType", "Range");
                //CallBacker.SetFieldsVisible("Range", true);
            }
        }

        public override void Bill_OnSave(BillSaveDataCollection SaveDatas)
        {
           string HID = SaveDatas["ID"].Value;
           string GroupName = SaveDatas["GroupName"].Value.AsSQLText();
           if (Sql.GetTable("SELECT * FROM HrKQ_PersonGroup WHERE GroupName = '" + GroupName + "' AND ID  <> '" + HID + "'").Rows.Count > 0)
           {
               Sql.RollbackTrans();
               Response.Write("<ajaxscript>alert('重名禁止录入！')</ajaxscript>");
               return;
           }
           if (SaveDatas["Device"].Value.IndexOf("1") > -1)
           {
               if (SaveDatas["Mode"].Value.IndexOf("0") > -1 && SaveDatas["KQAddress"].Table.Rows.Count == 0)
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("请填写考勤地点相关明细配置！");
                   return;
               }
               else if (SaveDatas["Mode"].Value.IndexOf("1") > -1 && SaveDatas["KQWIFI"].Table.Rows.Count == 0)
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("请填写考勤WiFi相关明细配置！");
                   return;
               }
           }
           int RangeType = SaveDatas["RangeType"].Value.ToInt();
           string Range = "0";
           string where = "";
           if (Bill.Ord > 0)
           {
               where = " AND ID <> " + Bill.Ord + "";
           }
           if (RangeType == 0)
           {
               Range = string.Empty; //如果选择所有人员，则清除旧数据。
               if (Sql.GetTable("SELECT 1 FROM dbo.HrKQ_PersonGroup WHERE RangeType IN(0,1)  AND [Disable] = 0 " + where + "").Rows.Count > 0)
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("不能为已分组的人员再次分组！");
                   return;
               }
           }
           else
           {
               Range = SaveDatas["Range"].GateValues(SaveDataGateValueType.PersonValues);
               if (Sql.GetTable("SELECT 1 FROM dbo.HrKQ_PersonGroup WHERE RangeType = 0  AND [Disable] = 0 " + where + "").Rows.Count > 0)
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("不能为已分组的人员再次分组！");
                   return;
               }
               string sql = "DECLARE @Ranges VARCHAR(8000) SET @Ranges = ''";
               sql += " SELECT @Ranges = @Ranges + ',' + CONVERT(VARCHAR(8000),[Range]) FROM dbo.HrKQ_PersonGroup WHERE 1 =1 AND [Disable] = 0 " + where;
               sql += " SELECT @Ranges = STUFF(@Ranges,1,1,'')";
               sql += " SELECT 1 FROM dbo.split(@Ranges,',') WHERE short_str IN (SELECT short_str FROM dbo.split('" + Range + "',',')) AND short_str <> ''";
               if (Sql.GetTable(sql).Rows.Count > 0)
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("不能为已分组的人员再次分组！");
                   return;
               }
           }
           if (Bill.UiState == BillViewStateEnum.Modify)
           {
               string ids = "0";
               //修改时需要校验当前分组排班的人员是否和其他分组人员的排班存在时间交叉
               if (RangeType == 0 || Sql.Exists("SELECT 1 FROM dbo.HrKQ_PersonGroup WHERE RangeType = 0 AND ID <> "+ Bill.Ord))
               {
                   //所有人员或其他分组含有所有人员只需判断排班区间没有重合
                   ids = Bill.Ord.ToString();
               }
               else
               {
                   //部分人员需要校验每个人的排班和其他分组中人员的排班是否重合
                   ids = Sql.GetValue("SELECT a.ID FROM dbo.HrKQ_PersonGroup a INNER JOIN dbo.HrKQ_PersonGroup b ON dbo.existsPower2('" + Range + "',b.Range,',') = 1 WHERE a.ID <> " + Bill.Ord + " and b.ID <> " + Bill.Ord + " GROUP BY a.ID").IsNull("0");
               }
               //校验时需要筛除自己本身分组包含的数据，不然校验永远通不过
               if (Sql.Exists(@"SELECT TOP 1 1 FROM dbo.HrKQ_Scheduling a
                                    INNER JOIN dbo.HrKQ_Scheduling b ON b.StartDate BETWEEN a.StartDate AND a.EndDate OR b.EndDate BETWEEN a.StartDate AND a.EndDate
                                    inner join dbo.HrKQ_PersonGroup c on convert(varchar(50),a.PersonGroupIDs)=CONVERT(varchar(50),c.ID)
                                    WHERE dbo.existsPower2(','+CAST(a.PersonGroupIDs AS VARCHAR(4000))+',','" + ids + "',',') = 1 AND c.ID<>" + Bill.Ord))
               {
                   Sql.RollbackTrans();
                   CallBacker.MessageBox("当前分组中的部分人员已在其他分组中存在排班数据！");
                   return;
               }
            }
           int CreateID = SessionInfoClass.CurrUserID;
           string device = SaveDatas["Device"].Value.AsSQLText();
           string modetype = SaveDatas["Device"].Value.IndexOf("1") > -1 ? Convert.ToString(SaveDatas["Mode"].Value) : string.Empty;
           string rangem = SaveDatas["Device"].Value.IndexOf("1") > -1 && SaveDatas["Mode"].Value.IndexOf("0") > -1 ? Convert.ToString(SaveDatas["rangeM"].Value) : "null";
           RangeType = RangeType == 2 ? 0 : RangeType;//分组所有人员和打卡所有人员类型值统一
           int returnID = 0;
           int GroupID = Bill.Ord;
           if (Bill.Ord > 0)
           {
               string updateGroupSQL = "UPDATE HrKQ_PersonGroup SET GroupName='" + GroupName + "',RangeType=" + RangeType + ",Range='" + Range + "',CreateID=" + CreateID + ",CreateDate=GETDATE() WHERE ID = " + Bill.Ord;
               if (Sql.Execute(updateGroupSQL) > 0)
               {
                   returnID = Sql.GetValue("SELECT RangeID FROM dbo.HrKQ_CardSetting WHERE GroupID = " + Bill.Ord).IsNull(0);
                   string updateSQL = @"UPDATE dbo.HrKQ_CardSetting SET Title='" + GroupName + "',Device='" + device + "',RangeType=" + RangeType + ",ModeType='" + modetype + "',RangeM='" + rangem + "' where GroupID=" + Bill.Ord + @";
                   DELETE FROM dbo.HrKQ_CardSettingRange WHERE RangeID =" + returnID + ";DELETE FROM dbo.HrKQ_CardSettingMode WHERE RangeID = " + returnID;
                   Sql.Execute(updateSQL);
               }
               else
               {
                   Sql.RollbackTrans();
                   Response.Write("<ajaxscript>alert('保存失败！')</ajaxscript>");
               }
           }
           else
           {
               string GroupIDSQL = "INSERT INTO dbo.HrKQ_PersonGroup(GroupName, RangeType ,Range ,CreateID ,CreateDate,[Disable])VALUES('" + GroupName + "'," + RangeType + ",'" + Range + "' ," + CreateID + " ,GETDATE(),0);SELECT @@IDENTITY";
               GroupID = Sql.GetValue(GroupIDSQL).IsNull(0);
               if (GroupID == 0)
               {
                   Sql.RollbackTrans();
                   Response.Write("<ajaxscript>alert('保存失败！')</ajaxscript>");
               }
           }
           if (returnID == 0)
           {
               string insertSQL = "INSERT INTO dbo.HrKQ_CardSetting(Title ,Device ,RangeType ,CreateID ,CreateDate,GroupID,ModeType,RangeM) ";
               insertSQL += "VALUES ('" + GroupName + "' ,'" + device + "' ," + RangeType + " ," + CreateID + " ,GETDATE()," + GroupID + ",'" + modetype + "'," + rangem + ");SELECT @@IDENTITY AS returnID";
               DataTable result = Sql.GetTable(insertSQL);
               if (result.Rows.Count > 0 && result.Rows[0]["returnID"] != DBNull.Value)
               {
                   returnID = ConvertHelper.ToInt(result.Rows[0]["returnID"]);
               }
           }
           if (returnID > 0)
           {
               foreach (string item in Range.Split(','))
               {
                   if (!string.IsNullOrWhiteSpace(item))
                   {
                       string detailSQL = "INSERT INTO dbo.HrKQ_CardSettingRange( RangeID, UserID )VALUES(" + returnID + "," + item + ")";
                       Sql.Execute(detailSQL);
                   }
               }
               if (SaveDatas["Device"].Value.IndexOf("1") > -1)
               {
                   if (SaveDatas["Mode"].Value.IndexOf("0") > -1)
                   {
                       Sql.CreateSqlTableByDataTable("#KQAddress", SaveDatas["KQAddress"].Table);
                       Sql.Execute(@"INSERT INTO dbo.HrKQ_CardSettingMode(RangeID,ModeType,Name,TextContent,Coordinate)
                                    SELECT " + returnID + ",ModeType,Name,TextContent,Coordinate FROM #KQAddress");
                   }
                   if (SaveDatas["Mode"].Value.IndexOf("1") > -1)
                   {
                       Sql.CreateSqlTableByDataTable("#KQWIFI", SaveDatas["KQWIFI"].Table);
                       Sql.Execute(@"INSERT INTO dbo.HrKQ_CardSettingMode(RangeID,ModeType,Name,TextContent)
                                    SELECT " + returnID + ",ModeType,Name,TextContent FROM #KQWIFI");
                   }
               }
               Response.Write("<ajaxscript>alert('保存成功！');opener.Report.Refresh();window.close();</ajaxscript>");
           }
           else
           {
               Sql.RollbackTrans();
               Response.Write("<ajaxscript>alert('保存失败！')</ajaxscript>");
           }
        }

        public void Device_CallBack(BillSaveDataCollection savedata)
        {
            bool vis = savedata["Device"].Value.IndexOf("1") > -1;
            CallBacker.SetFieldsVisible("ModeHtm", vis);
            CallBacker.SetFieldsVisible("AddressHtm", vis && savedata["Mode"].Value.IndexOf("0") > -1);
            CallBacker.SetFieldsVisible("WIFIHtm", vis && savedata["Mode"].Value.IndexOf("1") > -1);
            CallBacker.SetFieldAttribute("Mode", "checked", "");
        }

        public void rangeM_CallBack(BillSaveDataCollection savedata)
        {
            int rangeM = savedata["rangeM"].Value.ToInt();
            if (rangeM < 100 || rangeM > 2000)
                CallBacker.ShowVerificationText("rangeM", "请输入100-2000之间的数字");
            else
                CallBacker.ShowVerificationText("rangeM", "");
        }
        public void Mode_CallBack(BillSaveDataCollection savedata)
        {
            CallBacker.SetFieldsVisible("AddressHtm", savedata["Mode"].Value.IndexOf("0") > -1);
            CallBacker.SetFieldsVisible("WIFIHtm", savedata["Mode"].Value.IndexOf("1") > -1);
        }
    }
}