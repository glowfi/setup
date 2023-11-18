#!/bin/fish

# Script Directory
set SCRIPT_DIR (cd (dirname (status -f)); and pwd)
set DETECT_INIT_SCRIPT (echo "$SCRIPT_DIR/detectInit.sh")

function install

    # Constants
    set max_iteration 5
    set initType (bash "$DETECT_INIT_SCRIPT")

    if [ "$initType" = systemD ]
        echo "Detected :"
        echo -e "\e[1;34mInit -> $initType \nDistro -> [Arch]\e[0m"
    else
        echo "Detected :"
        echo -e "\e[32mInit -> $initType \nDistro -> [Artix]\e[0m"
    end

    # Handle Repository
    if test "$argv[2]" = pac
        for package in (string split " " $argv[1])
            set iteration 1
            for i in (seq "$max_iteration")
                set packageExist (pacman -Ss "$package-$initType")
                if [ "$packageExist" != "" ]
                    sudo pacman -S --noconfirm "$package-$initType" && break
                else
                    sudo pacman -S --noconfirm "$package" && break
                end
                set iteration (math $iteration + 1)
            end
            # Check Success
            if test "$iteration" = "$max_iteration"
                # Append Failed to install packages to a file
                echo "$package" >>"$SCRIPT_DIR/err.txt"
            else
                echo "All packages installed successfully!"
            end
        end
    else if test "$argv[2]" = yay
        for package in (string split " " $argv[1])
            for i in (seq "$max_iteration")
                yay -S --noconfirm $package && break
                set iteration (math $iteration + 1)
            end
            # Check Success
            if test "$iteration" = "$max_iteration"
                # Append Failed to install packages to a file
                echo "$package" >>"$SCRIPT_DIR/err.txt"
            else
                echo "All packages installed successfully!"
            end
        end
    end
end
