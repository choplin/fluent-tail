# Fluent::Tail

Using fluent-tail, you can tail [fluentd](http://fluentd.org/) event stream without any configuration changes.

## Caution

Because tool modify the running fluentd process using `drb` and `instance_eval', there is a potential risk that the process could be broken unexpectedly.

In addition, this tool might degrade the perfermance of the fluentd process.

*Use this tool at your own risk.*

## Installation

```
$ fluent-gem install fluent-tail
```

## Prerequisite

`in_debug_agent` plugin is required to be enabled.

```
<source>
  type debug_agent
</source>
```

## Usage

```
$ fluent-tail <tag_pattern>
```

You can specify a pattern of tag with the same format as fluentd match tag.

e.g.


```
$ fluent-tail foo.**
```

then events with tag, such as "foo" , "foo.bar" and "foo.bar.foo" etc., will be shown in your console.

```
2014-03-06 14:22:21 +0900 foo: {"hoge":"fuga"}
2014-03-06 14:22:23 +0900 foo.bar: {"hoge":"fuga"}
2014-03-06 14:22:27 +0900 foo.bar.foo: {"hoge":"fuga"}
```

## Option

|parameter|description|default|
|---|---|---|
|-h, --host HOST|fluent host|127.0.0.1|
|-p, --port PORT|debug_agent|24230|
|-u, --unix PATH|use unix socket instead of tcp||
|-t, --output-type TYPE|output format of record. available types are 'json' or 'hash'.|json|

## Copyright

See LICENSE.txt

## Contributing

1. Fork it ( http://github.com/choplin/fluent-tail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
