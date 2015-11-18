require 'renuo/cli/version'
require 'rubygems'
require 'renuo/cli/app/name_display'
require 'renuo/cli/app/local_storage'
require 'renuo/cli/app/migrate_to_github'

module Renuo
  class CLI
    def start
      require 'commander/import'
      program :version, Renuo::Cli::VERSION
      program :description, 'renuo CLI'

      command 'display-name'.to_sym do |c|
        c.syntax = 'renuo display-name [options]'
        c.summary = 'Sets the name of a customer on the Renuo dashboard'
        c.description = 'Sets the name of a customer on the Renuo dashboard'
        c.example 'Display "Peter Muster" on the dashboard', 'renuo display-name "Peter Muster"'
        c.example 'Remove the current name from the dashboard', 'renuo display-name --delete'
        c.option '--delete', 'Deletes the current name'
        c.action do |args, options|
          NameDisplay.new.run(args, options)
        end
      end

      command :config do |c|
        c.syntax = 'renuo config [options]'
        c.summary = ''
        c.description = 'Setup the config (API keys)'
        c.action do |_args, _options|
          key = ask('API Key?') { |q| q.echo = '*' }
          LocalStorage.new.store(:api_key, key)
          say('stored the api key')
        end
      end

      command 'migrate-to-github' do |c|
        c.syntax = 'renuo migrate-to-github [project]'
        c.summary = 'A guide how to migrate from gitlab to github'
        c.description = 'A guide how to migrate from gitlab to github'
        c.example 'migrate the renuo-cli project', 'renuo migrate-to-github renuo-cli'
        c.action do |args, _options|
          MigrateToGithub.new(args.first).run
        end
      end
    end
  end
end
