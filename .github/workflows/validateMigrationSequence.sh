# If forked repo then skip sql migration check
if [[ $HEAD_BRANCH  != $HEAD_BRANCH ]]; then
  echo "Migration are not allowed from Forked repo"
  exit 0
fi

# Fetch the latest changes from the base and target branches
git fetch origin "$BASE_BRANCH"
git fetch origin "$HEAD_BRANCH"

# Get the list of changed files between the base and target branches
git diff origin/"$BASE_BRANCH"...origin/"$HEAD_BRANCH" --name-only > diff

# Specify the directory containing migration files
MIGRATION_DIR="scripts/sql"

# Print the current directory and the contents of the diff file
echo "Current directory:"
pwd
echo "Files changed between $BASE_BRANCH and $HEAD_BRANCH:"
cat diff

# Initialize an empty variable to hold .up.sql files
changed_files=""

# Loop through the list of changed files and filter .up.sql files in the migration directory
while IFS= read -r file; do
  if [[ $file == $MIGRATION_DIR/* && $file == *.up.sql ]]; then
    changed_files+="$file\n"
  fi
done < diff

# Print the filtered .up.sql files
echo "Filtered .up.sql files:"
echo -e "$changed_files"

# If no .up.sql migration files are found, exit early
if [[ -z "$changed_files" ]]; then
  echo "No .up.sql migration files found in the changes."
  exit 0
fi

# Extract unique migration numbers from the existing migration files in the directory
existing_migrations=$(ls "$MIGRATION_DIR" | grep -E "\.up\.sql$" | grep -oE "[0-9]{6}[0-9]{2}" | sort -n | uniq)

# Loop through each changed .up.sql file to validate
is_valid=true
processed_migrations=()
while IFS= read -r file; do
  # Extract migration number from the file
  migration_number=$(basename "$file" | grep -oE "[0-9]{6}[0-9]{2}")

  # Validate the file name format (ensure it has the full XXXPPPNN format)
  if [[ ! $(basename "$file") =~ ^[0-9]{6}[0-9]{2}_ ]]; then
    echo "Error: Migration file $file does not have the complete XXXPPPNN format."
    is_valid=false
    continue
  fi

  # Check if we could extract a valid migration number
  if [[ -z "$migration_number" ]]; then
    echo "Warning: Could not extract migration number from $file."
    continue
  fi

  # Check if this migration number has already been processed
  if [[ " ${processed_migrations[@]} " =~ " $migration_number " ]]; then
    continue
  fi
  processed_migrations+=("$migration_number")

  # Check if the migration number already exists
  if echo "$existing_migrations" | grep -q "$migration_number"; then
    echo "Error: Migration number $migration_number already exists in the directory."
    is_valid=false
  fi

  # Check if the migration number is greater than previous ones (order check)
  last_migration=$(echo "$existing_migrations" | tail -n 1)
  if [[ "$migration_number" -le "$last_migration" ]]; then
    echo "Error: Migration number $migration_number is not greater than the latest ($last_migration)."
    is_valid=false
  fi

  # Check for sequential hotfix requirement (if NN > 01, check for NN-1)
  hotfix_number=$(echo "$migration_number" | grep -oE "[0-9]{2}$")
  if [[ "$hotfix_number" -gt "01" ]]; then
    previous_hotfix=$(printf "%02d" $((10#$hotfix_number - 1)))
    expected_previous_number="${migration_number:0:6}$previous_hotfix"
    if ! echo "$existing_migrations" | grep -q "$expected_previous_number"; then
      echo "Error: Previous hotfix migration $expected_previous_number not found for $migration_number."
      is_valid=false
    fi
  fi
done <<< "$changed_files"

# Final validation check
if [ "$is_valid" = false ]; then
  echo "Validation failed. Please fix the errors before merging."
  gh pr comment "$pr_no" --body "The Migration files provided inside the PR do not pass the criteria!!"
  exit 1
fi

echo "All .up.sql migration file validations passed."
gh pr comment "$pr_no" --body "The migration files have successfully passed the criteria!!"
exit 0
