<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AdminLogin.aspx.cs" Inherits="AdminLogin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Essentially Flawless Administrator Login</title>
    <link rel="stylesheet" href="Styles/Login.css" />
    <script src="Scripts/jquery-2.1.4.js"></script>
    <script src="Scripts/jquery-2.1.4.min.js"></script>
    <script src="Scripts/navigation.js"></script>
    <script src="Scripts/jquery.easing.1.3.js"></script>
    <script>
        $(document).ready(function () {
            $('#Top').css('height', ($(window).outerHeight()) + 'px');

            
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnableViewState="true" runat="server" />
        <script type="text/javascript">
            function showPanel() {
                $('#Reset').slideDown().css('display', 'block');
            }
            
            function setLoaderSuccess() {
                $('.success').css('display', 'inline-block');
            }
            function setLoaderFailure() {
                $('.fail').css({ 'display': 'inline-block'});
            }
        </script>
    <div id="Top">
        
        <img class="logo" src="Images/SiteImages/logo_cool.png" />
        <span class="title">Administrator Login</span>
        
        <asp:UpdatePanel ID="up1" runat="server">
            <Triggers></Triggers>
            <ContentTemplate>
                <div id="Login">
                    <asp:Label ID="Label1" Text="Username" CssClass="label" runat="server" AssociatedControlID="txtUserName" />
                    <asp:TextBox ID="txtUsername" runat="server" /><br />
                    <asp:Label ID="Label2" Text="Password" CssClass="label" runat="server" AssociatedControlID="txtPassword" />
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" /><br />
                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="button" OnClick="btnLogin_Click" />
                    <asp:LinkButton ID="lnkForgot" runat="server" Text="Forgot Password" OnClick="lnkForgot_Click" CssClass="linkButton" />
                </div>  
                <asp:Label ID="lblMessage" CssClass="error" Visible="false" runat="server" />
                <div id="Reset">
                    <asp:Label ID="Label3" Text="Username" CssClass="label" runat="server" AssociatedControlID="txtRecUname" />
                    <asp:TextBox ID="txtRecUname" CssClass="input" runat="server" /><asp:Button ID="btnGo" OnClick="btnGo_Click" runat="server" Text="Go" />
                    <br />
                    <asp:Label ID="Question" CssClass="label2" runat="server"/><br />
                    <asp:TextBox ID="txtQResponse" TextMode="Password" runat="server" EnableViewState="false" Visible="false" /><asp:TextBox ID="txtAnswer" CssClass="input2" Visible="false" Width="150" runat="server" />
                    <img class="fail" src="Images/SiteImages/x-mark-tiny.png" style="display:none;" />
                    <asp:LinkButton ID="lnkVerify" Visible="false" EnableViewState="false" CssClass="linkButton2" OnClick="lnkVerify_Click" Text="Verify" runat="server" />
                    <div class="progress">
                        <asp:UpdateProgress ID="upr1" runat="server" AssociatedUpdatePanelID="up1">
                            <ProgressTemplate>
                                <img src="Images/SiteImages/ajax-loader.gif"/>
                            </ProgressTemplate>
                        </asp:UpdateProgress>
                    </div>
                    
                    
                    <br />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
