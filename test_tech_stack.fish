#!/usr/bin/env fish

# Test suite for tech detection functionality
# Usage: fish test_tech_stack.fish

set -g test_count 0
set -g pass_count 0
set -g fail_count 0

function test_assert
    set -g test_count (math $test_count + 1)
    set -l description $argv[1]
    set -l expected $argv[2]
    set -l actual $argv[3]

    if test "$expected" = "$actual"
        set -g pass_count (math $pass_count + 1)
        echo "✅ PASS: $description"
    else
        set -g fail_count (math $fail_count + 1)
        echo "❌ FAIL: $description"
        echo "   Expected: '$expected'"
        echo "   Actual: '$actual'"
    end
end

function test_assert_contains
    set -g test_count (math $test_count + 1)
    set -l description $argv[1]
    set -l expected_substring $argv[2]
    set -l actual $argv[3]

    if string match -q "*$expected_substring*" "$actual"
        set -g pass_count (math $pass_count + 1)
        echo "✅ PASS: $description"
    else
        set -g fail_count (math $fail_count + 1)
        echo "❌ FAIL: $description"
        echo "   Expected to contain: '$expected_substring'"
        echo "   Actual: '$actual'"
    end
end

function test_assert_not_contains
    set -g test_count (math $test_count + 1)
    set -l description $argv[1]
    set -l not_expected_substring $argv[2]
    set -l actual $argv[3]

    if not string match -q "*$not_expected_substring*" "$actual"
        set -g pass_count (math $pass_count + 1)
        echo "✅ PASS: $description"
    else
        set -g fail_count (math $fail_count + 1)
        echo "❌ FAIL: $description"
        echo "   Expected NOT to contain: '$not_expected_substring'"
        echo "   Actual: '$actual'"
    end
end

function create_test_directory
    set -l test_dir $argv[1]
    mkdir -p $test_dir
    cd $test_dir
end

function cleanup_test_directory
    set -l test_dir $argv[1]
    if test -d $test_dir
        rm -rf $test_dir
    end
end

function run_tech_stack
    set -l var_name "test_tech_result"
    _tech_stack_worker $var_name
    echo $$var_name
end

function get_language_icon
    set -l language_name $argv[1]
    set -l config_file "$HOME/.config/fish/language_rules.json"
    if not test -f $config_file
        set config_file functions/_tech_stack_language_rules.json"
    end
    if command -v jq >/dev/null 2>&1; and test -f $config_file
        jq -r --arg name "$language_name" '.rules[] | select(.name == $name) | .icon' $config_file
    else
        echo "$language_name" # fallback to name if jq not available
    end
end

function get_tech_icon
    set -l tech_name $argv[1]
    set -l config_file "$HOME/.config/fish/tech_rules.json"
    if not test -f $config_file
        set config_file functions/_tech_stack_rules.json"
    end
    if command -v jq >/dev/null 2>&1; and test -f $config_file
        jq -r --arg name "$tech_name" '.rules[] | select(.name == $name) | .icon' $config_file
    else
        echo "$tech_name" # fallback to name if jq not available
    end
end

echo "🚀 Starting tech detection tests..."
set -l project_root (pwd)
echo

# Test 1: Empty directory should not detect project-specific tech
echo "📁 Testing empty directory..."
set -l empty_test_dir "/tmp/tech_test_empty"
create_test_directory $empty_test_dir
set -l result (run_tech_stack)
test_assert_not_contains "Empty directory should not detect .NET" "💜" "$result"
test_assert_not_contains "Empty directory should not detect Ruby" "💎" "$result"
test_assert_not_contains "Empty directory should not detect TypeScript" "🔷" "$result"
cleanup_test_directory $empty_test_dir
echo

# Test 2: Dynamic language detection tests
echo "🔬 Testing all languages from configuration..."
set -l language_rules_file "$project_root/functions/_tech_stack_language_rules.json"
if test -f $language_rules_file; and command -v jq >/dev/null 2>&1
    set -l rule_count (jq '.rules | length' $language_rules_file)
    for i in (seq 0 (math $rule_count - 1))
        set -l name (jq -r --argjson idx $i '.rules[$idx].name' $language_rules_file)
        set -l icon (jq -r --argjson idx $i '.rules[$idx].icon' $language_rules_file)
        set -l file_indicators (jq -r --argjson idx $i '.rules[$idx].file_indicators[]' $language_rules_file)

        echo "🔍 Testing $name detection..."
        set -l test_dir "/tmp/tech_test_lang_$i"
        create_test_directory $test_dir

        # Create the first file indicator (skip glob patterns for safety)
        set -l first_indicator $file_indicators[1]
        if not string match -q "*\**" $first_indicator
            if string match -q "*.*" $first_indicator
                # It's a file
                touch $first_indicator
            else if not string match -q "*/*" $first_indicator
                # It's a simple filename
                touch $first_indicator
            else
                # Create directory structure if needed
                set -l dir_path (dirname $first_indicator)
                if test "$dir_path" != "."
                    mkdir -p $dir_path
                end
                touch $first_indicator
            end

            set -l result (run_tech_stack)
            test_assert_contains "$name should be detected" "$icon" "$result"
        else
            echo "   Skipping $name (complex pattern: $first_indicator)"
        end

        cleanup_test_directory $test_dir
    end
