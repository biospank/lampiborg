require "socket"
require "timeout"

module UDPServer

  def self.answer_client(ip, port, response)
    s = UDPSocket.new
    #s.send(Marshal.dump(response), 0, ip, port)
    s.send(response, 0, ip, port)
    s.close
  end

  def self.start_service_announcer(server_udp_port, &code)
    Thread.fork do
      s = UDPSocket.new
      s.bind('0.0.0.0', server_udp_port)

      loop do
        body, sender = s.recvfrom(1024)

        params = Hash[body.split(',').collect {|prop| prop.split('=')}]
        client_ip = sender[3]
        client_port = params['reply_port']
        response = code.call(body, client_ip)

        if response
          begin
            answer_client(client_ip, client_port, response)
          rescue
            # Make sure thread does not crash
          end
        end
      end
    end
  end

end

SERVER_LISTEN_PORT = 1234

puts "Starting Server..."

thread = UDPServer.start_service_announcer(SERVER_LISTEN_PORT) do |client_msg, client_ip|
  "you_are=#{client_ip},you_said=#{client_msg},i_say=wellcome!"
end

puts "Server running."

thread.join

