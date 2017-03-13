<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.master" AutoEventWireup="true" CodeFile="Portfolio.aspx.cs" Inherits="Portfolio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
    <title>Portfolio</title>
    <link rel="stylesheet" href="Styles/Portfolio.css" />
    <script src="Scripts/Gallery.js"></script>
    <script>
       
        $(document).ready(function () {
            $('#Gallery').css('height', parseInt($(window).outerHeight()) + 'px');
            $('.mainWindow').css({ 'position': 'relative', 'height': '90%' });
            $(window).scrollTop(190);
            $('.currentImg').load(function () {
                $('#loader').hide();
                $(this).show();
            });
            
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div id="Gallery">
        <div class="categories">
            <ul>

            </ul>
        </div>
        <div class="thumbWindow">
            
            <div class="reel">

            </div>
            
        </div>
        <div class="mainWindow">
            <div class="navLeft"></div>
            <div class="image">
                <div id="loader"><img src="Images/SiteImages/ajax-loader.gif" alt="loading" title="Loading..." /></div>
                <img src="" alt="" class="currentImg"/>
                <div class="caption"></div>
            </div>
            <div class="navRight"></div>
        </div>
    </div>
</asp:Content>

