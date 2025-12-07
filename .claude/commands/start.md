# Start New Project: $ARGUMENTS

## Instructions

Initialize a new project: **$ARGUMENTS**

Follow the model selection guide in `.claude/patterns/model-selection.md` when invoking agents.

### Step 1: Understand the Project
Ask clarifying questions:
- What type of application? (web, mobile, API, CLI, etc.)
- What is the main purpose?
- Who are the target users?
- Any specific technology preferences?

### Step 2: Create Project Plan
Use the **product-manager agent** to:
- Define the MVP scope
- Create initial user stories
- Identify key features

### Step 3: Design User Experience (for UI projects)

**If project has a user interface**, use the **ui-ux-designer agent** to:
- Create user personas and journey maps
- Design user flows and wireframes
- Define design tokens (colors, typography, spacing)
- Specify accessibility requirements
- Write specifications to:
  - `.claude/specs/ui-ux-specs.md`
  - `.claude/specs/design-system.md`
  - `.claude/specs/accessibility.md`

**Skip this step for CLI, API-only, or backend projects.**

### Step 4: Design Architecture
Use the **architect agent** to:
- Choose technology stack
- Design folder structure
- Create initial architecture
- **For UI projects:** Design frontend architecture (component patterns, state management, styling)
- Write specifications to:
  - `.claude/specs/requirements.md`
  - `.claude/specs/architecture.md`
  - `.claude/specs/tech-stack.md`
  - `.claude/specs/frontend-architecture.md` (for UI projects)

### Step 5: Auto-Populate CLAUDE.md

After Architect creates specifications, invoke Architect again to populate CLAUDE.md:

**Architect Task:**
1. Read all specifications you just created:
   - `.claude/specs/requirements.md`
   - `.claude/specs/architecture.md`
   - `.claude/specs/tech-stack.md`

2. Update `CLAUDE.md` sections based on TEMPLATE-CLAUDE.md format:

   **## Overview**
   - 1-2 paragraph summary from requirements.md (what the project does, who it's for)

   **## Technology Stack**
   - Frontend: {from tech-stack.md}
   - Backend: {from tech-stack.md}
   - Database: {from tech-stack.md}
   - Infrastructure: {from tech-stack.md}

   **## Project Structure**
   - Directory structure from architecture.md
   - Component organization
   - File naming conventions

   **## Architecture**
   - High-level architecture overview from architecture.md
   - Key patterns being used
   - Component interactions

   **## Development Guidelines**
   - Code style from architecture.md
   - Testing approach
   - Git workflow
   - Quality standards

3. Commit update:
   ```bash
   git add CLAUDE.md
   git commit -m "docs: auto-populate CLAUDE.md from specifications

   - Overview from requirements.md
   - Tech stack from tech-stack.md
   - Architecture from architecture.md
   - Development guidelines

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   ```

**Why this matters:**
- CLAUDE.md stays in sync with actual architecture
- No manual documentation lag
- Single source of truth (specs → CLAUDE.md)
- Future sessions have accurate project context

### Step 6: Initialize Project
Use the **engineer agent** to:
- Create project structure
- Set up initial files
- Configure development environment

### Step 7: Document
Use the **documenter agent** to:
- Create initial README.md
- Document setup instructions
- Add development guidelines

### Output
A fully initialized project with:
- Complete folder structure
- Configuration files
- README with instructions
- Development guidelines
- **CLAUDE.md auto-populated from specifications**
  - Overview (from requirements.md)
  - Technology stack (from tech-stack.md)
  - Architecture (from architecture.md)
  - Development guidelines (from architecture.md)
- Specifications in `.claude/specs/`:
  - requirements.md
  - architecture.md
  - tech-stack.md
  - **For UI projects:**
    - ui-ux-specs.md (user flows, wireframes)
    - design-system.md (design tokens, component specs)
    - accessibility.md (WCAG requirements)
    - frontend-architecture.md (component patterns, state management)
