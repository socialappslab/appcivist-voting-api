# Each worker is an isolated process with its own database connection pool.
# Specifying pool=5 will limit number of PG connections to 5 for *each* worker.
# Each thread uses a unique DB connection meaning that num_threads <= pool_size.
# Source: https://devcenter.heroku.com/articles/concurrency-and-database-connections#calculating-required-connections
#
# NOTE: Heroku limits active DB connections to 20 (Free tier) meaning that
# (workers * threads * num_dyno) must be <= 20.
# https://devcenter.heroku.com/articles/concurrency-and-database-connections#maximum-database-connections
workers Integer(ENV['PUMA_WORKERS'] || 3)

# The reason to set minimum threads is to use less resources. Setting > 0 allows
# for requests to be served faster. See
# https://github.com/puma/puma/issues/322
threads 1, Integer(ENV['DATABASE_POOL'] || 16)

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

preload_app!

on_worker_boot do
  # NOTE: It's ok to leave out DATABASE_URL out. We're trading
  # a slow initial request (that requires DATABASE_URL) for code
  # simplicity.
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
