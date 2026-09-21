#!/usr/bin/env bash

APP_NAME="OTP-BOMBER"
APP_VERSION="1.0.0"

# ==========================================
# Colors
# ==========================================

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'


# ==========================================
# Project Directory
# ==========================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Always run from the directory containing this script
cd "$SCRIPT_DIR" || exit 1


# ==========================================
# Platform Detection
# ==========================================

detect_platform() {
    case "$OSTYPE" in
        darwin*)
            PLATFORM="macos"
            ;;

        linux-android*)
            PLATFORM="termux"
            ;;

        *)
            PLATFORM="unsupported"
            ;;
    esac
}


# ==========================================
# Command Detection
# ==========================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# ==========================================
# Clear Screen
# ==========================================

clear_screen() {
    if command_exists clear; then
        clear
    else
        printf '\033c'
    fi
}


# ==========================================
# Pause
# ==========================================

pause() {
    printf "\n${YELLOW}Press any key to continue...${RESET}"
    read -r -n 1
    echo
}


# ==========================================
# Banner
# ==========================================

banner() {

    clear_screen

    printf "${CYAN}"

    if command_exists figlet; then
        figlet "$APP_NAME"
    else
        echo "================================"
        echo "             $APP_NAME"
        echo "================================"
    fi

    printf "${RESET}"

    echo
    printf "${BLUE}OTP BOMBER CLI Toolkit${RESET}\n"
    printf "${WHITE}Version : ${APP_VERSION}${RESET}\n"
    printf "${WHITE}Platform: ${PLATFORM}${RESET}\n"
    echo
}


# ==========================================
# Install Package
# ==========================================

install_package() {

    package="$1"

    case "$PLATFORM" in

        termux)
            pkg install -y "$package"
            ;;

        macos)
            if command_exists brew; then
                brew install "$package"
            else
                printf "${RED}Homebrew is not installed.${RESET}\n"
                return 1
            fi
            ;;

    esac
}


# ==========================================
# Python Detection
# ==========================================

detect_python() {

    if command_exists python3; then
        PYTHON="python3"

    elif command_exists python; then
        PYTHON="python"

    else
        PYTHON=""
    fi
}


# ==========================================
# Dependencies
# ==========================================

check_dependencies() {

    echo
    printf "${CYAN}Checking dependencies...${RESET}\n"
    echo

    # Python

    if [ -z "$PYTHON" ]; then

        printf "${YELLOW}Python not found. Installing...${RESET}\n"

        if [ "$PLATFORM" = "termux" ]; then
            install_package python

        elif [ "$PLATFORM" = "macos" ]; then
            install_package python
        fi

        detect_python
    fi


    # Git

    if ! command_exists git; then

        printf "${YELLOW}Git not found. Installing...${RESET}\n"

        install_package git
    fi


    # Figlet - optional

    if ! command_exists figlet; then

        printf "${YELLOW}Figlet not found. Installing...${RESET}\n"

        install_package figlet 2>/dev/null || true
    fi


    echo

    if [ -n "$PYTHON" ]; then
        printf "${GREEN}Python: $PYTHON${RESET}\n"
    else
        printf "${RED}Python could not be installed.${RESET}\n"
        return 1
    fi

    if command_exists git; then
        printf "${GREEN}Git: Installed${RESET}\n"
    else
        printf "${RED}Git: Missing${RESET}\n"
    fi

    echo
}


# ==========================================
# Python Requirements
# ==========================================

install_python_requirements() {

    if [ -f "$SCRIPT_DIR/requirements.txt" ]; then

        echo
        printf "${CYAN}Installing Python requirements...${RESET}\n"
        echo

        "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt"

    else

        printf "${YELLOW}requirements.txt not found.${RESET}\n"

    fi
}


# ==========================================
# First Run
# ==========================================

initialize() {

    banner
    pause

    check_dependencies || exit 1

    if [ -f "$SCRIPT_DIR/.update" ]; then

        printf "${GREEN}All requirements found.${RESET}\n"

    else

        printf "${CYAN}Installing requirements...${RESET}\n"

        install_python_requirements

        echo "OTP-BOMBER $APP_VERSION" > "$SCRIPT_DIR/.update"

        printf "${GREEN}Requirements installed.${RESET}\n"

        pause
    fi
}


# ==========================================
# Run Python Application
# ==========================================

run_app() {

    if [ ! -f "$SCRIPT_DIR/main.py" ]; then

        printf "${RED}main.py was not found.${RESET}\n"
        printf "${YELLOW}Expected:${RESET} $SCRIPT_DIR/main.py\n"

        pause
        return
    fi

    "$PYTHON" "$SCRIPT_DIR/main.py"
}


# ==========================================
# Update
# ==========================================

# update_app() {

#     clear_screen

#     printf "${BLUE}Checking for updates...${RESET}\n"
#     echo

#     if [ -d "$SCRIPT_DIR/.git" ] && command_exists git; then

#         git -C "$SCRIPT_DIR" pull

#         echo

#         install_python_requirements

#         echo "OTP-BOMBER $APP_VERSION" > "$SCRIPT_DIR/.update"

#         printf "${GREEN}Update complete.${RESET}\n"

#     else

#         printf "${YELLOW}Git repository not found.${RESET}\n"
#         printf "${WHITE}Skipping Git update.${RESET}\n"

#     fi

#     pause
# }


# ==========================================
# Environment Information
# ==========================================

environment_info() {

    clear_screen

    echo
    printf "${CYAN}OTP-BOMBER Environment${RESET}\n"
    echo "-------------------------"

    echo "App       : $APP_NAME"
    echo "Version   : $APP_VERSION"
    echo "Platform  : $PLATFORM"
    echo "Directory : $SCRIPT_DIR"
    echo "Python    : ${PYTHON:-Not found}"

    if command_exists git; then
        echo "Git       : Installed"
    else
        echo "Git       : Missing"
    fi

    if command_exists figlet; then
        echo "Figlet    : Installed"
    else
        echo "Figlet    : Missing"
    fi

    echo

    pause
}


# ==========================================
# Main Menu
# ==========================================

menu() {

    while true
    do

        banner

        echo -e "${WHITE}Please select an option:${RESET}"
        echo

        echo -e "${GREEN}1${RESET}  Run OTP-BOMBER"
        echo -e "${GREEN}3${RESET}  Environment"
        echo -e "${GREEN}4${RESET}  Exit"

        echo

        read -r -p "Select: " choice

        case "$choice" in

            1)
                clear_screen
                run_app
                pause
                ;;

            3)
                environment_info
                ;;

            4)
                clear_screen
                printf "${CYAN}Thanks for using OTP-BOMBER.${RESET}\n"
                exit 0
                ;;

            *)
                printf "${RED}Invalid input.${RESET}\n"
                pause
                ;;

        esac

    done
}


# ==========================================
# Start
# ==========================================

detect_platform

if [ "$PLATFORM" = "unsupported" ]; then

    echo
    echo "OTP-BOMBER currently supports:"
    echo "  • macOS Terminal"
    echo "  • Android Termux"
    echo

    exit 1
fi


detect_python

initialize

menu