#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

#ctrl+c 
trap ctrl_c INT

function helPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}${purpleColour} $0${endColour}\n"
  echo -e "\t${blueColour}-m)${endColour}${grayColour} Dinero con el que se desea jugar${endColour}"
  echo -e "\t${blueColour}-t)${endColour}${grayColour} Técnica a utilizar${endColour} ${purpleColour}(${endColour}${yellowColour}martingala${endColour}${blueColour}/${endColour}${yellowColour}inverseLabrouchere${endColour}${purpleColour})${endColour}"
  echo -e "\t${blueColour}-h)${endColour}${grayColour} Llamar a este panel de ayuda${endColour}\n"
}

function martingala(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual: ${endColour}${purpleColour}\$$money${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿Cuánto dinero tienes pensado apostar? -> ${endColour}" && read initial_bet
  if ! [[ "$initial_bet" =~ ^[0-9]+$ ]]; then
    echo -e "${redColour}[!] Entrada inválida. Debes ingresar un número entero positivo.${endColour}"
    tput cnorm; exit 1
  fi
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
  if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ]; then
   echo -e "${redColour}[!] Entrada inválida. Debes ingresar 'par' o 'impar'.${endColour}"
   tput cnorm; exit 1
  fi
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con una cantidad inicial de ${endColour}${yellowColour}\$$initial_bet${endColour}${grayColour} a${endColour}${yellowColour} $par_impar${endColour}"

  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas="[ "
  tope_money=$money

  tput civis
  while true; do
    money=$(($money-$initial_bet))
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Acabas de apostar${endColour}${yellowColour} \$$initial_bet${endColour}${grayColour} y tienes${endColour}${purpleColour} \$$money${endColour}"
    random_number="$(($RANDOM % 37))"
    echo -e "${yellowColour}[+]${endColour}${grayColour} Ha salido el número ${endColour}${yellowColour}$random_number${endColour}"
   
    if [ ! "$money" -lt 0 ];then 
      if [ "$par_impar" == "par" ]; then
        # Toda esta definición es para cuando apostamos números pares 
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ $random_number -eq 0 ]; then
            echo -e "${redColour}[!] Ha salido el 0, ¡pierdes!${endColour}"
            initial_bet=$(($initial_bet*2))
            jugadas_malas+="$random_number "
            echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en ${purpleColour}\$$money${endColour}"
          else
            echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es par, ¡ganas!${endColour}"
            reward=$(($initial_bet*2))
            echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}\$$reward${endColour}"
            money=$(($money+$reward))
            if [ "$money" -gt "$tope_money" ]; then
              tope_money=$money
            fi

            echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${purpleColour}\$$money${endColour}"
            initial_bet=$backup_bet
            jugadas_malas="[ "
          fi
        else 
          echo -e "${redColour}[!] El número que ha salido es impar, ¡pierdes!${endColour}"
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en ${purpleColour}\$$money${endColour}"
        fi  
      else 
          # Toda esta definición es para cuando apostamos número impares 
        if [ "$(($random_number % 2))" -eq 1 ]; then
          echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es impar, ¡ganas!${endColour}"
          reward=$(($initial_bet*2))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}\$$reward${endColour}"
          money=$(($money+$reward))
          echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes ${endColour}${purpleColour}\$$money${endColour}"
          initial_bet=$backup_bet
          jugadas_malas="[ "
          if [ "$money" -gt "$tope_money" ]; then
            tope_money=$money
          fi 
          else
            echo -e "${yellowColour}[+]${endColour}${redColour} El número que ha salido es par, ¡pierdes!${endColour}"
            initial_bet=$(($initial_bet*2))
            jugadas_malas+="$random_number "
            echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en ${purpleColour}\$$money${endColour}"
          fi
        fi
    else 
      # Nos quedamos sin dinero 
      echo -e "\n${redColour}[!] Te has quedado sin dinero${endColour}\n"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Han habido un total de ${endColour}${yellowColour}$(($play_counter-1))${endColour}${grayColour} jugadas${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} A continuación se van a representar las malas jugadas que han salido:${endColour}\n"
      echo -e "${blueColour}$jugadas_malas]${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Has llegado a tener un total de ${endColour}${purpleColour}\$$tope_money${endColour}"
      tput cnorm; exit 0 
    fi

    let play_counter+=1
  done
  tput cnorm
}

