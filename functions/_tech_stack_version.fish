#!/usr/bin/env fish

function _check_local_then_global --description 'Check local node_modules/.bin first, then global command'
    set -l cmd_name $argv[1]
    set -l version_args $argv[2..-1]

    if test -f "./node_modules/.bin/$cmd_name"
        "./node_modules/.bin/$cmd_name" $version_args 2>/dev/null
    else if command -v $cmd_name >/dev/null 2>&1
        $cmd_name $version_args 2>/dev/null
    end
end

function _tech_stack_version --description 'Get version for supported languages'
    set -l language $argv[1]

    # Sanitize language name for use as variable name (remove dots, spaces, etc.)
    set -l sanitized_name (string replace -a '.' '_' -- $language | string replace -a ' ' '_')

    # Check cache first (session-level cache)
    set -l cache_var "_tech_version_cache_$sanitized_name"
    if set -q $cache_var
        echo $$cache_var
        return
    end

    # Get version (captured from switch output)
    set -l tech_ver (begin
        switch $language
            case "Node.js"
                if command -v node >/dev/null 2>&1
                    node -v 2>/dev/null | sed 's/v//'
                end
            case "Python"
            if command -v python3 >/dev/null 2>&1
                python3 --version 2>/dev/null | awk '{print $2}'
            else if command -v python >/dev/null 2>&1
                python --version 2>/dev/null | awk '{print $2}'
            end
        case "Rust"
            if command -v rustc >/dev/null 2>&1
                rustc --version 2>/dev/null | awk '{print $2}'
            end
        case "Go"
            if command -v go >/dev/null 2>&1
                go version 2>/dev/null | awk '{print $3}' | sed 's/go//'
            end
        case "PHP"
            if command -v php >/dev/null 2>&1
                php --version 2>/dev/null | head -n1 | awk '{print $2}' | cut -d'-' -f1
            end
        case "Ruby"
            if command -v ruby >/dev/null 2>&1
                ruby --version 2>/dev/null | awk '{print $2}'
            end
        case "Java"
            if command -v javac >/dev/null 2>&1
                javac -version 2>/dev/null | awk '{print $2}'
            end
        case ".NET"
            if command -v dotnet >/dev/null 2>&1
                dotnet --version 2>/dev/null
            end
        case "yarn"
            if command -v yarn >/dev/null 2>&1
                yarn --version 2>/dev/null
            end
        case "pnpm"
            if command -v pnpm >/dev/null 2>&1
                pnpm --version 2>/dev/null
            end
        case "bun"
            if command -v bun >/dev/null 2>&1
                bun --version 2>/dev/null
            end
        case "typescript"
            _check_local_then_global tsc --version | awk '{print $2}'
        case "webpack"
            _check_local_then_global webpack --version | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | head -n1
        case "vite"
            _check_local_then_global vite --version
        case "rollup"
            _check_local_then_global rollup --version | awk '{print $2}'
        case "eslint"
            _check_local_then_global eslint --version
        case "prettier"
            _check_local_then_global prettier --version
        case "docker"
            if command -v docker >/dev/null 2>&1
                docker --version 2>/dev/null | awk '{print $3}' | sed 's/,//'
            end
        case "terraform"
            if command -v terraform >/dev/null 2>&1
                terraform --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/v//'
            end
        case "ansible"
            if command -v ansible >/dev/null 2>&1
                ansible --version 2>/dev/null | head -n1 | awk '{print $2}'
            end
        case "next.js"
            # Check package.json for Next.js version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["next"] // .devDependencies["next"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "nuxt.js"
            # Check package.json for Nuxt.js version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["nuxt"] // .devDependencies["nuxt"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "babel"
            _check_local_then_global babel --version | awk '{print $2}'
        case "jest"
            _check_local_then_global jest --version
        case "vitest"
            _check_local_then_global vitest --version
        case "cypress"
            _check_local_then_global cypress --version
        case "playwright"
            _check_local_then_global playwright --version
        case "svelte"
            # Check package.json for Svelte version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["svelte"] // .devDependencies["svelte"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "astro"
            # Check package.json for Astro version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["astro"] // .devDependencies["astro"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "gatsby"
            # Check package.json for Gatsby version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["gatsby"] // .devDependencies["gatsby"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "remix"
            # Check package.json for Remix version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["@remix-run/react"] // .devDependencies["@remix-run/react"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "solidjs"
            # Check package.json for SolidJS version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["solid-js"] // .devDependencies["solid-js"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "angular"
            _check_local_then_global ng version | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | head -n1
        case "vue.js"
            # Check package.json for Vue version
            if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["vue"] // .devDependencies["vue"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "poetry"
            if command -v poetry >/dev/null 2>&1
                poetry --version 2>/dev/null | awk '{print $3}'
            end
        case "django"
            # Check if manage.py exists and try to get Django version
            if test -f manage.py
                python manage.py --version 2>/dev/null
            else if test -f package.json; and command -v jq >/dev/null 2>&1
                jq -r '.dependencies["django"] // .devDependencies["django"] // empty' package.json 2>/dev/null | sed 's/[\^~]//'
            end
        case "flutter"
            if command -v flutter >/dev/null 2>&1
                flutter --version 2>/dev/null | head -n1 | awk '{print $2}'
            end
        case "gradle"
            # Check for local gradlew wrapper first
            if test -f ./gradlew
                ./gradlew --version 2>/dev/null | grep 'Gradle' | awk '{print $2}'
            else if command -v gradle >/dev/null 2>&1
                gradle --version 2>/dev/null | grep 'Gradle' | awk '{print $2}'
            end
        case "make"
            if command -v make >/dev/null 2>&1
                make --version 2>/dev/null | head -n1 | awk '{print $3}'
            end
        case "cmake"
            if command -v cmake >/dev/null 2>&1
                cmake --version 2>/dev/null | head -n1 | awk '{print $3}'
            end
        case "bazel"
            if command -v bazel >/dev/null 2>&1
                bazel --version 2>/dev/null | awk '{print $3}'
            end
        case "git"
            if command -v git >/dev/null 2>&1
                git --version 2>/dev/null | awk '{print $3}'
            end
        case "fish"
            if command -v fish >/dev/null 2>&1
                fish --private --version 2>/dev/null | awk '{print $3}'
            end
        end
    end)

    # Cache the result and return it
    if test -n "$tech_ver"
        set -g $cache_var $tech_ver
        echo $tech_ver
    end
end
