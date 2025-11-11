#!/usr/bin/env python3
"""
PoC Environment Summary Generator
Analyzes logs and generates a comprehensive report
"""

import sys
import re
from datetime import datetime
from typing import Dict, List, Tuple

class SummaryGenerator:
    def __init__(self, log_file: str = None):
        self.log_content = ""
        self.errors = []
        self.warnings = []
        self.passed_checks = []
        self.failed_checks = []
        
        if log_file:
            try:
                with open(log_file, 'r') as f:
                    self.log_content = f.read()
            except FileNotFoundError:
                print(f"Warning: Log file '{log_file}' not found. Generating empty report.", file=sys.stderr)
                self.log_content = ""
    
    def parse_logs(self):
        """Parse logs to extract status information"""
        lines = self.log_content.split('\n')
        
        for line in lines:
            # Remove ANSI color codes
            clean_line = re.sub(r'\x1b\[[0-9;]*m', '', line)
            
            # Detect passed checks
            if '[PASS]' in clean_line or '[SUCCESS]' in clean_line or '✓' in clean_line:
                self.passed_checks.append(clean_line.strip())
            
            # Detect failed checks
            if '[FAIL]' in clean_line or '[ERROR]' in clean_line or '✗' in clean_line:
                self.failed_checks.append(clean_line.strip())
            
            # Detect warnings
            if '[WARN]' in clean_line:
                self.warnings.append(clean_line.strip())
            
            # Detect errors from docker logs
            if 'error' in clean_line.lower() and 'error' not in clean_line.lower()[:10]:
                self.errors.append(clean_line.strip())
    
    def detect_container_status(self) -> Dict[str, str]:
        """Detect container statuses from logs"""
        containers = {}
        pattern = r'poc1_(\w+)\s+.*\s+(running|exited|created|restarting|paused)'
        
        matches = re.finditer(pattern, self.log_content.lower())
        for match in matches:
            container_name = match.group(1)
            status = match.group(2)
            containers[container_name] = status
        
        return containers
    
    def generate_report(self) -> str:
        """Generate a comprehensive summary report"""
        self.parse_logs()
        
        report = []
        report.append("=" * 60)
        report.append("  PoC1 ENVIRONMENT SUMMARY REPORT")
        report.append("=" * 60)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        # Overall Status
        report.append("📊 OVERALL STATUS")
        report.append("-" * 60)
        if self.failed_checks:
            report.append("Status: ❌ FAILED")
            report.append(f"Some checks did not pass ({len(self.failed_checks)} failures)")
        elif self.passed_checks:
            report.append("Status: ✅ PASSED")
            report.append(f"All checks completed successfully ({len(self.passed_checks)} passed)")
        else:
            report.append("Status: ⚠️  UNKNOWN")
            report.append("No check results found in logs")
        report.append("")
        
        # Container Status
        containers = self.detect_container_status()
        if containers:
            report.append("🐳 CONTAINER STATUS")
            report.append("-" * 60)
            for name, status in containers.items():
                icon = "✅" if status == "running" else "❌"
                report.append(f"{icon} {name}: {status.upper()}")
            report.append("")
        
        # Passed Checks
        if self.passed_checks:
            report.append(f"✅ PASSED CHECKS ({len(self.passed_checks)})")
            report.append("-" * 60)
            for check in self.passed_checks[:10]:  # Limit to first 10
                report.append(f"  ✓ {check}")
            if len(self.passed_checks) > 10:
                report.append(f"  ... and {len(self.passed_checks) - 10} more")
            report.append("")
        
        # Failed Checks
        if self.failed_checks:
            report.append(f"❌ FAILED CHECKS ({len(self.failed_checks)})")
            report.append("-" * 60)
            for check in self.failed_checks:
                report.append(f"  ✗ {check}")
            report.append("")
        
        # Warnings
        if self.warnings:
            report.append(f"⚠️  WARNINGS ({len(self.warnings)})")
            report.append("-" * 60)
            for warning in self.warnings:
                report.append(f"  ⚠ {warning}")
            report.append("")
        
        # Errors
        if self.errors:
            report.append(f"🔥 ERRORS DETECTED ({len(self.errors)})")
            report.append("-" * 60)
            for error in self.errors[:5]:  # Limit to first 5
                report.append(f"  • {error}")
            if len(self.errors) > 5:
                report.append(f"  ... and {len(self.errors) - 5} more errors")
            report.append("")
        
        # Service Endpoints
        report.append("🌐 SERVICE ENDPOINTS")
        report.append("-" * 60)
        report.append("  • Authentik:   http://localhost:9000")
        report.append("  • JumpServer:  http://localhost:8080")
        report.append("")
        
        # Recommendations
        report.append("💡 RECOMMENDATIONS")
        report.append("-" * 60)
        if self.failed_checks:
            report.append("  1. Review failed checks above")
            report.append("  2. Check container logs: docker compose logs <service>")
            report.append("  3. Verify .env configuration in config/.env")
            report.append("  4. Ensure all required ports are available")
        else:
            report.append("  • Environment is ready for testing")
            report.append("  • Access services using URLs above")
            report.append("  • Check config/.env for credentials")
        report.append("")
        
        report.append("=" * 60)
        report.append("End of Report")
        report.append("=" * 60)
        
        return "\n".join(report)

def main():
    if len(sys.argv) > 1:
        log_file = sys.argv[1]
    else:
        log_file = "logs.txt"
    
    generator = SummaryGenerator(log_file)
    report = generator.generate_report()
    print(report)

if __name__ == "__main__":
    main()

