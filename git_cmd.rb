@git_local_directory = "../workspace"

#The directory of git project
def git_init
  Dir.chdir(@git_local_directory)
end

def get_size dirs
  depot_size = []
  dirs.each do |dir|
    size = `du -sh #{dir}`
    depot_size << size[0,size.index("\t")]
  end
  depot_size
end

# commit the change.
def git_commit message
  git_init
  message.gsub!(/["]/,"'")  # deal the comments contain double question marks"
  `git add -A .`
  `git commit -m "#{message}"`
  git_push
  dirs = ['../trunk.git/','../workspace/.git/','../workspace/']
  get_size dirs
end

def git_status_time
   git_init
   before =  Time.now
   `git status`
   Time.now - before
end

def git_push
  cc = `git push origin master`
end

