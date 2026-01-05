# Frontend Design Skill - Agent Zero UI

## 🎯 Design Direction: Vercel/v0.dev Inspired

**CRITICAL**: See `AgentZero_KnowledgeTransfer/UI_COMPLETE_REDESIGN_SPEC.md` for full specifications.

### Design Vision
- **Inspiration**: v0.dev / Vercel AI Chat Interface
- **Aesthetic**: Clean, minimal, professional, modern SaaS
- **Goal**: Premium product feel, not a developer tool

---

## Core Principles

1. **Simplicity over complexity** - Remove visual noise
2. **Light theme primary** - White backgrounds, subtle grays
3. **Centered content** - Max-width 800px for readability
4. **Floating elements** - Input bar detached, shadowed
5. **Generous whitespace** - Let content breathe

---

## Typography

**Font**: Inter (via Google Fonts)
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
```

**Weights**: 400 (normal), 500 (medium), 600 (semibold), 700 (bold)

---

## Color Palette

### Light Theme (Primary)
- **Backgrounds**: `#ffffff`, `#f9fafb`, `#f3f4f6`
- **Text**: `#111827`, `#6b7280`, `#9ca3af`
- **Borders**: `#e5e7eb`
- **Accents**: `#a855f7` (purple), `#3b82f6` (blue)
- **Gradients**: Purple (`#a855f7`) to Indigo (`#6366f1`)

---

## Critical Layout Rules

### Chat Input (MOST IMPORTANT!)
```css
.chat-input-container {
  max-width: 800px;
  margin: 0 auto;           /* CENTERED */
}

.chat-input-wrapper {
  border-radius: 24px;      /* Very rounded */
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  background: white;
  border: 1px solid #e5e7eb;
}
```

The input bar MUST be:
- ✅ CENTERED in main content area
- ✅ NOT attached to sidebar
- ✅ Floating with rounded corners (24px)
- ✅ Subtle shadow for depth

---

## Reference Images

Located in `UI_enhancement_project/`:
- `vercel.png` through `verrcel 8.png`

---

## NEVER Use

❌ Dark theme as primary
❌ Emerald/green color schemes
❌ Input attached to sidebar
❌ Heavy borders instead of shadows
❌ Cramped spacing

---

## Quality Checklist

- [ ] Chat input CENTERED and FLOATING?
- [ ] Light theme clean and professional?
- [ ] Inter font loading correctly?
- [ ] Accents purple/blue (not green)?
- [ ] Generous whitespace?
- [ ] Matches Vercel reference at 80%+?

