using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Dashboard : System.Web.UI.Page
{
    string fileURL;
    string fileDestination;
    string thumbDestination;
    string newDir;
    NodeFormatter nf = new NodeFormatter();


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            
            //Label1.Text = "Welcome, " + Session["Username"].ToString();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "hideDivs", "hideDivs();", true);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "hideContainer", "hideContainer();", true);
            //Load data for jsTree
            nf.GetFormattedHTML();

            //populate list of destination folders
            ddlDestinations.Items.Clear();
            DirectoryInfo dirs = new DirectoryInfo(Server.MapPath(@"~\Images\Portfolio"));
            ddlDestinations.Items.Add("Choose a Destination");
            foreach (DirectoryInfo d in dirs.GetDirectories())
            {
                ddlDestinations.Items.Add(d.Name);
            }
            ddlDestinations.Items.Add("[Create New...]");
        }
        else
        {
            //Refresh jsTree data
            nf.GetFormattedHTML();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshTree", "refreshTree();", true);
        }
        
    }
     
    
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (ddlDestinations.SelectedValue == "Choose a Destination")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showError", "showError();", true);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "hideDivs", "hideDivs();", true);
            return;
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "hideError", "hideError();", true);
            Boolean fileOk = false;
            String path = Server.MapPath(@"~/Images/Portfolio/" + ddlDestinations.SelectedValue + @"/");
            if (FUP1.HasFile)
            {
                String fileExt = System.IO.Path.GetExtension(FUP1.FileName).ToLower();
                String[] allowed = { ".jpg" };
                for (int i = 0; i < allowed.Length; i++)
                {
                    if (fileExt == allowed[i])
                        fileOk = true;
                    else
                        fileOk = false;
                }
                if (fileOk)
                {
                    fileURL = @"Images/Portfolio/"+ ddlDestinations.SelectedValue + @"/" + FUP1.FileName;
                    try
                    {
                        FUP1.PostedFile.SaveAs(path + FUP1.FileName);
                    }
                    catch (Exception ex)
                    {
                        Response.Write(ex.Message);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "NoGo", "alert('Files of this type are not allowed.');", true);
                }
            }
            if (fileURL != null && !fileURL.Equals(""))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "setImage", "setImg('" + fileURL + "');", true);
                nf.GetFormattedHTML();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshTree", "refreshTree();", true);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showDiv3", "showDiv3();", true);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showContainer", "showContainer();", true);
            }
        }
    }

    protected void ddlDestinations_SelectedIndexChanged(object sender, EventArgs e)
    {
        //set the main file destination
        if (ddlDestinations.SelectedValue != "[Create New...]")
        {
            fileDestination = @"~/Images/Portfolio/" + ddlDestinations.SelectedValue;
            thumbDestination = @"~/Images/Portfolio" + ddlDestinations.SelectedValue + @"/Thumbs";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showDiv", "showDiv2();", true);
        }
        else if (ddlDestinations.SelectedIndex.Equals("Choose a Destination"))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "hideDivs", "hideDivs();", true);
        }
        else
        {
            txtNewDir.Visible = true;
            btnAdd.Visible = true;
        }

        if (Session["FUP1"] != null)
        {
            FUP1 = (FileUpload)Session["FUP1"];
        }
    }
    protected void btnAdd_Click(object sender, ImageClickEventArgs e)
    {
        newDir = txtNewDir.Text;
        ddlDestinations.Items.Insert(ddlDestinations.Items.Count - 1, newDir);
        ddlDestinations.SelectedValue = newDir;
        NewDirectory(newDir);
        txtNewDir.Visible = false;
        btnAdd.Visible = false;
        //Refresh jsTree data
        nf.GetFormattedHTML();
        ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshTree", "refreshTree();", true);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "showDiv", "showDiv('Step2');", true);

    }

    protected void NewDirectory(string path)
    {
        DirectoryInfo dir = new DirectoryInfo(Server.MapPath(@"~/Images/Portfolio/") + path);
        DirectoryInfo dir2 = new DirectoryInfo(Server.MapPath(@"~/Images/Portfolio/") + path + @"/Thumbs/");
        try
        {
            dir.Create();
            dir2.Create();

        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }
        finally
        {
            fileDestination = @"~/Images/Portfolio/" + ddlDestinations.SelectedValue;
            thumbDestination = @"~/Images/Portfolio" + ddlDestinations.SelectedValue + @"/Thumbs";
        }
    }

}