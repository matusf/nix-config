function ccd --description "Create and cd to new directory"
    if set -q argv[1]
	mkdir -p $argv[1] && cd $argv[1]
    end
end

