// CREATE VIEW-CONTROLLER

var api_version = 'v1';

// TOGGLES

// template or iso
$('#create_guest_iso').hide();
$('[name="template_flag"]').change(function () {
  $('#create_guest_template').toggle();
  $('#create_guest_iso').toggle();
  $('#create_guest_os_disk_no').hide();
  $('#create_guest_os_disk_yes').show();
  $('#create_guest_cow_enable').prop('checked', true);
});

// data disk
$('#create_guest_data_disk_yes').hide();
$('#create_guest_data_disk_enable').change(function () {
  $('#create_guest_data_disk_no').hide();
  $('#create_guest_data_disk_yes').show();
  var enable_state = $('#create_guest_data_disk_enable').val();
  $('#create_guest_data_disk_input').val(enable_state);
});
$('#create_guest_data_disk_close').click(function () {
  $('#create_guest_data_disk_enable').prop('checked', false);
  $('#create_guest_data_disk_no').show();
  $('#create_guest_data_disk_yes').hide();
  $('#create_guest_data_disk_input').val('false');
});

// os disk 
$('#create_guest_os_disk_no').hide();
$('#create_guest_os_disk_enable').change(function () {
  $('#create_guest_os_disk_no').hide();
  $('#create_guest_os_disk_yes').show();
  var enable_state = $('#create_guest_os_disk_enable').val();
  $('#create_guest_os_disk_input').val(enable_state);
});
$('#create_guest_os_disk_close').click(function () {
  $('#create_guest_os_disk_enable').prop('checked', false);
  $('#create_guest_os_disk_no').show();
  $('#create_guest_os_disk_yes').hide();
});

// GET SETTINGS FROM THE DATABASE
var settings = null;
function exSet(retStr) {
  settings = retStr;
}
function getSet() {
  $.ajax({
    type: 'GET',
    url: '/api/' + api_version + '/',
    success: function(data) {
      exSet(data);
    },
    headers: { 'X-Unit-Name': 'settings' },
    async: false
  });
}
getSet();

// DROP-DOWN POPULATION

// lab
$.ajax({
  type: 'GET',
  url: '/api/' + api_version + '/',
  success: function(data) {
    $('#create_guest_lab').html($.map(data, function(value) {
      return $('<option value=' + value.id + '>').html(value.name)[0];
    }));
  },
  headers: { 'X-Unit-Name': 'virtual_router' }
});

// iso
$.ajax({
  type: 'GET',
  url: '/api/' + api_version + '/',
  success: function(data) {
    $('#create_guest_iso_select').html($.map(data, function(value) {
      return $('<option value=' + value.id + '>').html(value.name)[0];
    }));
  },
  headers: { 'X-Unit-Name': 'iso' }
});

// template
$.ajax({
  type: 'GET',
  url: '/api/' + api_version + '/',
  success: function(data) {
    $('#create_guest_template_select').html($.map(data, function(value) {
      return $('<option value=' + value.id + '>').html(value.name)[0];
    }));
  },
  headers: { 'X-Unit-Name': 'template' }
});

// VALUE ADJUSTMENT +- BUTTONS

/*
 * span.text				#create_guest__ram__display
 * hidden_input.val			#create_guest__ram__input
 * plus_toggle.click			#create_guest__ram__increase
 * minus_toggle.click			#create_guest__ram__decrease
 *
 * create_guest__ram__value		from setting.guest_default_ram
 * create_guest__ram__step_value	from setting.guest_default_ram_step
 * create_guest__ram__max_value		from setting.guest_default_ram_max
 * create_guest__ram__min_value		from setting.guest_default_ram_min
 *
 */

// items having + and - controls
var items = ['ram', 'os_capacity', 'data_capacity'];

