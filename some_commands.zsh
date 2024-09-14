# Function to check if there are uncommitted changes
uncommitted-changes() {
    git diff-index --quiet HEAD -- || return 1
}

rebase-branch() {
    # Save the name of the current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check for uncommitted changes and stash them if necessary
    changes_stashed=false
    if uncommitted-changes; then
        echo "Uncommitted changes detected. Stashing changes."
        git stash
        changes_stashed=true
    fi

    # Check if we're already on main branch
    if [ "$current_branch" = "main" ]; then
        echo "Already on main branch. Pulling latest changes."
        git pull origin main
    else
        # Checkout main branch
        git checkout main

        # Pull latest changes from main
        git pull origin main

        # Checkout the original branch
        git checkout $current_branch

        # Attempt to rebase
        if ! git rebase main; then
            echo "Rebase failed. Please resolve conflicts manually."
        else
            echo "Rebase completed successfully."
        fi
    fi

    # If changes were stashed, pop them now
    if [ "$changes_stashed" = true ]; then
        echo "Reapplying stashed changes."
        if git stash pop; then
            echo "Stashed changes reapplied successfully."
        else
            echo "Conflicts occurred when reapplying stashed changes. Please resolve them manually."
        fi
    fi

    echo "Process completed. Current branch: $(git rev-parse --abbrev-ref HEAD)"
}
