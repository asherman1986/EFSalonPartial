using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using System.IO;
using System.Web.Http;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// Web Service to retrieve images and metadata 
/// of images dynamically, and to perform file and
/// directory operations related to content management
/// </summary>
[WebService(Namespace = "http://www.gemini-tech.net/")]
[ScriptService]
public class Filenames : WebService
{
    NodeFormatter nf = new NodeFormatter();

    public Filenames()
    {
    }

    
    [WebMethod, ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetFiles(string folderName)
    {
        FileObj[] imgs;
        string path = AppDomain.CurrentDomain.BaseDirectory;
        DirectoryInfo dirInfo = new DirectoryInfo(path + @"Images\Portfolio\" + folderName);
        FileInfo[] files = dirInfo.GetFiles();
        imgs = new FileObj[files.Length];
        int i = 0;
        char[] jpg = { '.', 'j', 'p', 'g' };
        char[] jpeg = { '.', 'j', 'p', 'e', 'g' };
        foreach (FileInfo f in files)
        {
            string name = f.Name.ToLower();
            if (f.Name != "CategoryThumb.jpg")
            {
                string tempName = "";
                string href = @"Images\Portfolio\" + folderName;
                href = href.Replace(@"\\", @"\");
                imgs[i] = new FileObj();
                if (name.IndexOf(".jpg") > -1)
                {
                    imgs[i].fileName = name.TrimEnd(jpg);
                    tempName = name.Remove(name.Length - 4);
                }
                else if (name.IndexOf(".jpeg") > -1)
                {
                    imgs[i].fileName = f.Name.TrimEnd(jpeg);
                    tempName = name.Remove(name.Length - 5);
                }
                imgs[i].fileHREF = href + @"\" + f.Name;
                imgs[i].thumbHref = href + @"\Thumbs\" + tempName + @"_thumb.jpg";
                imgs[i].caption = GetCaption(f.Name, folderName);
                i++;
            }
        }

        return new JavaScriptSerializer().Serialize(imgs);
    }
    
    [WebMethod, ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string GetDirectories(string directory)
    {
        string[] dirNames;
        string path = AppDomain.CurrentDomain.BaseDirectory;
        DirectoryInfo[] dirs = new DirectoryInfo(path + @"Images\" + directory).GetDirectories();
        dirNames = new string[dirs.Length];
        int i = 0;
        foreach (DirectoryInfo d in dirs)
        {
            dirNames[i] = d.Name.ToString();
            i++;
        }

        return new JavaScriptSerializer().Serialize(dirNames);
    }

    

    [WebMethod]
    public void UploadImage(string imageData, string path, string fileName)
    {
        string fullPath = Server.MapPath(path);
        using (FileStream fs = new FileStream(fullPath, FileMode.Create))
        {
            using (BinaryWriter bw = new BinaryWriter(fs))
            {
                byte[] data = Convert.FromBase64String(imageData);
                bw.Write(data);
                bw.Close();
            }
        }

        nf.GetFormattedHTML();
    }
    [WebMethod]
    public void MoveImage(string src, string dest)
    {
        string a = Server.MapPath(src);
        string b = Server.MapPath(dest);
        try
        {
            if (System.IO.File.Exists(b))
            {
                System.IO.File.Delete(b);
            }
            System.IO.File.Move(a, b);
            System.IO.File.Delete(a);
        }
        catch (Exception e)
        {
            Console.Write(e.Message);
        }
    }
    [WebMethod, HttpPost]
    public void UploadFile()
    {
        string path = "";
        if (HttpContext.Current.Request.Files.AllKeys.Any())
        {
            var httpPostedFile = HttpContext.Current.Request.Files["UploadedImage"];
            if (httpPostedFile != null)
            {
                path = @"Temp/" + httpPostedFile.FileName;
                var fileSavePath = Path.Combine(HttpContext.Current.Server.MapPath("~/Temp"), httpPostedFile.FileName);
                httpPostedFile.SaveAs(fileSavePath);
            }
        }

    }
    [WebMethod]
    public void RenameDirectory(string oldPath, string newPath)
    {
        string src = Server.MapPath(oldPath);
        string dest = Server.MapPath(newPath);
        try
        {
            Directory.Move(src, dest);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
        finally
        {
            nf.GetFormattedHTML();
        }
    }

    [WebMethod]
    public void CreateDirectory(string path)
    {
        string newDir = Server.MapPath(@path);
        string newThumbDir = Server.MapPath(@path + "/Thumbs/");
        try
        {
            Directory.CreateDirectory(newDir);
            Directory.CreateDirectory(newThumbDir);
        }
        catch (Exception e)
        {
            Console.Write(e.Message);
        }
        finally
        {
            nf.GetFormattedHTML();
        }
    }

    [WebMethod]
    public void DeleteDirectory(string path)
    {
        string dir = Server.MapPath(path);
        DirectoryInfo dirInfo = new DirectoryInfo(dir);
        if (dirInfo.GetFiles().Length > 0 || dirInfo.GetDirectories().Length > 0)
        {
            foreach (DirectoryInfo d in dirInfo.GetDirectories())
            {
                DeleteContents(d);
                d.Delete();
            }
            foreach (FileInfo f in dirInfo.GetFiles())
            {
                f.Delete();
            }
        }
        try
        {

            Directory.Delete(dir);
        }
        catch (Exception e)
        {
            Console.Write(e.Message);
        }
        finally
        {
            nf.GetFormattedHTML();
        }
    }

    [WebMethod]
    public void DeleteFile(string path, string thumbPath)
    {
        string file = Server.MapPath(path);
        string thumb = Server.MapPath(thumbPath);
        try
        {
            System.IO.File.Delete(file);
            System.IO.File.Delete(thumb);
        }
        catch (Exception e)
        {
            Console.Write(e.Message);
        }
        finally
        {
            nf.GetFormattedHTML();
        }
    }

    private void DeleteContents(DirectoryInfo dir)
    {
        foreach(FileInfo f in dir.GetFiles()){
            f.Delete();
        }
    }

    private string GetCaption(string filename, string category)
    {
        string cap = "";
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            //Create command and set up its parameters
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandText = "GetCaption"; // this sp concatenates and returns a scalar string value for the image's caption data. 
            cmd.CommandType = CommandType.StoredProcedure;
            
            cmd.Parameters.Add(new SqlParameter("@Filename", SqlDbType.NVarChar, 50));
            cmd.Parameters["@Filename"].Direction = ParameterDirection.Input;
            cmd.Parameters["@Filename"].Value = filename;

            cmd.Parameters.Add(new SqlParameter("@Category", SqlDbType.NVarChar, 50));
            cmd.Parameters["@Category"].Direction = ParameterDirection.Input;
            cmd.Parameters["@Category"].Value = category;

            cmd.Parameters.Add(new SqlParameter("@Caption", SqlDbType.NVarChar, -1));
            cmd.Parameters["@Caption"].Direction = ParameterDirection.Output;


            cmd.Connection.Open();
            cmd.ExecuteNonQuery();

            cap = cmd.Parameters["@Caption"].Value.ToString();
        }


        return cap;
    }

    [WebMethod]
    public void SetCaption(string Category, string imgFileName, string Photog, string HS, string MUA, string stylist, string Pub, string Desc)
    {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            conn.Open();
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "SetCaption";
            cmd.Parameters.AddWithValue("@Category", Category);
            cmd.Parameters.AddWithValue("@imgFileName", imgFileName);
            cmd.Parameters.AddWithValue("@Photographer", Photog);
            cmd.Parameters.AddWithValue("@HairStylist", HS);
            cmd.Parameters.AddWithValue("@MakeUpArtist", MUA);
            cmd.Parameters.AddWithValue("@Stylist", stylist);
            cmd.Parameters.AddWithValue("@Publication", Pub);
            cmd.Parameters.AddWithValue("@Descript", Desc);

            cmd.ExecuteNonQuery();
            conn.Close();
            cmd.Dispose();
        }
    }

}