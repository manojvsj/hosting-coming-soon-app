"""WSGI entry point for Gunicorn. Avoids factory-pattern issues."""
from app import create_app

application = create_app()