---
description: Create comprehensive technical documentation using the note-complet-creator agent
argument-hint: [subject to research and document]
---

# Note - Comprehensive Documentation Creator

This command launches the `note-complet-creator` agent to create in-depth technical documentation on any subject.

## Usage:

`/note [subject to research and document]`

## What it does:

The command automatically launches the specialized `note-complet-creator` agent which will:

1. **Conduct Multi-Source Research**
   - Search multiple authoritative sources (minimum 10)
   - Cross-reference information for accuracy
   - Prioritize official documentation and credible technical sources

2. **Generate Comprehensive Documentation**
   - Create detailed markdown document with proper structure
   - Include frontmatter, logo, cheatsheets (when relevant)
   - Add code examples with English comments
   - Provide tables, diagrams, and visual aids
   - Write content in French with technical precision

3. **Cover All Aspects**
   - Historical context and evolution
   - Fundamentals and architecture
   - Implementation patterns and best practices
   - Performance, security, and troubleshooting
   - Comparisons with alternatives
   - Real-world applications and future trends

4. **Deliver Complete Reference**
   - Save as markdown file with descriptive filename
   - Include comprehensive references and further reading
   - Ready to integrate into knowledge base

## Examples:

- `/note WebSockets`
  - Creates comprehensive technical guide on WebSocket protocol

- `/note Kubernetes architecture`
  - Generates detailed documentation on Kubernetes design and components

- `/note OAuth 2.0 security best practices`
  - Produces in-depth security analysis and implementation guide

- `/note Python async/await patterns`
  - Documents Python asynchronous programming comprehensively

## Agent Details:

- **Agent:** note-complet-creator
- **Model:** Haiku (fast and efficient)
- **Depth:** Maximum (comprehensive research and documentation)
- **Output:** French content with English code comments
- **Format:** Structured markdown with frontmatter, cheatsheets, TOC

## Notes:

- The agent works autonomously and may take several minutes
- Requires internet access for web research
- Generated documentation is designed for long-term reference
- Files are saved in the current working directory
- Content quality is optimized for knowledge base integration

---

When invoked, launch the note-complet-creator agent with the Task tool using the subject provided by the user.
