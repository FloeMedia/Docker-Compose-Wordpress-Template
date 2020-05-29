#!/usr/bin/env bash

CMD=$1
ARG1=$2
ARG2=$3
ARG_COUNT=$#

help() {
    echo Database Utilities:
    printf "\t* ./cli.sh db_b [database]            - Creates a backup of the database \"database\" and saves it as \"filename\"\n"
    printf "\t* ./cli.sh db_i [database] [filename] - Imports \"filename\" to database \"database\"\n"
    echo;
    echo File Utilities:
    printf "\t* ./cli.sh f_b                        - Creates a backup of the files in backups/ directory\n"
    printf "\t* ./cli.sh f_i [archive]             - Imports an archive created with this script. Creates a backup first for safety\n"
    printf "\t* ./cli.sh f_p                        - Fixes file permissions\n"
    exit
}

ensure_arg_count() {
    if test "$ARG_COUNT" -lt $1; then
        echo "Not enough arguments."; echo
        help
    fi
}

ensure_file_exists() {
    if ! test -e "$1"; then
        echo "File \"$1\" does not exist :("; echo
        exit
    fi
}

cooldate() {
    printf "$(date +%F_%T)"
}

backup_db() {
    read -p "DB Password: " -s PASS
    mkdir -p backups/db
    docker-compose exec -T db mysqldump --password=$PASS "$ARG1" 1> "backups/db/$1"
}

import_db() {
    read -p "DB Password: " -s PASS
    cat "$2" | docker-compose exec -T db mysql -u root --password="$PASS" $1
}

backup_files() {
    mkdir -p backups/wp
    sudo tar -czvf "backups/wp/$1" -C data/wordpress wp-content .htaccess wp-config.php
}

import_files() {
    CURTIME=$(cooldate)
    DIR=tmp/import-$CURTIME
    mkdir -p $DIR
    tar -xzf $1 -C $DIR

    if test -e "$DIR/.htaccess"; then
        sudo rm data/wordpress/.htaccess
        sudo cp "$DIR/.htaccess" data/wordpress/
    fi

    if test -e "$DIR/wp-config.php"; then
        sudo rm data/wordpress/wp-config.php
        sudo cp "$DIR/wp-config.php" data/wordpress/
    fi

    if test -e "$DIR/wp-content/"; then
        sudo rm -rf data/wordpress/wp-content
        sudo cp -r "$1" data/wordpress/wp-content
    fi

    sudo rm -rf tmp/
}

fix_file_permissions() {
    sudo chown -R 33:33 data/wordpress # chown to www-data group
    sudo find data/wordpress -type f -exec chmod 644 {} +
    sudo find data/wordpress -type d -exec chmod 755 {} +
    sudo chmod 640 data/wordpress/wp-config.php
    sudo chmod 644 data/wordpress/.htaccess
}

ensure_arg_count 1

case "$CMD" in
    db_b)
        ensure_arg_count 2
        backup_db "$ARG1-$(cooldate).sql"
        ;;

    db_i)
        ensure_arg_count 2
        import_db "$ARG1" "$ARG2"
        ;;

    f_b)
        backup_files "$(cooldate).tar.gz"
        ;;

    f_i)
        ensure_arg_count 2
        ensure_file_exists "$ARG1"
        echo "Making a backup before import..."
        backup_files "PRE_IMPORT-$(cooldate).tar.gz"
        echo "Importing..."
        import_files "$ARG1"
        echo "Fixing permissions of imported files..."
        fix_file_permissions
        ;;

    f_p)
        fix_file_permissions
        ;;
    *)
      echo Unknown Option \"$CMD\"; echo
      help
esac
