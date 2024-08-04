#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUM=$(( 1 + RANDOM % 1000 ))

echo Enter your username:
read USRNAME

if [[ -z USRNAME ]]
then
  echo "ENTER VALID USERNAME"
else
  USRNO=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USRNAME';");
  if [[ -z $USRNO ]]
  then
    INSRES=$($PSQL "INSERT INTO users (user_name) VALUES ('$USRNAME');");
    USRNO=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USRNAME';");
    NOGAMES=0
  else
    NOGAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USRNO;")
  fi

  if [[ $NOGAMES -eq 0 ]]
  then
    echo "Welcome, $USRNAME! It looks like this is your first time here."
  else
    BSTGAME=$($PSQL "SELECT min(guess) FROM games WHERE user_id = $USRNO;")
    echo "Welcome back, $USRNAME! You have played $NOGAMES games, and your best game took $BSTGAME guesses."
  fi

  COUNT=1
  echo Guess the secret number between 1 and 1000:

  getnum(){
  read NO

  if [[ $NO =~ ^[0-9]+$ ]]
  then
    if [[ $NO -eq $NUM ]]
    then 
      echo "You guessed it in $COUNT tries. The secret number was $NUM. Nice job!"
      GINSRES=$($PSQL "INSERT INTO games (user_id,guess) VALUES ($USRNO,$COUNT);")
    elif [[ $NO -lt $NUM ]]
    then
      echo "It's higher than that, guess again:"
      COUNT=$(( COUNT + 1 ))
      getnum
    else
      echo "It's lower than that, guess again:"
      COUNT=$(( COUNT + 1 ))
      getnum
    fi
  else
    echo "That is not an integer, guess again:"
    COUNT=$(( COUNT + 1 ))
    getnum
  fi
  }

  getnum
fi


