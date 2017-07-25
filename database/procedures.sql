--------------------------------
-- GUEST
--------------------------------
-- procedure to get an iso's default boot device if not the default setting
DELIMITER //
CREATE PROCEDURE get_iso_boot_device_id(IN iso_id BIGINT, OUT boot_device_id_out TINYINT)
BEGIN
    DECLARE setting, current TINYINT;
    SELECT guest_default_boot_device_id FROM settings LIMIT 1 INTO setting;
    SELECT boot_device_id FROM iso WHERE id = iso_id INTO current;
    SELECT IF(current > 0, current, setting) into setting;
    SELECT setting INTO boot_device_id_out;
END //
DELIMITER ;
-- procedure to get an iso's default nic driver if not the default setting
DELIMITER //
CREATE PROCEDURE get_iso_nic_driver_id(IN guest_id BIGINT, OUT nic_driver_id_out TINYINT)
BEGIN
    DECLARE setting, current TINYINT;
    SELECT guest_default_nic_driver_id FROM settings LIMIT 1 INTO setting;
    SELECT iso.nic_driver_id FROM iso INNER JOIN guest_iso WHERE guest_iso.iso_id = iso.id AND guest_iso.guest_id = guest_id INTO current;
    SELECT IF(current > 0, current, setting) into setting;
    SELECT setting INTO nic_driver_id_out;
END //
DELIMITER ;
-- create, iso os data
DELIMITER //
CREATE PROCEDURE create_guest__iso_os_data(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN iso_id BIGINT, IN os_disk_capacity FLOAT, IN data_disk_capacity FLOAT, OUT next_id BIGINT)
  BEGIN
    -- read the default settings for guest creation
    SELECT create_guest_from_iso_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_iso_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, iso_id);
    -- os disk
    INSERT INTO vdisk (capacity, primary_flag) VALUES (os_disk_capacity, true);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- data disk
    INSERT INTO vdisk (capacity) VALUES (data_disk_capacity);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- create, iso os
DELIMITER //
CREATE PROCEDURE create_guest__iso_os(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN iso_id BIGINT, IN os_disk_capacity FLOAT, OUT next_id BIGINT)
  BEGIN
    -- read the default settings for guest creation
    SELECT create_guest_from_iso_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_iso_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, iso_id);
    -- os disk
    INSERT INTO vdisk (capacity, primary_flag) VALUES (os_disk_capacity, true);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- create, iso data
DELIMITER //
CREATE PROCEDURE create_guest__iso_data(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN iso_id BIGINT, IN data_disk_capacity FLOAT, OUT next_id BIGINT)
  BEGIN
    -- read the default settings for guest creation
    SELECT create_guest_from_iso_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_iso_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, iso_id);
    -- data disk
    INSERT INTO vdisk (capacity) VALUES (data_disk_capacity);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- create, iso
DELIMITER //
CREATE PROCEDURE create_guest__iso(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN iso_id BIGINT, OUT next_id BIGINT)
  BEGIN
    -- read the default settings for guest creation
    SELECT create_guest_from_iso_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_iso_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, iso_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- create, template cow data
--   template data, uses template cow data procedure, pass in false as cow_flag_in
DELIMITER //
CREATE PROCEDURE create_guest__template_cow_data(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN template_id_in BIGINT, IN cow_flag_in BOOLEAN, IN data_disk_capacity FLOAT, OUT next_id BIGINT)
  BEGIN
    -- determine iso id by template id
    SELECT iso.id FROM iso INNER JOIN template WHERE (iso.id = template.iso_id) AND template.id = template_id_in INTO @iso_id;
    -- determine vdisk capacity, vdisk used by template id
    SELECT vdisk.capacity FROM vdisk INNER JOIN template WHERE (vdisk.id = template.vdisk_id) AND template.id = template_id_in INTO @os_capacity;
    SELECT vdisk.used FROM vdisk INNER JOIN template WHERE (vdisk.id = template.vdisk_id) AND template.id = template_id_in INTO @os_used;
    -- read the default settings for guest creation
    SELECT create_guest_from_template_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_template_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(@iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, @iso_id);
    -- template
    INSERT INTO guest_template (guest_id, template_id) VALUES (@guest_id, template_id_in);
    -- os disk
    INSERT INTO vdisk (capacity, used, primary_flag, cow_flag) VALUES (@os_capacity, @os_used, true, cow_flag_in);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- data disk
    INSERT INTO vdisk (capacity, primary_flag) VALUES (data_disk_capacity, false);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- create, template cow
--   template, uses template cow procedure, pass in false as cow_flag_in
DELIMITER //
CREATE PROCEDURE create_guest__template_cow(IN guest_name VARCHAR(24), IN guest_ram VARCHAR(24), IN virtual_router_id BIGINT, IN template_id_in BIGINT, IN cow_flag_in BOOLEAN, OUT next_id BIGINT)
  BEGIN
    -- determine iso id by template id
    SELECT iso.id FROM iso INNER JOIN template WHERE (iso.id = template.iso_id) AND template.id = template_id_in INTO @iso_id;
    -- determine vdisk capacity, vdisk used by template id
    SELECT vdisk.capacity FROM vdisk INNER JOIN template WHERE (vdisk.id = template.vdisk_id) AND template.id = template_id_in INTO @os_capacity;
    SELECT vdisk.used FROM vdisk INNER JOIN template WHERE (vdisk.id = template.vdisk_id) AND template.id = template_id_in INTO @os_used;
    -- read the default settings for guest creation
    SELECT create_guest_from_template_default_machine_state_id FROM settings INTO @machine_state_id;
    SELECT create_guest_from_template_default_machine_substate_id FROM settings INTO @machine_substate_id;
    CALL get_iso_boot_device_id(@iso_id, @boot_device_id);
    -- guest
    INSERT INTO guest (name, ram_capacity, machine_state_id, machine_substate_id, boot_device_id) VALUES (guest_name, guest_ram, @machine_state_id, @machine_substate_id, @boot_device_id);
    SELECT LAST_INSERT_ID() INTO @guest_id;
    -- lab
    INSERT INTO guest_virtual_router (guest_id, virtual_router_id) VALUES (@guest_id, virtual_router_id);
    -- iso
    INSERT INTO guest_iso (guest_id, iso_id) VALUES (@guest_id, @iso_id);
    -- template
    INSERT INTO guest_template (guest_id, template_id) VALUES (@guest_id, template_id_in);
    -- os disk
    INSERT INTO vdisk (capacity, used, primary_flag, cow_flag) VALUES (@os_capacity, @os_used, true, cow_flag_in);
    SELECT LAST_INSERT_ID() INTO @vdisk_id;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (@guest_id, @vdisk_id);
    -- nic
    CALL get_iso_nic_driver_id(@guest_id, @nic_driver_id);
    CALL create_nic(@nic_driver_id, @nic_id);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (@guest_id, @nic_id);
    -- output
    SELECT @guest_id INTO next_id;
  END //
