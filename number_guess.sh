#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read NAME

PLAYER_FOUND=$($PSQL "SELECT name FROM players WHERE name = '$NAME'")

if [[ -z $PLAYER_FOUND ]]
then
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players(name) VALUES('$NAME')")
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name = '$NAME'")
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(player_id) VALUES($PLAYER_ID)")
  NUMBER_GAMES=0
  BEST_GAME=0
  echo -e "\nWelcome, $NAME! It looks like this is your first time here."
else 
  PLAYER_ID=$($PSQL "SELECT player_id FROM players INNER JOIN games USING(player_id) WHERE name = '$NAME'")
  NUMBER_GAMES=$($PSQL "SELECT number_games FROM players INNER JOIN games USING(player_id) WHERE name = '$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players INNER JOIN games USING(player_id) WHERE name = '$NAME'")
  echo -e "\nWelcome back, $NAME! You have played $NUMBER_GAMES games, and your best game took $BEST_GAME guesses."
  
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

FLAG=0
VECES=0


while [[ $FLAG == 0 ]]
do 
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    VECES=$(($VECES +1))
    LEIDO_UNA_VEZ=0
    if [[ $GUESS -lt $NUMBER ]] && [[ $LEIDO_UNA_VEZ == 0 ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read GUESS
      LEIDO_UNA_VEZ=1
    fi
    if [[ $GUESS -gt $NUMBER ]] && [[ $LEIDO_UNA_VEZ == 0 ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      read GUESS
      LEIDO_UNA_VEZ=1
    fi
    if [[ $GUESS -eq $NUMBER ]] && [[ $LEIDO_UNA_VEZ == 0 ]]
    then
      NUMBER_GAMES_NEW=$(($NUMBER_GAMES +1))
      UPDATE_GAMES_RESULT=$($PSQL "UPDATE games SET number_games = $NUMBER_GAMES_NEW WHERE player_id = '$PLAYER_ID'")

      
      if [[ $BEST_GAME == 0 ]]
      then
        BEST_GAME=$VECES
      else
        BEST_GAME=$VECES
        if [[ $VECES -lt $BEST_GAME ]]
        then
          BEST_GAME=$VECES
        fi
      fi

      UPDATE_BEST_RESULT=$($PSQL "UPDATE games SET best_game = $BEST_GAME WHERE player_id = $PLAYER_ID")   
      echo -e "\nYou guessed it in $VECES tries. The secret number was $NUMBER. Nice job!"

      FLAG=1 
    fi
  else
    VECES=$(($VECES +1))
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  fi  
done