// increase
function incr (value, step_value, max_value, min_value) {
  var current_value = $('#create_guest__' + value + '__input').val();
  current_value = parseInt(current_value);
  var new_value = current_value + step_value;
  // upper limit
  if (new_value == max_value) {
    $('#create_guest__' + value + '__increase').hide();
    $('#create_guest__' + value + '__increase_limit').show();
  } else if (current_value == min_value) {
    $('#create_guest__' + value + '__decrease').show();
    $('#create_guest__' + value + '__decrease_limit').hide();
  }
  // otherwise, increase
  $('#create_guest__' + value + '__input').val(new_value);
  $('#create_guest__' + value + '__display').text(new_value);
}

// decrease
function decr (value, step_value, max_value, min_value) {
  var current_value = $('#create_guest__' + value + '__input').val();
  current_value = parseInt(current_value);
  var new_value = current_value - step_value;
  // lower limit
  if (new_value == min_value) {
    $('#create_guest__' + value + '__decrease').hide();
    $('#create_guest__' + value + '__decrease_limit').show();
  } else if (current_value == max_value) {
    $('#create_guest__' + value + '__increase').show();
    $('#create_guest__' + value + '__increase_limit').hide();
  } 
  // otherwise, decrease
  $('#create_guest__' + value + '__input').val(new_value);
  $('#create_guest__' + value + '__display').text(new_value);
}

// iterate over each item
$.each(items, function (index, value) {

  // set item values from database setting[] values
  switch (value) {
    case 'ram':
      var default_value = parseInt(settings[0].guest_default_ram);
      var step_value = parseInt(settings[0].guest_default_ram_step);
      var max_value = parseInt(settings[0].guest_default_ram_max);
      var min_value = parseInt(settings[0].guest_default_ram_min);
      $('#create_guest__' + value + '__input').val(default_value);
      $('#create_guest__' + value + '__display').text(default_value);
      incr(value, step_value, max_value, min_value);
      decr(value, step_value, max_value, min_value);
      $('#create_guest__' + value + '__increase').click(function () {
        incr(value, step_value, max_value, min_value);
      });
      $('#create_guest__' + value + '__decrease').click(function () {
        decr(value, step_value, max_value, min_value);
      });
      break;
    case 'os_capacity':
      var default_value = parseInt(settings[0].guest_default_os_capacity);
      var step_value = parseInt(settings[0].guest_default_os_capacity_step);
      var max_value = parseInt(settings[0].guest_default_os_capacity_max);
      var min_value = parseInt(settings[0].guest_default_os_capacity_min);
      $('#create_guest__' + value + '__input').val(default_value);
      $('#create_guest__' + value + '__display').text(default_value);
      incr(value, step_value, max_value, min_value);
      decr(value, step_value, max_value, min_value);
      $('#create_guest__' + value + '__increase').click(function () {
        incr(value, step_value, max_value, min_value);
      });
      $('#create_guest__' + value + '__decrease').click(function () {
        decr(value, step_value, max_value, min_value);
      });
      break;
    case 'data_capacity':
      var default_value = parseInt(settings[0].guest_default_data_capacity);
      var step_value = parseInt(settings[0].guest_default_data_capacity_step);
      var max_value = parseInt(settings[0].guest_default_data_capacity_max);
      var min_value = parseInt(settings[0].guest_default_data_capacity_min);
      $('#create_guest__' + value + '__input').val(default_value);
      $('#create_guest__' + value + '__display').text(default_value);
      incr(value, step_value, max_value, min_value);
      decr(value, step_value, max_value, min_value);
      $('#create_guest__' + value + '__increase').click(function () {
        incr(value, step_value, max_value, min_value);
      });
      $('#create_guest__' + value + '__decrease').click(function () {
        decr(value, step_value, max_value, min_value);
      });
      break;
    default:
      alert('error: invalid item case');
  }
});

// READ VIEW-CONTROLLER

$('.read__guest__name').show();
$('.read__guest__cpu_use').show();
$('.read__guest__ram_use').show();
$('.read__guest__vdisk_used').show();

controls = '<a href="">c</a> <a href="">o</a> <a href="">o</a> <a href="">l</a>';
$('.read__guest____controls').html('<span> ' + controls + ' </span>');
