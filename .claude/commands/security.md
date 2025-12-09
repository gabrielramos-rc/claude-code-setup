---
description: Perform security audit for vulnerabilities and compliance
allowed-tools: Task, Read, Bash(npm audit:*), Bash(npx:*), Grep, Glob
argument-hint: <scope-or-module-to-audit>
---

# Security Audit: $ARGUMENTS

## Instructions

Perform a security audit of: **$ARGUMENTS**

If no argument, audit the entire project.

### Use the **security-auditor agent** to check:

1. **Code Security**
   - Injection vulnerabilities
   - XSS risks
   - Authentication issues
   - Authorization flaws

2. **Secrets Management**
   - No hardcoded credentials
   - Environment variables secure
   - .gitignore properly configured

3. **Dependencies**
   - Check for vulnerable packages
   - Review package versions

4. **Configuration**
   - Security headers
   - CORS settings
   - HTTPS enforcement

### Output

Security Report with:
- Severity level for each finding
- Location (file:line)
- Description and impact
- Recommended fix
- References (OWASP, CWE)
