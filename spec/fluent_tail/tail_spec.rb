require 'json'
require 'spec_helper'
require 'fluent/tail/version'

describe Fluent::Tail do
  TAG_PATTER = 'foo.**'
  CONFIG_PATH = File.join(File.dirname(__FILE__), 'fluent.conf')
  BIN_DIR = File.join(ROOT, 'bin')

  LOG = File.join(File.dirname(__FILE__), 'test.log')

  before :all do
    @fluentd_pid = spawn('fluentd', '-c', CONFIG_PATH, out: '/dev/null')
    sleep 2

    @r,w = IO.pipe
    @fluent_tail_pid = spawn("#{File.join(BIN_DIR, 'fluent-tail')} #{TAG_PATTER}", out: w)
    sleep 1
  end

  after :all do
    Process.kill(:TERM, @fluent_tail_pid)
    sleep 1
    Process.kill(:TERM, @fluentd_pid)
    Process.waitall
  end

  it 'have a version number' do
    expect(Fluent::Tail::VERSION).not_to be_nil
  end

  it 'show matched events' do
    tag = 'foo.bar'
    time = Time.now
    event = {'foo' => 'bar'}

    client = FluentdClient.connect
    client.write(tag, time.to_i, event)

    line = @r.gets
    expect(line).to eq("#{time.localtime} #{tag}: #{event.to_json}\n")
  end

  it 'does not show matched events' do
    tag = 'hoge'
    time = Time.now
    event = {'foo' => 'bar'}

    client = FluentdClient.connect
    client.write(tag, time.to_i, event)

    expect {@r.read_nonblock(10)}.to raise_error(Errno::EAGAIN)
  end
end
