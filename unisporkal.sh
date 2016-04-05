#!/bin/bash

generate_command() {
    if [ "$2" = true ] ; then 
        create_bash_command "$3" "runRails"
    else
        create_bash_command "$3"
    fi
    eval_command+=' --tab --title="'
    eval_command+="$4"
    eval_command+='" -e "$'
    eval_command+="$1"
    eval_command+='"'
}

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

    if [ "$2" = "runRails" ] ; then
        bash_command="$bash_command rails s;"
    fi

    bash_command="$bash_command exec bash\""
}

start_app() {
    if [ "$var" = "$1" ] || [ "$var" = "$2" ] ; then
        should_run=true; if [ "$var" = "$1" ] ; then should_run=false; fi
        generate_command "$3" "$should_run" "$4" "$5"
        declare -g "$3"="$bash_command"
    fi
}

DOCKER=true

create_bash_command "~/src/unisporkal"
unisporkal="$bash_command"

eval_command='gnome-terminal --tab --title="Unisporkal" -e "$unisporkal"'

for var in "$@"
do
    if [ "$var" = '-p' ]  || [ "$var" = '--pull' ] ; then PULL=true; fi
    if [ "$var" = '-f' ]  || [ "$var" = '--fetch' ] ; then FETCH=true; fi
    if [ "$var" = '-s' ]  || [ "$var" = '--sublime' ] ; then SUBLIME=true; fi
    if [ "$var" = '-nd' ] || [ "$var" = '--no-docker' ] ; then DOCKER=false; fi

    if [ "$var" = '--engine' ] ; then
        generate_command "engine_command" false '~/src/unisporkal/gems/unisporkal_engine' 'Engine'
        declare "engine_command"="$bash_command"
    fi

    if [ "$var" = '--style' ] || [ "$var" = '--styles' ] ; then
        generate_command "style_command" false '~/src/unisporkal/gems/unisporkal_styles' 'Styles'
        declare "style_command"="$bash_command"
    fi

    if [ "$var" = '--giproxy' ] || [ "$var" = '--gi-proxy' ] ; then
        generate_command "gi_command" false '~/src/unisporkal/gi_proxy' 'GI Proxy'
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