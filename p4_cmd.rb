require 'logger'
require './git_cmd.rb'

# set enviroment variable
ENV["P4CONFIG"]=p4.ini
# ENV["P4PORT"]="from p4.ini"
ENV["P4CHARSET"]="utf8"
# ENV["P4PASSWD"]="from p4.ini"
# ENV["P4USER"]="from p4.ini"
# ENV["P4CLIENT"]="from p4.ini"

# deal the changes day by day in future
from_date = "2012/05/10"
to_date = "2012/05/11"

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
  output "p4 -R changes //www/expweb/trunk/...@#{from_date},@#{to_date}" 
end

def p4_sync change
  output "p4 -R sync //www/expweb/trunk/...@" + change
end

def linked_job cl_id
  output "p4 -R fixes -c " + cl_id
end

current = Dir.new(".")
logger = Logger.new("./logger.txt","daily");
changes = p4_changes(from_date,to_date);

# sync each change and commit to local git repository
changes.reverse.each do |element|
   change = element['change']
   comment = element['desc'] 
   time = Time.at(element['time'].to_i).strftime("%Y/%m/%d %H:%M:%S")
   job = linked_job change 
   job = job[0].nil? ? "" :  job[0]['Job']   
   message = change+", "+ comment+"," + time+", "+ job
   
   sync_info = p4_sync change
   
   dir_size = git_commit message
   
   status_time = git_status_time
   info = Time.now.strftime("%Y/%m/%d %H:%M:%S")+", depotSize="+ dir_size.to_s+", statusTime="+ status_time.to_s
   logger.debug info
end

#git_push #need to handle the password issue.