function inverseLabrouchere(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual: ${endColour}${purpleColour}\$$money${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
  tope_money=$money
  if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ]; then
    echo -e "${redColour}[!] Entrada inválida. Debes ingresar 'par' o 'impar'.${endColour}"
    tput cnorm; exit 1
  fi

  declare -a my_sequence=(1 2 3 4)

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comenzamos con la secuencia${endColour}${greenColour} [${my_sequence[@]}]${endColour}"

  bet=$((${my_sequence[0]}+${my_sequence[-1]}))

  jugadas_totales=0
  bet_to_renew=$(($money+50))

  echo -e "${yellowColour}[+]${endColour}${grayColour} El tope a renovar la secuencia está establecido por encima de los${endColour}${yellowColour} \$$bet_to_renew${endColour}"

  tput civis
  while true; do 
    let jugadas_totales+=1
    random_number=$(($RANDOM % 37))
    money=$(($money-$bet))
    if [ ! "$money" -lt 0 ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} Inviertes${endColour} ${yellowColour}\$$bet${endColour}${grayColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en ${purpleColour}\$$money${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Ha salido el número${endColour}${yellowColour} $random_number${endColour}"

      if  ([ "$par_impar" == "par" ] && [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ];) || \
        ([ "$par_impar" == "impar" ] && [ "$(($random_number % 2))" -eq 1 ];); then
        echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es $par_impar, ¡ganas!${endColour}"
        reward=$(($bet*2))
        let money+=$reward
        echo -e "${yellowColour}[+]${endColour}${grayColour} Ahora mismo te quedas en ${purpleColour}\$$money${endColour}"
        if [ $money -gt $tope_money ]; then
          tope_money=$money
        fi
        if [ $money -gt $bet_to_renew ]; then 
          echo -e "${yellowColour}[+]${endColour}${grayColour} El dinero ha superado el tope establecido de ${endColour}${yellowColour}\$$bet_to_renew${endColour}${grayColour}, se renueva la secuencia${endColour}"
          bet_to_renew=$(($bet_to_renew+50))
          echo -e "${yellowColour}[+]${endColour}${grayColour} El nuevo tope es ${endColour}${yellowColour}\$$bet_to_renew${endColour}"
          my_sequence=(1 2 3 4)
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ha sido restablecida a:${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
        else  
          my_sequence+=($bet)
          my_sequence=(${my_sequence[@]})
          echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es ${endColour}${greenColour}[${my_sequence[@]}]${endColour}"
          if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}      
          else 
            echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi 
        fi
      else
        if [ "$random_number" -eq 0 ]; then
          echo -e "${redColour}[!] Ha salido el 0, ¡pierdes!${endColour}"
        else
          tipo=$([ "$(($random_number % 2))" -eq 0 ] && echo "par" || echo "impar")
          echo -e "${redColour}[!] El número que ha salido es $tipo, ¡pierdes!${endColour}"
        fi  

        if [ $money -lt $(($bet_to_renew-100)) ]; then 
          echo -e "${yellowColour}[+]${endColour}${greenColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
          bet_to_renew=$(($bet_to_renew-50))
          echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a ${endColour}${yellowColour}\$$bet_to_renew${endColour}"
          unset my_sequence[0]
          unset my_sequence[-1] 2>/dev/null
          my_sequence=(${my_sequence[@]})
          echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva secuencia es ${endColour}${greenColour}[${my_sequence[@]}]${endColour}"
          if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}      
          else 
            echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        else
          unset my_sequence[0]
          unset my_sequence[-1] 2>/dev/null
          my_sequence=(${my_sequence[@]})

          echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia se queda de la siguiente forma: ${greenColour}[${my_sequence[@]}]${endColour}"
          if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            echo -e "${redColour}[!] Hemos perdido nuestra secuencia${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour}${grayColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        fi  
      fi
    else 
      echo -e "\n${redColour}[!] Te has quedado sin dinero${endColour}\n"
      echo -e "${yellowColour}[+]${endColour}${grayColour} En total han habido ${endColour}${yellowColour}${jugadas_totales}${endColour}${grayColour} jugadas totales${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Has llegado a tener un total de ${endColour}${purpleColour}\$$tope_money${endColour}"
     tput cnorm; exit 1
    fi
  done  
  tput cnorm
}

while getopts "m:t:h" arg; do 
  case $arg in
    m) money="$OPTARG";;
    t) technique="$OPTARG";; 
    h) ;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ]; then
    martingala
  elif [ "$technique" == "inverseLabrouchere" ]; then 
    inverseLabrouchere 
  else 
    echo -e "\n${redColour}[!] La técnica introducida no existe${endColour}\n"
    helPanel
  fi
else 
  helPanel
fi  
