$(document).ready(function() {

// CUSTOM METHODS

  // override the default content-type header for all .ajax methods
  $.ajaxSetup({
    contentType: 'application/json',
    dataType: 'json'
  });

  // function to convert form data into json
  function QueryStringToJsonObject (QueryString) {
    var match,
      pl		= /\+/g,
      search	= /([^&=]+)=?([^&]*)/g,
      decode	= function (s) { return decodeURIComponent(s.replace(pl, " ")); };
    var JsonObject = {};
    while (match = search.exec(QueryString)) {
      JsonObject[decode(match[1])] = decode(match[2]);
    }
    return JsonObject
  }

// READ VIEW LOOP

  // define which crud objects to pull as feeds. value will be used as the display name in this interface, while key is the relation name sent to the api
  var sections = {
    'hypervisor': 'hypervisor_server',
    'storage server': 'storage_server',
    'lab': 'virtual_router',
    'guest': 'guest',
    'template': 'template',
    'iso': 'iso',
  };
  var api_version = 'v1';
  var base = '/interface';

  // create html containers and load view-controlles for each section
  $.each(sections, function (index, value) { 
    $('#sections').append('<h3>' + index + 's <a ref="' + value + '" href="javascript:void(0)" class="controls crud create activate_modal" name="create">&plus;</a><!-- <a href="javascript:void(0)" class="controls supercrud flush activate_modal">&#9760;</a>--></h3><p id="' + value + '"></p>');
  });

  // continuously iterate, to refresh and display Read data for each crud feed
  var timeout = 1000;
  var action = function() {
    $.each(sections, function(index, value) {
      $.ajax({
        type: 'GET',
        url: '/api/' + api_version + '/',
	success: function(data) {
          ShowFeed(value, data);
        },
	headers: { 'X-Unit-Name': value }
      });
    });
  };
  setInterval(action,timeout);

// MODAL WINDOW

  // function to open a modal window
  function show_modal () {
    $("#mask").css({"display": "block", opacity: 0.8});
    $('#modal').show();
  }

  // function to close a modal window
  function close_modal () {
    $("#mask").hide();
    $("#modal").hide();
    $('#modal').empty();
  }

  // function to calculate modal window positon
  function calc_modal () {
    var window_width = $(window).width();
    var window_height = $(window).height();
    var modal_width = $('#modal').outerWidth();
    var modal_height = $('#modal').outerHeight();
    var left = (window_width - modal_width) / 2;
    var top = (window_height - modal_height) / 4;
    $('#modal').css({"top": top, "left": left});
  }

  // trigger to open a view
  $('body').on('click', '.activate_modal', function () {
    var view = $(this).attr('name');
    var referrer = $(this).attr('ref');
    var data_id = $(this).attr('record_id');
    var data_name = $(this).attr('record_name');
    if (view === 'create') {
      ShowCreate(api_version, referrer);
    } else if (view === 'delete') {
      ShowDelete(api_version, referrer, data_id, data_name);
    } else {
      ShowUpdate(api_version, referrer, data_id, data_name);
    }
    calc_modal();
    show_modal();
  });

  // trigger to close a view
  $('body').on('click', '.close_modal', function () {
    close_modal();
  });

// READ VIEW

  // function to display Read data to the page
  function ShowFeed (section, json) {
    $('#' + section).html($.map(json, function(value) {
      var content = $.map(value, function(v, k) {
        return '<span id="read__' + section + '__' + k + '" class="noshow read__' + section + '__' + k + '">' + v + '</span>';
      });
      var controls = '<span class="read__' + section + '____controls"></span>';
      var cruds =' <a ref="' + section + '" name="update" record_id="' + value.id + '" record_name="' + value.name + '" href="javascript:void(0)" class="controls crud delete activate_modal">&plusmn;</a> <a ref="' + section + '" name="delete" record_id="' + value.id + '" record_name="' + value.name + '" href="javascript:void(0)" class="controls crud update activate_modal">&times;</a>';
      return $('<div></div>').html(content.join(' ') + controls + cruds);
    }));

    // load view-controller for this section
    $.ajax({
      type: 'GET',
      url: base + '/' + section + '.controller.js',
      dataType: 'script'//,
      //async: false
    });
      
  }

// CREATE VIEW

  // function to display Create form as a modal window
  function ShowCreate (api_version, section) {
    //$("#modal").load('create.html', function () {
    $("#modal").load(section + '.create.html', function () {
      $('#ref_name').html(section);
      $('button.submit_create').attr('ref', section);

      // load view-controller for this section
      $.ajax({
        type: 'GET',
        url: base + '/' + section + '.controller.js',
        dataType: 'script'//,
        //async: false
      });
    });

    // submit post
    $('body').on('click', '[ref="' + section + '"].submit_create', function () {

      // convert form-data into a json object
      obj = QueryStringToJsonObject( $('#create_form').serialize() );
      str = JSON.stringify(obj);

      $.ajax({
	type: 'POST',
	url: '/api/' + api_version + '/',
	data: str,
	success: function (data, status) {
          if (status == 'success') {
            close_modal();
          } else {
            alert('data: ' + data + ' status: ' + status);
          }
        },
	headers: { 'X-Unit-Name': section }
	//headers: { 'X-Unit-Name': sections[section] }
      });
      event.stopPropagation();
    });
  }

// UPDATE VIEW

  // function to display Update form as a modal window
  function ShowUpdate (api_version, section, id, name) {

    // display update view modal window
    $("#modal").load('update.html', function () {
      $('#update_id').val(id);
      $('#update_name').val(name);
      $('button.submit_update').attr('ref', section);
    });

    // submit put
    $('body').on('click', '[ref="' + section + '"].submit_update', function () {

      // convert form-data into a json object
      obj = QueryStringToJsonObject( $('#update_form').serialize() );
      str = JSON.stringify(obj);

      $.ajax({
	type: 'PUT',
	url: '/api/' + api_version + '/',
	data: str,
	success: function (data, status) {
          if (status == 'success') {
            close_modal();
          } else {
            alert('data: ' + data + ' status: ' + status);
          }
        },
	headers: { 'X-Unit-Name': section }
      });
      event.stopPropagation();
    });
  }

// DELETE VIEW

  // function to display Delete form as a modal window
  function ShowDelete (api_version, section, id, name) {

    // dispay delete view modal window
    $('#modal').load('delete.html', function () {
        $('#delete_id').val(id);
        $('#delete_name').html(name);
      $('button.submit_delete').attr('ref', section);
    });

    // submit delete
    $('body').on('click', '[ref="' + section + '"].submit_delete', function () {

      // convert form-data into a json object
      obj = QueryStringToJsonObject( $('#delete_form').serialize() );
      str = JSON.stringify(obj);

      $.ajax({
	type: 'DELETE',
	url: '/api/' + api_version + '/',
	data: str,
	success: function (data, status) {
          if (status == 'success') {
            close_modal();
          } else {
            alert('data: ' + data + ' status: ' + status);
          }
        },
	headers: { 'X-Unit-Name': section }
      });
      event.stopPropagation();
    });
  }
});