DELIMITER ;
-- read, one
DELIMITER //
CREATE PROCEDURE read_guest__one(
  IN guest_id_in BIGINT, 
  OUT name VARCHAR, 
  OUT state VARCHAR, 
  OUT substate VARCHAR, 
  OUT cpu_capacity FLOAT, 
  OUT cpu_use FLOAT, 
  OUT ram_capacity VARCHAR, 
  OUT ram_use FLOAT, 
  OUT access_port BIGINT, 
  OUT boot_device_id TINYINT, 
  OUT boot_device_name VARCHAR, 
  OUT nic_count_out BIGINT, 
  OUT nic_id_out BIGINT, 
  OUT ip_address_id_out BIGINT, 
  OUT ip_address_out VARCHAR(16), 
  OUT mac_address_id_out BIGINT, 
  OUT mac_address_out VARCHAR(24), 
  OUT vswitch_port_id_out BIGINT, 
  OUT vswitch_port_out SMALLINT, 
  OUT vlan_tag_id_out BIGINT, 
  OUT vlan_tag_out SMALLINT, 
  OUT nic_driver_id_out TINYINT, 
  OUT nic_driver_out VARCHAR(16), 
  OUT vdisk_count_out BIGINT,
  OUT vdisk_id_out BIGINT,
  OUT vdisk_capacity_out FLOAT,
  OUT vdisk_used_out FLOAT,
  OUT vdisk_primary_flag_out BOOLEAN,
  OUT vdisk_cow_flag_out BOOLEAN,
  OUT  ,
  OUT 
)
  BEGIN
    -- guest
    SELECT guest.name FROM guest WHERE guest.id = guest_id INTO name;
    SELECT machine_state.state FROM guest INNER JOIN machine_state WHERE (guest.machine_state_id = machine_state.id) AND guest.id = guest_id_in INTO state;
    SELECT machine_substate.state FROM guest INNER JOIN machine_substate WHERE (guest.machine_substate_id = machine_substate.id) AND guest.id = guest_id_in INTO substate;
    SELECT guest.cpu_capacity FROM guest WHERE guest.id = guest_id INTO cpu_capacity;
    SELECT guest.cpu_use FROM guest WHERE guest.id = guest_id INTO cpu_use;
    SELECT guest.ram_capacity FROM guest WHERE guest.id = guest_id INTO ram_capacity;
    SELECT guest.ram_use FROM guest WHERE guest.id = guest_id INTO ram_use;
    SELECT guest.access_port_pool_id FROM guest WHERE guest.id = guest_id INTO access_port;
    SELECT boot_device.id, boot_device.name FROM guest INNER JOIN boot_device WHERE (guest.boot_device_id = boot_device.id) AND guest.id = guest_id INTO boot_device_id, boot_device_name;
    -- nic
    CALL read_nic__first(guest_id_in, nic_count_out, nic_id_out, ip_address_id_out, ip_address_out, mac_address_id_out, mac_address_out, vswitch_port_id_out, vswitch_port_out, vlan_tag_id_out, vlan_tag_out, nic_driver_id_out, nic_driver_out);
    -- vdisk
    CALL read_vdisk__first(guest_id_in, vdisk_count_out, vdisk_id_out, vdisk_capacity_out, vdisk_used_out, vdisk_primary_flag_out, vdisk_cow_flag_out);
    -- snapshot
    -- iso
    SELECT name FROM iso INNER JOIN guest_iso WHERE (guest_iso.iso_id = iso.id AND guest_id = guest_id_in) INTO iso_name;
    --SELECT name, boot_device_id, nic_driver_id FROM iso INNER JOIN guest_iso WHERE (guest_iso.iso_id = iso.id AND guest_id = 48); -- full table read.
    -- template ???
    SELECT template.name AS tepmlate_name, template.iso_id, template.vdisk_id, iso.name AS iso_name  FROM template INNER JOIN guest_template ON guest_template.template_id = template.id  INNER JOIN iso ON iso.id = template.iso_id AND guest_template.guest_id = guest_id_in;
    --SELECT template.name AS tepmlate_name, template.iso_id, template.vdisk_id, iso.name AS iso_name  FROM template INNER JOIN guest_template ON guest_template.template_id = template.id  INNER JOIN iso ON iso.id = template.iso_id AND guest_template.guest_id = guest_id_in; -- full table read.
    -- ?virtual_router
    -- hypervisor_server
    -- storage_server
  END //
DELIMITER ;
-- read, one
  --  COUNT(*) as nic_count,
