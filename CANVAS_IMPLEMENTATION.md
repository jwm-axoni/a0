# Canvas Tool Implementation - Complete Feature Addition

This document provides a comprehensive overview of the Canvas Tool implementation added to Agent Zero, including all changes, architecture, and functionality details.

## Overview

The Canvas Tool brings interactive visual artifact creation capabilities to Agent Zero, similar to Claude's artifacts functionality. This implementation allows agents to create, display, and manage HTML, CSS, JavaScript, and Markdown content in a dedicated canvas panel within the web interface.

## What is the Canvas Tool?

The Canvas Tool enables Agent Zero to:
- Create interactive web content (HTML/CSS/JavaScript)
- Display visual artifacts alongside chat conversations
- Provide real-time content updates and streaming
- Offer fullscreen and side-by-side viewing modes
- Export and share created artifacts
- Persist artifacts for future access

## Complete File Structure Changes

### New Files Added

```
docs/
├── canvas.md                                    # Comprehensive Canvas Tool documentation

prompts/default/
├── agent.system.tool.canvas.md                # Canvas tool prompt instructions for agents

python/api/
├── canvas_serve.py                             # Secure Canvas artifact serving API

python/tools/
├── canvas_tool.py                              # Core Canvas Tool implementation

webui/js/
├── canvas.js                                   # Client-side Canvas Manager
```

### Modified Files

```
docs/
├── installation.md                             # Updated with Canvas setup instructions

example.env                                     # Added Canvas-related environment variables

knowledge/default/main/about/
├── installation.md                             # Updated knowledge base with Canvas info

prompts/default/
├── agent.system.tools.md                      # Added Canvas tool to available tools list

python/helpers/
├── whisper.py                                  # Enhanced for Canvas audio integration

run_ui.py                                       # Added Canvas serve endpoint registration

webui/
├── index.html                                  # Added Canvas UI components
├── index.js                                    # Integrated Canvas Manager
├── index.css                                   # Added Canvas styling

webui/css/
├── settings.css                                # Added Canvas settings styles

webui/js/
├── messages.js                                 # Added Canvas artifact message integration
```

## Detailed Implementation Breakdown

### 1. Core Canvas Tool (`python/tools/canvas_tool.py`)

**Purpose**: Main server-side Canvas functionality
**Key Features**:
- Artifact creation and management
- File system operations for Canvas storage
- Content type validation (HTML, CSS, JavaScript, Markdown)
- Unique Canvas ID generation
- Metadata management

**Key Methods**:
```python
async def execute(**kwargs):
    # Main entry point supporting actions: create, update, show, list
    
def create_canvas(content, type, title, description):
    # Creates new Canvas artifacts with validation
    
def update_canvas(canvas_id, content):
    # Updates existing Canvas content
    
def show_canvas(canvas_id):
    # Displays existing Canvas artifacts
    
def list_canvases():
    # Lists all available Canvas artifacts
```

**File Storage Architecture**:
```
work_dir/
  canvas/
    {canvas_id}/
      content.html          # Main artifact content
      metadata.json         # Canvas metadata (title, type, description)
```

### 2. Canvas Serve API (`python/api/canvas_serve.py`)

**Purpose**: Secure serving of Canvas artifacts
**Key Features**:
- Authenticated endpoint access
- Path traversal protection
- MIME type detection
- CORS handling for iframe embedding

**Endpoint Structure**:
```
GET /canvas_serve/{canvas_id}/{filename}
```

**Security Features**:
- Validates Canvas ID format
- Prevents directory traversal attacks
- Serves only from designated Canvas directories
- Proper Content-Type headers

### 3. Client-Side Canvas Manager (`webui/js/canvas.js`)

**Purpose**: Frontend Canvas functionality and UI management
**Key Features**:
- Canvas panel show/hide management
- Fullscreen mode handling
- Iframe content loading
- UI element visibility control
- Keyboard shortcut handling
- Tab switching (Preview/Code views)

