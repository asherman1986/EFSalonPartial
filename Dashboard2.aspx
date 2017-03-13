<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Dashboard2.aspx.cs" Inherits="Dashboard2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard Take 2</title>
    <script src="Scripts/jquery-2.1.4.min.js"></script>
    <script src="Scripts/jquery-ui-1.11.4.min.js"></script>
    <script src="Scripts/jquery.easing.1.3.js"></script>
    <script src="Scripts/tooltip.min.js"></script>
    <script src="Scripts/jstree.min.js"></script>
    <link rel="stylesheet" href="Styles/Dashboard2.css" />
    <link rel="stylesheet" href="Styles/style.min.css" />

    <link rel="stylesheet" href="Styles/cropper.css" />
    <script src="Scripts/cropper.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            var filename;
            $('#Main').css('height', $(window).innerHeight() - 60 + 'px');

            //configure jstree
            $('#tree').jstree({
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
                'contextmenu': {
                    'items': customMenu
                }
            }).on('hover_node.jstree', function (e, data) {
                var $node = $("#" + data.node.id);
                var url = $node.find('a').attr('href');

                if (url != '#') {
                    //get the mouse position
                    var x = $node.position().left + 150;
                    var y = $node.position().top;
                    $('.tooltip').css({ 'top': y + 'px', 'left': x + 'px' });
                    $('.tooltip').find('img').attr('src', url);
                    $('.tooltip').fadeIn(300, 'easeOutSine');
                }
            }).on('dehover_node.jstree', function () {
                $('.tooltip').hide();
            }).on('delete_node.jstree', function (e, data) {
                var $node = $('#' + data.node.id);
                var $parent = $('#' + data.parent);
                var parentFolder = $parent.find('a').first().text();
                var nodeText = $node.text().toLowerCase();
                debugger
                if (nodeText.indexOf(".jpg") > -1 || nodeText.indexOf(".jpeg") > -1) {

                    var path = "Images/Portfolio/" + parentFolder + "/" + nodeText;
                    if (nodeText.indexOf('.jpg') > -1) {
                        filename = nodeText.slice(0, -4);
                    }
                    else {
                        filename = nodeText.slice(0, -5);
                    }
                    filename += "_thumb.jpg";
                    var thumbPath = "Images/Portfolio/" + parentFolder + "/Thumbs/" + filename;
                    $.ajax({
                        type: 'POST',
                        url: 'WebService.asmx/DeleteFile',
                        data: '{"path" : "' + path + '", "thumbPath" : "' + thumbPath + '"}',
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function (msg) {
                        }
                    }).done(function (response) {
                        location.reload();
                    }).fail(function (response) {
                        alert(response.responseText);
                    });
                }
                else {
                    nodeText = $node.find('a').first().text();
                    var path = "Images/Portfolio/" + nodeText;
                    $.ajax({
                        type: 'POST',
                        url: 'WebService.asmx/DeleteDirectory',
                        data: '{"path" : "' + path + '"}',
                        contentType: 'application/json; charset=utf=8',
                        dataType: 'json',
                        success: function (msg) {
                        }
                    }).done(function (response) {
                        $('#tree').jstree(true).refresh();
                        location.reload(true);
                    });
                }

            }).on('create_node.jstree', function (e, data) {
                var id = data.node.id;
                var path = "Images/Portfolio/" + $('#' + data.node.id).text();
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/CreateDirectory',
                    data: '{"path" : "' + path + '"}',
                    contentType: 'application/json; charset=utf=8',
                    dataType: 'json',
                    success: function (msg) {

                    }
                }).done(function (response) {
                    //$('#tree').jstree(true).refresh();
                });
            }).on('rename_node.jstree', function (e, data) {
                $('.tooltip').hide();
                var oldPath = "Images/Portfolio/" + data.old;
                var newPath = "Images/Portfolio/" + data.text;
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/RenameDirectory',
                    data: '{"oldPath" : "' + oldPath + '", "newPath" : "' + newPath + '"}',
                    contentType: 'application/json; charset=utf=8',
                    dataType: 'json',
                    success: function (msg) {
                    }
                }).done(function (response) {
                    $('#tree').jstree(true).refresh();
                    location.reload(true);
                });
            });


            function customMenu(node) {
                var tree = $('#tree').jstree(true);
                var ID = $(node).attr('id');
                if (ID == "j1_1") {
                    return items = {
                        "create": {
                            "label": "New Category",
                            "action": function (obj) {
                                //debugger
                                $node = tree.create_node(node);
                                tree.edit($node);
                            }
                        }
                    };
                }
                else if (node.text == "Thumbs") {
                    return items = {};
                }
                else if (node.text.indexOf("_thumb.jpg") > -1) {
                    return items = {};
                }
                else if (node.text.indexOf(".jpg") > -1 || node.text.indexOf(".jpeg") > -1) {
                    return items = {
                        "delete": {
                            "label": "Delete",
                            "action": function (obj) {
                                tree.delete_node([node]);
                            }
                        }
                    }
                }
                var $mynode = $('#' + ID);
                var folder = false;
                if ($mynode.hasClass("jstree-closed") || $mynode.hasClass("jstree-open")) { //If node is a folder
                    folder = true;
                }
                var items = {
                    "rename": {
                        "label": "Rename",
                        "action": function (obj) {
                            tree.edit($mynode);
                        }
                    },
                    "delete": {
                        "label": "Delete",
                        "action": function (obj) {
                            tree.delete_node($mynode);
                        }
                    }
                };

                return items;
            }

            $('.section:not(:first)').hide();
            $('ul.controls > li').click(function (e) {
                e.preventDefault();
                var $menu = $('ul.controls');
                $menu.children('li').each(function () {
                    if ($(this).hasClass('active')) {
                        $(this).removeClass('active');
                    }
                });
                $(this).addClass('active');
                $('.section').hide();
                $('#' + $(this).text()).fadeIn(300, "easeInSine");
            });

            function CheckFile(filename) {
                filename = filename.toLowerCase();
                if (filename.indexOf('.jpg') > -1 || filename.indexOf('.jpeg') > -1) {
                    if (filename.indexOf('.jpeg') > -1) {
                        filename = filename.slice(0, -5);
                        filename += ".jpg";
                    }
                    return true;
                }
                else {
                    return false;
                }
            }

            $('#btnUploadFile').on('click', function (e) {
                e.preventDefault();
                var data = new FormData();
                var files = $('#fileUpload').get(0).files;
                var filepath = "Temp/" + files[0].name;
                filename = files[0].name;
                //HERE I need to deal with this stupid filename
                valid = CheckFile(filename);
                if (valid) {
                    if (files.length > 0) {
                        data.append("UploadedImage", files[0]);
                    }

                    var ajaxRequest = $.ajax({
                        type: "POST",
                        url: "WebService.asmx/UploadFile",
                        contentType: false,
                        processData: false,
                        data: data
                    });
                    ajaxRequest.done(function (response) {
                        $('.preview').attr('src', filepath);
                        $('.container').fadeIn().css('display', 'block');
                        $('.img-preview').css('display', 'block');
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
                    });

                    ajaxRequest.fail(function (xhr, response) {
                        alert('Fail: ' + xhr.statusText + '\n' + xhr.responseText + '\n');
                    });
                }
                else {
                    alert('The file format you have selected is invalid. Please choose a JPEG image to upload.');
                }
            });

            $('a.imgUpload').on('click', function (e) {
                e.preventDefault();
                var savePath = '~/Images/Portfolio/' + $('#ddlCats').val() + '/' + filename;
                var dataURL = $('.container > img').cropper('getCroppedCanvas', { width: 100, height: 75 }).toDataURL('image/jpeg', 1.0);
                dataURL = dataURL.replace('data:image/jpeg;base64,', '');
                var fullPath = savePath;
                debugger
                filename = filename.toLowerCase();
                if (filename.indexOf('.jpg') > -1) {
                    var thumbName = filename.slice(0, -4) + "_thumb.jpg";
                }
                else {
                    var thumbName = filename.slice(0, -5) + "_thumb.jpg";
                }
                var thumbPath = '~/Images/Portfolio/' + $('#ddlCats').val() + '/Thumbs/' + thumbName;

                var dir = fullPath.substring(0, fullPath.lastIndexOf("/")) + '/';
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/UploadImage',
                    data: '{"imageData" : "' + dataURL + '", "path" : "' + thumbPath + '", "fileName" : "' + thumbName + '"}',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (msg) {
                    }
                }).done(function (response) {
                    var src = $('.container').find('img').attr('src');
                    $.ajax({
                        type: 'POST',
                        url: 'WebService.asmx/MoveImage',
                        data: '{"src" : "' + src + '", "dest" : "' + savePath + '"}',
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function (msg) {
                            //location.reload();
                        }
                    }).fail(function (response) {
                        alert(response.statusText);
                    });
                });

                var category = $('#ddlCats').val();
                var photog = $('#txtPhotog').val();
                var hair = $('#txtHairStylist').val();
                var mua = $('#txtMUA').val();
                var stylist = $('#txtStylist').val();
                var pub = $('#txtPub').val();
                var desc = $('#txtDesc').val();
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/SetCaption',
                    data: '{"Category" : "' + category + '", "imgFileName" : "' + filename + '", "Photog" : "' + photog + '", "HS" : "' + hair + '", "MUA" : "' + mua + '", "stylist" : "' + stylist + '", "Pub": "' + pub + '", "Desc" : "' + desc + '"}',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (msg) {
                        location.reload();
                    }
                }).fail(function (response) {
                    alert(response.responseText);
                });
            });
        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="Head">
            <img class="logo" src="Images/SiteImages/logo_cool.png" alt="EF logo" />
            <h1>Administrator Dashboard</h1>
        </div>
        <div id="Main">
            <div id="tree"></div>
            <div class="tooltip">
                <img src="" alt="" />        
            </div>
            <div id="Content">
                <div class ="topBar">
                    <ul class="controls">
                        <li class="active" title="Upload a new photo"><a href="#">New</a></li>
                        <li title="Edit a photo selected from the list"><a href="#">Edit</a></li>
                        <li title="Delete selected item from list"><a href="#">Delete</a></li>
                    </ul>
                </div>
                <div id="New" class="section" >
                    <asp:Label ID="lblCategory" CssClass="label" AssociatedControlID="ddlCats" Text="Select a Category for the new image: " runat="server" />
                    <asp:DropDownList ID="ddlCats" ClientIDMode="Static" CssClass="label" Width="150" ToolTip="This is where the new file will go." runat="server" /><br />
                    <label for="fileUpload" class="label">Select File  </label><input id="fileUpload" type="file" />
                    <input id="btnUploadFile" type="button" value="Open" /><br /><br />
                    <span class="label">Enter Caption Data:</span><br />
                    <div id="CaptionData">
                        <span class="label">Photographer:</span><input class="textBox" id="txtPhotog" type="text" /><br />
                        <span class="label">Hair Stylist:</span><input class="textBox" id="txtHairStylist" type="text" /><br />
                        <span class="label">Makeup Artist:</span><input class="textBox" id="txtMUA" type="text" /><br />
                        <span class="label">Stylist:</span><input class="textBox" id="txtStylist" type="text" /><br />
                        <span class="label">Publication:</span><input class="textBox" id="txtPub" type="text" /><br />
                        <span class="label">Description:</span><input class="textBox" id="txtDesc" type="text" />
                    </div>
                    <a href="#" class="imgUpload" title="Upload Data">
                        <img src="Images/SiteImages/upload.png" alt="Upload" />
                        <span style="display: inline-block; height: 27px;  vertical-align: bottom;">Upload</span></a>
                    <div id="Right" class="container">
                        <img class="preview" src="" alt="" />
                        <div class="img-preview"></div>
                    </div>
                </div>
                <div id="Edit" class="section" >
                    <div style="display: block; float: left; position: relative; width: 50%; height: 100%;">
                        <span class="label">Photographer:</span><input class="textBox" id="txtPhotogEdit" type="text" /><br />
                        <span class="label">Hair Stylist:</span><input class="textBox" id="txtHSEdit" type="text" /><br />
                        <span class="label">Makeup Artist:</span><input class="textBox" id="txtMUAEdit" type="text" /><br />
                        <span class="label">Stylist:</span><input class="textBox" id="txtStylistEdit" type="text" /><br />
                        <span class="label">Publication:</span><input class="textBox" id="txtPubEdit" type="text" /><br />
                        <span class="label">Description:</span><input class="textBox" id="txtDescEdit" type="text" />
                        <a href="#" id="submitEdit"></a>
                    </div>
                    <div style="display: block; float: right; width: 50%; position:relative; height: 100%;">
                        <img src="" class="display" alt="" style="height: 95%; border: 1px solid black; float: right;" />
                    </div>"
                </div>
                <div id="Delete" class="section">
                    Delete Section
                </div>
            </div>
        </div>        
    </form>
</body>
</html>
