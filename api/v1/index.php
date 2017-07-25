<?php
/* 
 * steps to configure
 *
 * 1. change sql queries for all crud+ methods to use the defined stored procedures, for each unit.
 * 2. uncomment the relevent line for each optional api integration.
 * 3. set the $base_path variable.
 * 4. create ../../../$application_name.config.ini and set the four values for the database connection. be sure to use the same database credentials in step 7.
 * 5. add a line to each crud+ function to reassign each input variable used within the function, passing the value through db_quote().
 * 6. within the declaration of validate_inputs(), set the correct *_field_rulesets variable values for each input variable used by the application as a whole, to include their respective validaition checks.
 * 7. design a databese scheme, including stored procedure definitions, and script its creation and seed data insertion, in a deploy.sh shell script. remember to use the same credentials as in step 4.
 * 8. set the 'sections' array within interface.js to use each relation for the api. also do the same for the android, iphone, and thick-client interfaces.
 * 9. 'mkdir' and 'chown -R apache:' /var/log/$application_name as root.
 *
 */
// OPTIONAL API INTERGATIONS
#require_once('authentication.php');
#require_once('account.php');
#require_once('payment.php');
#require_once('serveraction.php');
require_once('vmlab/db_create.php');
// DB HELPER FUNCTIONS
function db_connect() { // connect
  static $connection;
  if(!isset($connection)) {
    $config = parse_ini_file("../../../config/config.ini");									// read the config file
    $connection = mysqli_connect($config['host'], $config['username'], $config['password'], $config['dbname']);			// connect to the database
  }
  if ($connection === false) {													// return error if connect fails
    $msg = mysqli_connect_error();
    $timestamp = time();
    $msg = "$timestamp: $msg \n";
    log_event('alert', $msg);
    return false;
  }
  return $connection;														// return connection if connect succeeds
}
function db_query($query) { // query
  $connection = db_connect();												// connect, if not already connected, and get the connection object if we already are
  $result = mysqli_query($connection, $query);											// run the query, and get the query result
  return $result;														// return the result
}
function db_error() { // read the db error
  $connection = db_connect();												// get the connection object
  return mysqli_error($connection);												// get the database error and return it
}
function db_quote($value) { // quote and escape user input
  $connection = db_connect();
  return "'" . mysqli_real_escape_string($connection, $value) . "'";
}
// LOGGING FUNCTIONS
function logs_init() { // log an api access event to the application log file
  if (!is_dir("/var/log/api")) {
    mkdir("/var/log/api", 0700);
  }
  $types = ['access','error','alert','header'];
  foreach ($types as $type) {
    $file = "/var/log/api/$type.log";
    if(!file_exists($file)) {
      $handle = fopen($file, 'w') or die('cannot open' . $type . 'log file');
    }
  }
}
function log_event($type, $logdata) { // log api requests to files for access, error, and alert
  $file = "/var/log/api/$type.log";
  $handle = fopen($file, 'a') or die("cannot open $type log file");
  fwrite($handle, $logdata);													// one line at a time
}
// JSON FUNCTIONS
function status_success() { // send success status json
  header('content-type: application/json');
  $array = ['status' => 'success'];
  return json_encode($array, JSON_PRETTY_PRINT);
}
function status_fail($msg) { // send fail status json
  header('content-type: application/json');
  $array = ['status' => 'fail', 'message' => "$msg"];
  return json_encode($array, JSON_PRETTY_PRINT);
}
// DB QUERY FUNCTIONS
function db_write($query) { // insert, update, delete. these methods change, or 'write' to, the database
  $result = db_query($query);
  if ($result === false) {
    $msg = db_error();
    log_event('alert', $msg);
    return false;
  } else {
    return true;
  }
}
function db_read($query) { // select. this method does not change, but only 'reads' from, the database
  $rows = array();
  $result = db_query($query);
  if ($result === false) {													// return false if query fails
    $msg = db_error();
    log_event('alert', $msg);
    return false;
  }
  while ($row = mysqli_fetch_assoc($result)) {											// return the rows if query succeeds
    $rows[] = $row;
  }
  return $rows;
}
// INPUT HELPER FUNCTIONS
function receive_input() { // parse the request data, whether JSON or a query string, and return an array called '$data'
  $request = file_get_contents('php://input');
  switch ($_SERVER['CONTENT_TYPE']) {
    case 'application/x-www-form-urlencoded':
      parse_str(file_get_contents('php://input'),$input_vars);
      break;
    case 'application/json':
      $json = file_get_contents('php://input');
      $input_vars = json_decode($json, true);
      break;
  }
  return $input_vars;
}
function translate_boolean($string) { // convert string literals 'true' and 'false' to boolean datatype. or return false on other input
  switch ($string) {
    case "true":	$boolean = true;	break;
    case "TRUE":	$boolean = true;	break;
    case "false":	$boolean = false;	break;
    case "FALSE":	$boolean = false;	break;
    default:
      $msg = 'translate_boolean(): invalid input, cannot convert to boolean';
      log_event('error', $msg);
      echo status_fail($msg);
      exit;
  }
  return $boolean;
}
function validate_inputs() { // input validation. maybe it should take an array of paramet fields for each instance to validate? or a nested hash of params-to-rules to apply? how do i make a hash in php?
  #$rules = {"nonblank": '//|/[\t ]*/', "alphabetic": '/[A-Za-z ]/', "punctuation": '/[.,:!?/\@_-]/', "numeric": '/[0-9.]/'};
  #$fields = ['id','name','task_id','iso_id']
  #$create_field_rules = {'id': 'numeric', 'name': ['alphabetic','punctuation','numeric'], 'task_id': 'numeric', 'iso_id': 'numeric'}
  #$read_field_rules = {'id': 'numeric'}
  #$update_field_rules = {'id': ['nonblank','numeric']}
  #$delete_field_rules = {'id': ['nonblank','numeric']}
  //search_field_rules = {'id': 'numeric' || *.......}
  //flush_field_rules = {'id': 'numeric'}
#  foreach ($item as $k=>$v) {
    //$k $v; // recursively iterate over the above sturctures
#  }
## check schema of relation or in the case of a stored proc., a data structure defining which fields must be validated?
#  $name = db_quote($data['name']);
#  if(empty($name) or !isset($name)) {
#    $msg = 'id parameter not set';
#    echo status_fail($msg);
#    return false;
#  }
### this function should accept all input params (as the array called '$data', and then return the same, with error messages for each field failing checks if any fail.)
}
function get_application_headers() { // get the headers used by the application
  $headers = array();
  foreach(getallheaders() as $name => $value) {
    $headers[$name] = $value;
  }
  $application = $headers['X-Unit-Name'];
  return $application;
}
function validate_application_headers($application) { // white-list acceptable values for the headers used by the application, and log any violations
  $units = ['hypervisor_server', 'storage_server', 'image_server', 'virtual_router', 'guest', 'template', 'iso', 'snapshot', 'vdisk', 'settings'];
  $found = false;
  if (empty($application) or !isset($application)) {
    $found = false;
  }
  foreach ($units as $value) {
    if ($application === $value) { $found = true; }
  }
  if ($found === false) {
    $timestamp = time();
    $msg = 'client header error';
    log_event('header', "$timestamp: $msg " . $_SERVER['REMOTE_ADDR'] . ' ' .$_SERVER['HTTP_USER_AGENT'] . "\n");
    echo status_fail($msg);
    exit(1);
  }
}
// CRUD API FUNCTIONS
function api_create($app) { // create
  $timestamp = time();
  $data = receive_input();
#  validate_inputs($data);
  switch ($app) {
    case 'guest':
      $sql_insert = application__determine_create_query($data);
      #echo "data: \r" . var_dump($data) . "\r" . 'query: ' . $sql_insert;
      break;
    case 'hypervisor_server':
      $name = db_quote($data['name']);
      $sql_insert = 'CALL create_hypervisor_server(' . $name . ', @a)';
      break;
    case 'storage_server':
      $name = db_quote($data['name']);
      $sql_insert = 'CALL create_storage_server(' . $name . ', @a)';
      break;
  }
  $result = db_write($sql_insert);
  if($result === false) {
    $msg = "$timestamp: $app create fail " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
    log_event('error', $msg);
    echo status_fail($msg);
    return false;
  }
  $msg = "$timestamp: $app create success " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
  log_event('access', $msg);
  echo status_success();
  return true;
}
function api_read($app) { // read
  $timestamp = time();
  switch ($app) {
    case 'guest':
      $sql_select = 'CALL read_guest__all()';
      break;
    case 'virtual_router':
      $sql_select = 'select id, name from virtual_router';
      break;
    case 'storage_server':
      $sql_select = 'CALL read_storage_server__all()';
      break;
    case 'hypervisor_server':
      $sql_select = 'CALL read_hypervisor_server__all()';
      break;
    case 'iso':
      $sql_select = 'SELECT * FROM iso';
      break;
    case 'template':
      $sql_select = 'SELECT * FROM template';
      break;
    case 'settings':
      $sql_select = 'SELECT * FROM settings';
      break;
  }
  $rows = db_read($sql_select);
  if($rows === false) {
    $msg = "$timestamp: $app no records to read " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
    log_event('error', $msg);
    echo status_fail($msg);
    return false;
  }
  $msg = "$timestamp: $app read success " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
  log_event('access', $msg);
  header('content-type: application/json');
  echo json_encode($rows, JSON_PRETTY_PRINT);
  return true;
}
function api_update($app) { // update
  $timestamp = time();
  $data = receive_input();
  validate_inputs($data);
  switch ($app) {
    case 'hypervisor_server':
      $id = db_quote($data['id']);
      $cpu_capacity = db_quote($data['cpu_capacity']);
      $cpu_use = db_quote($data['cpu_use']);
      $ram_capacity = db_quote($data['ram_capacity']);
      $ram_use = db_quote($data['ram_use']);
      $disk_capacity = db_quote($data['disk_capacity']);
      $disk_used = db_quote($data['disk_used']);
      $sql_update = 'CALL update_hypervisor_server__agent(' . $id . ', ' . $cpu_capacity . ', ' . $cpu_use . ', ' . $ram_capacity . ', ' . $ram_use . ', ' . $disk_capacity . ', ' . $disk_used  . ')';
      break;
    case 'storage_server':
      $id = db_quote($data['id']);
      $cpu_capacity = db_quote($data['cpu_capacity']);
      $cpu_use = db_quote($data['cpu_use']);
      $ram_capacity = db_quote($data['ram_capacity']);
      $ram_use = db_quote($data['ram_use']);
      $disk_capacity = db_quote($data['disk_capacity']);
      $disk_used = db_quote($data['disk_used']);
      $volume_capacity = db_quote($data['volume_capacity']);
      $volume_use = db_quote($data['volume_use']);
      $sql_update = 'CALL update_storage_server__agent(' . $id . ', ' . $cpu_capacity . ', ' . $cpu_use . ', ' . $ram_capacity . ', ' . $ram_use . ', ' . $disk_capacity . ', ' . $disk_used  . ', ' . $volume_capacity . ', ' . $volume_use . ')';
      break;
    case 'task':
      $id = db_quote($data['id']);
      $name = db_quote($data['name']);
      $parent_id = db_quote($data['parent_id']);
      $sql_update = 'UPDATE task SET name = ' . $name . ' WHERE (id = ' . $id . ');';
      break;
    case 'iso':
      $id = db_quote($data['id']);
      $name = db_quote($data['name']);
      $parent_id = db_quote($data['parent_id']);
      $sql_update = 'UPDATE iso SET name = ' . $name . ' WHERE (id = ' . $id . ');';
      break;
  }
  $result = db_write($sql_update);
  if($result === false) {
    $msg = "$timestamp: $app update fail " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
    log_event('error', $msg);
    echo status_fail($msg);
    return false;
  }
  $msg = "$timestamp: $app update success " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
  log_event('access', $msg);
  echo status_success();
  return true;
}
function api_delete($app) { // delete
  $timestamp = time();
  $data = receive_input();
  validate_inputs($data);
  switch ($app) {
    case 'guest':
      $id = db_quote($data['id']);
      $sql_delete = 'CALL delete_guest(' . $id . ')';
      break;
    case 'virtual_router':
      $id = db_quote($data['id']);
      $sql_delete = 'CALL delete_virtual_router(' . $id . ')';
      break;
    case 'hypervisor_server':
      $id = db_quote($data['id']);
      $sql_delete = 'CALL delete_hypervisor_server(' . $id . ')';
      break;
    case 'storage_server':
      $id = db_quote($data['id']);
      $sql_delete = 'CALL delete_storage_server(' . $id . ')';
      break;
  }
  $result = db_write($sql_delete);
  if($result === false) {
    $msg = "$timestamp: $app delete fail " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
    log_event('error', $msg);
    echo status_fail($msg);
    return false;
  }
  $msg = "$timestamp: $app delete success " . $_SERVER['REMOTE_ADDR'] . ' ' . $_SERVER['HTTP_USER_AGENT'] . "\n";
  log_event('access', $msg);
  echo status_success();
  return true;
}
// BUSINESS LOGIC
$application = get_application_headers();
validate_application_headers($application);
logs_init($application);
switch ($_SERVER['REQUEST_METHOD']) {
  case 'GET':		api_read($application);		break;
  case 'POST':		api_create($application);	break;
  case 'PUT':		api_update($application);	break;
  case 'DELETE':	api_delete($application);	break;
}
?>
