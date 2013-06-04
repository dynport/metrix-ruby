# Metrix

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem install 'metrix'

## Configuration

    # in /etc/metrix.tml

    # local metrics
    load:           true
    system:         true
    processes:      true

    # http metrics
    elasticsearch:  http://127.0.0.1:9200/_status
    mongodb:        http://127.0.0.1:28017/serverStatus
    fpm:            http://127.0.0.1:9001/fpm-status
    nginx:          http://127.0.0.1:8000/

    # reporters
    opentsdb:       tcp://127.0.0.1:4242/
    graphite:       tcp://127.0.0.1:2003/

## Start

    $ metrix start

## Stop

    $ metrix stop

## Status

    $ metrix status

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
