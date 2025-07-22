#!/usr/bin/env python3
"""
DevOps AI Agent for Drupal-AWS Infrastructure
Automates routine tasks: module updates, Terraform validation, planning, and documentation updates.
"""

import os
import sys
import subprocess
import json
import re
import argparse
from datetime import datetime
from pathlib import Path
# import yaml  # Not currently used
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('devops_agent.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class DevOpsAgent:
    def __init__(self, project_root="/Users/deepak/Documents/projects/Drupal-AWS"):
        self.project_root = Path(project_root)
        self.terraform_dirs = [
            "terraform/network",
            "terraform/ecr",
            "terraform/rds",
            "terraform/ecs"
        ]
        self.docs_dir = self.project_root / "docs"
        self.architecture_file = self.docs_dir / "architecture-overview.md"

    def run_command(self, command, cwd=None, capture_output=True):
        """Execute shell command and return result"""
        try:
            if cwd is None:
                cwd = self.project_root

            logger.info(f"Executing: {command}")
            result = subprocess.run(
                command,
                shell=True,
                cwd=cwd,
                capture_output=capture_output,
                text=True,
                check=True
            )
            return result
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e}")
            logger.error(f"Error output: {e.stderr}")
            return None

    def check_drupal_module_updates(self):
        """Check for available Drupal module updates"""
        logger.info("🔍 Checking for Drupal module updates...")

        # Check if composer.json exists
        composer_file = self.project_root / "composer.json"
        if not composer_file.exists():
            logger.warning("composer.json not found")
            return False

        # Check for outdated packages
        result = self.run_command("composer outdated --format=json")
        if result and result.stdout:
            try:
                outdated = json.loads(result.stdout)
                if outdated:
                    logger.info(f"Found {len(outdated)} outdated packages")
                    for package in outdated:
                        logger.info(f"  - {package['name']}: {package['version']} -> {package['latest']}")
                    return True
                else:
                    logger.info("All packages are up to date")
                    return False
            except json.JSONDecodeError:
                logger.error("Failed to parse composer outdated output")
                return False
        return False

    def update_drupal_modules(self, modules=None):
        """Update specified Drupal modules or all modules"""
        logger.info("🔄 Updating Drupal modules...")

        if modules:
            for module in modules:
                logger.info(f"Updating module: {module}")
                result = self.run_command(f"composer update {module}")
                if not result:
                    logger.error(f"Failed to update {module}")
                    return False
        else:
            # Update all packages
            result = self.run_command("composer update")
            if not result:
                logger.error("Failed to update packages")
                return False

        logger.info("✅ Module updates completed")
        return True

    def validate_terraform(self):
        """Validate all Terraform configurations"""
        logger.info("🔍 Validating Terraform configurations...")

        validation_results = {}

        for terraform_dir in self.terraform_dirs:
            dir_path = self.project_root / terraform_dir
            if dir_path.exists():
                logger.info(f"Validating {terraform_dir}...")
                result = self.run_command("terraform validate", cwd=dir_path)
                validation_results[terraform_dir] = result is not None

                if result:
                    logger.info(f"✅ {terraform_dir} - Valid")
                else:
                    logger.error(f"❌ {terraform_dir} - Invalid")
            else:
                logger.warning(f"Terraform directory not found: {terraform_dir}")

        return validation_results

    def plan_terraform_changes(self):
        """Generate Terraform plan for all modules"""
        logger.info("📋 Generating Terraform plans...")

        plan_results = {}

        for terraform_dir in self.terraform_dirs:
            dir_path = self.project_root / terraform_dir
            if dir_path.exists():
                logger.info(f"Planning {terraform_dir}...")

                # Initialize if needed
                init_result = self.run_command("terraform init", cwd=dir_path)
                if not init_result:
                    logger.error(f"Failed to initialize {terraform_dir}")
                    continue

                # Generate plan
                plan_file = dir_path / "plan.out"
                result = self.run_command(f"terraform plan -out={plan_file}", cwd=dir_path)

                if result:
                    # Parse plan output for changes
                    plan_output = result.stdout
                    changes = self.parse_terraform_plan(plan_output)
                    plan_results[terraform_dir] = changes
                    logger.info(f"✅ {terraform_dir} - {len(changes)} changes planned")
                else:
                    logger.error(f"❌ {terraform_dir} - Plan failed")
                    plan_results[terraform_dir] = []

        return plan_results

    def parse_terraform_plan(self, plan_output):
        """Parse Terraform plan output to extract changes"""
        changes = []

        # Look for resource changes
        resource_pattern = r'#\s*([^\s]+)\s+will be\s+(created|updated|destroyed)'
        matches = re.findall(resource_pattern, plan_output)

        for resource, action in matches:
            changes.append({
                'resource': resource,
                'action': action,
                'timestamp': datetime.now().isoformat()
            })

        return changes

    def generate_change_summary(self, module_updates=None, terraform_changes=None):
        """Generate a summary of changes for documentation"""
        logger.info("📝 Generating change summary...")

        summary = {
            'timestamp': datetime.now().isoformat(),
            'module_updates': module_updates or [],
            'terraform_changes': terraform_changes or {},
            'total_changes': 0
        }

        # Count total changes
        if terraform_changes:
            for module, changes in terraform_changes.items():
                summary['total_changes'] += len(changes)

        return summary

    def update_architecture_docs(self, change_summary):
        """Update architecture documentation with change summary"""
        logger.info("📚 Updating architecture documentation...")

        if not self.architecture_file.exists():
            logger.error("Architecture file not found")
            return False

        # Read current documentation
        with open(self.architecture_file, 'r') as f:
            content = f.read()

        # Create change log section
        change_log = self.create_change_log_section(change_summary)

        # Add or update change log section
        if "## Change Log" in content:
            # Update existing change log
            pattern = r'(## Change Log\n\n)(.*?)(\n## |$)'
            replacement = r'\1' + change_log + r'\3'
            updated_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        else:
            # Add new change log section before Conclusion
            if "## Conclusion" in content:
                updated_content = content.replace("## Conclusion", change_log + "\n## Conclusion")
            else:
                updated_content = content + "\n\n" + change_log

        # Write updated documentation
        with open(self.architecture_file, 'w') as f:
            f.write(updated_content)

        logger.info("✅ Architecture documentation updated")
        return True

    def create_change_log_section(self, change_summary):
        """Create a formatted change log section"""
        timestamp = datetime.fromisoformat(change_summary['timestamp']).strftime("%Y-%m-%d %H:%M:%S")

        change_log = f"""## Change Log

### {timestamp}

#### Module Updates
"""

        if change_summary['module_updates']:
            for update in change_summary['module_updates']:
                change_log += f"- {update}\n"
        else:
            change_log += "- No module updates\n"

        change_log += "\n#### Infrastructure Changes\n"

        if change_summary['terraform_changes']:
            for module, changes in change_summary['terraform_changes'].items():
                if changes:
                    change_log += f"\n**{module}**:\n"
                    for change in changes:
                        change_log += f"- {change['action']}: {change['resource']}\n"
        else:
            change_log += "- No infrastructure changes\n"

        change_log += f"\n**Total Changes**: {change_summary['total_changes']}\n"

        return change_log

    def run_full_workflow(self, update_modules=False, modules_to_update=None):
        """Run the complete DevOps workflow"""
        logger.info("🚀 Starting DevOps AI Agent workflow...")

        # Step 1: Check for module updates
        has_updates = self.check_drupal_module_updates()

        # Step 2: Update modules if requested
        module_updates = []
        if update_modules and has_updates:
            if self.update_drupal_modules(modules_to_update):
                module_updates = ["Drupal modules updated"]

        # Step 3: Validate Terraform
        validation_results = self.validate_terraform()

        # Step 4: Plan Terraform changes
        terraform_changes = self.plan_terraform_changes()

        # Step 5: Generate change summary
        change_summary = self.generate_change_summary(module_updates, terraform_changes)

        # Step 6: Update documentation
        self.update_architecture_docs(change_summary)

        # Step 7: Generate final report
        self.generate_final_report(validation_results, terraform_changes, change_summary)

        logger.info("✅ DevOps workflow completed successfully!")

    def generate_final_report(self, validation_results, terraform_changes, change_summary):
        """Generate a final summary report"""
        report_file = self.docs_dir / "devops_report.md"

        report = f"""# DevOps Workflow Report

**Generated**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## Summary

- **Total Changes**: {change_summary['total_changes']}
- **Modules Updated**: {len(change_summary['module_updates'])}
- **Terraform Modules**: {len(terraform_changes)}

## Validation Results

"""

        for module, is_valid in validation_results.items():
            status = "✅ Valid" if is_valid else "❌ Invalid"
            report += f"- **{module}**: {status}\n"

        report += "\n## Planned Changes\n"

        for module, changes in terraform_changes.items():
            if changes:
                report += f"\n### {module}\n"
                for change in changes:
                    report += f"- {change['action']}: {change['resource']}\n"

        with open(report_file, 'w') as f:
            f.write(report)

        logger.info(f"📊 Final report generated: {report_file}")

def main():
    parser = argparse.ArgumentParser(description="DevOps AI Agent for Drupal-AWS")
    parser.add_argument("--check-updates", action="store_true", help="Check for module updates")
    parser.add_argument("--update-modules", action="store_true", help="Update Drupal modules")
    parser.add_argument("--modules", nargs="+", help="Specific modules to update")
    parser.add_argument("--validate", action="store_true", help="Validate Terraform")
    parser.add_argument("--plan", action="store_true", help="Generate Terraform plans")
    parser.add_argument("--full", action="store_true", help="Run complete workflow")

    args = parser.parse_args()

    agent = DevOpsAgent()

    if args.full:
        agent.run_full_workflow(update_modules=True, modules_to_update=args.modules)
    elif args.check_updates:
        agent.check_drupal_module_updates()
    elif args.update_modules:
        agent.update_drupal_modules(args.modules)
    elif args.validate:
        agent.validate_terraform()
    elif args.plan:
        agent.plan_terraform_changes()
    else:
        # Default: run full workflow
        agent.run_full_workflow()

if __name__ == "__main__":
    main()
