#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

# Query: allow atomic number, symbol or name (case-insensitive for symbol/name)
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  ROW=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING (atomic_number) JOIN types t ON p.type_id = t.type_id WHERE e.atomic_number = $INPUT;")
else
  # match symbol or name ignoring case
  ROW=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING (atomic_number) JOIN types t ON p.type_id = t.type_id WHERE LOWER(e.symbol) = LOWER('$INPUT') OR LOWER(e.name) = LOWER('$INPUT');")
fi

if [[ -z $ROW ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# parse row (psql -t --no-align returns a single row with fields separated by |)
IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ROW"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."

# just adding a comment to have another reason to commit
# yet another pointless line of text
