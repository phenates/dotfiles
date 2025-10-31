---
description: Create comprehensive research notes on any subject with cross-referenced sources
argument-hint: [subject to research]
allowed-tools: WebSearch, WebFetch, Write, Read, Bash
---

# Note Test - Research Note Generator

This command performs in-depth research on a specified subject and generates a comprehensive markdown file with cross-referenced information from multiple sources.

## Usage:

`/note-test [subject to research]`

## Process:

1. **Subject Analysis**
   - Parse the input subject and identify key research angles
   - Determine relevant search queries to cover different perspectives

2. **Multi-Source Research**
   - Execute multiple web searches with varied query formulations
   - Fetch content from diverse, credible sources
   - Prioritize authoritative sources (official documentation, academic papers, reputable tech blogs)

3. **Information Synthesis**
   - Cross-reference findings from different sources
   - Identify consensus points and contradictions
   - Highlight key concepts, definitions, and best practices
   - Note any controversies or differing viewpoints

4. **Note Generation**
   - Create a structured markdown file with clear sections:
     - **Overview**: High-level summary of the subject
     - **Key Concepts**: Core ideas and definitions
     - **Main Points**: Detailed findings organized by theme
     - **Different Perspectives**: Contrasting viewpoints if applicable
     - **Practical Applications**: Real-world usage and examples
     - **Sources**: All references used in research
   - Use proper markdown formatting (headers, lists, code blocks, quotes)
   - Include citations and links to sources

5. **File Output**
   - Save the note as a markdown file with a descriptive filename
   - Format: `{subject-slug}-notes-{date}.md`
   - Inform the user of the file location

## Examples:

- `/note-test React Server Components`
  - Researches RSC architecture, benefits, limitations, and implementation
  - Creates: `react-server-components-notes-2025-10-31.md`

- `/note-test OAuth 2.0 security best practices`
  - Investigates OAuth flows, security considerations, common vulnerabilities
  - Creates: `oauth-2-0-security-best-practices-notes-2025-10-31.md`

- `/note-test Python async/await patterns`
  - Explores async programming in Python, patterns, pitfalls, performance
  - Creates: `python-async-await-patterns-notes-2025-10-31.md`

## Research Strategy:

To ensure comprehensive coverage, perform:
- **Broad search**: General overview of the subject
- **Technical search**: In-depth technical details and specifications
- **Practical search**: Tutorials, examples, real-world usage
- **Critical search**: Common issues, limitations, criticisms

Cross-reference at least 3-5 different sources to validate information and provide a balanced perspective.

## Notes:

- The command requires internet access for web searches
- Research quality depends on available sources and search results
- Generated notes are starting points for deeper study, not exhaustive references
- Always verify critical information from primary sources
- The note file is created in the current working directory unless specified otherwise
