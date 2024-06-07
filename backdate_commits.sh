#!/bin/bash

# Check if the repository directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_repository>"
    exit 1
fi

REPO_DIR=$1

# Navigate to the repository directory
cd "$REPO_DIR" || { echo "Repository not found!"; exit 1; }

# Function to create a commit with a random message
random_commit() {
    local commit_date=$1
    local commit_message=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)

    # Create or modify a trivial file
    echo "Fake commit message: $commit_message" > fake_commit.txt
    git add fake_commit.txt

    # Set the commit date
    GIT_AUTHOR_DATE="$commit_date 12:00:00" GIT_COMMITTER_DATE="$commit_date 12:00:00" git commit -m "$commit_message"
}

# Function to generate a list of random dates
generate_random_dates() {
    local year=$1
    local num_dates=$2
    shuf -i "$(date -d "$year-01-01" +%s)"-"$(date -d "$year-12-31" +%s)" -n $num_dates | while read -r timestamp; do
        date -d "@$timestamp" +"%Y-%m-%d"
    done
}

# Set the year range
START_YEAR=2020
END_YEAR=2020

# Total number of commits
TOTAL_COMMITS=1000

# Generate commits for each year
for year in $(seq $START_YEAR $END_YEAR); do
    # Determine the number of commits for this year
    commits_per_year=$((TOTAL_COMMITS / (END_YEAR - START_YEAR + 1)))

    # Generate random dates for commits
    random_dates=$(generate_random_dates "$year" "$commits_per_year")

    for date in $random_dates; do
        # Ensure the date is not in the future
        if [[ "$date" < "$(date +%Y-%m-%d)" ]]; then
            # Generate a random number of commits for each date
            num_commits=$(shuf -i 2-10 -n 1)
            for ((i=0; i<num_commits; i++)); do
                random_commit "$date"
            done
        fi
    done
done

# Push the changes to the master branch
git push origin master
