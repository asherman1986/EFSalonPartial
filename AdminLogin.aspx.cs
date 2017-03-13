using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data;

public partial class AdminLogin : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnLogin_Click(Object sender, EventArgs e)
    {
        VerifyCredentials();
    }

    protected void VerifyCredentials()
    {
        bool success = false;
        string uName = this.txtUsername.Text;
        string pWord = this.txtPassword.Text;

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            //Create command and set up its parameters
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandText = "VerifyCreds";
            cmd.CommandType = CommandType.StoredProcedure;

            //Add input parameters and set their properties
            cmd.Parameters.Add(new SqlParameter("@UserName", SqlDbType.NVarChar, 15));
            cmd.Parameters["@UserName"].Value = uName;
            cmd.Parameters["@UserName"].Direction = ParameterDirection.Input;

            cmd.Parameters.Add(new SqlParameter("@Pass", SqlDbType.NVarChar, 30));
            cmd.Parameters["@Pass"].Value = pWord;
            cmd.Parameters["@Pass"].Direction = ParameterDirection.Input;

            cmd.Parameters.Add(new SqlParameter("@Msg", SqlDbType.NVarChar, -1));
            cmd.Parameters["@Msg"].Direction = ParameterDirection.Output;
            
            cmd.Parameters.Add(new SqlParameter("@Success", SqlDbType.Bit));
            cmd.Parameters["@Success"].Direction = ParameterDirection.Output;

            cmd.Connection.Open();
            cmd.ExecuteNonQuery();

            success = (Boolean)cmd.Parameters["@Success"].Value;
            if (success)
            {
                if (lblMessage.Visible)
                    lblMessage.Visible = false;

                //Update Users table to indicate user is logged in


                //Update Session state variables UserID
                Session["UserID"] = getUserID(uName);
                Session["Username"] = uName;
                lblMessage.Visible = true;
                lblMessage.Text = Session["UserID"].ToString();
                Response.Redirect("Dashboard2.aspx");
            }
            else
            {
                this.lblMessage.Visible = true;
                this.lblMessage.Text = cmd.Parameters["@Msg"].Value.ToString();
            }
        }

    }

    protected int getUserID(string username)
    {
        bool success;
        int uID;
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            //Create command and set up its parameters
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandText = "getUserID";
            cmd.CommandType = CommandType.StoredProcedure;

            //Add input parameters and set their properties
            cmd.Parameters.Add(new SqlParameter("@UserName", SqlDbType.NVarChar, 15));
            cmd.Parameters["@UserName"].Value = username;
            cmd.Parameters["@UserName"].Direction = ParameterDirection.Input;

            cmd.Parameters.Add(new SqlParameter("@UserID", SqlDbType.Int));
            cmd.Parameters["@UserID"].Direction = ParameterDirection.Output;

            cmd.Parameters.Add(new SqlParameter("@Success", SqlDbType.Bit));
            cmd.Parameters["@Success"].Direction = ParameterDirection.Output;

            cmd.Connection.Open();
            cmd.ExecuteNonQuery();

            success = (Boolean)cmd.Parameters["@Success"].Value;
            if (success)
            {
                uID = Convert.ToInt32(cmd.Parameters["@UserID"].Value);
            }
            else
            {
                uID = -1;
            }
            return uID;
        }
    }
    protected void lnkForgot_Click(Object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPanel", "showPanel()", true);
    }
    protected void btnGo_Click(Object sender, EventArgs e)
    {
        string uName = this.txtRecUname.Text;

        //First we need to obtain the security question for that user.
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandText = "GetSecurityQ";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection.Open();

            cmd.Parameters.Add(new SqlParameter("@Username", SqlDbType.NVarChar, 15));
            cmd.Parameters["@Username"].Value = uName;
            cmd.Parameters.Add(new SqlParameter("@Question", SqlDbType.NVarChar, 100));
            cmd.Parameters["@Question"].Direction = ParameterDirection.Output;
            cmd.Parameters.Add(new SqlParameter("@Success", SqlDbType.Bit));
            cmd.Parameters["@Success"].Direction = ParameterDirection.Output;

            cmd.ExecuteNonQuery();
            bool success = Convert.ToBoolean(cmd.Parameters["@Success"].Value);
            if (success)
            {
                this.lblMessage.Visible = false;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPanel", "$('#Reset').css('display', 'block');", true);
                this.Question.Visible = true;
                this.Question.Text = cmd.Parameters["@Question"].Value.ToString();
                this.txtAnswer.Visible = true;
                this.lnkVerify.Visible = true;
            }
            else
            {
                this.Question.Text = cmd.Parameters["@Question"].Value.ToString();
            }
        }
    }

    protected void lnkVerify_Click(Object sender, EventArgs e)
    {
        this.lnkVerify.Visible = false;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPanel", "$('#Reset').css('display', 'block');", true);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "HideIcons", "$('.fail').css('display', 'none');", true);
        //so now we need to verify the answer
        string answer = this.txtAnswer.Text;
        int userID = getUserID(this.txtRecUname.Text);
        bool success;
        string response;

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["Salon"].ToString()))
        {
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;
            cmd.CommandText = "VerifyAnswer";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Connection.Open();

            cmd.Parameters.Add(new SqlParameter("@UserID", SqlDbType.Int));
            cmd.Parameters["@UserID"].Value = userID;
            cmd.Parameters.Add(new SqlParameter("@Answer", SqlDbType.NVarChar, 100));
            cmd.Parameters["@Answer"].Value = answer;
            cmd.Parameters.Add(new SqlParameter("@Success", SqlDbType.Bit));
            cmd.Parameters["@Success"].Direction = ParameterDirection.Output;
            cmd.Parameters.Add(new SqlParameter("@Msg", SqlDbType.NVarChar, 50));
            cmd.Parameters["@Msg"].Direction = ParameterDirection.Output;

            cmd.ExecuteNonQuery();
            success = Convert.ToBoolean(cmd.Parameters["@Success"].Value);
            response = cmd.Parameters["@Msg"].Value.ToString();
            if (success)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "successLoad", "setLoaderSuccess()", true);
                System.Threading.Thread.Sleep(3000); 
                Response.Redirect("Dashboard2.aspx");
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "failLoader", "setLoaderFailure()", true);
                this.lnkVerify.Visible = true;
            }
        }
    }

    protected void UpdatePassword()
    {
        
    }
}