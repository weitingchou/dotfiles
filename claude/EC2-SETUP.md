# EC2 Dev Instance Setup

## Account & Profile
- AWS Account ID: `<YOUR_AWS_ACCOUNT_ID>`
- CLI Profile: `claude-bot` (IAM user)
- Region: `ap-southeast-1`

## Prerequisites

### IAM Policy: ClaudeEC2ManagerPolicy
Attached to `claude-bot` user. Key rules:
- `ec2:RunInstances` on `instance/*` and `volume/*` requires tag `ManagedBy=claude-bot` at request time
- `ec2:RunInstances` on existing resources (subnet, security-group, network-interface, image) — no tag condition
- `ec2:StartInstances/StopInstances/TerminateInstances/RebootInstances` require tag `ec2:ResourceTag/ManagedBy=claude-bot`
- `iam:PassRole` for `arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/EC2-SSM-Role` only
- SSM: `SendCommand`, `StartSession`, `TerminateSession`, `ResumeSession`, `GetCommandInvocation`, `DescribeInstanceInformation`, `ListCommandInvocations`

### IAM Role for EC2: EC2-SSM-Role
- Policy: `AmazonSSMManagedInstanceCore`
- Used as instance profile to enable SSM Session Manager access (no key pair needed)

## Step 1: Find Latest Ubuntu 24.04 AMI

```bash
aws ec2 describe-images --profile claude-bot --region ap-southeast-1 \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].{ImageId:ImageId,Name:Name}' \
  --output table
```

## Step 2: Launch Instance

```bash
aws ec2 run-instances \
  --profile claude-bot \
  --region ap-southeast-1 \
  --image-id <ami-id> \
  --instance-type m7i-flex.large \
  --iam-instance-profile Name=EC2-SSM-Role \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
  --tag-specifications \
    'ResourceType=instance,Tags=[{Key=Name,Value=<name>},{Key=ManagedBy,Value=claude-bot}]' \
    'ResourceType=volume,Tags=[{Key=ManagedBy,Value=claude-bot}]' \
  --output table
```

> Both `Name` and `ManagedBy=claude-bot` tags are required. The IAM policy enforces `ManagedBy=claude-bot` at launch time.

## Step 3: Install Dotfiles via SSM

Wait ~1-2 minutes for the instance to reach `running` state and the SSM agent to register, then run:

```bash
aws ssm send-command \
  --profile claude-bot \
  --region ap-southeast-1 \
  --instance-ids <instance-id> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["rm -rf /tmp/dotfiles /home/ubuntu/.oh-my-zsh && sudo -u ubuntu -i bash -c '\''export TERM=xterm-256color && printf \"y\\nserver\\n\" | bash -c \"$(curl -fsSL https://raw.githubusercontent.com/weitingchou/dotfiles/master/bootstrap.sh)\"'\''"]' \
  --comment "Install dotfiles as ubuntu user" \
  --timeout-seconds 600 \
  --query 'Command.CommandId' \
  --output text
```

### Poll until complete

```bash
aws ssm get-command-invocation \
  --profile claude-bot \
  --region ap-southeast-1 \
  --command-id <command-id> \
  --instance-id <instance-id> \
  --query '{Status:Status,Output:StandardOutputContent}' \
  --output table
```

Installation is successful when stdout contains:
```
[OK] Installation completed without errors.
```

> Note: the command exits with code 127 (`zsh: command not found: server`) — this is harmless. It comes from `env zsh` at the end of the install script consuming leftover stdin input.

## Step 4: Connect

```bash
aws ssm start-session --profile claude-bot --region ap-southeast-1 --target <instance-id>
```

## Known Gotchas

| Issue | Cause | Fix |
|-------|-------|-----|
| `tput: No value for $TERM` | SSM has no terminal | Set `TERM=xterm-256color` |
| `$HOME` resolves to `/` | SSM runs as root without login env | Run as `sudo -u ubuntu -i` |
| `chsh: PAM: Authentication failure` | `chsh` requires PAM in non-root context | Use `sudo chsh -s $(which zsh) $USER` (already fixed in scripts) |
| `cp: -r not specified; omitting directory` | powerlevel10k theme is a directory | Use `cp -r` (already fixed in scripts) |
| Stale script served by CDN | `raw.github.com` has CDN caching | Always use `raw.githubusercontent.com` (already fixed in scripts) |
| Oh-my-zsh already exists on re-run | Previous partial install left `/home/ubuntu/.oh-my-zsh` | `rm -rf /home/ubuntu/.oh-my-zsh` before re-running |
