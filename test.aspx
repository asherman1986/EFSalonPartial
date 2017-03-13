<%@ Page Language="C#" AutoEventWireup="true" CodeFile="test.aspx.cs" Inherits="test" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>cropper test</title>
    <script src="Scripts/jquery-2.1.4.min.js"></script>
    <link rel="stylesheet" href="Styles/cropper.css" />
    <script src="Scripts/cropper.min.js"></script>
    <style>
        .container {
            display: block;
            width: 500px;
            height: 500px;
            margin: 0 auto;
        }
        .img-preview {
            display: block;
            max-width:100px;
            width: 100px;
            max-height: 75px;
            height: 75px;
            border: 1px solid black;
            position: absolute;
            top: 50px;
            right: 300px;
            overflow: hidden;
        }
    </style>
    <script>
        $(document).ready(function () {
            $('.container > img').cropper({
                //options
                guides: false,
                center: false,
                highlight: false,
                background: true,
                movable: true,
                zoomable: true,
                dragCrop: false,
                cropBoxMovable: false,
                cropBoxResizable: false,
                aspectRatio: 4 / 3,
                preview: '.img-preview',
                crop: function () {
                                       
                }
            });

            $('#btnAccept').click(function (e) {
                var dataURL = $('.container > img').cropper('getCroppedCanvas', { width: 100, height: 75 }).toDataURL('image/jpeg', 1.0);
                dataURL = dataURL.replace('data:image/jpeg;base64,', '');
                
                $.ajax({
                    type: 'POST',
                    url: 'WebService.asmx/UploadImage',
                    data: '{"imageData" : "' + dataURL + '"}',
                    contentType: 'application/json; charset=utf=8',
                    dataType: 'json',
                    success: function (msg) {
                        alert("Your image has been uploaded successfully!");
                    }
                });
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" />
    <div>
        <div class="container">
            <img src="Temp/softdrink.jpg" alt="" />
        </div>
        <div class="img-preview">
        </div>
        <input id="btnAccept" type="button" name="Accept" value="Accept Thumbnail" />
    </div>
    </form>
</body>
</html>
