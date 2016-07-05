require 'json'
require 'sinatra'
require 'mongo'
class Application < Sinatra::Base

  Mongo::Logger.logger.level = ::Logger::FATAL
  servers = ['mongol.icd.teradyne.com:27017', 'kiku.std.teradyne.com:27017']
  replica_set = 'regression_data'
  database_name = 'regression_data'
  username = 'regr_ro'
  password = 'regr_ro'

  @@db = Mongo::Client.new(servers,
                           replica_set: replica_set,
                           read: { mode: :primary_preferred },
                           database: database_name,
                           auth_mech: :mongodb_cr,
                           user: username,
                           password: password,
                           max_pool_size: 1,
                           server_selection_timeout: 10,
                           socket_timeout: 10,
                           wait_queue_timeout: 10,
                           connect_timeout: 10
                          )

  def map_seed_field(records)
    records.map do |rec|
      if rec['seed']
        rec['seed'] = rec['seed'].to_s
      end
      rec
    end
  end

  def regressions_index
    fourteen_days_ago = Time.new - 14 * 24 * 60 * 60
    query = {'start_date' =>  {'$gt' => fourteen_days_ago}}
    projection = {'_id' => false,
                  'name' => true,
                  'user' => true,
                  'proj' => true,
                  "run_type" => true}

    @@db['regress_data']
      .find(query)
      .projection(projection)
      .sort({'start_date' => -1})
      .map { |rec| rec }
  end

  def regressions_show(regression_name)
   compiles = @@db['compile_data']
     .find({'regr' => regression_name})
     .projection({'_id' => false})
     .map { |rec| rec }

   lints = @@db['lint_data']
     .find({'regr' => regression_name})
     .projection({'_id' => false})
     .map { |rec| rec }

   simulations = @@db['sim_data']
     .find({'regr' => regression_name})
     .projection({'_id' => false})
     .map { |rec| rec }

   {compiles: compiles, lints: lints, simulations: map_seed_field(simulations)}
  end

  get '/api/regressions' do
    headers 'Access-Control-Allow-Origin' => '*'
    regressions_index.to_json
  end

  get '/api/regressions/:name' do
    headers 'Access-Control-Allow-Origin' => '*'
    regression_name = params['name']
    regressions_show(regression_name).to_json
  end
end
