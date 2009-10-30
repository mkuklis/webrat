require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class Rails < Webrat::Selenium::ApplicationServers::Base

        def start
          if windows?
            @shell.run remove_service, {:background => true }
            @shell.run install_service, {:background => false }
          end
          @shell.run start_command, {:background => true}
        end

        def stop
          silence_stream(STDOUT) do
            @shell.run stop_command, {:background => false}
            if windows?
              @shell.run remove_service, {:background => false }
            end
          end
        end

        def fail
          $stderr.puts
          $stderr.puts
          $stderr.puts "==> Failed to boot the Rails application server... exiting!"
          $stderr.puts
          $stderr.puts "Verify you can start a Rails server on port #{Webrat.configuration.application_port} with the following command:"
          $stderr.puts
          $stderr.puts "    #{start_command}"
          exit
        end

        def pid_file
          prepare_pid_file("#{RAILS_ROOT}/tmp/pids", "mongrel_selenium.pid")
        end
        
        def install_service
          "mongrel_rails service::install -N testapp -c #{RAILS_ROOT} -p #{Webrat.configuration.application_port} -e test"
        end
        
        def remove_service
          "mongrel_rails service::remove -N testapp"
        end
        
        def start_command
          if windows?
            "net start testapp"
          else 
            "mongrel_rails start -d --chdir='#{RAILS_ROOT}' --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} --pid #{pid_file}"
          end
        end

        def stop_command
          if windows?
            "net stop testapp"
         else
            "mongrel_rails stop -c #{RAILS_ROOT} --pid #{pid_file}"
          end
        end

      end
    end
  end
end
