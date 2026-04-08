#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
session_name=$(echo "$input" | jq -r '.session_name // empty')

# Get current directory (shortened)
dir_display=$(basename "$cwd")
if [ ${#cwd} -gt 40 ]; then
    parent=$(dirname "$cwd")
    parent_base=$(basename "$parent")
    dir_display="$parent_base/$dir_display"
fi

# Git status
git_status=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")

    status_output=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    staged=$(echo "$status_output" | grep -c '^[MADRC]')
    modified=$(echo "$status_output" | grep -c '^ M')
    untracked=$(echo "$status_output" | grep -c '^??')

    git_status=$(printf "\033[32m \033[0m%s" "$branch")

    [ "$staged" -gt 0 ] && git_status="$git_status $(printf "\033[33m+%d\033[0m" "$staged")"
    [ "$modified" -gt 0 ] && git_status="$git_status $(printf "\033[33m!%d\033[0m" "$modified")"
    [ "$untracked" -gt 0 ] && git_status="$git_status $(printf "\033[36m?%d\033[0m" "$untracked")"
fi

# Node version (if in a node project)
node_version=""
if [ -f "$cwd/package.json" ]; then
    node_version=$(printf "\033[32m \033[0m%s" "$(node --version 2>/dev/null | sed 's/v//')")
fi

# Context remaining percentage
context_info=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$context_info" ]; then
    context_display=$(printf "\033[2mctx: %.0f%%\033[0m" "$context_info")
fi

# Build output
output=$(printf "\033[2m \033[0m")
output="$output $(printf "\033[34m%s\033[0m" "$dir_display")"

[ -n "$git_status" ] && output="$output$git_status"
[ -n "$node_version" ] && output="$output $node_version"
[ -n "$context_display" ] && output="$output  $context_display"

if [ -n "$session_name" ]; then
    output="$output $(printf "\033[2m[%s]\033[0m" "$session_name")"
fi

echo "$output"
