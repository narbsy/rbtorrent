var update_interval = undefined;

$(document).ready(function(){
  // Show/hide sibling .torrent
  $('.title').click(function() {
    $(this).siblings('.torrent').slideToggle();
  });

  
  var seconds = 1000;
  var minutes = 60 * seconds;

  update_interval = setInterval( update_torrents, 10 * seconds );
  // Idle after 1 minute
  $.idleTimer( 1 * minutes );

  $(document).bind("idle.idleTimer", function(){
    clearInterval(update_interval);
    update_interval = setInterval( update_torrents, 15 * minutes );
    console.log("setting interval to 15 minutes");
  });
  
  $(document).bind("active.idleTimer", function(){
    clearInterval(update_interval);
    update_interval = setInterval( update_torrents, 10 * seconds );
    console.log("setting interval to 10 seconds");
  }); 
});

function update_torrents(){
  $.get('/update', function(data) {
    console.log('got: ' + data);
    console.log('data: ' + data.length);
    var len = data.length;
    for(i = 0; i < len; i++) {
      var update = data[i];
      var hash = update.hash;
      console.log(i + ' for: ' + hash );
      console.log(data.length);
      // ratio
      var elem = $('#' + hash + ' .torrent .ratio');
      $(elem).text('Ratio: ' + (update.ratio / 1000));
      //percentage
      elem = $('#' + hash + ' .torrent .percent span');
      var percent = update.percentage * 100;
      $(elem).text(percent + '%');
      $(elem).css('width', percent + '%');
      //status
      update_status(hash, update.status);
    }
  }, 'json');
}

function hide_all_but(css_class){
  var css = '.' + css_class
  var li = $('li');
  li.not(css).hide();
  $('li ' + css).show();
  // which one is faster?
  // li.filter(css).show();
  return false;
}

function show_all(){
  $('li').show();
  return false;
}

function update_status(hash, new_status){
  $('#' + hash + ' .title .status').html('[ ' + new_status + ' ]');
}

function action_with_hash(action, hash){
	$.post(action, { hash: hash }, 
		function(data){
			alert('finished: ' + action + '\n\n\n\n' + data.status);
      update_status(hash, data.status);
		}, "json"
	);
	return false;
}


