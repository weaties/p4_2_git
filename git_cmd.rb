
#The directory of git project
def git_init 
  Dir.chdir("/opt/haitao/perforce/1953/www/expweb/trunk")
end

# commit the change.
def git_commit message
  git_init
  message.gsub!(/["]/,"'")  # deal the comments contain "
  `git add .`
  `git commit -m "#{message}"`
  `du -sh`
end

def git_status_time
   git_init
   before =  Time.now
   `git status`
   Time.now - before
end
#TODO How to deal with the input of password issue, when push the change to remote server
def git_push
  cc = `git push origin master`
end