DELIMITER //
CREATE PROCEDURE read_guest__one(
  IN guest_id_in BIGINT, 
  OUT name VARCHAR, 
  OUT state VARCHAR, 
  OUT substate VARCHAR, 
  OUT cpu_capacity FLOAT, 
  OUT cpu_use FLOAT, 
  OUT ram_capacity VARCHAR, 
  OUT ram_use FLOAT, 
  OUT access_port BIGINT, 
  OUT boot_device_id TINYINT, 
  OUT boot_device_name VARCHAR, 
  OUT nic_count_out BIGINT, 
  OUT nic_id_out BIGINT, 
  OUT ip_address_id_out BIGINT, 
  OUT ip_address_out VARCHAR(16), 
  OUT mac_address_id_out BIGINT, 
  OUT mac_address_out VARCHAR(24), 
  OUT vswitch_port_id_out BIGINT, 
  OUT vswitch_port_out SMALLINT, 
  OUT vlan_tag_id_out BIGINT, 
  OUT vlan_tag_out SMALLINT, 
  OUT nic_driver_id_out TINYINT, 
  OUT nic_driver_out VARCHAR(16), 
  OUT vdisk_count_out BIGINT,
  OUT vdisk_id_out BIGINT,
  OUT vdisk_capacity_out FLOAT,
  OUT vdisk_used_out FLOAT,
  OUT vdisk_primary_flag_out BOOLEAN,
  OUT vdisk_cow_flag_out BOOLEAN,
  OUT  ,
  OUT 
)
  BEGIN
    SELECT guest.name FROM guest WHERE guest.id = guest_id_in INTO name;
    SELECT machine_state.state FROM guest INNER JOIN machine_state WHERE (guest.machine_state_id = machine_state.id) 
      AND guest.id = guest_id_in INTO state;
    SELECT machine_substate.state FROM guest INNER JOIN machine_substate WHERE (guest.machine_substate_id = machine_substate.id) 
      AND guest.id = guest_id_in INTO substate;
    SELECT guest.cpu_capacity FROM guest WHERE guest.id = guest_id_in INTO cpu_capacity;
    SELECT guest.cpu_use FROM guest WHERE guest.id = guest_id_in INTO cpu_use;
    SELECT guest.ram_capacity FROM guest WHERE guest.id = guest_id_in INTO ram_capacity;
    SELECT guest.ram_use FROM guest WHERE guest.id = guest_id_in INTO ram_use;
    -- nic
    CALL read_nic__first(guest_id_in, nic_count_out, nic_id_out, ip_address_id_out, ip_address_out, mac_address_id_out, mac_address_out, vswitch_port_id_out, 
      vswitch_port_out, vlan_tag_id_out, vlan_tag_out, nic_driver_id_out, nic_driver_out);
    -- disk
    SELECT disk.id, disk.capacity, disk.used INTO disk_id_out, disk_capacity_out, disk_used_out FROM disk INNER JOIN guest_disk ON guest_disk.disk_id = disk.id 
      AND hypervisor_server_disk.hypervisor_server_id = hypervisor_server_id_in;
  END //
DELIMITER ;
-- read, all
DELIMITER //
CREATE PROCEDURE read_guest__all()
  BEGIN
    SELECT 
      guest.id, 
      guest.name, 
      machine_state.state, 
      machine_substate.state as substate, 
      guest.cpu_capacity, 
      guest.cpu_use, 
      guest.ram_capacity, 
      guest.ram_use, 
      nic.id as nic_id, 
      nic.ip_address_pool_id,
      ip_address_pool.name as ip_address,
      nic.mac_address_pool_id,
      mac_address_pool.name as mac_address,
      nic.vswitch_port_pool_id,
      vswitch_port_pool.name as vswitch_port,
      nic.vlan_tag_pool_id,
      vlan_tag_pool.name as vlan_tag,
      nic.nic_driver_id,
      nic_driver.name as nic_driver,
      vdisk.id as vdisk_id,
      vdisk.capacity as vdisk_capacity,
      vdisk.used as vdisk_used,
      vdisk.primary_flag as vdisk_primary_flag,
      vdisk.cow_flag as vdisk_cow_flag
    FROM guest_nic 
      INNER JOIN nic ON guest_nic.nic_id = nic.id 
      INNER JOIN ip_address_pool ON ip_address_pool.id = nic.ip_address_pool_id
      INNER JOIN mac_address_pool ON mac_address_pool.id = nic.mac_address_pool_id
      INNER JOIN vswitch_port_pool ON vswitch_port_pool.id = nic.vswitch_port_pool_id
      INNER JOIN vlan_tag_pool ON vlan_tag_pool.id = nic.vlan_tag_pool_id
      INNER JOIN nic_driver ON nic_driver.id = nic.nic_driver_id
      INNER JOIN guest_vdisk ON guest_vdisk.guest_id = guest_nic.guest_id 
      INNER JOIN vdisk ON vdisk.id = guest_vdisk.vdisk_id
      INNER JOIN guest ON guest.id = guest_vdisk.guest_id
      INNER JOIN machine_state ON machine_state.id = guest.machine_state_id
      INNER JOIN machine_substate ON machine_substate.id = guest.machine_substate_id
    ;
  END //
DELIMITER ;
-- delete
DELIMITER //
CREATE PROCEDURE delete_guest(
  IN guest_id_in BIGINT
)
  BEGIN
    DECLARE disk_id_val, nic_id_val BIGINT;
    SELECT guest_disk.disk_id INTO disk_id_val FROM guest_disk INNER JOIN disk ON guest_disk.disk_id = disk.id AND guest_id = 5;
    SELECT guest_nic.nic_id INTO nic_id_val FROM guest_nic INNER JOIN nic ON guest_nic.nic_id = nic.id AND guest_id = 5;
    DELETE FROM disk WHERE id = disk_id_val;
    DELETE FROM guest_disk WHERE guest_id = guest_id_in;
    DELETE FROM nic WHERE id = nic_id_val;
    DELETE FROM guest_nic WHERE guest_id = guest_id_in;
    DELETE FROM guest WHERE id = guest_id_in;
  END //
DELIMITER ;

--------------------------------
-- VIRTUAL ROUTER
--------------------------------

--------------------------------
-- HYPERVISOR SERVER
--------------------------------
-- create
DELIMITER //
CREATE PROCEDURE create_hypervisor_server(
  IN name_in VARCHAR(64), 
  OUT hypervisor_server_id_val BIGINT
)
  BEGIN
    DECLARE machine_state_id_val, machine_substate_id_val, storage_server_id_val, disk_id_val, nic_id_val BIGINT;
    DECLARE nic_driver_id_val TINYINT;
    -- read the default settings for hypervisor_server creation
    SELECT create_physical_default_machine_state_id FROM settings INTO machine_state_id_val;
    SELECT create_physical_default_machine_substate_id FROM settings INTO machine_substate_id_val;
    SELECT physical_default_nic_driver_id FROM settings INTO nic_driver_id_val;
    -- hypervisor_server
    INSERT INTO hypervisor_server (name, machine_state_id, machine_substate_id) VALUES (name_in, machine_state_id_val, machine_substate_id_val);
    SELECT LAST_INSERT_ID() INTO hypervisor_server_id_val;
    -- disk
    INSERT INTO disk (capacity) VALUES (0);
    SELECT LAST_INSERT_ID() INTO disk_id_val;
    INSERT INTO hypervisor_server_disk (hypervisor_server_id, disk_id) VALUES (hypervisor_server_id_val, disk_id_val);
    -- nic
    CALL create_nic(nic_driver_id_val, nic_id_val);
    INSERT INTO hypervisor_server_nic (hypervisor_server_id, nic_id) VALUES (hypervisor_server_id_val, nic_id_val);
  END //
