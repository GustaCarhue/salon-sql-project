#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Función para mostrar los servicios y pedir la selección
SHOW_SERVICES() {
  echo -e "\nWelcome to My Salon, how can I help you?\n"
  
  # Mostrar lista de servicios
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Leer la selección del servicio
  read SERVICE_ID_SELECTED

  # Verificar si el servicio seleccionado es válido
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    # Si no es válido, mostrar el mensaje de error y volver a mostrar la lista
    echo -e "\nI could not find that service. Please select a valid service."
    SHOW_SERVICES
  fi
}

# Llamar a la función para mostrar los servicios
SHOW_SERVICES

# Pedir el número de teléfono del cliente
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Verificar si el cliente ya existe
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Si el cliente no existe, solicitar el nombre y agregarlo a la base de datos
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Pedir la hora de la cita
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Obtener el ID del cliente
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Insertar la cita en la base de datos
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmar la cita
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
