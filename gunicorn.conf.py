import os
import multiprocessing

# CRITICAL: Must bind to 0.0.0.0, NOT 127.0.0.1
bind = f"0.0.0.0:{os.environ.get('PORT', '8080')}"

workers = int(os.environ.get("WEB_CONCURRENCY", multiprocessing.cpu_count() * 2 + 1))
threads = int(os.environ.get("WEB_THREADS", 4))
worker_class = "gthread"
timeout = 120
accesslog = "-"
errorlog = "-"
loglevel = "info"
graceful_timeout = 30
preload_app = True