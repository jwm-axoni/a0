# Agent Zero Project Instructions

## Frontend Design Guidelines

When building or modifying UI components, follow these principles:

### Design Thinking
Before coding, commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist, retro-futuristic, luxury/refined, playful, editorial, brutalist, art deco, soft/pastel, industrial, etc.
- **Differentiation**: What makes this UNFORGETTABLE?

### Aesthetics Guidelines
- **Typography**: Choose distinctive fonts. AVOID generic fonts (Inter, Roboto, Arial, system fonts)
- **Color & Theme**: Dominant colors with sharp accents. Use CSS variables. AVOID cliched purple gradients on white.
- **Motion**: High-impact animations at key moments (page load, staggered reveals). Use CSS transitions or Motion library.
- **Spatial Composition**: Unexpected layouts, asymmetry, overlap, grid-breaking elements, generous negative space.
- **Backgrounds**: Create atmosphere with gradient meshes, noise textures, geometric patterns, layered transparencies.

### NEVER Use
- Generic AI aesthetics
- Overused fonts (Inter, Roboto, Arial)
- Predictable layouts and cookie-cutter patterns
- Cliched color schemes

## Project Context

- Agent Zero: AI agent framework
- Frontend: Vanilla JS + Alpine.js in `webui/`
- Backend: Python Flask in `python/`
- See `AgentZero_KnowledgeTransfer/` for architecture docs

## Code Style

- ES6+ JavaScript modules
- Follow existing component patterns in `webui/components/`
- Use CSS variables for theming
- Maintain accessibility (ARIA labels, keyboard navigation)

