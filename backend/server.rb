require 'json'
require 'sinatra'


get '/api/results' do
  headers 'Access-Control-Allow-Origin' => '*'
  random_regression_result.to_json
end

def random_regression_result
  { compiles: random_triplet, lints: random_triplet, sims: random_triplet}
end

def random_triplet
  total = rand(500)

  complete = rand(total)
  complete = complete < 1 ? 0 : complete

  fail = rand(complete)
  fail = fail < 1 ? 0 : fail

  {total: total, complete: complete, fail: fail}
end

