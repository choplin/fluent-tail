require 'optparse'
require 'drb/drb'
require 'fluent/load'

def parse_options
  op = OptionParser.new
  op.banner += ' <pattern>'

  (class<<self;self;end).module_eval do
    define_method(:usage) do |msg|
      puts op.to_s
      puts "error: #{msg}" if msg
      exit 1
    end
  end

  opts = {
    host: '127.0.0.1',
    port: 24230,
    unix: nil,
    pattern: nil,
    output_type: :json,
  }

  op.on('-h', '--host HOST', "fluent host (default: #{opts[:host]})") {|v|
    opts[:host] = v
  }

  op.on('-p', '--port PORT', "debug_agent tcp port (default: #{opts[:host]})", Integer) {|v|
    opts[:port] = v
  }

  op.on('-u', '--unix PATH', "use unix socket instead of tcp") {|v|
    opts[:unix] = b
  }

  op.on('-t', '--output-type TYPE', "output format of record. available types are 'json' or 'hash'. (default: #{opts[:output_type]})") {|v|
    case v.downcase
    when 'json'
      opts[:output_type] = :json
    when 'hash'
      opts[:output_type] = :hash
    else
      raise ConfigError, "output_type must be 'json' or 'hash'"
    end
  }

  begin
    op.parse!(ARGV)
    opts[:pattern] = ARGV.shift

    if opts[:pattern].nil?
      usage "a pattern must be specified"
    end
  rescue
    usage $!.to_s
  end

  opts
end

def format(tag, time, record)
  "#{Time.at(time).localtime} #{tag}: #{@output_proc.call(record)}"
end

def main
  opts = parse_options

  @output_proc = case opts[:output_type]
                 when :json then Proc.new {|record| Yajl.dump(record) }
                 when :hash then Proc.new {|record| record.to_s }
                 end

  unless opts[:unix].nil?
    uri = "drbunix:#{opts[:unix]}"
  else
    uri = "druby://#{opts[:host]}:#{opts[:port]}"
  end

  $remote_engine = DRb::DRbObject.new_with_uri(uri)

  remote_code = <<-CODE
    alias :original_emit_staream :emit_stream
    @fluent_tail_queue = Queue.new
    @fluent_tail_match_pattern = Fluent::MatchPattern.create("#{opts[:pattern]}")
    @fluent_tail_match_cache = {}

    def emit_stream(tag, es)
      matched = @fluent_tail_match_cache[tag]

      if matched.nil?
        matched = @fluent_tail_match_pattern.match(tag)
        @fluent_tail_match_cache[tag] = matched
      end

      @fluent_tail_queue.push([tag, es.dup]) if matched

      original_emit_staream(tag, es)
    end

    def pop
      @fluent_tail_queue.pop
    end
  CODE

  if $remote_engine.respond_to?(:original_emit_staream)
    abort 'another client has already connected to the server. abort.'
  end

  begin
    $remote_engine.method_missing(:instance_eval, remote_code)

    while e = $remote_engine.pop
      tag, es = e
      es.each do |time,record|
        STDOUT.puts format(tag, time, record)
      end
    end
  ensure
    if not $remote_engine.nil? and $remote_engine.respond_to?(:original_emit_staream)
      remote_code = <<-CODE
        @fluent_tail_queue = nil
        alias :emit_stream :original_emit_staream
        undef :original_emit_staream
      CODE
      $remote_engine.method_missing(:instance_eval, remote_code)
    end
  end
end

main
