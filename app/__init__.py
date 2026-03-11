from flask import Flask


def create_app():
    """Application factory pattern for creating the Flask app."""
    app = Flask(
        __name__,
        static_folder="static",
        template_folder="templates",
    )

    # Register routes
    from app.main import main_bp
    app.register_blueprint(main_bp)

    return app