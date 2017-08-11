class Job

	attr_reader :job_hash
	attr_reader :name
	attr_reader :plan_gets
	attr_reader :depends_on

	def initialize(job_hash)

		@job_hash = job_hash
		@name = ""

		return if job_hash.empty?

		@name = job_hash["name"]
		@plan_gets = []
		@depends_on = []

		return unless job_hash.key? "plan"
		return if job_hash["plan"].nil? or job_hash["plan"].empty?

		all_get_items = plan_aggregate_items[0]
		#all_get_items.concat(plan_aggregate_items())
		#all_get_items.concat(get_items(job_hash["plan"]))

		puts "count: #{all_get_items.count}"
		puts "#{all_get_items.class}"
		all_get_items.each_index{ |i|  puts "#{i}: #{all_get_items[i]}" }
		puts "\n\n"

		all_get_items.each { |get_item|
			@plan_gets << get_item
			@depends_on << get_item["passed"] if get_item.key?("passed")
		}
	end

	def valid?
		not name.empty?
	end

	private

	def plan_aggregate_items
		job_hash["plan"].select{|p| p.key?("aggregate")}.collect{|p| p["aggregate"]}
	end

	def get_items(plan)
		plan.select{ |item| item.key?("get") }
	end
end
