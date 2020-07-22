require 'simplecov-rcov'

SimpleCov.start do
  coverage_dir 'tmp/reports'
  formatter SimpleCov::Formatter::RcovFormatter
  minimum_coverage 100
end
