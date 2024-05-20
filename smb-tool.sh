#!/bin/bash

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
     
cat << EOF >> /etc/samba/smb.conf
[$share_name]
comment = $share_name
path = $share_path
$valid_user_line
browseable = yes
read only = no
guest ok = yes
create mask = 0777
directory mask = 0777
EOF

        
    # Restart the Samba service
    systemctl restart smbd
    

    }

function delete_share() {
    read -p "Enter the share name to delete: " share_name

    # Remove the Samba share configuration
    sed -i "/^\[$share_name\]/,/^$/d" /etc/samba/smb.conf

    # Restart the Samba service
    systemctl restart smbd
}

#!/bin/bash

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
    echo "3. Exit"

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
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac

    echo
done