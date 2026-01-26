# CORECONFIG

## Zigbee configuration

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
