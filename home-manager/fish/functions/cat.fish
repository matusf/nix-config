function cat
	if [ (count $argv) -ne 0 ] && [ -d $argv[1] ]
        	l $argv
        else
        	bat -p $argv
        end
end

