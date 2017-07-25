<?php
function application__determine_create_query($data) { // dynamically select the sql query
  // convert flag inputs to boolean
  if (isset($data['template_flag'])) { $template_flag = translate_boolean($data['template_flag']); }
  if (isset($data['data_disk_flag'])) { $data_disk_flag = translate_boolean($data['data_disk_flag']); }
  if (isset($data['cow_flag'])) { $cow_flag = translate_boolean($data['cow_flag']); }
  if (isset($data['os_disk_flag'])) { $os_disk_flag = translate_boolean($data['os_disk_flag']); }
  // sanitize sql inputs
  $name = db_quote($data['name']);
  $ram = db_quote($data['ram']);
  $lab = db_quote($data['lab']);
  // determine which query to return
  if ($template_flag === true) {
    if ($data_disk_flag === true) {
      if ($cow_flag === true) {			// template cow data
        $template = $data['template'];
        $data_capacity = $data['data_capacity'];
        $sql = "CALL create_guest__template_cow_data($name, $ram, $lab, $template, true, $data_capacity, @a);";
      } elseif ($cow_flag === false) {		// template data
        $template = $data['template'];
        $data_capacity = $data['data_capacity'];
        $sql = "CALL create_guest__template_cow_data($name, $ram, $lab, $template, false, $data_capacity, @a);";
      } else {
      #error on cow_flag
      }
    } elseif ($data_disk_flag === false) {
      if ($cow_flag === true) {			// template cow
        $template = $data['template'];
        $sql = "CALL create_guest__template_cow($name, $ram, $lab, $template, true, @a);";
      } elseif ($cow_flag === false) {		// template
        $template = $data['template'];
        $sql = "CALL create_guest__template_cow($name, $ram, $lab, $template, false, @a);";
      } else {
      #error on cow_flag
      }
    } else {
    #error on data_disk_flag
    }
  } elseif ($template_flag === false) {
    if ($data_disk_flag === true) {
      if ($os_disk_flag === true) {		// iso os data
        $iso = $data['iso'];
        $os_capacity = $data['os_capacity'];
        $data_capacity = $data['data_capacity'];
        $sql = "CALL create_guest__iso_os_data($name, $ram, $lab, $iso, $os_capacity, $data_capacity, @a);";
      } else {					// iso data
        $iso = $data['iso'];
        $data_capacity = $data['data_capacity'];
        $sql = "CALL create_guest__iso_data($name, $ram, $lab, $iso, $data_capacity, @a);";
      }
    } elseif ($data_disk_flag === false) {
      if ($os_disk_flag === true) {		// iso os
        $iso = $data['iso'];
        $os_capacity = $data['os_capacity'];
        $sql = "CALL create_guest__iso_os($name, $ram, $lab, $iso, $os_capacity, @a);";
      } elseif ($os_disk_flag === false) {	// iso
        $iso = $data['iso'];
        $sql = "CALL create_guest__iso($name, $ram, $lab, $iso, @a);";
      } else {
      # error on os_disk_flag
      }
    } else {
    #error on data_disk_flag
    }
  } else {					// error
  # error on template_flag
    $msg = 'invalid form data';
    log_event('error', $msg);
    echo status_fail($msg);
    exit;
  }
  return $sql;
}
?>
