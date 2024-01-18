#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "Choose\n"
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | sed 's/|/ /g' | while read SERV_ID SERV_N
  do
    echo "$SERV_ID) $SERV_N"
  done
  echo "0 for Exit"
  read SERVICE_ID_SELECTED
  SERV_EXIST=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then
   exit
  else
    if [[ -z $SERV_EXIST ]]
    then
      MAIN_MENU "does not exist, select again:"
    else
      echo "What's your phone number?"
      ENTER_PHONE(){
        read CUSTOMER_PHONE
        if [[ -z $CUSTOMER_PHONE ]]
        then
          echo "phone number missing"
          ENTER_PHONE
        else
          PHONE_EXIST=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          if [[ -z $PHONE_EXIST ]]
          then
            echo "phone unknown, enter your name"
            ENTER_NAME(){
              read CUSTOMER_NAME 
              if [[ -z $CUSTOMER_NAME ]]
              then
                echo "again:"
                ENTER_NAME
              else
                CLIENT_REG=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
              fi
            }
            ENTER_NAME
          else
            CUSTOMER_NAME=$PHONE_EXIST
          fi
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/^ *//g')
          echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
          ENTER_TIME(){
            read SERVICE_TIME
            if [[ -z $SERVICE_TIME ]]
            then
              echo "enter appointment time:"
              ENTER_TIME
            else
              CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
              APP_REG=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CLIENT_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
              echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
            fi
          }
          ENTER_TIME
        fi
      }
      ENTER_PHONE
    fi
  fi
}
MAIN_MENU
