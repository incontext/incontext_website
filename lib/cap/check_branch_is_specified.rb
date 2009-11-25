Capistrano::Configuration.instance(:must_exist).load do
  task :check_branch_name do
    # I tried to use defined? here but it doesn't work.
    begin
      branch
    rescue
      printf "You must specify a tag\n\n  use -s branch=<tag name> to specify the tag\n\n"
      exit
    end
  end
end
