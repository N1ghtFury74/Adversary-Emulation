# Adversary Emulation – Defender-First Walkthrough (with an Offensive Lens)

This repository collects **report-driven adversary emulations** with everything you need to reproduce behaviors safely, study artifacts, and design detections that stand up in production. Each scenario is grounded in **real intrusions from public threat-intel** (original reports included) and paired with:

- **Step-by-step operator runbooks** a red-teamer would follow—mapped to ATT&CK and annotated with defender checkpoints.
- **Automation/scripts** to recreate the same misconfigurations attackers exploit and execute each stage deterministically.
- **Defender goals, signals, and validation** to ensure you captured what matters (process lineage; file/registry/service artifacts; DNS/TLS; app logs).
- **What’s here now:** BlackSuit ransomware and “SELECT XMRig FROM SQLServer” emulations with flows, scripts, and the original reports.
- **Reproducible IaC (when applicable):** disposable lab infrastructure for emulations, provisioned with **Terraform** and configured with **Ansible**, enabling **one-command up / one-command down** runs. Where appropriate, we include **packaged lab solutions** (e.g., LUDUS roles) and **prebuilt detection rules/queries** used in the scenarios.

**Goal:** help defenders **understand attacker tradecraft in depth**, then turn that knowledge into **production-ready detections and hunts**—focusing on durable behaviors (e.g., *non-browser HTTP fetch → file write → process start*) rather than brittle IOCs.

**Audience:** blue teams, detection engineers, DFIR analysts, and purple teams who want realistic, repeatable attack surface—in a form that directly translates to **log sources, queries, and alerts**.
