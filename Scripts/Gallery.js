$(document).ready(function () {
    var dirs = [];
    var imgs = [];
    var caps = [];
    var wait = 0;
    var $currentImage = null;
    var minLeft = 0;
    var x = 0;
    var winWidth = $(window).outerWidth();
    var left = 0;

    Initialize();
    setTimeout(function () {
        $('.caption').html(caps[0]);
    }, 1000);
    function Initialize() {
        GetCategories("Portfolio");
        setTimeout(function () {
            $('.currentImg').attr('src', imgs[0]).css({ 'opacity': '0' });
            $('.currentImg').animate(
                {
                    'opacity': '1',
                }, 700, 'easeOutQuad');
            $currentImage = $('#Gallery .thumbWindow .reel').children().first();
            $currentImage.addClass('active');
            $currentImage.css('opacity', '1');
            $('.caption').html(caps[0]);
        }, 700);
    }

    function GetCategories(folder) {
        $.ajax({
            type: "POST",
            url: "WebService.asmx/GetDirectories",
            contentType: "application/json; charset=utf-8",
            data: '{ "directory" : "' + folder + '"}',
            dataType: "json",
            success: CategorySuccess,
        }).done(function (response) {
            GetThumbnails(dirs[0]);
        }).fail(function (response) {
            alert(response.d);
        });
    }

    function CategorySuccess(response) {
        dirs = $.parseJSON(response.d);
        for (var i = 0; i < dirs.length; i++) {
            var $cat = $('<li><a href="#">' + dirs[i] + '</a></li>');
            $cat.bind('click', function (e) { // when the category is clicked, get the files / thumbnails for that category
                e.preventDefault();
                imgs = [];
                GetThumbnails($(this).text());
                $currentImage = $('#Gallery .thumbWindow .reel').children().first();
            });
            $('.categories ul').append($cat);
        }
    }
    function GetThumbnails(category) {
        $.ajax({
            type: "POST",
            url: "WebService.asmx/GetFiles",
            contentType: "application/json; charset=utf-8",
            data: '{ "folderName" : "' + category + '"}',
            dataType: "json",
            success: OnThumbSuccess,
            failure: function (response) {
                alert('failure');
            }
        }).done(function (response) {
            var files = $.parseJSON(response.d);
            var $thumbs = $('#Gallery .thumbWindow .reel');
            
            //if there are items in the thumb reel
            if ($thumbs.children().length > 0) {
                setTimeout(function () {
                    $('.reel').empty();
                    $thumbs.empty();
                    //loop through the array of json objects
                    for (var i = 0; i < files.length; i++) {
                        InsertHTML(files[i].thumbHref, i);
                        imgs[i] = files[i].fileHREF;
                        caps[i] = files[i].caption;
                    }
                    Transition(imgs[0]);
                    $('.caption').html(caps[0]);
                }, $thumbs.children().length * 110);

            }
            else {
                //loop through the array of json objects
                for (var i = 0; i < files.length; i++) {
                    imgs[i] = files[i].fileHREF;
                    caps[i] = files[i].caption;
                    InsertHTML(files[i].thumbHref, i);
                }
                Transition(imgs[0]);
            }
            
        }).fail(function (response) {
            alert(response.responseText);
        });
    }
    function OnThumbSuccess(response) {
        var $thumbs = $('#Gallery .thumbWindow .reel');
        $thumbs.children().each(function (i) {
            $(this).delay(i * 100).animate({ 'opacity': '0' }, 100, 'easeOutSine');
        })
        //make sure the thumb reel resets to its original position
        $thumbs.css('left', '0px');
        $thumbs.css('opacity', '1');
    }

    function InsertHTML(data, index) {
        //create the thumbnail image
        var $thumb = $('<img id="' + index + '" src="' + data + '" alt=""/>');
        //set its default class to inactive
        $thumb.addClass('inactive');
        $thumb.bind('click', function () {
            $currentImage = $(this);

            $(this).parent().children().each(function () {
                if ($(this).hasClass('active')) {
                    $(this).removeClass('active');
                    $(this).addClass('inactive');
                    $(this).css('opacity', '.5');
                }
            });

            //set the clicked thumbnail active
            $(this).addClass('active');
            $(this).css('opacity', '1');

            //get the URL for the related image
            var id = parseInt($(this).attr('id'));
            var href = imgs[parseInt($(this).attr('id'))];
            var src = parseInt($(this).attr('id'));

            SlideThumbPanel(src);
            Transition(href, id);
        });
        
        
        $thumb.appendTo('#Gallery .thumbWindow .reel');
        if (index == 0) {
            $thumb.removeClass('inactive');
            $thumb.addClass('active');
            $thumb.css('opacity', '1');
        }
    } //end InsertHTML

    function SlideThumbPanel(index) {
        
        $thumbPanel = $('#Gallery .thumbWindow .reel');
        var winFit = Math.round(winWidth / 90);
        minLeft = ((imgs.length * 90) - winFit * 90);
        
        var mid = Math.round(winFit / 2);
        if (minLeft < 0) {
            return;
        }
        else {
            var numLeft;
            var currleft = parseInt($thumbPanel.css('left'));
            numLeft = (currleft / 90) * -1;
            mid = Math.round((winFit / 2) + numLeft);
            
            if (currleft == 0 && index > mid) {
                left -= 90;
                $thumbPanel.animate({ 'left': left + 'px' }, 300, 'easeOutSine');
            }
            else if (currleft != 0 && index > mid) {
                
                if ((left - 90) >= (minLeft * -1)) {
                    left -= 90;
                    $thumbPanel.animate({ 'left': left + 'px' }, 300, 'easeOutSine');
                }
            }
            else if (currleft != 0 && index < mid) {
                if (!(left + 90) >= 0) {
                    left += 90;
                    $thumbPanel.animate({ 'left': left + 'px' }, 300, 'easeOutSine');
                }
            }
        }
    }

    function Transition(url, i) {
        $('.currentImg').stop(true, true, true).animate({ 'opacity': '0' }, 300, 'easeInQuad');

        setTimeout(function () {
            $('.currentImg').hide();
            $('#loader').show();
            $('.currentImg').attr('src', url);
            $('.currentImg').animate({
                'opacity': '1'
            }, 300, 'easeOutQuad');
            $('.caption').html(caps[i]);
        }, 500);
        $('.currentImg').css('opacity', '1');
        $('.caption').html(caps[i]);
    }
    $('.navLeft').click(function () {
        var $next = null;
        var src;
        var index = 0;
        if (($currentImage.prev().index() >= 0)) {
            $next = $currentImage.prev();
            $currentImage.removeClass('active').css('opacity', '.5');
            $next.addClass('active').css('opacity', '1');
        }
        else {
            $next = $currentImage;
            return;
        }

        src = parseInt($next.attr('id'));
        
        Transition(imgs[src], src);
        SlideThumbPanel(src);
        $currentImage = $next;
    });
    $('.navRight').click(function () {
        var $next = null;
        var src;
        if ($currentImage.index() == -1) {
            $currentImage = $('#Gallery .thumbWindow .reel').children().first();
        }
        if (($currentImage.next().index() != -1)) {
            $next = $currentImage.next();
            $currentImage.removeClass('active').css('opacity', '.5');
            $next.addClass('active').css('opacity', '1');
        }
        else {
            $next = $currentImage;
            return;
        }
        src = parseInt($next.attr('id'));
        Transition(imgs[src], src);
        SlideThumbPanel(src);
        $currentImage = $next;
    });
});