DELIMITER ;
-- read, one
  --  COUNT(*) as nic_count,
DELIMITER //
CREATE PROCEDURE read_hypervisor_server__one(
  IN hypervisor_server_id_in BIGINT,
  OUT name VARCHAR(64),
  OUT state VARCHAR(16),
  OUT substate VARCHAR(16),
  OUT cpu_capacity FLOAT,
  OUT cpu_use FLOAT,
  OUT ram_capacity FLOAT,
  OUT ram_use FLOAT,
  OUT nic_count_out BIGINT, 
  OUT nic_id_out BIGINT, 
  OUT ip_address_id_out BIGINT, 
  OUT ip_address_out VARCHAR(16), 
  OUT mac_address_id_out BIGINT, 
  OUT mac_address_out VARCHAR(24), 
  OUT vswitch_port_id_out BIGINT, 
  OUT vswitch_port_out SMALLINT, 
  OUT vlan_tag_id_out BIGINT, 
  OUT vlan_tag_out SMALLINT, 
  OUT nic_driver_id_out TINYINT, 
  OUT nic_driver_out VARCHAR(16),
  OUT disk_id_out BIGINT,
  OUT disk_capacity_out FLOAT,
  OUT disk_used_out FLOAT
)
  BEGIN
    SELECT hypervisor_server.name FROM hypervisor_server WHERE hypervisor_server.id = hypervisor_server_id_in INTO name;
    SELECT machine_state.state FROM hypervisor_server INNER JOIN machine_state WHERE (hypervisor_server.machine_state_id = machine_state.id) 
      AND hypervisor_server.id = hypervisor_server_id_in INTO state;
    SELECT machine_substate.state FROM hypervisor_server INNER JOIN machine_substate WHERE (hypervisor_server.machine_substate_id = machine_substate.id) 
      AND hypervisor_server.id = hypervisor_server_id_in INTO substate;
    SELECT hypervisor_server.cpu_capacity FROM hypervisor_server WHERE hypervisor_server.id = hypervisor_server_id_in INTO cpu_capacity;
    SELECT hypervisor_server.cpu_use FROM hypervisor_server WHERE hypervisor_server.id = hypervisor_server_id_in INTO cpu_use;
    SELECT hypervisor_server.ram_capacity FROM hypervisor_server WHERE hypervisor_server.id = hypervisor_server_id_in INTO ram_capacity;
    SELECT hypervisor_server.ram_use FROM hypervisor_server WHERE hypervisor_server.id = hypervisor_server_id_in INTO ram_use;
    -- nic
    CALL read_nic__first(hypervisor_server_id_in, nic_count_out, nic_id_out, ip_address_id_out, ip_address_out, mac_address_id_out, mac_address_out, vswitch_port_id_out, 
      vswitch_port_out, vlan_tag_id_out, vlan_tag_out, nic_driver_id_out, nic_driver_out);
    -- disk
    SELECT disk.id, disk.capacity, disk.used INTO disk_id_out, disk_capacity_out, disk_used_out FROM disk INNER JOIN hypervisor_server_disk ON hypervisor_server_disk.disk_id = disk.id 
      AND hypervisor_server_disk.hypervisor_server_id = hypervisor_server_id_in;
  END //
DELIMITER ;
-- read, all
DELIMITER //
CREATE PROCEDURE read_hypervisor_server__all()
  BEGIN
    SELECT 
      hypervisor_server.id, 
      hypervisor_server.name, 
      machine_state.state, 
      machine_substate.state as substate, 
      hypervisor_server.cpu_capacity, 
      hypervisor_server.cpu_use, 
      hypervisor_server.ram_capacity, 
      hypervisor_server.ram_use, 
      disk.id as disk_id,
      disk.capacity as disk_capacity,
      disk.used as disk_used,
      nic.id as nic_id, 
      nic.ip_address_pool_id,
      ip_address_pool.name as ip_address,
      nic.mac_address_pool_id,
      mac_address_pool.name as mac_address,
      nic.vswitch_port_pool_id,
      vswitch_port_pool.name as vswitch_port,
      nic.vlan_tag_pool_id,
      vlan_tag_pool.name as vlan_tag,
      nic.nic_driver_id,
      nic_driver.name as nic_driver
    FROM hypervisor_server_nic 
      INNER JOIN nic ON hypervisor_server_nic.nic_id = nic.id 
      INNER JOIN ip_address_pool ON ip_address_pool.id = nic.ip_address_pool_id
      INNER JOIN mac_address_pool ON mac_address_pool.id = nic.mac_address_pool_id
      INNER JOIN vswitch_port_pool ON vswitch_port_pool.id = nic.vswitch_port_pool_id
      INNER JOIN vlan_tag_pool ON vlan_tag_pool.id = nic.vlan_tag_pool_id
      INNER JOIN nic_driver ON nic_driver.id = nic.nic_driver_id
      INNER JOIN hypervisor_server_disk ON hypervisor_server_disk.hypervisor_server_id = hypervisor_server_nic.hypervisor_server_id 
      INNER JOIN disk ON disk.id = hypervisor_server_disk.disk_id
      INNER JOIN hypervisor_server ON hypervisor_server.id = hypervisor_server_disk.hypervisor_server_id
      INNER JOIN machine_state ON machine_state.id = hypervisor_server.machine_state_id
      INNER JOIN machine_substate ON machine_substate.id = hypervisor_server.machine_substate_id
    ;
  END //
DELIMITER ;
-- update, agent interface
DELIMITER //
CREATE PROCEDURE update_hypervisor_server__agent(
  IN id_in BIGINT,
  IN cpu_capacity_in FLOAT,
  IN cpu_use_in FLOAT,
  IN ram_capacity_in FLOAT,
  IN ram_use_in FLOAT,
  IN disk_capacity_in FLOAT,
  IN disk_used_in FLOAT
)
  BEGIN
    DECLARE disk_id_val BIGINT;
    SELECT disk.id INTO disk_id_val FROM disk 
    INNER JOIN hypervisor_server_disk ON hypervisor_server_disk.disk_id = disk.id 
    INNER JOIN hypervisor_server ON hypervisor_server_disk.hypervisor_server_id = hypervisor_server.id 
    AND hypervisor_server.id = id_in;
    UPDATE disk SET disk.capacity = disk_capacity_in, disk.used = disk_used_in WHERE disk.id = disk_id_val;
    UPDATE hypervisor_server SET cpu_capacity = cpu_capacity_in, cpu_use = cpu_use_in, ram_capacity = ram_capacity_in, ram_use = ram_use_in WHERE id = id_in;
  END //
