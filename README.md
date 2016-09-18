# Yeelight-Wifi

Work with Yeelight WiFi Light from Ruby

## Usage

The "Developer Mode" need to be enabled to discover and operate the device.

### Ruby

To discover a Yeelight WiFi LED in the network

``` ruby
require './yeelight'

lamps = Yeelight.discover
puts lamps[0]
```

To control the Yeelight WiFi LED

``` ruby
require './yeelight'

lamp = Yeelight.new('192.168.1.255',55443)

# get the "power" property
puts lamp.get_prop('"power")

# toggle the smart LED
puts lamp.toggle()

```

Note: Only tested with Yeelight LED Bulb (Color) with the firmware 1.3.1_40

