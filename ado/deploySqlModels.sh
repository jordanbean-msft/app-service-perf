#!/bin/bash
set -e

while getopts "s:d:u:p:m:" flag; do
  case "${flag}" in
    s) serverName=${OPTARG};;
    d) databaseName=${OPTARG};;
    u) username=${OPTARG};;
    p) password=${OPTARG};;
    m) migrationScriptPath=${OPTARG};;
  esac
done

for sqlScript in "$migrationScriptPath"/*.sql; do

  echo "Executing SQL migration script $sqlScript..."

  /opt/mssql-tools/bin/sqlcmd -S tcp:$serverName.database.windows.net -d $databaseName -U $username -P $password -r -R -b -i "$sqlScript"

  echo "Executed SQL migration script $sqlScript."
done