using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Dashboard2 : System.Web.UI.Page
{
    NodeFormatter nf = new NodeFormatter();
    protected void Page_Load(object sender, EventArgs e)
    {
        nf.GetFormattedHTML();
        if (!Page.IsPostBack)
        {
            ddlCats.Items.Clear();
            DirectoryInfo dirs = new DirectoryInfo(Server.MapPath(@"~\Images\Portfolio"));
            foreach (DirectoryInfo d in dirs.GetDirectories())
            {
                ddlCats.Items.Add(d.Name);
            }
        }
    }

}