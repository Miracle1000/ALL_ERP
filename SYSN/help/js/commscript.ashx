 <%@WebHandler Language="C#"  Class="ZBServices.view.SYSN.view.help.js.commscript" %>
using ZBServices.ui;
namespace ZBServices.view.SYSN.view.help.js
{
    public class commscript : SesseionPage
    {
        public override void OnNoUserLogin() { }

        protected override void Page_Load()
        {
            SetPageType("", SystemPageContentType.JSON);
            if (!UserInfo.IsSupperAdmin)
            {
                Response.Write(@" document.write('<style>#syset{display:none}</style>'); ");
            }
            Response.End();
        }
    }
}