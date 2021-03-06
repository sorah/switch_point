# SwitchPoint
[![Gem Version](https://badge.fury.io/rb/switch_point.svg)](http://badge.fury.io/rb/switch_point)
[![Build Status](https://travis-ci.org/eagletmt/switch_point.svg?branch=master)](https://travis-ci.org/eagletmt/switch_point)
[![Coverage Status](https://coveralls.io/repos/eagletmt/switch_point/badge.png?branch=master)](https://coveralls.io/r/eagletmt/switch_point?branch=master)
[![Code Climate](https://codeclimate.com/github/eagletmt/switch_point.png)](https://codeclimate.com/github/eagletmt/switch_point)

Switching database connection between readonly one and writable one.

## Installation

Add this line to your application's Gemfile:

    gem 'switch_point'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_point

## Usage

See [spec/models](spec/models.rb).

### auto_writable
`auto_writable` is disabled by default.

When `auto_writable` is enabled, destructive queries is sent to writable connection even in readonly mode.
But it does NOT work well on transactions.

Suppose `after_save` callback is set to User model. When `User.create` is called, it proceeds as follows.

1. BEGIN TRANSACTION is sent to READONLY connection.
2. switch_point switches the connection to WRITABLE.
3. CREATE statement is sent to WRITABLE connection.
4. switch_point reset the connection to READONLY.
5. after_save callback is called.
    - At this point, the connection is READONLY and in a transaction.
6. COMMIT TRANSACTION is sent to READONLY connection.

## Internals
There's a proxy which holds two connections: readonly one and writable one.
A proxy has a thread-local state indicating the current mode: readonly or writable.

Each ActiveRecord model refers to a proxy.
`ActiveRecord::Base.connection` is hooked and delegated to the referred proxy.

When the writable connection is requested to execute destructive query, the readonly connection clears its query cache.

![switch_point](http://gyazo.wanko.cc/switch_point.svg)

### Special case: ActiveRecord::Base.connection
Basically, each connection managed by a proxy isn't shared between proxies.
But there's one exception: ActiveRecord::Base.

If `:writable` key is omitted (e.g., Nanika1 model in spec/models), it uses `ActiveRecord::Base.connection` as writable one.
When `ActiveRecord::Base.connection` is requested to execute destructive query, all readonly connections managed by a proxy which uses `ActiveRecord::Base.connection` as a writable connection clear query cache.

## Contributing

1. Fork it ( https://github.com/eagletmt/switch_point/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
