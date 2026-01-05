# Agent Zero UI Styling Upgrade Plan

## Approach: CSS-Only Changes (No Backend Modifications)

Based on the reference mockups, this plan upgrades the visual appearance while keeping all existing functionality intact.

---

## Phase 1: Design System Foundation

### 1.1 Color Palette Update (index.css)

**Current → New**

| Element | Current Dark | New Dark | Current Light | New Light |
|---------|--------------|----------|---------------|-----------|
| Background | #131313 | #0a0a0a | #dbdbdb | #ffffff |
| Panel | #1a1a1a | #141414 | #f0f0f0 | #f8f8f8 |
| Accent | #cf6679 | #10b981 (teal) | #b00020 | #10b981 |
| Highlight | #2b5ab9 | #3b82f6 | #2563eb | #3b82f6 |
| Border | #444444a8 | #262626 | #e0e0e0c7 | #e5e5e5 |

### 1.2 Typography Update

**Current:** Rubik + Roboto Mono
**New:** Keep Rubik (it's good), but consider:
- Increase heading weights
- Better line-height for readability
- Larger base font size (16px → 15px body)

---

## Phase 2: Component Styling

### 2.1 Settings Modal
- Add tabbed navigation styling (already exists, refine colors)
- Add accordion sections with colored left border accents
- Add colored icons for each section (orange, teal, blue, magenta)
- Improve form input styling (subtle backgrounds, better focus states)
- Add subtle shadows to modal

### 2.2 Sidebar
- Refine "New Conversation" button (teal gradient)
- Better chat list item styling (hover states, active states)
- Add subtle dividers between sections
- Improve search input styling

### 2.3 Chat Messages
- Better user message bubble (teal/blue background)
- Improved AI message styling (subtle background, avatar)
- Better code block styling (darker background, syntax colors)
- Add timestamp styling
- Better action button positioning

### 2.4 Input Bar
- Refined input area styling
- Better button styling for actions
- Subtle background and border

---

## Phase 3: Micro-Interactions

### 3.1 Animations
- Smooth accordion open/close
- Button hover effects
- Message fade-in
- Modal transitions

### 3.2 Focus States
- Better focus rings
- Smooth transitions

---

## Files to Modify

| File | Changes |
|------|---------|
| `webui/index.css` | Color variables, base typography |
| `webui/css/settings.css` | Settings modal, accordion, forms |
| `webui/css/messages.css` | Message bubbles, code blocks |
| `webui/css/buttons.css` | Button styles |
| `webui/css/modals.css` | Modal styling |
| `webui/components/sidebar/*.html` | Minor class additions if needed |

---

## Files NOT to Modify

- Any Python files
- Any JavaScript logic (only CSS classes)
- Backend API endpoints
- Data structures

---

## Implementation Order

1. **Color variables** (index.css :root)
2. **Settings modal** (most visible change from mockups)
3. **Sidebar** (second most visible)
4. **Chat messages** (incremental improvement)
5. **Input bar** (polish)
6. **Animations** (final polish)

---

## Success Criteria

- [ ] Dark mode matches mockup aesthetic
- [ ] Light mode matches mockup aesthetic
- [ ] All existing features still work
- [ ] No JavaScript errors
- [ ] No backend changes required
- [ ] Responsive on different screen sizes

