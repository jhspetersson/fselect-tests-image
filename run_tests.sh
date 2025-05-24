#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

TEST_EXECUTABLE=./fselect
FS_DIR="fs"
TESTS_DIR="tests"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
# Gray underlined
GU='\033[4;37m'
# No color
NC='\033[0m'

if [ ! -d "$FS_DIR" ]; then
  echo "Directory $FS_DIR does not exist. Please run this script from the root of the repository."
  exit 1
fi

if [ ! -f "$TEST_EXECUTABLE" ]; then
  echo "Executable $TEST_EXECUTABLE not found. Please build the project first."
  exit 1
fi

RESULT=0

while read -r dir; do
  query_file="$dir/query.txt"
  output_file="$dir/output.txt"

  if [ ! -f "$query_file" ] || [ ! -f "$output_file" ]; then
    continue
  fi

  query=$(cat "$query_file")
  expected=$(sed 's/\r//' < "$output_file")
  actual=$($TEST_EXECUTABLE "$query" 2>/dev/null)

  dir=${dir#../tests/}
  if [ "$actual" = "$expected" ]; then
    printf "%s: ${GREEN}ok${NC}\n" "$dir"
  else
    printf "%s: ${RED}fail${NC}\n${GU}Expected:\n${NC}%s\n\n${GU}Actual:\n${NC}%s\n" "$dir" "$expected" "$actual"
    RESULT=1
  fi
done < <(find ${TESTS_DIR} -type d)

if [ $RESULT -eq 0 ]; then
  echo -e "\nAll tests ${GREEN}PASSED${NC}"
else
  echo -e "\nSome tests ${RED}FAILED${NC}"
fi

exit $RESULT