**Key Methods**:
```javascript
class CanvasManager {
    show()                              // Display Canvas panel
    hide()                              // Hide Canvas panel
    toggle()                            // Toggle visibility
    toggleFullscreen()                  // Fullscreen mode
    createArtifact(content, type, title) // Create new artifact
    updateArtifact(content, type)       // Update current artifact
    displayFromUrl(url, title)          // Load from URL
}
```

**UI Features**:
- Responsive design adaptation
- Keyboard shortcuts (Ctrl/Cmd+K, Escape, F11)
- Dynamic UI element hiding in fullscreen
- Smooth transitions and animations

### 4. Web UI Integration

#### HTML Structure (`webui/index.html`)
Added Canvas panel structure:
```html
<div id="canvas-panel" class="canvas-panel">
  <div class="canvas-header">
    <div class="canvas-tabs">
      <button class="canvas-tab active" data-tab="preview">Preview</button>
      <button class="canvas-tab" data-tab="code">Code</button>
    </div>
    <div class="canvas-controls">
      <button class="canvas-btn" id="canvas-copy">Copy</button>
      <button class="canvas-btn" id="canvas-export">Export</button>
      <button class="canvas-btn" id="canvas-refresh">Refresh</button>
      <button class="canvas-btn" id="canvas-fullscreen">⛶</button>
      <button class="canvas-btn" id="canvas-close">✕</button>
    </div>
  </div>
  <div class="canvas-content">
    <div class="canvas-tab-content active" id="canvas-preview">
      <iframe id="canvas-iframe"></iframe>
    </div>
    <div class="canvas-tab-content" id="canvas-code">
      <pre id="canvas-code-content"></pre>
    </div>
  </div>
</div>
```

#### CSS Styling (`webui/index.css`)
Comprehensive Canvas styling including:
- Panel positioning and sizing
- Responsive breakpoints
- Fullscreen mode styles
- Tab interface styling
- Button and control styling
- Animation transitions

#### JavaScript Integration (`webui/index.js`)
- Canvas Manager initialization
- Event handler registration
- Keyboard shortcut setup
- Message integration

### 5. Message Integration (`webui/js/messages.js`)

**Canvas Artifact Bubbles**:
Interactive message cards that appear in chat when Canvas artifacts are created:

```javascript
function createCanvasArtifactBubble(canvasId, title, contentType) {
    // Creates clickable artifact cards in chat
    // Shows artifact icon, title, content type badge
    // Includes "Open" and "Copy" action buttons
}
```

**Features**:
- Visual artifact representation in chat
- One-click artifact opening
- Content type badges (HTML, CSS, JS, Markdown)
- Copy functionality
- Improved contrast and accessibility

### 6. Agent Prompt Integration

#### Canvas Tool Prompt (`prompts/default/agent.system.tool.canvas.md`)
Detailed instructions for agents on Canvas usage:

```markdown
# Canvas Tool

Use this tool to create, display, and manage interactive visual artifacts.

## When to Use Canvas
- Creating HTML pages or web applications
- Demonstrating CSS styling and layouts  
- Building interactive JavaScript applications
- Displaying formatted Markdown content
- Showing visual examples or prototypes

## Usage Examples
[Detailed examples and best practices for agents]
```

#### Tool Registration (`prompts/default/agent.system.tools.md`)
Added Canvas tool to the available tools list with description and usage guidance.

### 7. Configuration and Environment

#### Environment Variables (`example.env`)
```env
# Canvas Tool Configuration
WEB_UI_PORT=8080                    # Avoids Apple AirPlay port conflicts
CANVAS_MAX_FILE_SIZE=10MB           # Maximum artifact file size
CANVAS_ALLOWED_TYPES=html,css,js,md # Allowed content types
```

#### Server Configuration (`run_ui.py`)
Registered Canvas serve endpoint:
```python
# Canvas serve endpoint
app.add_url_rule('/canvas_serve/<canvas_id>/<filename>', 
                 'canvas_serve', 
                 canvas_serve, 
                 methods=['GET'])
```

