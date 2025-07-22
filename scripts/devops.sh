#!/bin/bash

# DevOps AI Agent Wrapper Script
# Makes it easy to run routine DevOps tasks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_SCRIPT="$SCRIPT_DIR/devops_agent.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "DevOps AI Agent - Drupal-AWS Infrastructure"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  check-updates     Check for Drupal module updates"
    echo "  update-modules    Update Drupal modules"
    echo "  validate         Validate Terraform configurations"
    echo "  plan             Generate Terraform plans"
    echo "  full             Run complete workflow (check, update, validate, plan, docs)"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check-updates"
    echo "  $0 update-modules"
    echo "  $0 validate"
    echo "  $0 plan"
    echo "  $0 full"
    echo ""
}

# Function to check if Python and required packages are available
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi

    # Check for required Python packages (PyYAML removed as not needed)
    print_status "Dependencies check passed"
}

# Function to run the agent
run_agent() {
    local command="$1"
    shift

    case "$command" in
        "check-updates")
            print_status "Checking for Drupal module updates..."
            python3 "$AGENT_SCRIPT" --check-updates
            ;;
        "update-modules")
            print_status "Updating Drupal modules..."
            python3 "$AGENT_SCRIPT" --update-modules "$@"
            ;;
        "validate")
            print_status "Validating Terraform configurations..."
            python3 "$AGENT_SCRIPT" --validate
            ;;
        "plan")
            print_status "Generating Terraform plans..."
            python3 "$AGENT_SCRIPT" --plan
            ;;
        "full")
            print_status "Running complete DevOps workflow..."
            python3 "$AGENT_SCRIPT" --full
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "$AGENT_SCRIPT" ]]; then
        print_error "DevOps agent script not found: $AGENT_SCRIPT"
        exit 1
    fi

    # Check dependencies
    check_dependencies

    # Make agent script executable
    chmod +x "$AGENT_SCRIPT"

    # Parse command
    if [[ $# -eq 0 ]]; then
        print_status "No command specified. Running full workflow..."
        run_agent "full"
    else
        run_agent "$@"
    fi
}

# Run main function with all arguments
main "$@"
