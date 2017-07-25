// VIRTUAL_ROUTER READ VIEW-CONTROLLER

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

// virtual_router
$('.read__virtual_router__name').show();