DELIMITER ;
-- delete
DELIMITER //
CREATE PROCEDURE delete_hypervisor_server(
  IN hypervisor_server_id_in BIGINT
)
  BEGIN
    DECLARE disk_id_val, nic_id_val BIGINT;
    SELECT hypervisor_server_disk.disk_id INTO disk_id_val FROM hypervisor_server_disk INNER JOIN disk ON hypervisor_server_disk.disk_id = disk.id AND hypervisor_server_id = 5;
    SELECT hypervisor_server_nic.nic_id INTO nic_id_val FROM hypervisor_server_nic INNER JOIN nic ON hypervisor_server_nic.nic_id = nic.id AND hypervisor_server_id = 5;
    DELETE FROM disk WHERE id = disk_id_val;
    DELETE FROM hypervisor_server_disk WHERE hypervisor_server_id = hypervisor_server_id_in;
    DELETE FROM nic WHERE id = nic_id_val;
    DELETE FROM hypervisor_server_nic WHERE hypervisor_server_id = hypervisor_server_id_in;
    DELETE FROM hypervisor_server WHERE id = hypervisor_server_id_in;
  END //
DELIMITER ;

--------------------------------
-- STORAGE SERVER
--------------------------------
-- create
DELIMITER //
CREATE PROCEDURE create_storage_server(
  IN name_in VARCHAR(64), 
  OUT storage_server_id_val BIGINT
)
  BEGIN
    DECLARE machine_state_id_val, machine_substate_id_val, storage_server_id_val, disk_id_val, nic_id_val BIGINT;
    DECLARE nic_driver_id_val TINYINT;
    -- read the default settings for storage_server creation
    SELECT create_physical_default_machine_state_id FROM settings INTO machine_state_id_val;
    SELECT create_physical_default_machine_substate_id FROM settings INTO machine_substate_id_val;
    SELECT physical_default_nic_driver_id FROM settings INTO nic_driver_id_val;
    -- storage_server
    INSERT INTO storage_server (name, machine_state_id, machine_substate_id) VALUES (name_in, machine_state_id_val, machine_substate_id_val);
    SELECT LAST_INSERT_ID() INTO storage_server_id_val;
    -- disk
    INSERT INTO disk (capacity) VALUES (0);
    SELECT LAST_INSERT_ID() INTO disk_id_val;
    INSERT INTO storage_server_disk (storage_server_id, disk_id) VALUES (storage_server_id_val, disk_id_val);
    -- nic
    CALL create_nic(nic_driver_id_val, nic_id_val);
    INSERT INTO storage_server_nic (storage_server_id, nic_id) VALUES (storage_server_id_val, nic_id_val);
  END //
DELIMITER ;
-- read, one
  --  COUNT(*) as nic_count,
DELIMITER //
CREATE PROCEDURE read_storage_server__one(
  IN storage_server_id_in BIGINT,
  OUT name VARCHAR(64),
  OUT state VARCHAR(16),
  OUT substate VARCHAR(16),
  OUT cpu_capacity FLOAT,
  OUT cpu_use FLOAT,
  OUT ram_capacity FLOAT,
  OUT ram_use FLOAT,
  OUT volume_capacity FLOAT,
  OUT volume_use FLOAT,
  OUT nic_count_out BIGINT, 
  OUT nic_id_out BIGINT, 
  OUT ip_address_id_out BIGINT, 
  OUT ip_address_out VARCHAR(16), 
  OUT mac_address_id_out BIGINT, 
  OUT mac_address_out VARCHAR(24), 
  OUT vswitch_port_id_out BIGINT, 
  OUT vswitch_port_out SMALLINT, 
  OUT vlan_tag_id_out BIGINT, 
  OUT vlan_tag_out SMALLINT, 
  OUT nic_driver_id_out TINYINT, 
  OUT nic_driver_out VARCHAR(16),
  OUT disk_id_out BIGINT,
  OUT disk_capacity_out FLOAT,
  OUT disk_used_out FLOAT
)
  BEGIN
    SELECT storage_server.name FROM storage_server WHERE storage_server.id = storage_server_id_in INTO name;
    SELECT machine_state.state FROM storage_server INNER JOIN machine_state WHERE (storage_server.machine_state_id = machine_state.id) 
      AND storage_server.id = storage_server_id_in INTO state;
    SELECT machine_substate.state FROM storage_server INNER JOIN machine_substate WHERE (storage_server.machine_substate_id = machine_substate.id) 
      AND storage_server.id = storage_server_id_in INTO substate;
    SELECT storage_server.cpu_capacity FROM storage_server WHERE storage_server.id = storage_server_id_in INTO cpu_capacity;
    SELECT storage_server.cpu_use FROM storage_server WHERE storage_server.id = storage_server_id_in INTO cpu_use;
    SELECT storage_server.ram_capacity FROM storage_server WHERE storage_server.id = storage_server_id_in INTO ram_capacity;
    SELECT storage_server.ram_use FROM storage_server WHERE storage_server.id = storage_server_id_in INTO ram_use;
    SELECT storage_server.volume_capacity FROM storage_server WHERE storage_server.id = storage_server_id_in INTO volume_capacity;
    SELECT storage_server.volume_use FROM storage_server WHERE storage_server.id = storage_server_id_in INTO volume_use;
    -- nic
    CALL read_nic__first(storage_server_id_in, nic_count_out, nic_id_out, ip_address_id_out, ip_address_out, mac_address_id_out, mac_address_out, vswitch_port_id_out, 
      vswitch_port_out, vlan_tag_id_out, vlan_tag_out, nic_driver_id_out, nic_driver_out);
    -- disk
    SELECT disk.id, disk.capacity, disk.used INTO disk_id_out, disk_capacity_out, disk_used_out FROM disk INNER JOIN storage_server_disk ON storage_server_disk.disk_id = disk.id 
      AND storage_server_disk.storage_server_id = storage_server_id_in;
  END //
