#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Welcome message
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU () {
  # Print error message (just in case)
  if [[ $1 ]]
  then
    echo -e "\n$1" 
  fi
  # Get services
  SERVICES=$($PSQL "SELECT * FROM services")
  # Print services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done
  # Read selection
  read SERVICE_ID_SELECTED
  # Check valid selection
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # if selection doesn't exist
  if [[ -z $SERVICE_ID ]]
  then
    # Return to main menu
    MAIN_MENU "Oops thats not a valid service!"
  else
    # make appointment
    MAKE_APPOINTMENT
  fi
}

MAKE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  # read phone number
  read CUSTOMER_PHONE
  # check number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'"  | sed -r 's/^ //g')
  # if phone number doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # create new customer
    INSERT_CUSTOMER_RES=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  # Format information
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID" | sed -r 's/^ //g') 
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  # read time
  read SERVICE_TIME
  # confirmation
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU