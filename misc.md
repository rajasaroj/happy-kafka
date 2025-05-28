```python
✅ Option 1: Use ContextVars (preferred for async/sync)
ContextVars are thread-safe and async-safe (introduced in Python 3.7). You can store and propagate context like trace_id and span_id across calls without changing method signatures.

🔧 Step-by-step implementation:
1. Setup context variables
------------------------------------------------------------------------------------
from contextvars import ContextVar
import uuid

trace_id_var = ContextVar("trace_id", default=None)
span_id_var = ContextVar("span_id", default=None)
------------------------------------------------------------------------------------
2. Utility functions
def generate_id():
    return str(uuid.uuid4())

def set_trace_id():
    trace_id = generate_id()
    trace_id_var.set(trace_id)
    return trace_id

def set_span_id():
    span_id = generate_id()
    span_id_var.set(span_id)
    return span_id

def get_trace_context():
    return {
        "trace_id": trace_id_var.get(),
        "span_id": span_id_var.get()
    }
------------------------------------------------------------------------------------
3. Logging decorator
import logging
from functools import wraps

logger = logging.getLogger(__name__)

def traced(span=False):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if span:
                set_span_id()
            context = get_trace_context()
            logger.info(f"[TRACE] {func.__name__} called", extra=context)
            return func(*args, **kwargs)
        return wrapper
    return decorator
------------------------------------------------------------------------------------
🧠 Example: Controller and Service classes
class Controller:
    @traced()  # just log, don’t create new span
    def api1(self):
        set_trace_id()  # initialize trace_id here
        print("Controller.api1")
        Service().api1_service()

class Service:
    @traced(span=True)  # this creates a new span ID
    def api1_service(self):
        print("Service.api1_service")
        Helper().do_something()

class Helper:
    @traced(span=True)
    def do_something(self):
        print("Helper.do_something")
------------------------------------------------------------------------------------        
🧪 Output log (example):
[TRACE] api1 called {'trace_id': 'abc123', 'span_id': None}
[TRACE] api1_service called {'trace_id': 'abc123', 'span_id': 'def456'}
[TRACE] do_something called {'trace_id': 'abc123', 'span_id': 'ghi789'}
------------------------------------------------------------------------------------      
⚠️ Why not use globals or thread-local?
Globals: Unsafe across threads and not async-friendly.
Thread-local (threading.local): Works for threads but not async code.
ContextVars: Best of both worlds — works with threads and asyncio.
------------------------------------------------------------------------------------      
🧰 Optional: Add auto trace_id creation if not already set
To make it foolproof, update the decorator:
def traced(span=False):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if not trace_id_var.get():
                set_trace_id()
            if span:
                set_span_id()
            context = get_trace_context()
            logger.info(f"[TRACE] {func.__name__} called", extra=context)
            return func(*args, **kwargs)
        return wrapper
    return decorator
------------------------------------------------------------------------------------      
🧩 Integration ideas
* Add trace_id/span_id to log formatter (logging.Formatter) or structured logging tools like structlog, loguru, or python-json-logger.
* Propagate headers in HTTP requests using something like X-Trace-Id.
------------------------------------------------------------------------------------      
✅ Summary
* Use ContextVar to avoid changing method signatures.
* Create trace_id in the controller.
* Create new span_id in each layer below.
* Use a decorator to inject logging logic cleanly.
* Extend to HTTP calls, MQ, etc., for full traceability.


