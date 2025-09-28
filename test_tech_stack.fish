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

echo "🚀 Starting tech detection tests..."
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

# Test 2: Node.js project detection
echo "📦 Testing Node.js project detection..."
set -l node_test_dir "/tmp/tech_test_node"
create_test_directory $node_test_dir
touch package.json
set -l result (run_tech_stack)
test_assert_contains "Node.js project should be detected" "📦" "$result"
cleanup_test_directory $node_test_dir
echo

# Test 3: Python project detection
echo "🐍 Testing Python project detection..."
set -l python_test_dir "/tmp/tech_test_python"
create_test_directory $python_test_dir
touch requirements.txt
set -l result (run_tech_stack)
test_assert_contains "Python project should be detected" "🐍" "$result"
cleanup_test_directory $python_test_dir
echo

# Test 4: Rust project detection
echo "🦀 Testing Rust project detection..."
set -l rust_test_dir "/tmp/tech_test_rust"
create_test_directory $rust_test_dir
touch Cargo.toml
set -l result (run_tech_stack)
test_assert_contains "Rust project should be detected" "🦀" "$result"
cleanup_test_directory $rust_test_dir
echo

# Test 5: .NET project detection (should only trigger with actual files)
echo "💜 Testing .NET project detection..."
set -l dotnet_test_dir "/tmp/tech_test_dotnet"
create_test_directory $dotnet_test_dir
touch project.csproj
set -l result (run_tech_stack)
test_assert_contains ".NET project should be detected with .csproj file" "💜" "$result"
cleanup_test_directory $dotnet_test_dir
echo

# Test 6: TypeScript detection
echo "🔷 Testing TypeScript detection..."
set -l ts_test_dir "/tmp/tech_test_typescript"
create_test_directory $ts_test_dir
touch tsconfig.json
set -l result (run_tech_stack)
test_assert_contains "TypeScript should be detected with tsconfig.json" "🔷" "$result"
cleanup_test_directory $ts_test_dir
echo

# Test 7: Docker detection
echo "🐳 Testing Docker detection..."
set -l docker_test_dir "/tmp/tech_test_docker"
create_test_directory $docker_test_dir
touch Dockerfile
set -l result (run_tech_stack)
test_assert_contains "Docker should be detected with Dockerfile" "🐳" "$result"
cleanup_test_directory $docker_test_dir
echo

# Test 8: Multiple technologies
echo "🔧 Testing multiple technologies..."
set -l multi_test_dir "/tmp/tech_test_multi"
create_test_directory $multi_test_dir
touch package.json tsconfig.json Dockerfile
set -l result (run_tech_stack)
test_assert_contains "Should detect Node.js in multi-tech project" "📦" "$result"
test_assert_contains "Should detect TypeScript in multi-tech project" "🔷" "$result"
test_assert_contains "Should detect Docker in multi-tech project" "🐳" "$result"
cleanup_test_directory $multi_test_dir
echo

# Test 9: False positive prevention (glob patterns)
echo "🛡️ Testing false positive prevention..."
set -l false_positive_test_dir "/tmp/tech_test_false_positive"
create_test_directory $false_positive_test_dir
# Create files that should NOT trigger language detection
touch not_a_gemspec.txt not_a_java_file.txt not_a_csproj.txt
set -l result (run_tech_stack)
test_assert_not_contains "Should not detect Ruby without proper files" "💎" "$result"
test_assert_not_contains "Should not detect Java without proper files" "☕" "$result"
test_assert_not_contains "Should not detect .NET without proper files" "💜" "$result"
cleanup_test_directory $false_positive_test_dir
echo

# Test 10: Ruby project detection (with Gemfile)
echo "💎 Testing Ruby project detection..."
set -l ruby_test_dir "/tmp/tech_test_ruby"
create_test_directory $ruby_test_dir
touch Gemfile
set -l result (run_tech_stack)
test_assert_contains "Ruby project should be detected with Gemfile" "💎" "$result"
cleanup_test_directory $ruby_test_dir
echo

