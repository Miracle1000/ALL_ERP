<%@ WebHandler Language="C#" Class="ZBServices.view.SYSN.view.init.guide.AttrSettingChildHome" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ZBServices.ui;

namespace ZBServices.view.SYSN.view.init.guide
{
	/// <summary>
	/// AttrSettingChildHome 的摘要说明
	/// </summary>
	public class AttrSettingChildHome : ZBServices.ui.BillPage
	{
		public override void OnBillInit(BillInitEventType callType)
		{
			Bill.UI.Title = "系统参数说明";
			CssTexts.Append(@"
				#aaa_fbg{border:0px;} 
				#aaa_fbg * {color:#000} 
				#bill_bottomdiv {display:none}
				div.carditem {width:25%;float:left; margin-bottom:45px}
				div.carditem  div.title, div.carditem  div.bodycontent{  margin:0px 20px; }
				#aaa_fbg div.carditem  div.title  { background-repeat:no-repeat; background-position:18% center; height:80px;color:#fff;padding-left:34%;font-size:16px;font-family:微软雅黑;line-height:80px;overflow:hidden;}
				div.line1,  div.line2 {clear:both;}
				#cd11 div.title {background:#4d93F3 url(../../../skin/default/img/guide/s11.png); }
				#cd12 div.title {background:#f28862 url(../../../skin/default/img/guide/s12.png); }
				#cd13 div.title {background:#BB87F2 url(../../../skin/default/img/guide/s13.png); }
				#cd14 div.title {background:#39BE9A url(../../../skin/default/img/guide/s14.png); }
				#cd21 div.title {background:#8692F3 url(../../../skin/default/img/guide/s21.png); }
				#cd22 div.title {background:#95BF44 url(../../../skin/default/img/guide/s22.png); }
				#cd23 div.title {background:#E57CBE url(../../../skin/default/img/guide/s23.png); }
				#cd24 div.title {background:#E69D40 url(../../../skin/default/img/guide/s24.png); }
				#aaa_fbg div.bodycontent {
						border:1px solid #ccc;border-top:0px;height:160px;padding:25px 21px;overflow:hidden;
						box-sizing: border-box; font-size:12px;
						line-height:17px; font-family:微软雅黑; color:#222;
						padding-bottom:0px;
						*height:135px;
				}
				div.bsplit {height:10px;overflow:hidden;}
				#aaa_fbg div.line1 div.bodycontent {padding-top:35px;}
                #editbody{min-width:1000px;}
                body,html{overflow-x: visible;}
			");
			Bill.UI.MaxSpan = 1;
			Bill.UI.ColsWidth = "1,5";
			Bill.BaseCroup.Ui.TitleBarVisible = false;
			Bill.BaseCroup.Fields.AddHtml("", "aaa").FormatHTML
				= @"<div style='font-weight:bold;text-align:center;line-height:17px;font-size:16px;  font-family:微软雅黑;padding-top:34px'>系统参数说明</div>
				<div style='text-align:center;line-height:15px;font-size:14px;padding-top:17px;font-family:微软雅黑'>为满足系统使用的流畅性、合理性、可持续性，请针对需要的栏目进行参数设置，方便快速启用系统</div>
				<div  style='padding-top:56px'>
				<div style='max-width:1300px;width:100%;margin:0 auto;overfow:hidden'>
					<div class='line1'>
						<div class='carditem' id='cd11'>
							<div class='title' >字段自定义</div>
							<div class='bodycontent' >
									自行设置各栏目个性化字段，满足企业字段多元化要求，方便用户根据需要增加字段。
									<div class='bsplit'>&nbsp;</div>
									如：客户字段自定义、合同字段自定义等。
							 </div>
						</div>
						<div class='carditem' id='cd12'>
							<div class='title' >编号自定义</div>
							<div class='bodycontent' >
									编号智能设置，方便编号规则统一生成并减少手动输入编号的麻烦。
									<div class='bsplit'>&nbsp;</div>
									如：合同编号自定义、采购编号自定义等。
							</div>
						</div>
						<div class='carditem' id='cd13'>
							<div class='title' >明细自定义</div>
							<div class='bodycontent' >
									产品明细自定义设置，方便根据需要设定明细中的显示内容、显示名称、显示顺序。
									<div class='bsplit'>&nbsp;</div>
									如：合同明细自定义、报价明细自定义等。
							</div>
						</div>
						<div class='carditem' id='cd14'>
							<div class='title' >参数自定义</div>
							<div class='bodycontent' >
									自定义基本参数满足各栏目使用的灵活性，支持按照需要设置各项参数。
									<div class='bsplit'>&nbsp;</div>
									如：客户行业、客户区域、合同分类、产品分类等。
							</div>
						</div>						
					</div>
					<div class='line2'>
						<div class='carditem' id='cd21'>
							<div class='title' >审批流程自定义</div>
							<div class='bodycontent' >
									自定义各栏目审批流程，满足多级审批、按金额审批、单审、会审、选审等多种审批需求，方便用户严格把控审批流程，保证单据的有效性。
									<div class='bsplit'>&nbsp;</div>
									如：合同审批流程设置、采购审批流程设置等。
							</div>
						</div>
						<div class='carditem' id='cd22'>
							<div class='title' >业务流程自定义</div>
							<div class='bodycontent' >
									自定义业务流程，满足不同业务场景特殊流程的需求，有效提高工作效率。
									<div class='bsplit'>&nbsp;</div>
									如：合同流程策略：添加合同时完成出库、添加合同时完成发货、出库不需要确认、发货不需要确认等。
							</div>
						</div>
						<div class='carditem' id='cd23'>
							<div class='title' >业务策略自定义</div>
							<div class='bodycontent' >
									自定义业务策略，方便统一规则，提高不同业务模式下严谨、流畅的自动化管理效率。
									<div class='bsplit'>&nbsp;</div>
									如：客户策略、产品策略
							</div>
						</div>
						<div class='carditem' id='cd24'>
							<div class='title' >打印模板自定义</div>
							<div class='bodycontent' >
									自定义打印模板支持复制对应的参数到Word中，并设计个性化的打印样式，满足用户不同打印内容、不同打印样式等需求。
									<div class='bsplit'>&nbsp;</div>
									如：合同最新版打印、报价最新版打印等。
							</div>
						</div>
					</div>
				</div>
				</div>";
		}

	}
}