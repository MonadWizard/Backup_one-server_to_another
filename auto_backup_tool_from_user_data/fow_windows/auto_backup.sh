#!/usr/bin/bash


if [ -install == "$1" ] || ([ ! -backup == "$1" ] && [ ! -uninstall == "$1" ] && [ --help == "$1" ] && [ -h == "$1" ])
then

    read -p "Enter source directory path : " -r source_path
    read -p "Type 1 for Full Backup or Type 2 for only New file Backup : " -r backup_type
    read -p "Enter Backup server ip address : " -r backup_server_ip
    read -p "Enter Backup server port : " -r backup_server_port
    read -p "Enter Backup server username : " -r backup_server_username
    IFS= read -r -e -p "Enter Backup server user password : " -r -s backup_server_password
    read -p "Enter the path of the folder where backed up : " -r backup_path
    read -p "Enter recicle backup hour : " -r backup_hour

    pwd=$(pwd)


    # rm -rf $pwd/config 
    
    nowD=$(date +%F)
    nowT=$(date +%T)

    config_path=~/backup_tool_config
    rm -rf $config_path
    if [[ ! -e $config_path/config ]]; 
    then
        mkdir ${config_path}
        touch ${config_path/config}
        touch ${config_path/transperlog.txt}
    fi

    # echo $backup_path

    echo source_path: "$source_path" >> $config_path/config
    echo backup_type: "$backup_type" >> $config_path/config
    echo backup_server_ip: "$backup_server_ip" >> $config_path/config
    echo backup_server_port: "$backup_server_port" >> $config_path/config
    echo backup_server_username: "$backup_server_username" >> $config_path/config
#    echo backup_server_password: "$backup_server_password" >> $config_path/config

    encript_pass=$(echo "$backup_server_password" | openssl enc -aes-256-cbc -md sha512 -a -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)
# encripted password......
    echo backup_server_password: "$encript_pass" >> $config_path/config

    echo backup_path: "$backup_path" >> $config_path/config
    echo backup_hour: "$backup_hour" >> $config_path/config
    echo now: "$nowD $nowT" >> $config_path/config

    echo "Backup Configurations saved"

    echo you are connected as backup_server >> $config_path/welcome

    # need to add cron job to run auto backup script every day at $backup_hour

    values="$config_path/config"

    while IFS=': ' read -r key value; do
        declare $key="$value"
    done < $values

        # backup all files
    # decripted password...........
    decript_pass=$(echo $backup_server_password | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)

    # echo "$backup_server_password" | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#
    
    # echo "backup_server_password: $decript_pass"




    sshpass -p "$decript_pass" scp -P $backup_server_port -r $config_path/welcome $backup_server_username@$backup_server_ip:"$backup_path" > $config_path/transperlog.txt

# create cron job to run auto backup script every day at $backup_hour
    croncmd="$config_path/auto_backup.sh -backup"
    cronjob="0 */$backup_hour * * * $croncmd"

    # echo "$cronjob"
    echo cronjob_added: "$cronjob" >> $config_path/config

# add cornjob to crontab
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

# unstall cron job
    # ( crontab -l | grep -v -F "$croncmd" ) | crontab -


    # commend out at last it complete......................
    cp "$(readlink -f $0)" "$config_path"

    # mv "$(readlink -f $0)" "$config_path"        #...................................
    exit 1
fi


if [ -backup == "$1" ]
then

    # pwd=$(pwd)
    config_path=~/backup_tool_config
    values="$config_path/config"

    while IFS=': ' read -r key value; do
        declare $key="$value"
    done < $values

    # backup all files
    # decripted password...........
    decript_pass=$(echo $backup_server_password | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:Secret@123#)




    if [ 1 == "$backup_type" ]
    then
        # echo "Full Backup"
        
        echo "'$backup_path'"

        sshpass -p "$decript_pass" scp -P $backup_server_port -r $source_path $backup_server_username@$backup_server_ip:"$backup_path" > $config_path/transperlog.txt


        echo "Backup file created"
    else

        echo "Only New File Backup"

        # find ~/AGL_DBBackup/DataBases -type f -newermt '2022-05-21 11:02:22' > tmp

        find $source_path -type f -newermt "$now" -exec sshpass -p "$decript_pass" scp -P $backup_server_port -r {} $backup_server_username@$backup_server_ip:"$backup_path" > $config_path/transperlog.txt \; 
        
        # backup only new files
        echo "Backup file created"



    fi

    exit 1
fi

if [ -uninstall == "$1" ]
then

    config_path=~/backup_tool_config
    values="$config_path/config"

    while IFS=': ' read -r key value; do
        declare $key="$value"
    done < $values
    
    echo "Uninstallation started"

    echo "$cronjob_added"

# add cornjob to crontab
    # ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

# unstall cron job
    ( crontab -l | grep -v -F "$cronjob_added" ) | crontab -


    exit 1
fi



if [ --help == "$1" ] || [ -h == "$1" ]
then

    echo " user following flags to execute the script"
    echo " -install : to install the script"
    echo " -uninstall : to uninstall the script"
    echo " --help : to show this help"
    echo " -h : to show this help"

    echo " -backup work automatically. It need config file to work"
    echo " -backup : to backup the files"    

    exit 1
fi




exit 0










