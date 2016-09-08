#!/bin/bash

# Creates a command that creates a new terminal window and switches directories to a specified app 
# $1 => String - Name of the command we are going to create
# $2 => Boolean - Whether to run this app or not
# $3 => String - Name of the directory we want to change to
# $4 => String - Name of the app (which will be set to the name of the terminal window)
create_terminal_window() {
    if [ "$2" = true ] ; then 
        create_bash_command "$3" "runRails"
    else
        if [ "$2" = false ] ; then
            create_bash_command "$3"
        else
            create_bash_command "$3" "$2"
        fi
    fi
    eval_command+=' --tab --title="'
    eval_command+="$4"
    eval_command+='" -e "$'
    eval_command+="$1"
    eval_command+='"'
}

# Creates a bash command to change directories, and optionally update git, run sublime, runDocker or runRails
create_bash_command() {
    bash_command="bash -c \"cd $1;" 
    if [ "$FETCH" = true ] ; then
        bash_command="$bash_command git fetch;"
    fi

    if [ "$PULL" = true ] ; then
        bash_command="$bash_command git pull --rebase;"
    fi

    if [ "$SUBLIME" = true ] ; then
        bash_command="$bash_command subl .;"
    fi

    if [ "$2" = "runDocker" ] ; then
        bash_command="$bash_command ./runDocker.sh -b;"
    fi

    if [ "$2" = "createAll" ] ; then
        bash_command="$bash_command ruby user_create.rb --all;"
    fi

    if [ "$2" = "createBoth" ] ; then
        bash_command="$bash_command ruby user_create.rb --both;"
    fi

    if [ "$2" = "createPlenty" ] ; then
        bash_command="$bash_command ruby user_create.rb --plenty;"
    fi

    if [ "$2" = "createLow" ] ; then
        bash_command="$bash_command ruby user_create.rb --low;"
    fi

    if [ "$2" = "createSignature" ] ; then
        bash_command="$bash_command ruby user_create.rb --signature;"
    fi

    if [ "$2" = "runRails" ] ; then
        bash_command="$bash_command rails s;"
    fi

    bash_command="$bash_command exec bash\""
}

# Creates new terminal windows based on passed in parameters, and sets them globally so they can be called later
# $var => String - Current variable passed to the command
# $1   => String - The app we want to start
# $2   => String - The app that we want to run
# $3   => String - Name of the variable we will store the command inside (to call later)
# $4   => String - Directory we want to change to
# $5   => String - Name of the app (which will set the terminal window)
start_app() {
    if [ "$var" = "$1" ] || [ "$var" = "$2" ] ; then
        should_run=true;
        command_name="$3"
        if [ "$var" = "$1" ] ; then
            should_run=false;
            command_name="run_$3"
        fi
        create_terminal_window "$command_name" "$should_run" "$4" "$5"
        declare -g "$command_name"="$bash_command"
    fi
}

DOCKER=true

create_bash_command "~/src/unisporkal"
unisporkal="$bash_command"

# Command to create a number of new terminal windows. Global
eval_command='gnome-terminal --tab --title="Unisporkal" -e "$unisporkal"'