# Test 11: Go project detection
echo "🐹 Testing Go project detection..."
set -l go_test_dir "/tmp/tech_test_go"
create_test_directory $go_test_dir
touch go.mod
set -l result (run_tech_stack)
test_assert_contains "Go project should be detected with go.mod" "🐹" "$result"
cleanup_test_directory $go_test_dir
echo

# Test 12: Vue.js project detection
echo "💚 Testing Vue.js project detection..."
set -l vue_test_dir "/tmp/tech_test_vue"
create_test_directory $vue_test_dir
touch vue.config.js
set -l result (run_tech_stack)
test_assert_contains "Vue.js should be detected with vue.config.js" "💚" "$result"
cleanup_test_directory $vue_test_dir
echo

# Test 13: Docker Compose detection
echo "🐳 Testing Docker Compose detection..."
set -l docker_compose_test_dir "/tmp/tech_test_docker_compose"
create_test_directory $docker_compose_test_dir
touch docker-compose.yml
set -l result (run_tech_stack)
test_assert_contains "Docker should be detected with docker-compose.yml" "🐳" "$result"
cleanup_test_directory $docker_compose_test_dir
echo

# Test 14: Complex project (fullstack)
echo "🎯 Testing complex fullstack project..."
set -l fullstack_test_dir "/tmp/tech_test_fullstack"
create_test_directory $fullstack_test_dir
touch package.json tsconfig.json Dockerfile docker-compose.yml requirements.txt
set -l result (run_tech_stack)
test_assert_contains "Should detect Node.js in fullstack project" "📦" "$result"
test_assert_contains "Should detect TypeScript in fullstack project" "🔷" "$result"
test_assert_contains "Should detect Python in fullstack project" "🐍" "$result"
# Note: Docker may not appear due to 3-tech display limit (indicated by ...)
echo "   Debug: Full result = '$result'"
cleanup_test_directory $fullstack_test_dir
echo

# Test 15: Edge case - files in subdirectories should not be detected
echo "📂 Testing subdirectory isolation..."
set -l subdir_test_dir "/tmp/tech_test_subdir"
create_test_directory $subdir_test_dir
mkdir -p backend frontend
touch backend/package.json frontend/tsconfig.json
set -l result (run_tech_stack)
test_assert_not_contains "Should not detect tech in subdirectories from parent" "📦" "$result"
test_assert_not_contains "Should not detect tech in subdirectories from parent" "🔷" "$result"
cleanup_test_directory $subdir_test_dir
echo

# Test 16: JSON configuration validation
echo "📄 Testing JSON configuration files..."
test_assert "tech_rules.json should exist" "true" (test -f ~/.config/fish/tech_rules.json; and echo true; or echo false)
test_assert "language_rules.json should exist" "true" (test -f ~/.config/fish/language_rules.json; and echo true; or echo false)

# Validate JSON syntax
if command -v jq >/dev/null 2>&1
    set -l tech_json_valid (jq empty ~/.config/fish/tech_rules.json 2>/dev/null; and echo true; or echo false)
    set -l lang_json_valid (jq empty ~/.config/fish/language_rules.json 2>/dev/null; and echo true; or echo false)
    test_assert "tech_rules.json should be valid JSON" "true" "$tech_json_valid"
    test_assert "language_rules.json should be valid JSON" "true" "$lang_json_valid"

    # Test that required fields exist
    set -l tech_rules_count (jq '.tech_rules | length' ~/.config/fish/tech_rules.json)
    set -l lang_rules_count (jq '.language_rules | length' ~/.config/fish/language_rules.json)
    test_assert "tech_rules.json should contain rules" "true" (test $tech_rules_count -gt 0; and echo true; or echo false)
    test_assert "language_rules.json should contain rules" "true" (test $lang_rules_count -gt 0; and echo true; or echo false)
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