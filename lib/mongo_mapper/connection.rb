# encoding: UTF-8
require 'uri'

module MongoMapper
  module Connection
    @@use_replset = false

    # @api public
    def connection
      if @@use_replset
        @@connection ||= Mongo::ReplSetConnection.new
      else
        @@connection ||= Mongo::Connection.new
      end
    end

    # @api public
    def connection=(new_connection)
      @@connection = new_connection
      @@use_replset = true if new_connection.kind_of? Mongo::ReplSetConnection
    end

    # @api public
    def logger
      connection.logger
    end

    # @api public
    def database=(name)
      @@database = nil
      @@database_name = name
    end

    # @api public
    def database
      if @@database_name.blank?
        raise 'You forgot to set the default database name: MongoMapper.database = "foobar"'
      end

      @@database ||= MongoMapper.connection.db(@@database_name)
    end

    def config=(hash)
      @@config = hash
    end

    def config
      raise 'Set config before connecting. MongoMapper.config = {...}' unless defined?(@@config)
      @@config
    end

    # @api private
    def config_for_environment(environment)
      env = config[environment]
      return env if env['uri'].blank?

      uri = URI.parse(env['uri'])
      raise InvalidScheme.new('must be mongodb') unless uri.scheme == 'mongodb'
      {
        'host'     => uri.host,
        'port'     => uri.port,
        'database' => uri.path.gsub(/^\//, ''),
        'username' => uri.user,
        'password' => uri.password,
      }
    end

    def connect(environment, options={})
      raise 'Set config before connecting. MongoMapper.config = {...}' if config.blank?
      env = config_for_environment(environment)

      if env['replication_set']
        @@use_replset = true
        puts "Starting replication set connection"
        MongoMapper.connection = Mongo::ReplSetConnection.new([env['host'], env['port']], options.merge(:rs_name => env['replication_set']))
      else
        @@use_replset = false
        MongoMapper.connection = Mongo::Connection.new(env['host'], env['port'], options)
      end

      MongoMapper.database = env['database']
      MongoMapper.database.authenticate(env['username'], env['password']) if env['username'] && env['password']
    end

    def setup(config, environment, options={})
      handle_passenger_forking
      self.config = config
      connect(environment, options)
    end

    def handle_passenger_forking
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          connection.connect if forked
        end
      end
    end
  end
end