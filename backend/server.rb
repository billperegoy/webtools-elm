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

  def get_api_data
   regression_name = 'val__dnldrel_par_reg_dnld_validate__2016_06_11_19_35_17_47669'
   regression_name = 'val__teslarel_edison_validate__2016_06_23_13_30_20_35168'
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

   {compiles: compiles, lints: lints, simulations: simulations}
  end

  get '/api/real' do
    headers 'Access-Control-Allow-Origin' => '*'

   results = get_api_data
   results.to_json
  end

  get '/api/results' do
    headers 'Access-Control-Allow-Origin' => '*'
    get_api_data.to_json
  end

  def gen_run_list(count)
    list = []
    (1..count).each do |num|
      list << {
        test_num: num,
        name: "test_" + num.to_s,
        config: ["default", "pcie", "ddr", "bypass"][rand(3)],
        status: ["Pass", "Fail", "Error"][rand(2)],
        lsf_status: ["Done", "Exit", "Run"][rand(3)],
        run_time: rand(1000)
      }
    end
    list
  end

  def random_triplet
    total = rand(10)

    complete = rand(total)
    complete = complete < 1 ? 0 : complete

    fail = rand(complete)
    fail = fail < 1 ? 0 : fail

    {total: total, complete: complete, fail: fail}
  end
end
