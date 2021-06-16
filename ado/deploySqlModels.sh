#!/bin/bash

while getopts s:d:u:p:m flag
do
  case "${flag}" in
    s) serverName=${OPTARG};;
    d) databaseName=${OPTARG};;
    u) username=${OPTARG};;
    p) password=${OPTARG};;
    m) migrationScriptPath=${OPTARG};;
  esac
done

for sqlScript in "$migrationScriptPath/*"
do
  echo "Executing SQL migration script $sqlScript..."
  sqlcmd -S tcp:$databaseName $serverName.database.windows.net -U $username -P $password -r -R -i ./$sqlScript
  echo "Executed SQL migration script $sqlScript."
done