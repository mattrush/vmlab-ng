// STORAGE_SERVER READ VIEW-CONTROLLER

var api_version = 'v1';

// GET SETTINGS FROM THE DATABASE
/*var settings = null;
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
getSet();*/

// storage server
$('.read__storage_server__name').show();
$('.read__storage_server__state').show();
$('.read__storage_server__substate').show();
$('.read__storage_server__cpu_capacity').show();
$('.read__storage_server__cpu_use').show();
$('.read__storage_server__ram_capacity').show();
$('.read__storage_server__ram_use').show();
$('.read__storage_server__disk_capacity').show();
$('.read__storage_server__disk_used').show();
$('.read__storage_server__volume_capacity').show();
$('.read__storage_server__volume_use').show();
