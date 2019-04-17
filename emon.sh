#!/bin/bash

:'
Author : RMJ (rahul.juliato@gmail.com)

Date   : v0.1 - 05.12.2015
         v0.2 - 17.04.2019 (fixed some minor bugs)

Program: eMON v0.1

Description: A tool for "fast and lazy" changes 
         of video outputs configurations. 
         It does nothing but being a sort of interface
         to the xrandr software.

License information: GPL2
https://www.gnu.org/licenses/gpl-2.0.html
'


#Variables
version=0.2
counte=0
stuff=0


console(){

    auth='^[0-9]+$'
    error=1

    while [[ $error == 1 ]]
    do
        printf "\neMON>>> "
        if [[ $1 != 1 ]]
        then
            read -rn 1 stuff
        else        
            read -r stuff
        fi
        
        if ! [[ $stuff =~ $auth ]]
        then
            printf "\nError:  Not a number. Try again or Ctrl-C to exit.\n"
        else
            error=0
        fi
    done

}


splash(){

    clear
    printf "
    
          __  __  ___  _   _ 
      ___|  \/  |/ _ \| \ | |   
     / _ \ |\/| | | | |  \| |
    |  __/ |  | | |_| | |\  |
     \___|_|  |_|\___/|_| \_|
                             

    "
    printf "\n\n...a xrandr util for lazyness sake.\n"
    printf "Version: %s \n" "$version"
    printf "by RMJ (rahul.juliato@gmail.com)\n"
    printf "\n"
    
}

relation_to(){

    counte=0

    while [ $counte -lt ${#listing[@]} ]
    do

        counte=$((counte+1))
        printf "%s.) %s \n" "$counte" "${listing[$counte]}"
    
    done

}


listing(){

    counte=0
    printf "\nShowing all devices avaiable and their status:\n"
        while IFS= read -r line
        do
            counte=$((counte+1))
            v_name=$( echo "$line" | cut -d " " -f 1 )
            v_status=$(echo "$line" | cut -d " " -f 2)
            listing[$counte]="$v_name"
            printf "%s.) %s %s\n" "$counte" "$v_name" "$v_status"
        done < <(xrandr | grep -i "Connected")
   
    #for debuggind    
    #printf "\nArray %s \n" "${listing[@]}"
}



modes(){

    task=0
    counte=0
    modelist=0

    printf "\nShowing all modes avaiable for %s:\n\n" "$monitor"
        while IFS= read -r line
        do
            v_name=$( echo "$line" | cut -d " " -f 1 )

            if [[ $v_name == "$position" ]]
            then
                task=0
            fi

            if [[ $task == 1 ]]
            then
                counte=$((counte+1))
                modelist[$counte]=$( echo "$line" | cut -d " " -f 4 )
                printf "%s.) %s \n" "$counte" "$line"
            fi

            if [[ $v_name == "$monitor" ]]
            then    
                task=1
            fi

        done < <(xrandr)

    printf "\n* marks the current mode. \n"

}



options(){

    clear
    monitor=${listing[stuff]}
    printf "\nShowing the current configuration for %s:\n\n" "$monitor"
    xrandr | grep "$monitor"
    
    printf "\nOptions:"
    printf "
    1.) Try to auto-configure and turn on
    2.) Set as preferred
    3.) Turn off
    4.) Change resolution (mode)
    5.) Put this above other
    6.) Put this below other
    7.) Put this left of other
    8.) Put this right of other
    9.) Rotate to normal
    10.) Rotate to left
    11.) Rotate to right
    12.) Rotate to inverted
    "

    printf "\nChoose your option and hit ENTER\n"

    console 1 

    case $stuff in

        1) xrandr --output "$monitor" --auto;;
        
        2) xrandr --output "$monitor" --preferred;;

        3) xrandr --output "$monitor" --off;;

        4) clear
            modes
            printf "\nType the number of the mode you want\n"
            printf "change to and hit ENTER:\n"
            console 1
            xrandr --output "$monitor" --mode "${modelist[$stuff]}" 
            #printf " xrandr --output $monitor --mode ${modelist[$stuff]} "
            #printf "\nMode changed. Hit ENTER do Continue.\n"
            #read
            ;;

        5) printf "Choose the number of the output you want %s above:\n" "$monitor"
            relation_to
            console
            xrandr --output "$monitor" --above "${listing[stuff]}" ;;

        6) printf "Choose the number of the output you want %s below:\n" "$monitor"
            relation_to
            console
            xrandr --output "$monitor" --below "${listing[stuff]}" ;;

        7) printf "Choose the number of the output you want %s left of:\n" "$monitor"
            relation_to
            console
            xrandr --output "$monitor" --left-of "${listing[stuff]}" ;;

        8) printf "Choose the number of the output you want %s right of:\n" "$monitor"
            relation_to
            console
            xrandr --output "$monitor" --right-of "${listing[stuff]}" ;;

        9) xrandr --output "$monitor" --rotate normal;;

        10) xrandr --output "$monitor" --rotate left;;

        11) xrandr --output "$monitor" --rotate right;;

        12) xrandr --output "$monitor" --rotate inverted;;

        *) echo "This is not an option, please hit ENTER."
            read -r;;
    esac

   
}




mainmenu(){

    while :
    do
        splash

        listing

        printf "\nEnter the number of the device you want to manage\n"
        printf "or hit Ctrl-C to exit the script:"
        
        console

        position=${listing[$((stuff+1))]}

        if [ "$stuff" -eq "0" ]
        then
            stuff=100
        fi

        if [ $stuff -le ${#listing[@]} ] 2> /dev/null
        then
            options
        else
            printf "\nYou did not entered a valid number.\n"
            printf "\nPress any key to try again.\n"
            read -r -s -n 1
        fi
    done

}



mainmenu


