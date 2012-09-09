require 'logger'
require './git_cmd.rb'

# set enviroment variable
ENV["P4CONFIG"]=p4.ini
# ENV["P4PORT"]="from p4.ini"
ENV["P4CHARSET"]="utf8"
# ENV["P4PASSWD"]="from p4.ini"
# ENV["P4USER"]="from p4.ini"
# ENV["P4CLIENT"]="from p4.ini"

#format the ouput of the p4 command in Ruby way
def output cmd
  output=[]
  IO.popen(cmd, "rb") do |file|
    while not file.eof
       output << Marshal.load(file)
    end
  end
  output
end

def p4_changes from_date, to_date
  output "p4 -R changes -l //www/expweb/trunk/...@#{from_date},@#{to_date}"
end

def p4_sync change
  output "p4 -R sync //www/expweb/trunk/...@" + change
end

def linked_job cl_id
  output "p4 -R fixes -c " + cl_id
end

current = Dir.new(".")
@logger = Logger.new("../logs/logger.txt","daily")
@error_logger = Logger.new("../logs/error_logger.txt","daily")
def deal_changes from_date, to_date
  changes = p4_changes(from_date,to_date);
  # sync each change and commit to local git repository
  changes.reverse.each do |element|
    change = element['change']
    comment = element['desc'].nil? ? "no comment" : element['desc']
    time = Time.at(element['time'].to_i).strftime("%Y/%m/%d %H:%M:%S")
    job = linked_job change
    job = job[0].nil? ? "" :  job[0]['Job']
    job = "no related job" if job.nil? # some changelist doesn't have related job
    message = time+"["+change+"]\n"+job+"\n"+comment
    sync_info = p4_sync change
    dir_size = git_commit message
    status_time = git_status_time
    info = Time.now.strftime("%Y/%m/%d %H:%M:%S")+", changelist="+change+", repo="+ dir_size[0].to_s+", local.git="+ dir_size[1].to_s+", full git workspace="+ dir_size[2].to_s+", statusTime="+ status_time.to_s
    @logger.info info
  end
end

def date_formater date
   date.strftime("%Y/%m/%d")
end
#deal the changes day by day
def run
  from_date = Time.utc(2012, 5, 9)
  to_date = Time.utc(2012, 5, 13)
  deal_date =from_date + 86400
  #to_date = Time.now
  #deal_date = to_date - (60 * 60 * 24)
  date_logger = ""
  while ( deal_date <=> to_date) < 0 do
    deal_changes(date_formater(from_date), date_formater(deal_date))
    from_date = deal_date
    deal_date = deal_date + (60 * 60 *24)
  end
end

begin
  run
rescue Exception => ex
  @error_logger.info ex
  `at now+5 minutes -f error_job`
end
