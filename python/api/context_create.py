from python.helpers.api import ApiHandler, Input, Output, Request, Response
from agent import AgentContext
from initialize import initialize_agent
from python.helpers import persist_chat


class ContextCreate(ApiHandler):
    async def process(self, input: Input, request: Request) -> Output:
        ctxid = input.get("context", "")
        context_type = input.get("type", "user")  # user, task, mcp
        
        if not ctxid:
            return {
                "error": "Context ID is required",
                "success": False
            }
        
        # Check if context already exists
        existing = AgentContext.get(ctxid)
        if existing:
            # Context already exists, that's fine
            return {
                "message": "Context already exists",
                "context": ctxid,
                "success": True
            }
        
        # Create new context with the specified ID
        try:
            from agent import AgentContextType
            
            # Map string type to enum
            type_mapping = {
                "user": AgentContextType.USER,
                "task": AgentContextType.TASK, 
                "mcp": AgentContextType.MCP
            }
            
            context_enum = type_mapping.get(context_type, AgentContextType.USER)
            
            context = AgentContext(
                config=initialize_agent(),
                id=ctxid,
                type=context_enum
            )
            
            # Save the context to persistent storage
            persist_chat.save_tmp_chat(context)
            
            return {
                "message": "Context created successfully",
                "context": ctxid,
                "success": True
            }
            
        except Exception as e:
            return {
                "error": f"Failed to create context: {str(e)}",
                "success": False
            }