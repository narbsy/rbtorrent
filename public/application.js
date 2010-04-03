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
    change_update_interval(15 * minutes);
  });
  
  $(document).bind("active.idleTimer", function(){
    change_update_interval(10 * seconds);
  }); 
});

function change_update_interval(new_interval){
  clearInterval(update_interval);
  update_interval = setInterval( update_torrents, new_interval );
}

function update_torrents(){
  $.get('/update', function(data) {
    data.forEach( function(update){
      var hash = update.hash;
      console.log(' for: ' + hash);
      // ratio
      var elem = $('#' + hash + ' .torrent .ratio');
      $(elem).text('Ratio: ' + (update.ratio / 1000).toFixed(3));
      //percentage
      elem = $('#' + hash + ' .torrent .percent span');
      var percent = update.percentage * 100;
      $(elem).text(percent + '%');
      $(elem).css('width', percent + '%');
      //status
      update_status(hash, update.status);
      //up, down rates
      var up = (update.up_rate / 1024).toFixed(2);
      var down = (update.down_rate / 1024).toFixed(2);
      var elem = $('#' + hash + ' .torrent .rates');
      $(elem).text('Upload: ' + up + 'KB/s Download: KB/s' + down);
    });
  }, 'json');
}

function hide_all_but(css_class){
  var css = '.' + css_class
  $('li:not(' + css + ')').hide();
  console.log(css);
  $('li' + css).show();
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

