## Security Policy

### Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < 1.0   | :x:                |

### Reporting a Vulnerability

Please report security vulnerabilities by opening a private security advisory on GitHub or emailing the maintainers directly.

### Current Security Notes

⚠️ **Current setup is for development only!**

For production:
- Change default passwords in `pjsip.conf`
- Enable TLS/SRTP for encrypted calls
- Implement fail2ban for brute force protection
- Use strong passwords
- Configure firewall rules properly
- Consider VPN for remote access