DELIMITER ;
-- read, all
DELIMITER //
CREATE PROCEDURE read_storage_server__all()
  BEGIN
    SELECT 
      storage_server.id, 
      storage_server.name, 
      machine_state.state, 
      machine_substate.state as substate, 
      storage_server.cpu_capacity, 
      storage_server.cpu_use, 
      storage_server.ram_capacity, 
      storage_server.ram_use, 
      disk.id as disk_id,
      disk.capacity as disk_capacity,
      disk.used as disk_used,
      storage_server.volume_capacity, 
      storage_server.volume_use,
      nic.id as nic_id, 
      nic.ip_address_pool_id,
      ip_address_pool.name as ip_address,
      nic.mac_address_pool_id,
      mac_address_pool.name as mac_address,
      nic.vswitch_port_pool_id,
      vswitch_port_pool.name as vswitch_port,
      nic.vlan_tag_pool_id,
      vlan_tag_pool.name as vlan_tag,
      nic.nic_driver_id,
      nic_driver.name as nic_driver
    FROM storage_server_nic 
      INNER JOIN nic ON storage_server_nic.nic_id = nic.id 
      INNER JOIN ip_address_pool ON ip_address_pool.id = nic.ip_address_pool_id
      INNER JOIN mac_address_pool ON mac_address_pool.id = nic.mac_address_pool_id
      INNER JOIN vswitch_port_pool ON vswitch_port_pool.id = nic.vswitch_port_pool_id
      INNER JOIN vlan_tag_pool ON vlan_tag_pool.id = nic.vlan_tag_pool_id
      INNER JOIN nic_driver ON nic_driver.id = nic.nic_driver_id
      INNER JOIN storage_server_disk ON storage_server_disk.storage_server_id = storage_server_nic.storage_server_id 
      INNER JOIN disk ON disk.id = storage_server_disk.disk_id
      INNER JOIN storage_server ON storage_server.id = storage_server_disk.storage_server_id
      INNER JOIN machine_state ON machine_state.id = storage_server.machine_state_id
      INNER JOIN machine_substate ON machine_substate.id = storage_server.machine_substate_id
    ;
  END //
DELIMITER ;
-- update, agent interface
DELIMITER //
CREATE PROCEDURE update_storage_server__agent(
  IN id_in BIGINT,
  IN cpu_capacity_in FLOAT,
  IN cpu_use_in FLOAT,
  IN ram_capacity_in FLOAT,
  IN ram_use_in FLOAT,
  IN disk_capacity_in FLOAT,
  IN disk_used_in FLOAT,
  IN volume_capacity_in FLOAT,
  IN volume_use_in FLOAT
)
  BEGIN
    DECLARE disk_id_val BIGINT;
    SELECT disk.id INTO disk_id_val FROM disk 
    INNER JOIN storage_server_disk ON storage_server_disk.disk_id = disk.id 
    INNER JOIN storage_server ON storage_server_disk.storage_server_id = storage_server.id 
    AND storage_server.id = id_in;
    UPDATE disk SET disk.capacity = disk_capacity_in, disk.used = disk_used_in WHERE disk.id = disk_id_val;
    UPDATE storage_server SET cpu_capacity = cpu_capacity_in, cpu_use = cpu_use_in, ram_capacity = ram_capacity_in, ram_use = ram_use_in, volume_capacity = volume_capacity_in, volume_use = volume_use_in WHERE id = id_in;
  END //
DELIMITER ;
-- delete
DELIMITER //
CREATE PROCEDURE delete_storage_server(
  IN storage_server_id_in BIGINT
)
  BEGIN
    DECLARE disk_id_val, nic_id_val BIGINT;
    SELECT storage_server_disk.disk_id INTO disk_id_val FROM storage_server_disk INNER JOIN disk ON storage_server_disk.disk_id = disk.id AND storage_server_id = 5;
    SELECT storage_server_nic.nic_id INTO nic_id_val FROM storage_server_nic INNER JOIN nic ON storage_server_nic.nic_id = nic.id AND storage_server_id = 5;
    DELETE FROM disk WHERE id = disk_id_val;
    DELETE FROM storage_server_disk WHERE storage_server_id = storage_server_id_in;
    DELETE FROM nic WHERE id = nic_id_val;
    DELETE FROM storage_server_nic WHERE storage_server_id = storage_server_id_in;
    DELETE FROM storage_server WHERE id = storage_server_id_in;
  END //
DELIMITER ;

--------------------------------
-- NIC
--------------------------------
-- create
DELIMITER //
CREATE PROCEDURE create_nic(IN nic_driver_id TINYINT, OUT next_id BIGINT)
  BEGIN
    SELECT settings.guest_default_vlan_id FROM settings INTO @vlan;
    SELECT nic_driver_id INTO @driver;
    CALL get_ip_address(@ip);
    CALL get_mac_address(@mac);
    CALL get_vswitch_port(@vswitch);
    INSERT INTO nic (nic.ip_address_pool_id, nic.mac_address_pool_id, nic.vswitch_port_pool_id, nic.vlan_tag_pool_id, nic.nic_driver_id) VALUES (@ip, @mac, @vswitch, @vlan, @driver);
    SELECT LAST_INSERT_ID() INTO next_id;
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_nic(IN nic_id_in BIGINT)
  BEGIN
    DECLARE ip_id, mac_id, vswitch_id BIGINT;
    SELECT ip_address_pool_id, mac_address_pool_id, vswitch_port_pool_id INTO ip_id, mac_id, vswitch_id FROM nic WHERE (id = nic_id_in);
    CALL release_ip_address(ip_id);
    CALL release_mac_address(mac_id);
    CALL release_vswitch_port(vswitch_id);
    DELETE FROM nic WHERE (nic.id = nic_id_in);
    DELETE FROM guest_nic WHERE (nic_id = nic_id_in);
  END //
DELIMITER ;
-- add
DELIMITER //
CREATE PROCEDURE add_nic(IN guest_id_in BIGINT)
  BEGIN
    DECLARE driver_id_val TINYINT;
    DECLARE nic_id_val BIGINT;
    SELECT nic.nic_driver_id INTO driver_id_val FROM guest_nic INNER JOIN nic where guest_nic.nic_id = nic.id AND guest_nic.guest_id = guest_id_in LIMIT 1;
    CALL create_nic(driver_id_val, nic_id_val);
    INSERT INTO guest_nic (guest_id, nic_id) VALUES (guest_id_in, nic_id_val);
  END //
