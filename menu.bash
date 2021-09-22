#!/bin/bash

# Storyline: Menu for admin, VPN, and security functions

function invalid_opt() {

         echo""
         echo "Invalid option"
         echo ""
         sleep 2
}

function menu() {

        # clears the screen
        clear

        echo "[1] Admin Menu"
        echo "[2] Security Menu"
        echo "[3] Exit"
        read -p "Please enter a choice above:"  choice

        case "$choice" in

                1) admin_menu
                ;;
                2) security_menu
                ;;
                3) exit 0
                ;;
                *)
                invalid_opt

                        # Call the main menu
                        menu
                ;;
        esac

}

function admin_menu() {
        clear
        echo "[L]ist Running Processes"
        echo "[N]etwork Sockets"
        echo "[V]PN Menu"
        echo "[B]ack to main menu"
        echo "[4] Exit"
        read -p "Please enter a choice above:"  choice

        case "$choice" in

                L|l) ps -ef |less

                ;;
                N|n) netstat -an --inet |less
                ;;
                V|v) vpn_menu
                ;;
                B|b) menu
                ;;
                4) exit 0
                ;;

                *)

                        invalid_opt
                ;;

        esac
admin_menu
}

function security_menu() {
        clear
        echo "[L]ist open network sockets"
        echo "[C]heck if any user besides root has a UID of 0"
        echo "[S]ee the last 10 logged in users"
        echo "[U]sers currently logged in"
        echo "[B]ack to menu"
        echo "[E]xit"
        read -p "Please enter a choice above:" choice

        case "$choice" in

                L|l) netstat -tulpn | grep LISTEN |less
                ;;
                C|c) cat /etc/passwd | awk -F: '($3 == 0) { print $1}' |less
                ;;
                S|s) last -10 |less
                ;;
                U|u) who |less
                ;;

                B|b) menu
                ;;
                E|e) exit 0
                ;;
                *)

                        invalid_opt

                ;;

         esac
security_menu
}
function vpn_menu() {
        clear
        echo "[A]dd a peer"
        echo "[D]elete a peer"
        echo "[B]ack to admin menu"
        echo "[M]ain menu"
        echo "[E]xit"
        read -p "Please select an option: " choice

        case "$choice" in

        A|a)

        bash peer.bash

        tail -6 wg0.conf |less

        ;;
        D|d) echo -n "What is the peers name you would like to delete?"
                read del_peer

                bash manage-users.bash -d -u ${del_peer}

        ;;

  esac
security_menu
}
function vpn_menu() {
        clear
        echo "[A]dd a peer"
        echo "[D]elete a peer"
        echo "[B]ack to admin menu"
        echo "[M]ain menu"
        echo "[E]xit"
        read -p "Please select an option: " choice

        case "$choice" in

        A|a)

        bash peer.bash

        tail -6 wg0.conf |less

        ;;
        D|d) echo -n "What is the peers name you would like to delete?"
                read del_peer

                bash manage-users.bash -d -u ${del_peer}

        ;;
        B|b) admin_menu
        ;;
        M|m) menu
        ;;
        E|e) exit 0
        ;;
        *)
                invalid_opt
        ;;

        esac

vpn__menu


}
# Call the main function

menu


