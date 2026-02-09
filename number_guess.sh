#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if username exists
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into DB
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL);")
else
  # Returning user
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  # Validate input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update database stats
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")
IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"

# Update best game if it's the first game or better than previous
if [[ -z $BEST_GAME ]] || (( NUMBER_OF_GUESSES < BEST_GAME )); then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

# Increment games played
GAMES_PLAYED=$((GAMES_PLAYED + 1))

UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME';")

# dummy commit 1
# dummy commit 2
# dummy commit 3
# dummy commit 4
# dummy commit 5