DELIMITER ;
-- read, first
DELIMITER //
CREATE PROCEDURE read_nic__first(
  IN guest_id_in BIGINT, 
  OUT nic_count_out BIGINT, 
  OUT nic_id_out BIGINT, 
  OUT ip_address_id_out BIGINT, 
  OUT ip_address_out VARCHAR(16), 
  OUT mac_address_id_out BIGINT, 
  OUT mac_address_out VARCHAR(24), 
  OUT vswitch_port_id_out BIGINT, 
  OUT vswitch_port_out SMALLINT, 
  OUT vlan_tag_id_out BIGINT, 
  OUT vlan_tag_out SMALLINT, 
  OUT nic_driver_id_out TINYINT, 
  OUT nic_driver_out VARCHAR(16)
)
  BEGIN
    SELECT COUNT(*) FROM guest_nic WHERE (guest_id = guest_id_in) INTO nic_count_out;
    SELECT 
      nic.id, 
      nic.ip_address_pool_id, 
      ip_address_pool.name, 
      nic.mac_address_pool_id, 
      mac_address_pool.name, 
      nic.vswitch_port_pool_id, 
      vswitch_port_pool.name, 
      nic.vlan_tag_pool_id, 
      vlan_tag_pool.name, 
      nic.nic_driver_id, 
      nic_driver.name
    INTO 
      nic_id_out,
      ip_address_id_out,
      ip_address_out,
      mac_address_id_out,
      mac_address_out,
      vswitch_port_id_out,
      vswitch_port_out,
      vlan_tag_id_out,
      vlan_tag_out,
      nic_driver_id_out,
      nic_driver_out
    FROM nic 
      INNER JOIN guest_nic ON guest_nic.nic_id = nic.id 
      INNER JOIN nic_driver ON nic_driver.id = nic.nic_driver_id
      INNER JOIN ip_address_pool ON ip_address_pool.id = nic.ip_address_pool_id
      INNER JOIN mac_address_pool ON mac_address_pool.id = nic.mac_address_pool_id
      INNER JOIN vswitch_port_pool ON vswitch_port_pool.id = nic.vswitch_port_pool_id
      INNER JOIN vlan_tag_pool ON vlan_tag_pool.id = nic.vlan_tag_pool_id
    AND guest_nic.guest_id = guest_id_in 
    LIMIT 1;
  END //
DELIMITER ;
-- read, all (all which belong to a machine id)
DELIMITER //
CREATE PROCEDURE read_nic__all(IN guest_id_in BIGINT)
  BEGIN
    SELECT 
      nic.id, 
      nic.ip_address_pool_id, 
      ip_address_pool.name, 
      nic.mac_address_pool_id, 
      mac_address_pool.name, 
      nic.vswitch_port_pool_id, 
      vswitch_port_pool.name, 
      nic.vlan_tag_pool_id, 
      vlan_tag_pool.name, 
      nic.nic_driver_id, 
      nic_driver.name
    FROM nic 
      INNER JOIN guest_nic ON guest_nic.nic_id = nic.id 
      INNER JOIN nic_driver ON nic_driver.id = nic.nic_driver_id
      INNER JOIN ip_address_pool ON ip_address_pool.id = nic.ip_address_pool_id
      INNER JOIN mac_address_pool ON mac_address_pool.id = nic.mac_address_pool_id
      INNER JOIN vswitch_port_pool ON vswitch_port_pool.id = nic.vswitch_port_pool_id
      INNER JOIN vlan_tag_pool ON vlan_tag_pool.id = nic.vlan_tag_pool_id
    AND guest_nic.guest_id = guest_id_in; 
  END //
DELIMITER ;

--------------------------------
-- PNIC
--------------------------------

--------------------------------
-- DISK
--------------------------------

--------------------------------
-- VDISK
--------------------------------
-- add
DELIMITER //
CREATE PROCEDURE add_vdisk(IN guest_id_in BIGINT, IN disk_capacity_in FLOAT, primary_flag_in BOOLEAN, cow_flag_in BOOLEAN)
  BEGIN
    DECLARE vdisk_id_val BIGINT;
    INSERT INTO vdisk (capacity, primary_flag, cow_flag) VALUES (disk_capacity_in, primary_flag_in, cow_flag_in);
    SELECT LAST_INSERT_ID() INTO vdisk_id_val;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (guest_id_in, vdisk_id_val);
  END //
DELIMITER ;
-- destroy
DELIMITER //
CREATE PROCEDURE destroy_vdisk(IN vdisk_id_in BIGINT)
  BEGIN
    DELETE FROM vdisk WHERE vdisk.id = vdisk_id_in;
    DELETE FROM guest_vdisk WHERE guest_vdisk.vdisk_id = vdisk_id_in;
  END //
DELIMITER ;
-- read, first
DELIMITER //
CREATE PROCEDURE read_vdisk__first(IN guest_id_in BIGINT, OUT vdisk_count_out BIGINT, OUT vdisk_id_out BIGINT, OUT vdisk_capacity_out FLOAT, OUT vdisk_used_out FLOAT, 
	OUT vdisk_primary_flag_out BOOLEAN, OUT vdisk_cow_flag_out BOOLEAN)
  BEGIN
    SELECT COUNT(*) FROM guest_vdisk WHERE (guest_id = guest_id_in) INTO vdisk_count_out;
    SELECT 
      vdisk.id, 
      vdisk.capacity, 
      vdisk.used, 
      vdisk.primary_flag, 
      vdisk.cow_flag 
    INTO
      vdisk_id_out,
      vdisk_capacity_out,
      vdisk_used_out,
      vdisk_primary_flag_out,
      vdisk_cow_flag_out
    FROM vdisk 
    INNER JOIN guest_vdisk 
    WHERE guest_vdisk.vdisk_id = vdisk.id
    AND vdisk.primary_flag = true
    AND guest_vdisk.guest_id = guest_id_in;
  END //
DELIMITER ;
-- read, all (all which belong to a machine id)
DELIMITER //
CREATE PROCEDURE read_vdisk__all(IN guest_id_in BIGINT)
  BEGIN
    SELECT 
      vdisk.id, 
      vdisk.capacity, 
      vdisk.used, 
      vdisk.primary_flag, 
      vdisk.cow_flag 
    FROM vdisk 
    INNER JOIN guest_vdisk 
    WHERE guest_vdisk.vdisk_id = vdisk.id 
    AND guest_vdisk.guest_id = guest_id_in;
  END //
