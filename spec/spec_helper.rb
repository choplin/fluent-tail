ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(ROOT, 'lib')

require 'socket'


class FluentdClient
  def self.connect
    conn = TCPSocket.open('127.0.0.1', 24224)
    self.new(conn)
  end

  def write(tag, time, event)
    @conn.write [tag, time, event].to_json
  end

  private

  def initialize(conn)
    @conn = conn
  end
end