### 8. Documentation Updates

#### Installation Guide (`docs/installation.md`)
- Added Canvas Tool setup instructions
- Port configuration guidance
- Troubleshooting section

#### Knowledge Base (`knowledge/default/main/about/installation.md`)
- Updated agent knowledge about Canvas capabilities
- Installation and configuration details

## Technical Architecture

### Data Flow
1. **Agent Request**: Agent calls Canvas tool with content and parameters
2. **Artifact Creation**: Canvas tool validates content and creates file structure
3. **Storage**: Artifact saved to `work_dir/canvas/{canvas_id}/`
4. **Notification**: Frontend notified of new artifact via WebSocket
5. **Display**: Canvas Manager loads artifact in iframe via secure endpoint
6. **Interaction**: User can view, copy, export, or fullscreen the artifact

### Security Model
- **Sandboxed Execution**: All Canvas content runs in isolated iframes
- **Authenticated Serving**: Canvas serve endpoint requires authentication
- **Path Validation**: Prevents directory traversal attacks
- **Content Validation**: Validates file types and content structure
- **CORS Handling**: Proper cross-origin resource sharing setup

### Performance Considerations
- **Lazy Loading**: Canvas content loaded only when displayed
- **Efficient Caching**: Browser caching for static Canvas resources
- **Optimized Serving**: Direct file serving without processing overhead
- **Memory Management**: Proper cleanup of Canvas resources

## Usage Examples

### 1. Creating an HTML Page
```python
await canvas_tool.execute(
    action="create",
    content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>My App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .header { color: #333; border-bottom: 2px solid #007bff; }
        </style>
    </head>
    <body>
        <h1 class="header">Welcome to My App</h1>
        <p>This is a Canvas artifact!</p>
        <button onclick="alert('Hello!')">Click Me</button>
    </body>
    </html>
    """,
    type="html",
    title="My First App",
    description="A simple HTML application"
)
```

### 2. Interactive JavaScript Application
```python
await canvas_tool.execute(
    action="create",
    content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Calculator</title>
        <style>
            .calculator { max-width: 300px; margin: 20px auto; }
            .display { width: 100%; height: 60px; font-size: 24px; text-align: right; }
            .buttons { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
            button { height: 60px; font-size: 18px; }
        </style>
    </head>
    <body>
        <div class="calculator">
            <input type="text" class="display" id="display" readonly>
            <div class="buttons">
                <button onclick="clearDisplay()">C</button>
                <button onclick="appendToDisplay('/')">/</button>
                <button onclick="appendToDisplay('*')">*</button>
                <button onclick="deleteLast()">←</button>
                <!-- More buttons... -->
            </div>
        </div>
        <script>
            function clearDisplay() { document.getElementById('display').value = ''; }
            function appendToDisplay(value) { document.getElementById('display').value += value; }
            function calculate() { /* calculation logic */ }
        </script>
    </body>
    </html>
    """,
    type="html",
    title="Calculator App",
    description="Interactive calculator with basic operations"
)
```

### 3. CSS Demonstration
```python
await canvas_tool.execute(
    action="create",
    content="""
    <!DOCTYPE html>
    <html>
    <head>
        <title>CSS Grid Layout</title>
        <style>
            .grid-container {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                padding: 20px;
            }
            .grid-item {
                background: linear-gradient(45deg, #007bff, #0056b3);
                color: white;
                padding: 20px;
                border-radius: 8px;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <h1>Responsive Grid Layout</h1>
        <div class="grid-container">
            <div class="grid-item">Item 1</div>
            <div class="grid-item">Item 2</div>
            <div class="grid-item">Item 3</div>
            <div class="grid-item">Item 4</div>
        </div>
    </body>
    </html>
    """,
    type="html",
    title="CSS Grid Demo",
    description="Responsive grid layout demonstration"
)
```

## User Interface Features

### Canvas Panel Modes
1. **Side-by-side View**: Canvas appears alongside chat (desktop)
2. **Fullscreen Mode**: Canvas takes over entire screen
3. **Mobile View**: Optimized fullscreen layout for mobile devices

