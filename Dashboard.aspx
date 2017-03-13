<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Administrator Dashboard</title>
 
    
    <script src="Scripts/jquery-2.1.4.min.js"></script>
    <script src="Scripts/jquery-ui-1.11.4.min.js"></script>
    <script src="Scripts/jquery.easing.1.3.js"></script>
    <script src="Scripts/tooltip.min.js"></script>
    <script src="Scripts/jstree.min.js"></script>
    <link rel="stylesheet" href="Styles/Dashboard.css" />
    <link rel="stylesheet" href="Styles/style.min.css" />

    <link rel="stylesheet" href="Styles/cropper.css" />
    <script src="Scripts/cropper.min.js"></script>
    <script>
        $(document).ready(function () {
            //configure the file tree
            $('#treeView').jstree({
                'core': {
                    'multiple': false,
                    'check_callback': true,
                    'data': {
                        'url': 'Temp/ajax.html',
                        'data': function (node) {
                            return { 'id': node.id };
                        }
                    }
                },
                'plugins': ["contextmenu"],
                'contextmenu':{
                    'items': customMenu
                }
            }).on('hover_node.jstree', function (e, data) {
                var $node = $("#" + data.node.id);
                var url = $node.find('a').attr('href');
                if (url != '#') {
                    //get the mouse position
                    var x = $node.position().left;
                    var y = $node.position().top;
                    $('.tooltip').css({ 'top': y + 'px', 'left': x + 'px' });
                    $('.tooltip').find('img').attr('src', url);
                    $('.tooltip').fadeIn(300, 'easeOutSine');
                }
            }).on('dehover_node.jstree', function () {
                $('.tooltip').hide();
            }).on('delete_node.jstree', function(e, data){
                //var $node = $('#' + data.node.id);
                //alert($//node.text());
                
            });

            
            function customMenu(node) {
                //debugger
                //Show a different label for renaming files and folders
                var tree = $('#treeView').jstree(true);
                var ID = $(node).attr('id');
                if (ID == "j1_1") {
                    return items = {}; 
                }
                var $mynode = $('#' + ID);
                var renameLabel;
                var deleteLabel;
                var folder = false;
                if ($mynode.hasClass("jstree-closed") || $mynode.hasClass("jstree-open")) { //If node is a folder
                    renameLabel = "Rename Folder";
                    deleteLabel = "Delete Folder";
                    folder = true;
                }
                else {
                    renameLabel = "Rename File";
                    deleteLabel = "Delete File";
                }
                var items = {
                    "rename" : {
                        "label" : renameLabel,   //Different label (defined above) will be shown depending on node type
                        "action": function (obj) {
                        }
                    },
                    "delete" : {
                        "label" : deleteLabel,
                        "action": function (obj) {
                            tree.delete_node($mynode);
                        }
                    }
                };

                return items;
            }


            $('#saveThumb').click(function (e) {
                //process thumbnail canvas data and upload to server
                //at specified destination folder
                e.preventDefault();
                var dataURL = $('.container > img').cropper('getCroppedCanvas', { width: 100, height: 75 }).toDataURL('image/jpeg', 1.0);
                dataURL = dataURL.replace('data:image/jpeg;base64,', '');
                var fullPath = $('.container').find('img').attr('src');
                var filename = fullPath.replace(/^.*[\\\/]/, '');
                filename = filename.slice(0, -4);
                filename += "_thumb.jpg";
                fullPath = fullPath.substring(0, fullPath.lastIndexOf("/")) + '/';
                alert(fullPath);
                
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/UploadImage',
                    data: '{"imageData" : "' + dataURL + '", "path" : "' + fullPath + '", "fileName" : "' + filename + '"}',
                    contentType: 'application/json; charset=utf=8',
                    dataType: 'json',
                    success: function (msg) {
                        alert("Your image has been uploaded successfully!");
                    }
                }).done(function (response) {
                    //refresh the JsTree and hide other steps
                    $('#treeView').jstree('refresh');
                    $('#Step2').hide();
                    $('#Step3').hide();
                    $('#Step4').hide();
                    $('.container').hide();
                });

                $('#treeView').jstree('refresh');
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="SM1" runat="server" />
        <script>
            
        </script>
    <div id="Header">
        <div class="welcome">
            <asp:Label ID="Label1" CssClass="label" runat="server" Text="Welcome, " />
            <asp:LinkButton ID="lnkLogout" CssClass="link" runat="server" Text="Logout" />
        </div>
    </div>
    <div id="treeView"></div>
    <div class="tooltip">
        <img src="" alt="" />        
    </div>
    <asp:UpdatePanel ID="UP1" runat="server">
        <Triggers>
            <asp:PostBackTrigger ControlID="btnUpload" />
            <asp:PostBackTrigger ControlID="ddlDestinations" />
        </Triggers>
        <ContentTemplate>
            <div id="Controls">
                <div id="ImageUpload">
                    <div class="selectFile">
                        <div id="Step1">
                            <img src="Images/SiteImages/step1.png" alt="step 1" />
                            <asp:Label ID="Label3" runat="server" CssClass="label" Text="Choose File Destination: " />
                            <asp:DropDownList ID="ddlDestinations" ClientIDMode="Static" CssClass="dropdown" runat="server" AutoPostBack="true" EnableViewState="true" OnSelectedIndexChanged="ddlDestinations_SelectedIndexChanged" />  
                            <asp:TextBox ID="txtNewDir" CssClass="newFolder" runat="server" Visible="false"/>
                            <asp:ImageButton runat="server" ID="btnAdd" Visible="false" ImageUrl="~/Images/SiteImages/check-mark-tiny.png" OnClick="btnAdd_Click" />
                            <br />
                        </div>
                        <div id="Step2">
                            <img src="Images/SiteImages/step2.png" alt ="step 2" />
                            <asp:Label ID="LabelA" runat="server" CssClass="label" Text="Select File to Upload" />
                            <asp:FileUpload ID="FUP1" AllowMultiple="false" CssClass="margin" EnableViewState="true" runat="server" />
                            <asp:Button ID="btnUpload" Text="Open" CssClass="floatright" runat="server" OnClick="btnUpload_Click" /><br /><br />
                        </div>
                        <div id="Step3">
                            <img src="Images/SiteImages/step3.png" alt="step 3" />
                            <asp:Label ID="Label5" runat="server" CssClass="label" Text="Set your thumbnail image!" />
                            <a id="saveThumb" href="#"><img src="Images/SiteImages/upload.png" alt="upload"/></a>
                        </div>
                        <div id="Step4">
                            <asp:Label ID="Label6" Text="Finish!" runat="server" CssClass="label" />
                        </div>
                    </div>
                    <div class="container">
                        <asp:Label Id="Label4" Text="Set Thumbnail for new image (scroll to zoom):" CssClass="label" runat="server" />
                        <img class="preview" src="" alt="" />
                        <div class="img-preview"></div>
                    </div>
                    
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <script type="text/javascript">
        function setImg(url) {
            //set the container image and load cropper
            $('.preview').attr('src', url);
            $('.container').fadeIn().css('display', 'block');
            $('.container > img').cropper({
                //options
                guides: true,
                center: true,
                highlight: true,
                background: true,
                movable: true,
                responsive: true,
                zoomable: true,
                dragCrop: false,
                cropBoxMovable: false,
                cropBoxResizable: false,
                aspectRatio: 4 / 3,
                preview: '.img-preview',
                crop: function () {
                }
            });
        }

        function hideContainer() {
            $('.container').hide();
        }
        function showContainer() {
            $('.container').show();
        }
        function showUploadDetails() {
            $('#UploadInfo').css('display', 'block');
        }
        function showError() {
            $('#ddlDestinations').css('border', '1px solid red');
        }
        function hideError() {
            $('#ddlDestinations').css('border', '1px solid #808080');
        }

        function refreshTree() {
            $('#treeView').jstree(true).refresh();
        }
        function hideDivs() {
            $('.container').hide();
            $('#Step2').css('display', 'none');
            $('#Step3').css('display', 'none');
            $('#Step4').css('display', 'none');
        }
        function showDiv2() {
            $('#Step2').slideDown();
            $('.container').hide();
            $('#Step3').css('display', 'none');
            $('#Step4').css('display', 'none');
        }

        function showDiv3() {
            $('#Step3').slideDown();
            $('.container').hide();
            $('#Step4').css('display', 'none');
        }
    </script>
</form>
</body>
</html>
