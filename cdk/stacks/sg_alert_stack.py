from aws_cdk import (
    Stack,
    Duration,
    aws_events as events,
    aws_events_targets as targets,
    aws_iam as iam,
    aws_lambda as lambda_,
    aws_secretsmanager as secretsmanager,
)
from constructs import Construct


LAMBDA_CODE = """\
import json, os, urllib.request
import boto3

def handler(event, context):
    sm = boto3.client("secretsmanager")
    ec2 = boto3.client("ec2", region_name="us-east-1")
    webhook_url = sm.get_secret_value(SecretId=os.environ["WEBHOOK_SECRET_NAME"])["SecretString"]

    detail = event.get("detail", {})
    user = detail.get("userIdentity", {})
    username = user.get("userName") or user.get("sessionContext", {}).get("sessionIssuer", {}).get("userName", "unknown")
    principal = user.get("principalId", "unknown")
    event_time = detail.get("eventTime", "unknown")
    sg_id = detail.get("requestParameters", {}).get("groupId", "unknown")

    # Parse the IP permissions for a readable summary and build revoke params
    perms = detail.get("requestParameters", {}).get("ipPermissions", {}).get("items", [])
    changes = []
    revoke_permissions = []
    for p in perms:
        proto = p.get("ipProtocol", "?")
        from_port = p.get("fromPort", "?")
        to_port = p.get("toPort", "?")
        port = str(from_port) if from_port == to_port else f"{from_port}-{to_port}"
        proto_port = "all traffic" if proto == "-1" else f"{proto}/{port}"
        sources = []

        revoke_perm = {"IpProtocol": str(proto)}
        if proto != "-1":
            revoke_perm["FromPort"] = int(from_port)
            revoke_perm["ToPort"] = int(to_port)

        ip_ranges = []
        for r in p.get("ipRanges", {}).get("items", []):
            cidr = r.get("cidrIp", "?")
            sources.append(cidr)
            ip_ranges.append({"CidrIp": cidr})
        if ip_ranges:
            revoke_perm["IpRanges"] = ip_ranges

        ipv6_ranges = []
        for r in p.get("ipv6Ranges", {}).get("items", []):
            cidr = r.get("cidrIpv6", "?")
            sources.append(cidr)
            ipv6_ranges.append({"CidrIpv6": cidr})
        if ipv6_ranges:
            revoke_perm["Ipv6Ranges"] = ipv6_ranges

        sg_refs = []
        for g in p.get("groups", {}).get("items", []):
            gid = g.get("groupId", "?")
            sources.append(f"sg:{gid}")
            sg_refs.append({"GroupId": gid})
        if sg_refs:
            revoke_perm["UserIdGroupPairs"] = sg_refs

        changes.append(f"{proto_port} from {', '.join(sources) or '?'}")
        revoke_permissions.append(revoke_perm)

    change_str = "; ".join(changes) or "details unavailable"

    # Automatically revoke the ingress rule
    revoked = False
    revoke_error = None
    if revoke_permissions:
        try:
            ec2.revoke_security_group_ingress(GroupId=sg_id, IpPermissions=revoke_permissions)
            revoked = True
        except Exception as e:
            revoke_error = str(e)

    if revoked:
        status = ":white_check_mark: *Automatically revoked*"
    elif revoke_error:
        status = f":x: *Auto-revoke failed:* {revoke_error}"
    else:
        status = ":warning: *Could not determine rule to revoke*"

    text = (
        f":rotating_light: *Security Group Ingress Blocked*\\n"
        f">:no_entry: *The `default` SG is attached to ALL EC2 instances. Adding ingress rules here opens ports across the entire infrastructure.*\\n"
        f">\\n"
        f">*SG:* `default` (`{sg_id}`)\\n"
        f">*User:* `{username}` (`{principal}`)\\n"
        f">*Attempted change:* {change_str}\\n"
        f">*Time:* {event_time}\\n"
        f">\\n"
        f">{status}\\n"
        f">\\n"
        f">_If you need to open a port, add the rule to a service-specific security group instead._"
    )

    payload = json.dumps({"channel": "#devops", "username": "AWS Security Alert", "text": text}).encode()
    req = urllib.request.Request(webhook_url, data=payload, headers={"Content-Type": "application/json"})
    urllib.request.urlopen(req)
"""


class SgAlertStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        default_sg_id = "sg-21ac675b"
        webhook_secret_name = "agr/slack/devops-webhook-url"

        secret = secretsmanager.Secret.from_secret_name_v2(
            self, "SlackWebhookSecret", webhook_secret_name,
        )

        fn = lambda_.Function(self, "SgAlertFunction",
            runtime=lambda_.Runtime.PYTHON_3_12,
            handler="index.handler",
            code=lambda_.Code.from_inline(LAMBDA_CODE),
            timeout=Duration.seconds(15),
            environment={"WEBHOOK_SECRET_NAME": webhook_secret_name},
            description="Blocks and alerts on default SG ingress changes",
        )
        secret.grant_read(fn)
        fn.add_to_role_policy(iam.PolicyStatement(
            actions=["ec2:RevokeSecurityGroupIngress"],
            resources=[f"arn:aws:ec2:us-east-1:100225593120:security-group/{default_sg_id}"],
        ))

        rule = events.Rule(self, "DefaultSgIngressRule",
            rule_name="agr-default-sg-ingress-alert",
            description=f"Alert when ingress rules are added to the default security group ({default_sg_id})",
            event_pattern=events.EventPattern(
                source=["aws.ec2"],
                detail_type=["AWS API Call via CloudTrail"],
                detail={
                    "eventName": ["AuthorizeSecurityGroupIngress"],
                    "requestParameters": {
                        "groupId": [default_sg_id],
                    },
                },
            ),
        )

        rule.add_target(targets.LambdaFunction(fn))
