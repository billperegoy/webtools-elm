require 'json'
require 'sinatra'


get '/api/results' do
  headers 'Access-Control-Allow-Origin' => '*'
  random_regression_result.to_json
end

def random_regression_result
  {
    summary: {
      run_name: "val__project_2106_06_17",
      release_label: "REL_0.23.34",
      start_time: "2016-06-17 03:34",
      end_time: nil,
      gvp_log: "#",
      compiles: random_triplet,
      lints: random_triplet,
      sims: random_triplet
    },
    compiles: gen_run_list(10),
    lints: gen_run_list(3),
    simulations: gen_run_list(1000)
  }
end

def gen_run_list(count)
  list = []
  (1..count).each do |num|
    list << {
      run_number: num,
      name: "test_" + num.to_s,
      config: ["default", "pcie", "ddr", "bypass"][rand(3)],
      status: ["PASS", "FAIL", "ERROR"][rand(2)],
      lsf_status: ["DONE", "EXIT", "RUN"][rand(3)],
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

