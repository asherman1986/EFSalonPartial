using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

/// <summary>
/// Retrieves directory info and returns the 
/// file/folder structure as an HTML unordered list
/// </summary>
public class NodeFormatter
{
    private DirectoryInfo rootDir;
    private string dirName;
    private string html;

    public string DirName { get; set; }

	public NodeFormatter()
	{
        rootDir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory + @"Images\Portfolio");
        dirName = rootDir.Name;
        html = @"<ul><li>" + dirName;
	}

    public NodeFormatter(string root)
    {
        dirName = root;
        rootDir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory + root);
        html = @"<ul><li>" + dirName;
    }

    public string GetFormattedHTML(){
        //the parent ul and first list item, the root, is open
        html = @"<ul><li class='root jstree-open'>" + "Portfolio";
        FormatHTML(rootDir, null);
        html += "</ul></li></ul>"; //last thing to do before returning.
        string path = AppDomain.CurrentDomain.BaseDirectory + @"\Temp\";
        StreamWriter file = new StreamWriter(path + "ajax.html");
        file.WriteLine(html);
        file.Close();
        return html;
    }

    
    private void FormatHTML(DirectoryInfo directory, DirectoryInfo rootDir)
    {
        string filesHTML = "";
        bool ULOpen = false;
        if (rootDir == null)
        {
            //this is the parent directory
            //Check to see if it has any files/folders in it. 
            if (directory.GetFiles().Length > 0 || directory.GetDirectories().Length > 0)
            {
                html += "<ul>"; //open a new ul for everything inside the root. 
                ULOpen = true;
            }

            if (directory.GetFiles().Length > 0)
            {
                //if this directory has files in it:
                //iterate through those files and save them for after the directory loop!
                foreach (FileInfo f in directory.GetFiles())
                {
                    //this formatting is fine.
                    string path = directory.Name + @"\" + f.Name;
                    filesHTML += @"<li data-jstree='{""icon"":""Images/SiteImages/JPEGicon.png""}'><a href='"+ f.FullName +"'>" + f.Name + "</a></li>";
                }
            } //set of all the files in the root directory

            //Check if ROOT has any directories
            if (directory.GetDirectories().Length > 0)
            {
                //loop through all directories. BEGIN
                foreach (DirectoryInfo dir in directory.GetDirectories())
                {
                    //each directory is a new list item
                    html += @"<li>" + dir.Name;  //<li>Dir1

                    //pass in the dir as the directory and myself as the root
                    FormatHTML(dir, directory);
                    
                    html += "</li>"; //close the list item.
                }
                //after going through all the directories, we can add the files and close up shop
                //recursion ends here. This is the end of the master loop. 
                html += filesHTML; //end. of. game.
            }
            else //no directories, just files! Let's append the fileHTML and be done. 
            {
                html += filesHTML;
                return;
            }
        }
        else //this is not the root directory. We're gonna need to recurse some more. 
        {
            if (directory.GetFiles().Length > 0 || directory.GetDirectories().Length > 0)
            {
                html += @"<ul>"; //open a new UL for everything inside this directory
                ULOpen = true;
            }

            //Are there any files floating around in this directory?
            if (directory.GetFiles().Length > 0)
            {
                //if this directory has files in it:
                //iterate through those files and save them for after the directory loop!
                foreach (FileInfo f in directory.GetFiles())
                {
                    string parent = "";
                    if(!rootDir.Parent.Name.Equals("Images")){
                        parent = @"Images\";
                    }
                    string path = parent + rootDir.Parent + @"\" + rootDir.Name + @"\" + directory.Name + @"\" + f.Name;
                    
                    filesHTML += @"<li src='" + path + @"' data-jstree='{""icon"":""Images/SiteImages/JPEGicon.png""}'><a href='" + path + "'>" + f.Name + "</a></li>";
                }
            } //now we have the files for this dir all wrapped up.
            //Any directories?
            if (directory.GetDirectories().Length > 0)
            {
                //We gonna loop through all these directories. 
                foreach (DirectoryInfo dir in directory.GetDirectories())
                {
                    //pass in the dir as the directory and myself as the root
                    html += "<li>" + dir.Name; //new List Item for the new dir
                    FormatHTML(dir, directory);
                    html += "</li>"; //close the list item for the dir
                }
            }
                        
            //add the files for this directory after the subdirectories
            if (ULOpen)
            {
                html += filesHTML + "</ul>"; //and close this ul
            }
        } //end else
    } //end FormatHTML method

    
}

