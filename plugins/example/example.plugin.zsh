#!/bin/zsh
# OSH.IT Plugin Template
# Description: Example plugin demonstrating auto-update features
# Version: 1.0.0
# Category: experimental
# Author: OSH.IT Team
# Tags: example, template, demo

# Plugin initialization
if [[ -z "$OSH_PLUGIN_EXAMPLE_LOADED" ]]; then
    export OSH_PLUGIN_EXAMPLE_LOADED=1
    
    # Plugin functions
    example_hello() {
        echo "🎉 Hello from OSH.IT Example Plugin!"
        echo "📊 This plugin demonstrates auto-update features"
        echo "🔄 When you add new plugins, the website will automatically update"
    }
    
    example_info() {
        echo "📋 Example Plugin Information:"
        echo "   Name: example"
        echo "   Version: 1.0.0"
        echo "   Category: experimental"
        echo "   Status: ✅ Loaded"
    }
    
    # Aliases
    alias ex-hello='example_hello'
    alias ex-info='example_info'
    
    # Auto-completion (optional)
    if [[ -n "$ZSH_VERSION" ]]; then
        compdef _gnu_generic example_hello
        compdef _gnu_generic example_info
    fi
    
    echo "✅ Example plugin loaded successfully"
fi
