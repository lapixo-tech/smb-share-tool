#!/bin/bash

function set_samba() {

        SMB_CONF_FILE=/etc/samba/smb.conf
        SMB_SHARE_CONF_DIR=/etc/samba/smb.conf.d/
        SMB_INCLUDES_FILE=/etc/samba/includes.conf

        if !  grep -q 'include = '"${SMB_INCLUDES_FILE}" $SMB_CONF_FILE ; then

            echo 'include = '"${SMB_INCLUDES_FILE}" | tee -a $SMB_CONF_FILE > /dev/null
        fi

        mkdir -p $SMB_SHARE_CONF_DIR 

    }

#function get_existing_shares() {}

function add_share() {
    read -p "Enter the share name: " share_name
    read -p "Enter the path to the shared folder: " share_path
    # Check if share path exists

    if ! [ "${share_path:0:1}" = "." ]; then
        share_path="$(pwd)/"
    fi  

    if [ -d "$share_path" ]; then
        echo "-> Share path already exists .. nothing to do"
    else
        # Create the directory if it doesn't exist
        mkdir -p "$share_path"
        echo "-> Directory does not exist - creating..." 
        echo "-> Share path created successfully"
    fi

    read -p "Enter the username with acces to the share (empty for all): " share_user




    if [[ -n "$share_user" ]]; then
        valid_user_line="valid user = @$share_user"
    else
        valid_user_line=""
    fi

    touch /etc/samba/smb.conf.d/$share_name.conf



    cat << EOF >> /etc/samba/smb.conf.d/$share_name.conf

    [$share_name]
    path = $share_path
    $valid_user_line
    writable = Yes
    create mask = 0777
    directory mask = 0777
    public = no

EOF

    echo "Setting ownership of $share_path for user $shared_user" 
    chown $share_user:$share_user $share_path 
    echo "include = /etc/samba/smb.conf.d/$share_name.conf" >> /etc/samba/includes.conf
    # Restart the Samba service
    systemctl restart smbd
    echo "-> Samba Restarted"
    echo "-> Access the share in Widnows: \\[THIS SERVER IP]\{$share_name}"
    echo "-> Access the share in Linux: smb://[THIS SERVER IP]\{$share_name}"


if [ -d "$share_path" ]; then
    echo "Share path already exists"
else
    mkdir -p "$share_path"
    echo "Share path created successfully"
fi
    

    }


function add_samba_user() {

    read -p "Enter the username for the new samba user: " smb_user
    
    smbpasswd -a $smb_user 

    ente

}


function delete_share() {
    
    
    
    SMB_SHARE_CONF_DIR=/etc/samba/smb.conf.d/

    # List all .conf files in the directory
    conf_files=($SMB_SHARE_CONF_DIR*.conf)
    
    # Check if any .conf files exist
    if [ ${#conf_files[@]} -eq 0 ]; then
        echo "No .conf files found for samba shares"
        return
    fi

    IFS=$'\n'
    config_files=($(sort <<<"${config_files[*]}"))
    unset IFS 
    # Display the menu options
    echo "Select the samba share to delete:"
    for (( i=0; i<${#conf_files[@]}; i++ )); do
        share_name_temp=$(basename "${conf_files[i]}")
        share_name="${share_name_temp%.*}"
        echo "$((i+1)). ${share_name}"
    done

    # Read the user's selection
    read -p "Enter the number of the file to delete: " file_number

    # Validate the input
    if [[ $file_number =~ ^[0-9]+$ ]]; then
        # Verify if the selected number is within the range
        if (( file_number >= 1 && file_number <= ${#conf_files[@]} )); then
            # Get the selected file name
            file_name_path=${conf_files[file_number-1]}
            
            # Remove the file
            rm "$file_name_path"

            #removing line from includes.conf

            grep -v "$file_name_path" /etc/samba/includes.conf > /etc/samba/includes.conf.temp
            mv /etc/samba/includes.conf.temp /etc/samba/includes.conf

            share_name_temp=$(basename "${file_name_path}")
            share_name="${share_name_temp%.*}"

            echo "Samba share: $share_name deleted successfully."
        else
            echo "Invalid input. Please enter a valid number."
        fi
    else
        echo "Invalid input. Please enter a valid number."
    fi


    ## delete share typing name

    ##read -p "Enter the share name to delete: " share_name

    # Remove the Samba share configuration
    ## sed -i "/^\[$share_name\]/,/^$/d" /etc/samba/smb.conf

    # Restart the Samba service
    systemctl restart smbd
}

set_samba

# Check if Samba is installed
if ! dpkg -s samba &> /dev/null; then
    echo "Samba is not installed. Installing Samba..."
    apt-get update
    apt-get install -y samba
    echo "Samba installed successfully."
fi

while true; do
    
    echo ">>> SAMBA TOOLBOX <<<"
    echo "1. Add Samba Share"
    echo "2. Delete Samba Share"
    echo "3. Add Samba User"
    echo "4. Exit"

    read -p "Choose an option (1-3): " option

    case $option in
        1)
            echo "Adding a Samba share..."
            add_share
            ;;
        2)
            echo "Deleting a Samba share..."
            delete_share
            ;;
        3)

            echo "Create samba user..."
            add_samba_user
            ;;        
        
        4)
            echo "Exiting..."
            exit 0
            ;;
        
        *)
            echo "Invalid option. Try again."
            ;;
    esac

    echo
done