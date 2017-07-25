// ISO READ VIEW-CONTROLLER

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

// iso
$('.read__iso__name').show();

// controls
controls = [
  {
    "": "",
    "": "",
    "": "",
    "": "",
  }
]

controls = 'a';
$('.read__iso____controls').html('<span> ' + controls + ' </span>');
