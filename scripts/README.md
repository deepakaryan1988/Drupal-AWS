# DevOps AI Agent

An intelligent automation tool for routine Drupal-AWS infrastructure tasks.

## Overview

The DevOps AI Agent automates common DevOps workflows including:
- Drupal module update checking and management
- Terraform configuration validation
- Infrastructure change planning
- Automated documentation updates
- Change summary generation

## Quick Start

### Prerequisites

- Python 3.7+
- Terraform
- Composer (for Drupal)
- AWS CLI configured

### Installation

1. Make scripts executable:
```bash
chmod +x scripts/devops.sh
chmod +x scripts/devops_agent.py
```

2. Install Python dependencies:
```bash
pip3 install PyYAML
```

### Usage

#### Simple Commands

```bash
# Check for Drupal module updates
./scripts/devops.sh check-updates

# Update all Drupal modules
./scripts/devops.sh update-modules

# Validate Terraform configurations
./scripts/devops.sh validate

# Generate Terraform plans
./scripts/devops.sh plan

# Run complete workflow
./scripts/devops.sh full
```

#### Advanced Usage

```bash
# Update specific modules
./scripts/devops.sh update-modules drupal/core drupal/admin_toolbar

# Run with Python directly
python3 scripts/devops_agent.py --full
python3 scripts/devops_agent.py --check-updates
python3 scripts/devops_agent.py --validate
```

## Workflow Details

### Full Workflow (`./scripts/devops.sh full`)

1. **Module Check**: Scans for outdated Drupal modules
2. **Module Updates**: Updates modules if requested
3. **Terraform Validation**: Validates all Terraform configurations
4. **Infrastructure Planning**: Generates Terraform plans
5. **Documentation Update**: Updates `docs/architecture-overview.md`
6. **Report Generation**: Creates `docs/devops_report.md`

### Individual Commands

#### `check-updates`
- Scans `composer.json` for outdated packages
- Displays current vs latest versions
- Returns exit code 0 if updates available

#### `update-modules`
- Updates specified modules or all modules
- Runs `composer update`
- Handles dependency resolution

#### `validate`
- Validates all Terraform modules:
  - `terraform/network`
  - `terraform/ecr`
  - `terraform/rds`
  - `terraform/ecs`
- Reports validation status for each module

#### `plan`
- Initializes Terraform modules if needed
- Generates detailed plans
- Parses plan output for change summary
- Saves plans as `plan.out` files

## Output Files

### Logs
- `devops_agent.log`: Detailed execution logs
- Console output: Real-time status updates

### Reports
- `docs/devops_report.md`: Summary of all changes and validations
- `docs/architecture-overview.md`: Updated with change log section

### Terraform Plans
- `terraform/*/plan.out`: Terraform plan files for each module

## Configuration

### Project Structure
```
Drupal-AWS/
├── scripts/
│   ├── devops_agent.py    # Main agent script
│   ├── devops.sh          # Shell wrapper
│   └── README.md          # This file
├── terraform/
│   ├── network/
│   ├── ecr/
│   ├── rds/
│   └── ecs/
├── docs/
│   └── architecture-overview.md
└── composer.json
```

### Customization

Edit `devops_agent.py` to modify:
- Terraform module paths
- Documentation file locations
- Logging configuration
- Command execution behavior

## Error Handling

The agent includes comprehensive error handling:
- Command execution failures
- Terraform validation errors
- File permission issues
- Dependency missing errors

All errors are logged with detailed information for debugging.

## Integration

### CI/CD Pipeline
Add to your CI/CD pipeline:
```yaml
# Example GitHub Actions step
- name: Run DevOps Agent
  run: |
    ./scripts/devops.sh validate
    ./scripts/devops.sh plan
```

### Scheduled Tasks
Set up cron jobs for regular checks:
```bash
# Daily module update check
0 9 * * * cd /path/to/Drupal-AWS && ./scripts/devops.sh check-updates

# Weekly full workflow
0 10 * * 0 cd /path/to/Drupal-AWS && ./scripts/devops.sh full
```

## Troubleshooting

### Common Issues

1. **Python not found**
   ```bash
   # Install Python 3
   brew install python3  # macOS
   sudo apt install python3  # Ubuntu
   ```

2. **PyYAML missing**
   ```bash
   pip3 install PyYAML
   ```

3. **Terraform not in PATH**
   ```bash
   # Add Terraform to PATH or install
   brew install terraform  # macOS
   ```

4. **Permission denied**
   ```bash
   chmod +x scripts/devops.sh
   chmod +x scripts/devops_agent.py
   ```

### Debug Mode

Run with verbose logging:
```bash
python3 scripts/devops_agent.py --full 2>&1 | tee debug.log
```

## Contributing

To extend the agent:

1. Add new methods to `DevOpsAgent` class
2. Update command-line argument parsing
3. Add corresponding shell script commands
4. Update this README

## License

This tool is part of the Drupal-AWS project and follows the same licensing terms.