else
    echo "⚠️  Skipping language tests - jq not available or rules file not found"
end
echo

# Test 3: Dynamic tech stack detection tests
echo "⚙️ Testing all tech stacks from configuration..."
set -l tech_rules_file "$project_root/functions/_tech_stack_rules.json"
if test -f $tech_rules_file; and command -v jq >/dev/null 2>&1
    set -l rule_count (jq '.rules | length' $tech_rules_file)
    for i in (seq 0 (math $rule_count - 1))
        set -l name (jq -r --argjson idx $i '.rules[$idx].name' $tech_rules_file)
        set -l icon (jq -r --argjson idx $i '.rules[$idx].icon' $tech_rules_file)
        set -l file_indicators (jq -r --argjson idx $i '.rules[$idx].file_indicators[]' $tech_rules_file)

        echo "🔍 Testing $name detection..."
        set -l test_dir "/tmp/tech_test_tech_$i"
        create_test_directory $test_dir

        # Create the first file indicator (skip complex glob patterns)
        set -l first_indicator $file_indicators[1]
        if not string match -q "*\**" $first_indicator
            # Check if it's a known directory indicator or ends with /
            if string match -q "*/" $first_indicator; or test "$first_indicator" = ".github/workflows"
                # It's a directory
                mkdir -p $first_indicator
            else if string match -q "*/*" $first_indicator
                # It's a file with path - ensure parent directories exist
                set -l parent_dir (dirname $first_indicator)
                mkdir -p $parent_dir
                touch $first_indicator
            else
                # It's a simple filename
                touch $first_indicator
            end

            set -l result (run_tech_stack)
            test_assert_contains "$name should be detected" "$icon" "$result"
        else
            echo "   Skipping $name (complex pattern: $first_indicator)"
        end

        cleanup_test_directory $test_dir
    end
else
    echo "⚠️  Skipping tech stack tests - jq not available or rules file not found"
end
echo

# Test 4: Multi-technology detection
echo "🔧 Testing multiple technologies together..."
set -l multi_test_dir "/tmp/tech_test_multi"
create_test_directory $multi_test_dir
touch package.json tsconfig.json Dockerfile
set -l result (run_tech_stack)
# Looking at the actual output format, we should test for the icon values directly
test_assert_contains "Should detect Node.js in multi-tech project" "Node" "$result"
test_assert_contains "Should detect TypeScript in multi-tech project" "TS" "$result"
test_assert_contains "Should detect Docker in multi-tech project" "Docker" "$result"
cleanup_test_directory $multi_test_dir
echo

# Test 5: Subdirectory isolation
echo "📂 Testing subdirectory isolation..."
set -l subdir_test_dir "/tmp/tech_test_subdir"
create_test_directory $subdir_test_dir
mkdir -p backend frontend
touch backend/package.json frontend/tsconfig.json
set -l result (run_tech_stack)
test_assert_not_contains "Should not detect tech in subdirectories from parent" "Node" "$result"
test_assert_not_contains "Should not detect tech in subdirectories from parent" "TS" "$result"
cleanup_test_directory $subdir_test_dir
echo

# Test 6: JSON configuration validation
echo "📄 Testing JSON configuration files..."
set -l tech_rules_file "$project_root/functions/_tech_stack_rules.json"
set -l lang_rules_file "$project_root/functions/_tech_stack_language_rules.json"

test_assert "_tech_stack_rules.json should exist" "true" (test -f $tech_rules_file; and echo true; or echo false)
test_assert "_tech_stack_language_rules.json should exist" "true" (test -f $lang_rules_file; and echo true; or echo false)

# Validate JSON syntax
if command -v jq >/dev/null 2>&1
    set -l tech_json_valid (jq empty $tech_rules_file 2>/dev/null; and echo true; or echo false)
    set -l lang_json_valid (jq empty $lang_rules_file 2>/dev/null; and echo true; or echo false)
    test_assert "_tech_stack_rules.json should be valid JSON" "true" "$tech_json_valid"
    test_assert "_tech_stack_language_rules.json should be valid JSON" "true" "$lang_json_valid"

    # Test that required fields exist
    set -l tech_rules_count (jq '.rules | length' $tech_rules_file)
    set -l lang_rules_count (jq '.rules | length' $lang_rules_file)
    test_assert "_tech_stack_rules.json should contain rules" "true" (test $tech_rules_count -gt 0; and echo true; or echo false)
    test_assert "_tech_stack_language_rules.json should contain rules" "true" (test $lang_rules_count -gt 0; and echo true; or echo false)
else
    echo "⚠️  Skipping JSON validation - jq not available"
end
echo

# Summary
echo "📊 Test Results Summary:"
echo "   Total tests: $test_count"
echo "   Passed: $pass_count"
echo "   Failed: $fail_count"

if test $fail_count -eq 0
    echo "🎉 All tests passed!"
    exit 0
else
    echo "💥 $fail_count test(s) failed!"
    exit 1
end
