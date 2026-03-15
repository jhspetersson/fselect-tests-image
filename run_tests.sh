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

# Build archive test fixture
ARC_DIR="fs_arc"
mkdir -p "$ARC_DIR/subdir/nested"
echo "archived1" > "$ARC_DIR/subdir/data1.txt"
echo "archived2-content" > "$ARC_DIR/subdir/data2.csv"
echo "deep-file" > "$ARC_DIR/subdir/nested/nested.txt"
echo "deep-data" > "$ARC_DIR/subdir/nested/nested.csv"

cd "$ARC_DIR/subdir" && zip -r ../archive.zip . > /dev/null 2>&1 && cd "$OLDPWD"
rm -rf "$ARC_DIR/subdir"

# Build symlink test fixture
SYM_DIR="fs_sym"
mkdir -p "$SYM_DIR/real/sub"
echo "real-file-1" > "$SYM_DIR/real/file1.txt"
echo "real-file-2-longer" > "$SYM_DIR/real/file2.txt"
echo "sub-file" > "$SYM_DIR/real/sub/deep.txt"
echo "sub-data" > "$SYM_DIR/real/sub/deep.csv"
ln -s real/file1.txt "$SYM_DIR/link_file.txt"
ln -s real/sub "$SYM_DIR/link_dir"
ln -s nonexistent "$SYM_DIR/broken_link"

RESULT=0

while read -r dir; do
  query_file="$dir/query.txt"
  output_file="$dir/output.txt"

  if [ ! -f "$query_file" ] || [ ! -f "$output_file" ]; then
    continue
  fi

  query=$(cat "$query_file")
  expected=$(sed 's/\r//' < "$output_file")
  actual=$($TEST_EXECUTABLE "$query")

  dir=${dir#tests/}
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