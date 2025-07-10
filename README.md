# 🔄 AWS EBS Cross-Account Backup Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/bash/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)

> **Automate EBS snapshot creation and cross-account sharing for disaster recovery and data migration**

A powerful and user-friendly bash script that automates the process of creating EBS snapshots from EC2 instances and sharing them across AWS accounts. Perfect for disaster recovery, data migration, and cross-account backups.

## 📖 About This Project

This tool was born out of the need to simplify and automate the complex process of backing up EC2 instances across AWS accounts. Whether you're implementing disaster recovery, migrating workloads, or ensuring compliance with backup policies, this script handles the heavy lifting while providing detailed logging and error handling.

### 🏷️ Repository Topics
`aws` `ebs` `snapshot` `backup` `cross-account` `disaster-recovery` `automation` `bash` `ec2` `migration` `devops` `infrastructure` `cloud`

## ✨ Features

- 🔍 **Automatic Discovery**: Automatically discovers all EC2 instances in your AWS account
- 📸 **Bulk Snapshot Creation**: Creates snapshots for all EBS volumes attached to instances
- 🤝 **Cross-Account Sharing**: Automatically shares snapshots with destination AWS accounts
- 🔐 **Encryption Support**: Handles encrypted volumes with proper KMS key sharing warnings
- 🏷️ **Smart Tagging**: Preserves instance names as snapshot tags for easy identification
- 📊 **Progress Tracking**: Real-time progress updates and detailed logging
- ⚡ **Performance Metrics**: Tracks timing for snapshot creation and sharing operations
- 🛡️ **Error Handling**: Robust error handling with detailed failure reporting

## 🚀 Quick Start

### Prerequisites

- AWS CLI installed and configured
- Appropriate IAM permissions (see [IAM Permissions](#iam-permissions))
- Bash shell (Linux/macOS/WSL)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/tuankg1028/aws-ebs-cross-account-backup.git
cd aws-ebs-cross-account-backup
```

2. Make the script executable:

```bash
chmod +x backup_snapshots.sh
```

### Usage

#### Method 1: Environment Variables (Recommended)

```bash
export DEST_ACCOUNT_ID="123456789012"
export AWS_REGION="us-east-1"
./backup_snapshots.sh
```

#### Method 2: Direct Script Modification

Edit the script and set your values:

```bash
DEST_ACCOUNT_ID="123456789012"
REGION="us-east-1"
```

## 📋 Configuration Options

| Variable          | Description                                 | Default          | Required |
| ----------------- | ------------------------------------------- | ---------------- | -------- |
| `DEST_ACCOUNT_ID` | Target AWS account ID for sharing snapshots | None             | ✅ Yes   |
| `AWS_REGION`      | AWS region to operate in                    | `ap-southeast-1` | ❌ No    |

## 🔐 IAM Permissions

The script requires the following IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:ModifySnapshotAttribute"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🎯 Use Cases

- **Disaster Recovery**: Create cross-region/cross-account backups
- **Data Migration**: Move EC2 instances between AWS accounts
- **Compliance**: Automated backup for regulatory requirements
- **Development**: Copy production data to development accounts
- **Cost Optimization**: Centralized backup management

## 📊 Sample Output

```
🚀 Starting EC2 migration process...
📋 Configuration:
   - Destination Account: 123456789012
   - Region: us-east-1
   - Timestamp: Mon Dec 18 10:30:00 UTC 2023

🔍 Fetching EC2 instance info from region us-east-1...
📊 Found 3 EC2 instances to process

🔍 Instance list preview:
   Instance ID: i-1234567890abcdef0
   Instance Name: web-server-prod

🖥️  Processing instance 1/3: i-1234567890abcdef0 (web-server-prod)
   📊 Found 2 volume(s) attached to this instance
   📸 Creating snapshot 1/2 for volume vol-1234567890abcdef0...
   ✅ Snapshot created: snap-1234567890abcdef0 (in 2s)
   🏷️  Adding name tag to snapshot...
   ✅ Name tag added successfully
   🤝 Sharing snapshot snap-1234567890abcdef0 with account 123456789012...
   ✅ Snapshot shared successfully (in 1s)

📈 Migration Summary:
   - Total instances processed: 3
   - Total snapshots attempted: 6
   - Successful snapshots: 6
   - Failed snapshots: 0
   - Completion time: Mon Dec 18 10:35:00 UTC 2023

✅ All snapshots created and shared successfully!
```

## 🔒 Security Considerations

- **KMS Encryption**: For encrypted volumes, ensure KMS keys are shared with the destination account
- **IAM Roles**: Use IAM roles instead of access keys when possible
- **Account Validation**: Always verify the destination account ID before running
- **Audit Logging**: Enable CloudTrail for audit logging of snapshot operations

## 🐛 Troubleshooting

### Common Issues

1. **Permission Denied**

   - Ensure IAM user/role has required permissions
   - Check if you're running in the correct AWS region

2. **Encrypted Volume Sharing Fails**

   - Share the KMS key with the destination account first
   - Grant `kms:CreateGrant` permission to the destination account

3. **Snapshot Creation Timeout**
   - Large volumes may take longer to snapshot
   - Check AWS service health status

### Debug Mode

Enable verbose logging:

```bash
set -x
./backup_snapshots.sh
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS CLI team for the excellent command-line interface
- Community contributors and testers
- AWS documentation team
- Open source community for inspiration and feedback

## 📈 Repository Stats

![GitHub stars](https://img.shields.io/github/stars/tuankg1028/aws-ebs-cross-account-backup?style=social)
![GitHub forks](https://img.shields.io/github/forks/tuankg1028/aws-ebs-cross-account-backup?style=social)
![GitHub issues](https://img.shields.io/github/issues/tuankg1028/aws-ebs-cross-account-backup)
![GitHub last commit](https://img.shields.io/github/last-commit/tuankg1028/aws-ebs-cross-account-backup)

## 📞 Support

- 🐛 [Report Bugs](https://github.com/tuankg1028/aws-ebs-cross-account-backup/issues)
- 💡 [Request Features](https://github.com/tuankg1028/aws-ebs-cross-account-backup/issues)
- 📧 [Email Support](mailto:lethanhtuan1028@gmail.com)
- 💬 [Discussions](https://github.com/tuankg1028/aws-ebs-cross-account-backup/discussions)

## 🌟 Show Your Support

If this project helped you, please consider:
- ⭐ Starring the repository
- 🍴 Forking it for your own use
- 📢 Sharing it with your network
- 🐛 Reporting issues or suggesting improvements

---

**Made with ❤️ for the AWS community** | **Free and Open Source** | **MIT Licensed**
