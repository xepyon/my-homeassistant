# CORECONFIG

## Important core config related to homeassistant and other container servers used

### Home Assistant configuration locations in container volumes

```
/srv/ha/dev/homeassistant/config/configuration.yaml
/srv/ha/dev/homeassistant/config/.storage/core.config_entries
```

### zigbee2mqtt configuration location in container volumes

```
/srv/ha/dev/zigbee2mqtt/configuration.yaml
```


### zigbe2mqtt bridge initial conf and backup

- Reset zigbee2mqtt bridge to factory settings
- Connect to zigbee brige wifi network for initial conf ZB-xxx
- Access to web interface under 192.168.4.1
- Configure 2.4ghz wifi network with vlan 20 access and save the ip address assigned to the zigbee2mqtt bridge
- Connect to default network and access to the zigbee2mqtt web interface provided above
- In ha core.config_entries edit the zigbee2mqtt bridge ip address to the new one assigned in vlan 20 if necessary OR configure it manually using ha web interface -> settings -> devices & services -> integrations -> add integration -> zigbee home automation -> Adapter type: ezsp ; Serial device path: tcp://192.168.20.246:6638 (replace with your TCP bridge) ; Serial port speed 115200 ; Serial port flow control: none -> I have created backup mentioned below, unsure if going to work.

Backup of the zigbee2mqtt configuration after changing vlan done under truneas-scale03.nico.com/container/ha/zigbee/bridge/Config_ZBbridge_Initial_conf_20iot.dmp

## Zigbee configuration advanced

The initial zigbee configuration was done in vlan 3.

To change the vlan for the zigbee2mqtt bridge it is as simple as editing the network in zigbee2mqtt/config/configuration.yaml.example and from homeassistant/storage/core.config_entries.

After resetting the zigbee2mqtt device a backup was done in truenasscale03, just in case.

### zigbee2mqtt old and new config

#### old

```
serial:
  port: tcp://192.168.3.129:6638   # replace with your TCP bridge
  baudrate: 115200
  adapter: ezsp                     # typical for ZBBridge-style devices
```

#### new

```
serial:
  port: tcp://192.168.20.246:6638   # replace with your TCP bridge
  baudrate: 115200
  adapter: ezsp                     # typical for ZBBridge-style devices
```


### ha core.config_entries

#### old

```
      {"created_at":"2025-11-22T16:43:41.433429+00:00","data":{"device":{"baudrate":115200,"flow_control":"software","path":"socket://192.168.3.129:6638"},"radio_type":"ezsp"},"disabled_by":"user","discovery_keys":{},"domain":"zha","entry_id":"01KAP76BZSN1WFTZY5BMY9KTW2","minor_version":1,"modified_at":"2025-11-22T16:43:41.433430+00:00","options":{},"pref_disable_new_entities":false,"pref_disable_polling":false,"source":"user","subentries":[],"title":"socket://192.168.3.129:6638","unique_id":"epid=34:99:62:b8:3d:63:5b:60","version":5},
```

#### new

```
      {"created_at":"2025-11-22T16:43:41.433429+00:00","data":{"device":{"baudrate":115200,"flow_control":"software","path":"socket://192.168.20.246:6638"},"radio_type":"ezsp"},"disabled_by":"user","discovery_keys":{},"domain":"zha","entry_id":"01KAP76BZSN1WFTZY5BMY9KTW2","minor_version":1,"modified_at":"2025-11-22T16:43:41.433430+00:00","options":{},"pref_disable_new_entities":false,"pref_disable_polling":false,"source":"user","subentries":[],"title":"socket://192.168.3.129:6638","unique_id":"epid=34:99:62:b8:3d:63:5b:60","version":5},
```
