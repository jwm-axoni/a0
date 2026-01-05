# Agent Zero Project Instructions

## 🎨 UI Redesign - Vercel/v0.dev Inspired

**CRITICAL**: All UI work MUST follow `AgentZero_KnowledgeTransfer/UI_COMPLETE_REDESIGN_SPEC.md`

### Design Direction
- **Inspiration**: v0.dev / Vercel AI Chat Interface
- **Aesthetic**: Clean, minimal, professional, premium SaaS
- **Primary Theme**: LIGHT (white backgrounds, subtle grays)
- **Secondary Theme**: Dark mode as option

### Key Design Requirements

#### 1. CENTERED CHAT INPUT (Most Important!)
- Input bar MUST be centered in main content area
- NOT attached to sidebar
- Floating with rounded corners (24px radius)
- Subtle shadow for depth
- Max-width: 800px

#### 2. Typography
- **Font**: Inter (via Google Fonts)
- Clean weights: 400, 500, 600, 700
- Generous line-height

#### 3. Color Palette
- **Backgrounds**: White (#ffffff), Light gray (#f9fafb)
- **Accents**: Purple (#a855f7), Blue (#3b82f6)
- **Gradients**: Purple to Indigo for CTAs
- **Borders**: Subtle gray (#e5e7eb)

#### 4. Layout
- Thin, collapsible sidebar (260px)
- Centered content with max-width (800px)
- Generous whitespace everywhere
- Card-based messages

#### 5. Components
- Floating input bar with shadow
- Rounded message bubbles
- Circular send button with gradient
- Modern toggle switches
- Subtle hover states

### Reference Images
Located in `UI_enhancement_project/`:
- `vercel.png` through `verrcel 8.png`

### NEVER Use
- Dark backgrounds as primary
- Emerald/green color schemes
- Input attached to sidebar
- Heavy borders instead of shadows
- Cramped spacing

## Project Context

- Agent Zero: AI agent framework
- Frontend: Vanilla JS + Alpine.js in `webui/`
- Backend: Python Flask in `python/`
- Full design spec: `AgentZero_KnowledgeTransfer/UI_COMPLETE_REDESIGN_SPEC.md`

## Code Style

- ES6+ JavaScript modules
- Follow existing component patterns in `webui/components/`
- Use CSS variables for theming
- Maintain accessibility (ARIA labels, keyboard navigation)

