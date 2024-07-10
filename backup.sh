#!/bin/bash

# Function to prompt and validate backup directory
prompt_and_validate_backup_dir() {
    while true; do
        read -p "Enter the backup directory path (press Enter to use the current directory): " user_backup_dir
        
        # Use current directory if user presses Enter
        if [ -z "$user_backup_dir" ]; then
            # user_backup_dir is empty
            backup_dir="./backup_test"
            break
        elif [ -d "$user_backup_dir" ]; then
	    # user_backpu_dir is valid
            backup_dir="$user_backup_dir"
            break
        else
            echo "Invalid directory path. Please enter a valid directory."
        fi
    done
}

# Function to prompt user for backup type for each directory
prompt_user_for_directory() {
    echo "Choose backup type for directory '$1':"
    echo "1. Only backup the directory"
    echo "2. Only compress the directory"
    echo "3. Both backup and compress the directory"
    read -p "Enter your choice (1/2/3): " backup_type

    # Validate user input
    while [[ "$backup_type" != "1" && "$backup_type" != "2" && "$backup_type" != "3" ]]; do
        echo "Invalid choice. Please enter 1, 2, or 3."
        read -p "Enter your choice (1/2/3): " backup_type
    done
}

# Function to log messages with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Prompt and validate backup directory
prompt_and_validate_backup_dir

# Check if directories are provided
if [ $# -eq 0 ]; then
    echo "No directories were provided"
    exit 1
fi

# Timestamp for backup
timestamp=$(date +%Y%m%d_%H%M%S)
log_file="./backup_test.log"

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"
log_message "Backup directory set to '$backup_dir'."

# Log start of backup
log_message "Backup process started."

# Loop through each directory and backup
for dir in "$@"; do
    if [ -d "$dir" ]; then
        # Get the absolute path of the directory to backup
        abs_dir=$(realpath "$dir")
        log_message "Processing directory '$abs_dir'."
        
        # Get the parent directory and the base name of the directory to backup
        parent_dir=$(dirname "$abs_dir")
        base_dir=$(basename "$abs_dir")

        # Prompt user for backup type for the current directory
        prompt_user_for_directory "$dir"
        log_message "User selected backup type '$backup_type' for directory '$dir'."

        echo "------------- Start operation on $dir ------------"

        if [ "$backup_type" == "1" ] || [ "$backup_type" == "3" ]; then
            # Copy directory to backup location
            cp -r "$dir" "$backup_dir"
            if [ $? -eq 0 ]; then
                log_message "Backup of directory '$dir' completed successfully."
                # Get the size of the directory in KB
                dir_size=$(du -sk "$dir" | cut -f1)
                log_message "Backup size for '$dir': ${dir_size}KB."
		echo "Backup size for '$dir': ${dir_size}KB."
            else
                log_message "Backup of directory '$dir' failed."
            fi
        fi
        
        if [ "$backup_type" == "2" ] || [ "$backup_type" == "3" ]; then
            # Set the backup file name
            backup_file="backup_${base_dir}_$timestamp.tar.gz"
            
            # Perform compression
            tar -cf - -C "$parent_dir" "$base_dir" 2>> "$log_file" | zstd -q - > "$backup_dir/$backup_file"

            # Check if compression was successful
            if [ $? -eq 0 ]; then
                log_message "Compression of directory '$dir' completed successfully."
                # Calculate and report compressed file size
                compressed_size=$(du -sk "$backup_dir/$backup_file" | cut -f1)
                log_message "Compressed file size for '$dir': ${compressed_size}KB."
		echo "Compressed size for '$dir': ${compressed_size}KB."
            else
                log_message "Compression of directory '$dir' failed."
            fi
        fi
        
        echo "------------- End operation on $dir ------------"
        
    else
        log_message "Error: '$dir' is not a valid directory."
    fi
done

# Log end of backup
log_message "Backup process finished."

# Notify user about completion
echo "Process completed. Check $log_file for details."