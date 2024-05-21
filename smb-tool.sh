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
    read -p "Enter the username with acces to the share (empty for all): " share_user
    mkdir -p $share_path


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

    echo "include = /etc/samba/smb.conf.d/$share_name.conf" >> /etc/samba/includes.conf
    # Restart the Samba service
    systemctl restart smbd
    

    }


function add_samba_user() {

    read -p "Enter the username for the new samba user: " smb_user
    
    smbpasswd -a $smb_user 

    ente

}


function delete_share() {
    read -p "Enter the share name to delete: " share_name

    # Remove the Samba share configuration
    sed -i "/^\[$share_name\]/,/^$/d" /etc/samba/smb.conf

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