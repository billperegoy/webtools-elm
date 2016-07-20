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

  # Map any bad regress_data values from mongoDB to legal values
  # for the front-end.
  #
  def map_summary_records(record)
    record['end_date'] = record['end_date'] || Time.now

    record
  end

  # Map any bad sim_data values from mongoDB to legal values
  # for the front-end.
  #
  def map_simulation_records(records)
    records.map do |rec|
      rec['seed'] = rec['seed'].to_s
      rec['status'] = rec['status'] || '-'

      rec
    end
  end

  # Map any bad compile_data values from mongoDB to legal values
  # for the front-end.
  #
  def map_compile_records(records)
    records.map do |rec|
      rec['status'] = rec['status'] || '-'

      unless rec['lsf_info']['cpu'].class == Float
        rec['lsf_info']['cpu'] = 0.0
      end

      unless rec['lsf_info']['swap'].class == Fixnum
        rec['lsf_info']['swap'] = 0
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
   summary = @@db['regress_data']
     .find({'name' => regression_name})
     .projection({'_id' => false})
     .map { |rec| rec }
     .first

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

   {
     summary: map_summary_records(summary),
     compiles: map_compile_records(compiles),
     lints: lints,
     simulations: map_simulation_records(simulations)
   }
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
