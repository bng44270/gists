/***********************************************
slideomatic.js

Creates slideshows of sequentially named image files (ex: 1.jpg, 2.jpg, 3.jpg, etc.)

Required jquery

Arguments:
  |-------------|-----------------------------------------------|
  | slideid     | ID of DOM object containing slideshow         |
  | bcolor      | Border color around slideshow                 |
  | slidedelay  | Delay for slide changing (in milliseconds)    |
  | basseurl    | Base URL of image files                       |
  | filext      | File extension of image files                 |
  | slidecount  | Number of slides to rotate through            |
  | frwid       | Width of slideshow container                  |
  | frhgt       | Height of slideshow container                 |
  |-------------|-----------------------------------------------|
  
Usage:
  <script type="text/javascript" src="http://bng44270.github.io/4e76e92aed9fb5819125737fa7043cbb/slideomatic.js"></script>
  <script type="text/javascript">
    $(document).ready(function() {
      slideOMatic('myslideshow','#000000',5000,true,false,'http://bng44270.github.io/images/','jpg',100,320,240);
    });
  </script>
***********************************************/
function slideOMatic(slideid, bcolor, slidedelay, autostart, showcontrols, baseurl, filext, slidecount,frwid, frhgt) {
  heightadd = (showcontrols) ? 50 : 0;
  $('#' + slideid).css('height', (frhgt+heightadd).toString() + 'px');
  $('#' + slideid).css('width', frwid.toString() + 'px');
  $('#' + slideid).css('border','2px solid ' + bcolor);
  $('#' + slideid).css('-webkit-touch-callout','none');
  $('#' + slideid).css('-webkit-user-select','none');
  $('#' + slideid).css('-khtml-user-select','none');
  $('#' + slideid).css('-moz-user-select','none');
  $('#' + slideid).css('-ms-user-select','none');
  $('#' + slideid).css('user-select','none');
  
  var imagenum = (window.location.hash.length > 0) ? window.location.hash.replace('#','') : '1';
  location.href = '#' + imagenum;
  
  $('#' + slideid).html('<div style="border:none; text-align:center;vertical-align:middle;width: ' + frwid + 'px; height: ' + frhgt + 'px;"><img src="' + baseurl + imagenum + '.' + filext + '" id="' + slideid + '-img" /></div>');
  $('#' + slideid).html($('#' + slideid).html() + '<div style="display:' + ((showcontrols) ? 'block' : 'none') + ';text-align:center;margin-top:30px;width: ' + frwid + 'px; height:50px;"><span style="cursor:pointer;"  id="' + slideid + '-prev">&lt&lt;&nbsp;</span>Slide&nbsp;<span id="' + slideid + '-lbl">' + imagenum + '</span><span style="cursor:pointer;" id="' + slideid + '-next">&nbsp;&gt;&gt;</span><input type="checkbox" id="' + slideid + '-auto" />Auto Advance</div><div style="clear:both;"></div>');
  
  
  $('#' + slideid + '-auto').click(function() {
    setTimeout(function() {
      currentslide = parseInt($('#' + slideid + '-lbl').html());
      if ($('#' + slideid + '-auto').prop('checked')) {
        if (currentslide == slidecount) {
          $('#' + slideid + '-lbl').html('0');
        }
        $('#' + slideid + '-next').click();
      }
    },slidedelay);
  });
  
  $('#' + slideid + '-prev').click(function() {
	currentslide = parseInt($('#' + slideid + '-lbl').html());
    if(currentslide != 1) {
      var newslide = currentslide - 1;
      $('#' + slideid + '-img').attr('src', baseurl + newslide + '.' + filext);
      $('#' + slideid + '-lbl').html(newslide.toString());
	  location.href = '#' + newslide.toString();
    }
  });
  
  $('#' + slideid + '-next').click(function() {
	currentslide = parseInt($('#' + slideid + '-lbl').html());
    if(currentslide != slidecount) {
      var newslide = currentslide + 1;
      $('#' + slideid + '-img').attr('src', baseurl + newslide + '.' + filext);
      $('#' + slideid + '-lbl').html(newslide.toString());
	  location.href = '#' + newslide.toString();
	  setTimeout(function() {
        if ($('#' + slideid + '-auto').prop('checked')) {
          if (currentslide == slidecount) {
            $('#' + slideid + '-lbl').html('0');
          }
          $('#' + slideid + '-next').click();
        }
      },slidedelay);
    }
  });
  
  $('#' + slideid + '-img').on('load',function() {
    var newwid = parseInt($('#' + slideid + '-img').css('width'));
    var newhgt = parseInt($('#' + slideid + '-img').css('height'));
    if (newwid == newhgt) {
      if (frwid >= frhgt) {
        $('#' + slideid + '-img').css('height',(parseInt($('#' + slideid).css('height'))-heightadd).toString() + 'px');
        $('#' + slideid + '-img').css('width','auto');
	  }
      else {
        $('#' + slideid + '-img').css('width',$('#' + slideid).css('width'));
        $('#' + slideid + '-img').css('height','auto');
	  }
    }
    else if (newwid >= newhgt) {
      $('#' + slideid + '-img').css('width',$('#' + slideid).css('width'));
      $('#' + slideid + '-img').css('height','auto');
    }
    else {
        $('#' + slideid + '-img').css('height',(parseInt($('#' + slideid).css('height'))-heightadd).toString() + 'px');
        $('#' + slideid + '-img').css('width','auto');
    }
  });
  
  $('#' + slideid + '-auto').ready(function() {
    $('#' + slideid + '-auto').prop('checked',autostart);
    setTimeout(function() {
      currentslide = parseInt($('#' + slideid + '-lbl').html());
      if ($('#' + slideid + '-auto').prop('checked')) {
        if (currentslide == slidecount) {
          $('#' + slideid + '-lbl').html('0');
        }
        $('#' + slideid + '-next').click();
      }
    },slidedelay);
  });
}