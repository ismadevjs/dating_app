#!/bin/bash

# Check if the repository directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_repository>"
    exit 1
fi

REPO_DIR=$1

# Navigate to the repository directory
cd "$REPO_DIR" || { echo "Repository not found!"; exit 1; }

# Get today's date
today=$(date +%Y-%m-%d)

# Function to create a commit on a given date
commit_on_date() {
    local commit_date=$1
    local commit_message="Commit on $commit_date"

    # Create a trivial change
    echo "$commit_message" > fake_commit.txt
    git add fake_commit.txt

    # Set the commit date
    GIT_AUTHOR_DATE="$commit_date 12:00:00" GIT_COMMITTER_DATE="$commit_date 12:00:00" git commit -m "$commit_message"
}

# Generate dates for 2023 and 2024
for year in 2023 2024; do
    for month in {01..12}; do
        for day in {01..31}; do
            # Format the date
            date="$year-$month-$day"
            
            # Check if the date is valid
            if date -d "$date" >/dev/null 2>&1; then
                # Commit on the valid date if it is not in the future
                if [[ "$date" < "$today" ]]; then
                    commit_on_date "$date"
                fi
            fi
        done
    done
done

# Push the changes
git push origin main
