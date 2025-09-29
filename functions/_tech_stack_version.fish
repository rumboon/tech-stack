#!/usr/bin/env fish

function _tech_stack_version --description 'Get version for supported languages'
    set -l language $argv[1]

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
    end
end