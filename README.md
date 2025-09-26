# Adversary Emulation – Defender-First Walkthrough (with an Offensive Lens)

This repository curates report-driven adversary emulations that you can run safely end-to-end to study artifacts and build production-ready detections. Each scenario is grounded in real intrusions from public threat-intel (source reports included) and paired with:

- **Step-by-step operator runbooks** that mirror realistic tradecraft—mapped to ATT&CK and annotated with defender checkpoints.
- **Automation and scripts** to reproduce the same preconditions/misconfigurations and execute each stage deterministically.
- **Defender objectives, signals, and validation** to ensure you capture the critical elements of infrastructure visibility.
- **Reproducible IaC (when used):** disposable lab infrastructure with one-command up/down, e.g.:
  - Terraform modules to provision isolated VPC/VNet, subnets, route tables/NAT, SG/NSG, and test hosts (Windows/Linux) with tags for log routing.
  - Ludus-based infrastructure automation configurations to compose and orchestrate multi-component labs quickly (networking, hosts, and services) for repeatable emulations.
- **Hunting, detection, and investigation approaches** for the techniques observed in the emulation.

## Purpose

Enable defenders to understand attack steps in depth—tactics, tooling, and sequencing—then translate that understanding into reliable detections and hunts. The emphasis is on durable behavioral signals (not brittle IOCs) while continually strengthening DFIR and investigation.
