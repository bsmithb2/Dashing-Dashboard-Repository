require 'csv'
require 'json'
require 'net/http'
require 'date'

reports_coverage_url = URI("http://aumelbdgorep01:8090/reports-coverage.csv")
newstack_coverage_url = URI("http://aumelbdgorep01:8090/arlive-newstack-coverage.csv")
mainline_unit_coverage_url = URI("http://aumelbdgorep01:8090/mainline-coverage.csv")

SCHEDULER.every '2s' do
  get_coverage(reports_coverage_url, 'reports_coverage')
  get_coverage(newstack_coverage_url, 'newstack_coverage')
  get_coverage(mainline_unit_coverage_url, 'mainline_unit_coverage')
end

def get_coverage(coverage_url, coverage_name)
  res = Net::HTTP.get_response(coverage_url)
  data = res.body if res.is_a?(Net::HTTPSuccess)
  dt = CSV.parse(data)
  data_array = []
  items_to_get = 100
  data_array << {x: 0, y: 0}
  date_now = DateTime.now
  aestHoursOffset = 10
  aestOffset = Rational(aestHoursOffset, 24)
  
  (1..items_to_get).each do |i|
    array_item_to_get = (items_to_get - (i-1)) * -1
    item = dt[array_item_to_get] 
    #puts item[1]
    if (item[1].to_f.is_a? Numeric) then 
      value = item[1]
      date = (DateTime.parse(item[0]) - (aestHoursOffset/24.0)).new_offset(aestOffset)
      date_diff = ((date_now - date) * 24 * 60 * 60).to_i
      #puts "date now is #{date_now}"
      #puts "date is #{date}"
      #uts "date diff is  #{date_diff}"

      #puts "getting item: #{array_item_to_get} with value #{value}"
      data_array << { x: i, y: item[1].to_f }
    end
  end
  #puts data_array
  send_event(coverage_name, points: data_array )

end

