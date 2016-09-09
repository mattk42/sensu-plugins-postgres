#! /usr/bin/env ruby
#
#   check-postgres-alive
#
# DESCRIPTION:
#
#   This plugin attempts to login to postgres with provided credentials.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: pg
#
# USAGE:
#   ./check-postgres-alive.rb -u db_user -p db_pass -h db_host -d db
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2012 Lewis Preson & Tom Bassindale
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'pg'

class CheckPostgres < Sensu::Plugin::Check::CLI
  option :connection_string,
         description: 'A postgres connection string to use, overrides any other parameters',
         short: '-c CONNECTION_STRING',
         long:  '--connection CONNECTION_STRING'

  option :user,
         description: 'Postgres User',
         short: '-u USER',
         long: '--user USER'

  option :password,
         description: 'Postgres Password',
         short: '-p PASS',
         long: '--password PASS'

  option :hostname,
         description: 'Hostname to login to',
         short: '-h HOST',
         long: '--hostname HOST'

  option :database,
         description: 'Database schema to connect to',
         short: '-d DATABASE',
         long: '--database DATABASE',
         default: 'test'

  option :port,
         description: 'Database port',
         short: '-P PORT',
         long: '--port PORT',
         default: 5432

  def run

    if config[:connection_string]
      con = PG::Connection.new(config[:connection_string])
    else
      con = PG::Connection.new(config[:hostname], config[:port], nil, nil, config[:database], config[:user], config[:password])
    end

    res = con.exec('select version();')
    info = res.first

    ok "Server version: #{info}"
  rescue PG::Error => e
    critical "Error message: #{e.error.split("\n").first}"
  ensure
    con.close if con
  end
end
