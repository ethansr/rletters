# Some custom support for gh-pages, cobbled together from gokdok
require 'grit'

def clear_git_vars
  %w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE).each { |var| ENV[var] = nil }
end

def run_git_command(command)
  clear_git_vars
  `git #{command}`
end

def find_repo_url
  re = Regexp.new("^origin[\t|\s]+([^\s]*)")
  md = re.match(`git remote -v`)
  raise(ArgumentError, "Cannot find out the repository URL.") unless(md)
  md[1]
end

namespace :doc do
  desc "Copy the documentation over to GitHub"
  task :gh_pages do
    repo_url = find_repo_url

    unless File.exists?('.gh_pages')
      puts "-> Setting up the local checkout of gh-pages"
      puts "-> Starting checkout of #{repo_url}"
      run_git_command("clone #{repo_url} .gh_pages -b gh-pages")
      puts "-> Repository cloned"
    end

    clear_git_vars
    repo = Grit::Repo.new(".gh_pages")
    remote_dir = File.join(".gh_pages", "api")
    puts "-> Deleting the old documentation in #{remote_dir}"
    FileUtils.rm_rf(remote_dir)
    puts "-> Copying in the app documentation"
    FileUtils.cp_r("doc/app", remote_dir)

    puts "-> Add and commit"
    Dir.chdir('.gh_pages')
    repo.add('.')
    repo.commit_all('Committed new app documentation from Rake')

    puts "-> Push to origin"
    run_git_command('pull origin gh-pages')
    run_git_command('push origin gh-pages')
  end
end
