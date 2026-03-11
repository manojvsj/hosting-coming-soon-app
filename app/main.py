from flask import Blueprint, render_template

main_bp = Blueprint("main", __name__)


@main_bp.route("/")
def index():
    """Serve the Coming Soon landing page."""
    return render_template("index.html")


@main_bp.route("/health")
def health():
    """Health check endpoint for Cloud Run."""
    return {"status": "healthy"}, 200


@main_bp.errorhandler(404)
def page_not_found(e):
    """Catch-all: redirect any unknown route to the landing page."""
    return render_template("index.html"), 404