DELIMITER ;

--------------------------------
-- SNAPSHOT
--------------------------------
-- add
DELIMITER //
CREATE PROCEDURE add_snapshot(IN guest_id_in BIGINT, IN disk_capacity_in FLOAT, primary_flag_in BOOLEAN, cow_flag_in BOOLEAN)
  BEGIN
    DECLARE vdisk_id_val BIGINT;
    INSERT INTO vdisk (capacity, primary_flag, cow_flag) VALUES (disk_capacity_in, primary_flag_in, cow_flag_in);
    SELECT LAST_INSERT_ID() INTO vdisk_id_val;
    INSERT INTO guest_vdisk (guest_id, vdisk_id) VALUES (guest_id_in, vdisk_id_val);
  END //
DELIMITER ;
-- destroy
DELIMITER //
CREATE PROCEDURE destroy_snapshot(IN snapshot_id_in BIGINT)
  BEGIN
    DELETE FROM vdisk WHERE vdisk.id = vdisk_id_in;
    DELETE FROM guest_vdisk WHERE guest_vdisk.vdisk_id = vdisk_id_in;
  END //
DELIMITER ;
-- read, first
    --SELECT COUNT(*) FROM vdisk_snapshot WHERE (vdisk_id = vdisk_id_in) INTO snapshot_count;
    -- sub proc or php query --SELECT snapshot.id AS snapshot_id, snapshot.name, snapshot.snapshot_id AS parent_snapshot FROM snapshot INNER JOIN vdisk_snapshot WHERE (vdisk_snapshot.snapshot_id = snapshot.id) AND vdisk_snapshot.vdisk_id = guest_id_in;
-- read, all

--------------------------------
-- ACCESS PORT POOL
--------------------------------
-- get
DELIMITER //
CREATE PROCEDURE get_access_port(OUT next_id BIGINT)
  BEGIN
    SELECT id FROM access_port_pool WHERE (taken_flag = 0) LIMIT 1 INTO next_id;
    UPDATE access_port_pool SET taken_flag = 1 WHERE (id = next_id);
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_access_port(IN current_id BIGINT)
  BEGIN
    UPDATE access_port_pool SET taken_flag = 0 WHERE (id = current_id);
  END //
DELIMITER ;

--------------------------------
-- IP ADDRESS POOL
--------------------------------
-- get
DELIMITER //
CREATE PROCEDURE get_ip_address(OUT next_id BIGINT)
  BEGIN
    SELECT id FROM ip_address_pool WHERE (taken_flag = 0) LIMIT 1 INTO next_id;
    UPDATE ip_address_pool SET taken_flag = 1 WHERE (id = next_id);
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_ip_address(IN current_id BIGINT)
  BEGIN
    UPDATE ip_address_pool SET taken_flag = 0 WHERE (id = current_id);
  END //
DELIMITER ;

--------------------------------
-- MAC ADDRESS POOL
--------------------------------
-- function to generate
DELIMITER //
CREATE FUNCTION generate_mac_address() RETURNS varchar(24) NOT DETERMINISTIC
  BEGIN
    DECLARE newmac varchar(24);
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @a;
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @b;
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @c;
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @d;
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @e;
    SELECT LPAD(HEX(FLOOR(RAND() * (256 - 0 + 1))),2,0) INTO @f;
    SELECT CONCAT_WS(':', @a, @b, @c, @d, @e, @f) INTO newmac;
    RETURN (newmac);
  END //
DELIMITER ;
-- get, generating if necessary
DELIMITER //
CREATE PROCEDURE get_mac_address(OUT mac_address_id BIGINT)
  BEGIN
    DECLARE value, newmac varchar(24);
    SELECT id FROM mac_address_pool WHERE taken_flag = 0 LIMIT 1 INTO value;
    IF value IS NULL THEN
      SELECT generate_mac_address() INTO newmac;
      INSERT INTO mac_address_pool (name, taken_flag) VALUES (newmac, true);
      SELECT LAST_INSERT_ID() INTO mac_address_id;
    ELSE
      UPDATE mac_address_pool SET taken_flag = 1 WHERE (id = value);
      SELECT value INTO mac_address_id;
    END IF;
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_mac_address(IN current_id BIGINT)
  BEGIN
    UPDATE mac_address_pool SET taken_flag = 0 WHERE (id = current_id);
  END //
DELIMITER ;
-- create and get a specific mac address
DELIMITER //
CREATE PROCEDURE create_mac_address(IN newmac VARCHAR(24), OUT next_id BIGINT)
  BEGIN
    INSERT INTO mac_address_pool (name, taken_flag) VALUES (newmac, true);
    SELECT LAST_INSERT_ID() INTO next_id;
  END //
DELIMITER ;
-- delete a specific mac address
DELIMITER //
CREATE PROCEDURE delete_mac_address(IN current_id BIGINT)
  BEGIN
    DELETE FROM mac_address_pool WHERE (id = current_id);
  END //
DELIMITER ;

--------------------------------
-- VSWITCH PORT POOL
--------------------------------
-- get
DELIMITER //
CREATE PROCEDURE get_vswitch_port(OUT next_id BIGINT)
  BEGIN
    SELECT id FROM vswitch_port_pool WHERE (taken_flag = 0) LIMIT 1 INTO next_id;
    UPDATE vswitch_port_pool SET taken_flag = 1 WHERE (id = next_id);
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_vswitch_port(IN current_id BIGINT)
  BEGIN
    UPDATE vswitch_port_pool SET taken_flag = 0 WHERE (id = current_id);
  END //
DELIMITER ;

--------------------------------
-- VLAN TAG POOL
--------------------------------
-- get
DELIMITER //
CREATE PROCEDURE get_vlan_tag(OUT next_id BIGINT)
  BEGIN
    SELECT id FROM vlan_tag_pool WHERE (taken_flag = 0) LIMIT 1 INTO next_id;
    UPDATE vlan_tag_pool SET taken_flag = 1 WHERE (id = next_id);
  END //
DELIMITER ;
-- release
DELIMITER //
CREATE PROCEDURE release_vlan_tag(IN current_id BIGINT)
  BEGIN
    UPDATE vlan_tag_pool SET taken_flag = 0 WHERE (id = current_id);
  END //
DELIMITER ;
