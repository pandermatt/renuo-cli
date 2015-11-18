class MigrateToGithub
  def initialize(project_name)
    @project_name = project_name
    @pwd = `pwd`.strip
  end

  def run
    return stop unless check_pwd

    transfer_git
    update_readme
    repo_settings
    check_deploy
    rename_repo
    setup_ci
    congrats
  end

  private

  def check_pwd
    say("Project to transfer is called '#{@project_name}'. Thus, we will create and delete the directories")
    say("* #{@pwd}/#{@project_name}")
    say("* #{@pwd}/#{@project_name}.git")
    agree('Is that ok?')
  end

  def transfer_git
    `git clone --mirror git@git.renuo.ch:renuo/#{@project_name}.git`
    `cd #{@project_name}.git && hub create -p renuo/#{@project_name}`
    `cd #{@project_name}.git && git push --mirror git@github.com:renuo/#{@project_name}.git`
    `rm -rf #{@project_name}.git`
  end

  def update_readme
    agree('Let us update the README.md now. Ready?')

    `git clone git@github.com:renuo/#{@project_name}.git`
    `cd #{@project_name} && git fetch --all && git checkout develop && git pull && git flow init -d`
    File.write("#{@project_name}/README.md", File.read("#{@project_name}/README.md").gsub('git.renuo.ch', 'github.com'))

    update_readme_loop

    `cd #{@project_name} && git commit -m 'migrate to github' && git push --set-upstream origin develop`
    `rm -rf #{@project_name}`
  end

  def update_readme_loop
    loop do
      puts `cd #{@project_name} && git add . && git status && git diff --staged`
      break if agree('Does this look ok?')
      ask("Please change it manually in #{@pwd}/#{@project_name}. Hit enter when you are done.")
    end
  end

  def repo_settings
    general_repo_settings
    repo_collaborators
    repo_branches
    copy_hooks
  end

  def general_repo_settings
    say('The repo settings are next')
    say('Remove the features "Wikis" and "Issues"')
    say('Close the tab when you are done')
    agree('The browser will open automatically. Ready?')
    `open https://github.com/renuo/#{@project_name}/settings`
  end

  def repo_collaborators
    say("Next, assign Renuo-Team 'Renuo | Master' to project")
    agree('Ready?')
    `open https://github.com/renuo/#{@project_name}/settings/collaboration`
  end

  def repo_branches
    say('Choose develop as default branch')
    say('Protect branches master and develop')
    agree('Ready?')
    `open https://github.com/renuo/#{@project_name}/settings/branches`
  end

  def copy_hooks
    say('Copy the hooks from gitlab to github. We will open two tabs this time (gitlab and github)')
    agree('Ready?')
    `open https://github.com/renuo/#{@project_name}/settings/hooks`
    `open https://git.renuo.ch/renuo/#{@project_name}/hooks`
  end

  def check_deploy
    say('Check the deployment scripts for the correct repository')
    agree('Ready?')
    `open https://deploy.renuo.ch/deployment_configs`
    say('Now login to the deployment server, and change the remotes. E.g.')
    cd = "cd deployments/#{@project_name}"
    say("#{cd}-master && git remote set-url origin git@github.com:renuo/#{@project_name}.git && cd ..")
    say("#{cd}-develop && git remote set-url origin git@github.com:renuo/#{@project_name}.git && cd ..")
    say("#{cd}-testing && git remote set-url origin git@github.com:renuo/#{@project_name}.git && cd ..")
    agree('Ready?')
  end

  def rename_repo
    say("Almost done. Rename the old repo to zzz-old-#{@project_name}")
    say('* Project name')
    say('* Path')
    agree('Ready?')
    `open https://git.renuo.ch/renuo/#{@project_name}/edit`
  end

  def setup_ci
    say('One last thing: CI')
    say('Find your CI script on the old CI:')
    say('Click on <project> --> Settings --> preview')
    agree('Ready?')
    `open https://ci.renuo.ch/`
    say("Enable TravisCI for #{@project_name}")
    agree('Ready?')
    `open https://magnum.travis-ci.com/profile/renuo`
  end

  def congrats
    agree("That's it! Congrats!!")
    agree('I hope you enjoy Github and TravisCI!')
    agree('Cheers!')
  end

  def stop
    say('Command aborted.')
  end
end
