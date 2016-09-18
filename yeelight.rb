require 'socket'
require 'json'
require 'timeout'

class Yeelight

    def initialize(host, port)
        @host = host
        @port = port
    end

    def request(cmd)
        begin
            s = TCPSocket.open(@host, @port)
            s.puts cmd
            data = s.gets.chomp
            s.close
            response(data)
        rescue Exception => msg
            response(JSON.generate({:exception => msg}))
        end
    end

    def response(data)
        json = JSON.parse(data)
        # create a standard response message
        result = {
            :status => json['result'] ? true : false,
            :data => json
        }
        JSON.generate(result)
    end

    private :request, :response

    # This method is used to retrieve current property of smart LED.
    def get_prop(values)
        cmd = "{\"id\":1,\"method\":\"get_prop\",\"params\":[#{values}]}\r\n"
        request(cmd)
    end

    # This method is used to change the color temperature of a smart LED.
    def set_ct_abx(ct_value, effect, duration)
        cmd = "{\"id\":2,\"method\":\"set_ct_abx\",\"params\":[#{ct_value},\"#{effect}\",#{duration}]}\r\n"
        request(cmd)
    end

    # This method is used to change the color RGB of a smart LED.
    def set_rgb(rgb_value, effect, duration)
        cmd = "{\"id\":3,\"method\":\"set_rgb\",\"params\":[#{rgb_value},\"#{effect}\",#{duration}]}\r\n"
        request(cmd)
    end

    # This method is used to change the color HSV of a smart LED.
    def set_hsv(hue, sat, effect, duration)
        cmd = "{\"id\":4,\"method\":\"set_hsv\",\"params\":[#{hue},#{sat},\"#{effect}\",#{duration}]}\r\n"
        request(cmd)
    end

    # This method is used to change the brightness of a smart LED.
    def set_bright(brightness, effect, duration)
        cmd = "{\"id\":5,\"method\":\"set_bright\",\"params\":[#{brightness},\"#{effect}\",#{duration}]}\r\n"
        request(cmd)
    end

    # This method is used to switch on or off the smart LED (software managed on/off).
    def set_power(power, effect, duration)
        cmd = "{\"id\":6,\"method\":\"set_power\",\"params\":[\"#{power}\",\"#{effect}\",#{duration}]}\r\n"
        request(cmd)
    end

    # This method is used to toggle the smart LED.
    def toggle
        cmd = "{\"id\":7,\"method\":\"toggle\",\"params\":[]}\r\n"
        request(cmd)
    end

    # This method is used to save current state of smart LED in persistent memory.
    # So if user powers off and then powers on the smart LED again (hard power reset),
    # the smart LED will show last saved state.
    # Note: The "automatic state saving" must be turn off
    def set_default
        cmd = "{\"id\":8,\"method\":\"set_default\",\"params\":[]}\r\n"
        request(cmd)
    end

    # This method is used to start a color flow. Color flow is a series of smart
    # LED visible state changing. It can be brightness changing, color changing
    # or color temperature changing
    def start_cf(count, action, flow_expression)
        cmd = "{\"id\":9,\"method\":\"set_power\",\"params\":[#{count},#{action},\"#{flow_expression}\"]}\r\n"
        request(cmd)
    end

    # This method is used to stop a running color flow.
    def stop_cf
        cmd = "{\"id\":10,\"method\":\"stop_cf\",\"params\":[]}\r\n"
        request(cmd)
    end

    # This method is used to set the smart LED directly to specified state. If
    # the smart LED is off, then it will turn on the smart LED firstly and then
    # apply the specified scommand.
    def set_scene(classe, val1, val2)
        cmd = "{\"id\":11,\"method\":\"set_scene\",\"params\":[\"#{classe}\",#{val1},#{val2}]}\r\n"
        request(cmd)
    end

    # This method is used to start a timer job on the smart LED
    def cron_add(type, value)
        cmd = "{\"id\":12,\"method\":\"cron_add\",\"params\":[#{type},#{value}]}\r\n"
        request(cmd)
    end

    # This method is used to retrieve the setting of the current cron job
    # of the specified type
    def cron_get(type)
        cmd = "{\"id\":13,\"method\":\"cron_get\",\"params\":[#{type}]}\r\n"
        request(cmd)
    end

    # This method is used to stop the specified cron job.
    def cron_del(type)
        cmd = "{\"id\":14,\"method\":\"cron_del\",\"params\":[#{type}]}\r\n"
        request(cmd)
    end

    # This method is used to change brightness, CT or color of a smart LED
    # without knowing the current value, it's main used by controllers.
    def set_adjust(action, prop)
        cmd = "{\"id\":15,\"method\":\"set_adjust\",\"params\":[\"#{action}\",\"#{prop}\"]}\r\n"
        request(cmd)
    end

    # This method is used to name the device. The name will be stored on the
    # device and reported in discovering response. User can also read the name
    # through “get_prop” method.
    def set_name(name)
        cmd = "{\"id\":16,\"method\":\"set_name\",\"params\":[\"#{name}\"]}\r\n"
        request(cmd)
    end

    # This method is used to switch on the smart LED
    def on
        set_power("on", "smooth",1000)
    end

    # This method is used to switch off the smart LED
    def off
        set_power("off", "smooth",1000)
    end


    # This method is used to discover a smart LED in the network
    def self.discover
        host = "239.255.255.250"
        port = 1982
        socket  = UDPSocket.new(Socket::AF_INET)

        payload = []
        payload << "M-SEARCH * HTTP/1.1\r\n"
        payload << "HOST: #{host}:#{port}\r\n"
        payload << "MAN: \"ssdp:discover\"\r\n"
        payload << "ST: wifi_bulb"

        socket.send(payload.join(), 0, host, port)

        devices = []
        begin
            Timeout.timeout(2) do
                loop do
                    devices << socket.recvfrom(2048)
                end
            end
        rescue Timeout::Error => ex
            ex
        end

        devices
    end
end