### Interactive Controls
- **Preview Tab**: Shows rendered content in iframe
- **Code Tab**: Displays source code with syntax highlighting
- **Copy Button**: Copies source code to clipboard
- **Export Button**: Downloads artifact as file
- **Refresh Button**: Reloads canvas content
- **Fullscreen Button**: Toggles fullscreen mode
- **Close Button**: Hides canvas panel

### Keyboard Shortcuts
- `Ctrl/Cmd + K`: Toggle canvas visibility
- `Escape`: Close canvas (when visible)
- `F11`: Toggle fullscreen mode (when canvas is visible)

## Integration Benefits

### For Users
- **Visual Learning**: See code results immediately
- **Interactive Examples**: Engage with created content
- **Easy Sharing**: Export and share artifacts
- **Mobile Friendly**: Responsive design for all devices

### For Agents
- **Rich Output**: Create engaging visual content
- **Educational Tools**: Build interactive tutorials
- **Prototyping**: Quickly create and iterate on designs
- **Documentation**: Visual examples alongside explanations

### For Developers
- **Extensible Architecture**: Easy to add new content types
- **Secure Implementation**: Sandboxed execution environment
- **Performance Optimized**: Efficient resource usage
- **Well Documented**: Comprehensive API and usage docs

## Troubleshooting and Common Issues

### Port Conflicts
**Issue**: Canvas not loading due to port conflicts (Apple AirPlay uses 5000)
**Solution**: Set `WEB_UI_PORT=8080` in environment variables

### Canvas Not Displaying
**Issue**: Canvas panel not showing or content not loading
**Solutions**:
- Check browser console for JavaScript errors
- Verify Canvas files exist in `work_dir/canvas/`
- Ensure server is running and endpoints are accessible
- Check for CORS issues in browser developer tools

### Fullscreen Issues
**Issue**: UI elements overlapping in fullscreen mode
**Solution**: Canvas automatically hides conflicting elements, but custom CSS may need adjustment

### Performance Issues
**Issue**: Slow Canvas loading or UI responsiveness
**Solutions**:
- Optimize Canvas content (minimize large assets)
- Check for memory leaks in JavaScript
- Monitor network requests in browser dev tools

## Future Enhancements

### Planned Features
- **Version Control**: Track Canvas artifact history
- **Collaboration**: Multi-user Canvas editing
- **Templates**: Pre-built Canvas templates
- **Asset Management**: Built-in image and resource handling
- **Export Formats**: PDF, PNG, and other export options

### Extension Points
- **Custom Content Types**: Add support for SVG, WebGL, etc.
- **Plugin System**: Allow third-party Canvas extensions
- **API Expansion**: Additional Canvas management endpoints
- **Integration APIs**: Connect with external design tools

## Conclusion

The Canvas Tool implementation represents a significant enhancement to Agent Zero's capabilities, providing a comprehensive visual artifact creation and management system. The implementation includes:

- **Complete Backend Infrastructure**: Secure storage, serving, and management
- **Rich Frontend Experience**: Interactive UI with multiple viewing modes
- **Seamless Integration**: Natural chat interface integration
- **Extensible Architecture**: Built for future enhancements
- **Security First**: Sandboxed execution and authenticated access
- **Performance Optimized**: Efficient resource usage and caching

This implementation enables Agent Zero to create engaging, interactive content that enhances the user experience and provides powerful tools for education, prototyping, and demonstration purposes.

## Related Files Reference

For complete implementation details, refer to:
- `docs/canvas.md` - Comprehensive user documentation
- `python/tools/canvas_tool.py` - Core tool implementation
- `python/api/canvas_serve.py` - Serving API
- `webui/js/canvas.js` - Client-side manager
- `prompts/default/agent.system.tool.canvas.md` - Agent instructions

---

*This implementation was designed to integrate seamlessly with existing Agent Zero architecture while providing a foundation for future visual and interactive capabilities.*
