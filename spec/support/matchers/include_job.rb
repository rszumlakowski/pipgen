require 'rspec/expectations'
require 'pry'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end

class IncludeJobMatcher

	def initialize(expected_job)
		@expected_job = expected_job
		@later_jobs = []
		@earlier_jobs = []
		@actual_array = []
	end

	def matches? actual_array
		raise "Actual value must be an array" unless actual_array.is_a? Array
		@actual_array = actual_array
		(result, message) = helper
		return result
	end

	def does_not_match? actual_array
		raise "Actual value must be an array" unless actual_array.is_a? Array
		raise "before_job matcher not supported during negated matches" unless @later_jobs.empty?
		raise "after_job matcher not supported during negated matches" unless @earlier_jobs.empty?
		@actual_array = actual_array
		(result, message) = negated_helper
		return result
	end

	def and_be_before_job later_job
		@later_jobs << later_job
		self
	end

	def and_be_before_jobs *later_jobs
		raise "Expected value must be an array" unless later_jobs.is_a? Array
		@later_jobs.concat later_jobs
		self
	end

	def and_be_after_job earlier_job
		@earlier_jobs << earlier_job
		self
	end

	def and_be_after_jobs *earlier_jobs
		raise "Expected value must be an array" unless earlier_jobs.is_a? Array
		@earlier_jobs.concat earlier_jobs
		self
	end

	def failure_message
		(result, message) = helper
		return message
	end

	def failure_message_when_negated
		(result, message) = negated_helper
		return message
	end

	def description
		"include job \"#{@expected_job}\""
	end

	private

	def helper

		return missing_job_result(@expected_job) unless @actual_array.include? @expected_job

		expected_job_index = @actual_array.index @expected_job

		@later_jobs.each do |j|
			return missing_job_result(j) unless @actual_array.include? j
			j_index = @actual_array.index j
			return bad_order_result(@expected_job, j) if expected_job_index >= j_index
		end

		@earlier_jobs.each do |j|
			return missing_job_result(j) unless @actual_array.include? j
			j_index = @actual_array.index j
			return bad_order_result(j, @expected_job) if expected_job_index <= j_index
		end

		return good_result
	end

	def negated_helper
		return found_job_result(@expected_job) if @actual_array.include? @expected_job
		return good_result
	end

	def missing_job_result missing_job
		[false, "expected job \"#{missing_job}\" to be in list #{@actual_array}"]
	end

	def found_job_result found_job
		[false, "expected job \"#{found_job}\" to not be in list #{@actual_array}"]
	end

	def bad_order_result(first_expected_job, second_expected_job)
		[false, "expected job \"#{first_expected_job}\" to be before job \"#{second_expected_job}\" in list #{@actual_array}"]
	end

	def good_result
		[true, "OK"]
	end
end

def include_job(*args)
	IncludeJobMatcher.new(*args)
end

RSpec.describe ["job0", "job1", "job2", "job3"] do
  it { is_expected.to include_job("job0") }
  it { is_expected.to_not include_job("jobX") }
  it { is_expected.to include_job("job0").and_be_before_job("job1") }
  it { is_expected.to include_job("job0").and_be_before_jobs("job1", "job2", "job3") }
  it { is_expected.to include_job("job1").and_be_after_job("job0").and_be_before_job("job2") }
  it { is_expected.to include_job("job1").and_be_after_job("job0").and_be_before_jobs("job2", "job3") }
  it { is_expected.to include_job("job1").and_be_after_job("job0") }
  it { is_expected.to include_job("job3").and_be_after_jobs("job0", "job1", "job2") }
end