for var in "$@"
do
    if [ "$var" = '-h' ]  || [ "$var" = '--help' ] ; then HELP=true; fi 
    if [ "$var" = '-p' ]  || [ "$var" = '--pull' ] ; then PULL=true; fi
    if [ "$var" = '-f' ]  || [ "$var" = '--fetch' ] ; then FETCH=true; fi
    if [ "$var" = '-s' ]  || [ "$var" = '--sublime' ] ; then SUBLIME=true; fi
    if [ "$var" = '-nd' ] || [ "$var" = '--no-docker' ] ; then DOCKER=false; fi
    if [ "$var" = '-c' ]  || [ "$var" = '--create-user' ] || [ "$var" = '--create' ] ; then CREATE=true ; fi


    if [ "$var" = '--engine' ] ; then
        create_terminal_window "engine_command" false '~/src/unisporkal/gems/unisporkal_engine' 'Engine'
        declare "engine_command"="$bash_command"
    fi

    if [ "$var" = '--style' ] || [ "$var" = '--styles' ] ; then
        create_terminal_window "style_command" false '~/src/unisporkal/gems/unisporkal_styles' 'Styles'
        declare "style_command"="$bash_command"
    fi

    if [ "$var" = '--giproxy' ] || [ "$var" = '--gi-proxy' ] ; then
        create_terminal_window "gi_command" false '~/src/unisporkal/gi_proxy' 'GI Proxy'
        declare "gi_command"="$bash_command"
    fi

    start_app '--account' '--run-account' 'account_command' '~/src/unisporkal/account' 'Account'
    start_app '--collab' '--run-collab' 'collab_account' '~/src/unisporkal/collaboration' 'Collaboration'
    start_app '--gallery' '--run-gallery' 'gallery_command' '~/src/unisporkal/gallery' 'Gallery'
    start_app '--purchase' '--run-purchase' 'purchase_command' '~/src/unisporkal/purchase' 'Purchase'
    start_app '--landing' '--run-landing' 'landing_command' '~/src/unisporkal/landing' 'Landing App'
    start_app '--sign-in' '--run-sign-in' 'sign_in_command' '~/src/unisporkal/sign_in' 'Sign in'
    start_app '--search' '--run-search' 'search_command' '~/src/unisporkal/search' 'Search'

    if [ "$var" = '--asset' ] || [ "$var" = '--asset-detail' ] || [ "$var" = '--run-asset' ] || [ "$var" = '--run-asset-detail' ] ; then
        if [ "$var" = '--asset-detail' ] ; then var="--asset"; fi
        if [ "$var" = '--run-asset-detail' ] ; then var="--run-asset"; fi
        start_app '--asset' '--run-asset' 'asset_command' '~/src/unisporkal/asset_detail' 'Asset'
    fi
done

if [ "$HELP" = true ] ; then
    echo -e '\t\tAPPS'
    echo '===================================='
    echo -e '--account \t\t Start the account app \n--run-account \t\t Run the account app\n'
    echo -e '--collab \t\t Start the collaboration app \n--run-collab \t\t Run the collobration app\n'
    echo -e '--gallery \t\t Start the gallery app \n--run-gallery \t\t Run the gallery app\n'
    echo -e '--purchase \t\t Start the purchase app \n--run-purchase \t\t Run the purchase app\n'
    echo -e '--landing \t\t Start the landing app \n--run-landing \t\t Run the landing app\n'
    echo -e '--sign-in \t\t Start the sign-in app \n--run-sign-in \t\t Run the sign-in app\n'
    echo -e '--search \t\t Start the search app \n--run-search \t\t Run the search app\n'
    echo -e '--asset-detail \t\t Start the asset-detail app \n--run-asset-detail \t Run the asset-detail app\n'
    echo -e '\n\tOTHER COMMANDS'
    echo '=============================='
    echo -e '-h --help \t\t\t Show the help command'
    echo -e '-p --pull \t\t\t Pull the current repository down from git'
    echo -e '-f --fetch \t\t\t Fetch the current repository down from git'
    echo -e '-s --sublime \t\t\t Run the sublime commands from within the window'
    echo -e '-nd --no-docker \t\t Do not create a new docker instance'
    echo -e '-c --create-user --create \t Creates user(s) for candidate istock'
    exit
fi

if [ "$CREATE" = true ] ; then
    while true; do
        read -p "Please select a - all, b - both, s - signature, p - plenty, l - low, n -none: " yn
        case $yn in
            [Aa]* ) create_terminal_window "user_create_command" "createAll" "~" "Home" ; break;;
            [Bb]* ) create_terminal_window "user_create_command" "createBoth" "~" "Home" ; break;;
            [Ll]* ) create_terminal_window "user_create_command" "createLow" "~" "Home" ; break;;
            [Ss]* ) create_terminal_window "user_create_command" "createSignature" "~" "Home" ; break;;
            [Pp]* ) create_terminal_window "user_create_command" "createPlenty" "~" "Home" ; break;;
            [Nn]* ) create_terminal_window "user_create_command" false "~" "Home" ; break;;
            * ) ;;
        esac
    done
    declare "user_create_command"="$bash_command" ;
fi

if [ "$DOCKER" = true ] ; then
    create_bash_command "~/src/unisporkal/gi_proxy" "runDocker"
else 
    create_bash_command "~/src/unisporkal/gi_proxy"
fi
docker="$bash_command"
eval_command+=' --tab --title="Docker" -e "$docker"'

# echo "$eval_command"
eval "$eval_command"
kill -9 $PPID