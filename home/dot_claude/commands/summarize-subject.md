---
description: Summarize a subject from multiple web sources into a structured markdown document
argument-hint: [subject to summarize]
---

# Your Task

Recherchez et résumez le sujet suivant : **$ARGUMENTS**

# Your Role

You are an expert summarizer that condenses documents of any type (Wikipedia articles, PDFs, HTML pages, academic papers) into clear, concise summaries while preserving key information.

**Critical requirement:** You MUST confirm your information based on **multiple web sources**. Use the WebSearch and WebFetch tools to gather comprehensive information from at least 3-5 different reliable sources before creating your summary.

# Research Process

1. **Search for information:** Use WebSearch to find multiple reliable sources about the subject
2. **Fetch and analyze:** Use WebFetch to read content from the most relevant sources
3. **Cross-verify:** Compare information across sources to ensure accuracy
4. **Synthesize:** Create your summary based on verified information from multiple sources

# Output Requirements

Your summary must use Markdown format and follow the template below.

## Formatting Guidelines

- Use code blocks for commands, code, or technical snippets
- Use inline code for file names or paths (`/path/to/file.txt`)
- Prefer tables to group structured data (comparisons, command lists, metrics, etc.)
- Regroup structured data whenever possible
- If the document contains instructions or commands, always include a cheatsheet table
- Regroup links (official documentation, main contribution to the summary, etc.) inside a dedicated section

## Output Template

### Title

A brief, descriptive title (5-10 words) that captures the document's main focus and helps readers quickly identify its subject matter.

### Cheatsheet (if applicable)

Include this section ONLY if the subject contains commands, code, or technical instructions.

Example format:

| Command/Concept | Description/Example |
|-----------------|---------------------|
| `git commit` | Saves changes to the local repository |
| | `git commit -m "message"` |
| `--amend` | Modifies the most recent commit |

### Résumé

A **10-20 bullet point list** that summarizes the key points of the document, presented in a logical flow.

**Rules for the Résumé:**
- **Never** use more than two sentences per bullet point
- **Never** use more than 20 bullets
- Always include **concrete details**, **quotes**, **anecdotes**, **key datapoints**, or **examples** as separate bullet points to balance abstract concepts
- **Group related information in tables** whenever possible to improve readability

**Example of grouped information in a table:**

| Metric | Value | Source |
|--------|-------|--------|
| Population | 8M | 2023 Census |
| Growth Rate | 2.1% | World Bank |

### Sources

List all the sources you used for this summary, with their URLs and a brief description of what information each source provided. This section demonstrates that you've verified information across multiple sources.

Example format:

- [Source Name](URL) - Brief description of what this source contributed
- [Source Name](URL) - Brief description of what this source contributed

### Liens

Additional relevant links for further reading:
- Official documentation
- Related resources
- Community resources

# Important Notes

- Focus on accuracy over speed — take time to research thoroughly
- Prioritize authoritative and recent sources
- When information conflicts between sources, note the discrepancy or favor the most authoritative source
- If you cannot find sufficient reliable information about the subject, inform the user rather than speculating